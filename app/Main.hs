module Main where

import           Parse                        
import           System.Console.GetOpt
import qualified System.Environment            as Env
import           PrettyPrinter
import System.Environment (lookupEnv)

import System.Exit ( exitWith )
import System.IO ( hPrint, stderr, hGetContents)
import System.FilePath (dropExtension)
import System.Directory ( getCurrentDirectory, removeFile )
import System.Info (os)
import Common
import C ( prog2C, def2CFun )
import System.Process
import System.Exit (ExitCode(..))

import           MonadKM

---------------------------------------------------------

data Options = Options
  { optPrint    :: Bool
  , optAST      :: Bool
  , optLinux    :: Bool
  , optWindows  :: Bool
  , optExe      :: Bool
  , optCCode    :: Bool
  , optRun      :: Bool
  , optHelp     :: Bool
  }
  deriving Show

defaultOptions :: Options
defaultOptions =
  Options { optPrint = False, optAST = False, optLinux = False, optWindows = False, optHelp = False, optCCode = False, optExe = False, optRun = False }

options :: [OptDescr (Options -> Options)]
options =
  [ Option ['p']
           ["print"]
           (NoArg (\opts -> opts { optPrint = True }))
           "Imprimir el programa de entrada."
  , Option ['a']
           ["AST"]
           (NoArg (\opts -> opts { optAST = True }))
           "Mostrar el AST del programa de entrada."
  , Option ['l']
           ["linux"]
           (NoArg (\opts -> opts { optLinux = True }))
           "Compilar para Linux"
  , Option ['w']
           ["windows"]
           (NoArg (\opts -> opts { optWindows = True }))
           "Compilar para Windows"
  , Option ['c']
           ["c-code"]
           (NoArg (\opts -> opts { optCCode = True }))
           "Generar Codigo en C++"
  , Option ['e']
           ["executable"]
           (NoArg (\opts -> opts { optExe = True }))
           "Generar el ejecutable (solo funciona si se esta utilizando el sistema para el que se esta compilando)"
  , Option ['r']
           ["run"]
           (NoArg (\opts -> opts { optRun = True }))
           "Correr el macro (solo funciona si se esta utilizando el sistema para el que se esta corriendo)"
  , Option ['h']
           ["help"]
           (NoArg (\opts -> opts { optHelp = True }))
           "Imprimir guia de uso."
  ]

finalOptions :: [String] -> IO (Options, [String])
finalOptions argv = case getOpt Permute options argv of
  (o, n, []  ) -> return (foldl (flip id) defaultOptions o, n)
  (_, _, errs) -> ioError (userError (concat errs ++ usageInfo header options))
  where header = "Uso:"

isX11 :: IO Bool
isX11 = do
    maybeX11 <- lookupEnv "XDG_SESSION_TYPE"
    case maybeX11 of
        Just "x11"  -> return True
        _ -> return False

isWindows :: Bool
isWindows = os == "mingw32" || os == "mingw64" || os == "cygwin"

main :: IO ()
main = do
  s : opts   <- Env.getArgs
  (opts', _) <- finalOptions opts
  runOptions s opts'
                    
setDefaultOS :: Options -> Options
setDefaultOS opts = if (not (optLinux opts) && not (optWindows opts)) 
                      then (
                        if isWindows 
                          then opts { optWindows = True}
                          else opts { optLinux = True}
                        ) 
                      else opts

setDefaultComOpt :: Options -> Options
setDefaultComOpt opts = if (not (optCCode opts) && not (optExe opts) && not (optRun opts)) 
                          then opts { optExe = True }
                          else opts

runOptions :: FilePath -> Options -> IO ()
runOptions fp opts
  | optHelp opts = putStrLn (usageInfo "Uso: " options)
  | otherwise = do
    x11 <- liftIO isX11
    opts' <- return (setDefaultComOpt (setDefaultOS opts))
    if ((optWindows opts') && ((optExe opts') || (optRun opts')) && (not isWindows)) 
      then putStrLn "Can't compile for windows while running in another SO" >>= (\_ -> exitWith (ExitFailure 1)) 
      else return ()
    if ((optLinux opts') && (optExe opts' || optRun opts') && (not x11)) 
      then putStrLn "Can't compile for linux if X11 is not the window handler or if running in another SO" >>= (\_ -> exitWith (ExitFailure 1)) 
      else return ()
    s <- readFile fp
    p <- parseIO fp prog_parse s
    case p of
      Nothing -> return ()
      Just ast   -> if
        | optAST opts'       -> print ast
        | optPrint opts'     -> putStrLn (renderProg ast)
        | otherwise         -> runOrFail (compileMacro ast opts' fp)

runOrFail :: KM a -> IO ()
runOrFail m = do
  r <- runKM m
  case r of
    Left err -> do
      liftIO $ hPrint stderr err
      exitWith (ExitFailure 1)
    Right _ -> return ()

parseIO :: String -> (String -> ParseResult a) -> String -> IO (Maybe a)
parseIO f p x = case p x of
  Failed e -> do
    putStrLn (f ++ ": " ++ e)
    return Nothing
  Ok r -> return (Just r)

compileMacro :: MonadKM m => Prog -> Options -> FilePath -> m ()
compileMacro (Prog xs p) opts fp = do 
                                  m <- return (if optLinux opts then 'l' else 'w')
                                  mapM_ addDef xs
                                  needed <- getNeededDefs p
                                  let defList = map (def2CFun m) (foldl (\list e -> if defListHas list e then list else e:list) [] needed)
                                  cd <- liftIO getCurrentDirectory
                                  ccode <- return (prog2C cd m p defList)
                                  let cname = (dropExtension fp ++ ".cpp")
                                  liftIO $ writeFile cname ccode
                                  exeName <- if (optExe opts || optRun opts) then liftIO $ c2exe m cname cd else return ""
                                  if (not (optCCode opts)) then liftIO $ removeFile cname else return ()
                                  if (optRun opts) then liftIO $ runMacro exeName else return ()
                                  if (not (optExe opts) && (optRun opts)) then liftIO $ removeFile exeName else return ()
                                  return ()

c2exe :: Char -> FilePath -> FilePath -> IO String
c2exe m fp cd = do
    let exeName = if (m == 'l') then dropExtension fp else dropExtension fp ++ ".exe"
    let params = if (m == 'l') then [fp, "-o", exeName, cd ++ "/src/linux_c/macro_linux.o", "-lX11", "-lXtst", "-lX11-xcb"]
                               else [fp, "-o", exeName, cd ++ "/src/windows_c/macro_windows.o", "-lstdc++"]
    (_, Just _, Just herr, ph) <- createProcess (proc "gcc" params){ std_out = CreatePipe, std_err = CreatePipe }
    exitCode <- waitForProcess ph
    case exitCode of
        ExitSuccess   -> putStrLn "Compilation successful"
        ExitFailure _ -> do
            putStrLn "Compilation failed. Error output:"
            errorOutput <- hGetContents herr
            putStrLn errorOutput
            exitWith (ExitFailure 1)
    return exeName

runMacro :: FilePath -> IO ()
runMacro fp = do
    putStrLn ("Running Macro" ++ fp)
    (_, Just _, Just _, ph) <- createProcess (proc fp []){ std_out = CreatePipe, std_err = CreatePipe }
    _ <- waitForProcess ph
    return ()

getNeededDefs :: MonadKM m => Tm -> m [Def Tm]
getNeededDefs (Var n) = do 
                      def <- lookupDef n
                      case def of
                        Just fdef@(Def _ tm) -> do 
                                      needed <- getNeededDefs tm
                                      return (fdef : needed)
                        Nothing -> failKM ("Undefined def " ++ n)
getNeededDefs (While _ t) = getNeededDefs t
getNeededDefs (Repeat _ t) = getNeededDefs t
getNeededDefs (TimeRepeat _ t) = getNeededDefs t
getNeededDefs (Seq t1 t2) = do d1 <- getNeededDefs t1
                               d2 <- getNeededDefs t2
                               return (d1 ++ d2)
getNeededDefs _ = return []