module Main where

import           Parse                        
import           System.Console.GetOpt
import qualified System.Environment            as Env
import           PrettyPrinter

import System.Exit ( exitWith, ExitCode(ExitFailure) )
import System.IO ( hPrint, stderr )
import Common

import           MonadKM

---------------------------------------------------------

data Options = Options
  { optPrint    :: Bool
  , optAST      :: Bool
  , optLinux    :: Bool
  , optWindows  :: Bool
  , optHelp     :: Bool
  }
  deriving Show

defaultOptions :: Options
defaultOptions =
  Options { optPrint = False, optAST = False, optLinux = False, optWindows = False, optHelp = False }

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
           (NoArg (\opts -> opts { optAST = True }))
           "Compilar para Linux"
  , Option ['w']
           ["windows"]
           (NoArg (\opts -> opts { optAST = True }))
           "Compilar para Windows"
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

main :: IO ()
main = do
  s : opts   <- Env.getArgs
  (opts', _) <- finalOptions opts
  runOptions s opts'

runOptions :: FilePath -> Options -> IO ()
runOptions fp opts
  | optHelp opts = putStrLn (usageInfo "Uso: " options)
  | otherwise = do
    s <- readFile fp
    p <- parseIO fp stmts_parse s
    case p of
      Nothing -> return ()
      Just asts   -> if
        | optAST opts       -> print asts
        | optPrint opts     -> mapM_ putStrLn (map renderStmt asts)
        | optLinux opts     -> do runOrFail (compileMacro asts 'l')
                                  return ()
        -- | optWindows opts   -> Compile Windows
        -- | otherwise         -> Compile Linux
        | otherwise         -> print asts

runOrFail :: KM a -> IO a
runOrFail m = do
  r <- runKM m
  case r of
    Left err -> do
      liftIO $ hPrint stderr err
      exitWith (ExitFailure 1)
    Right v -> return v

parseIO :: String -> (String -> ParseResult a) -> String -> IO (Maybe a)
parseIO f p x = case p x of
  Failed e -> do
    putStrLn (f ++ ": " ++ e)
    return Nothing
  Ok r -> return (Just r)

compileMacro :: MonadKM m => [Stmt Tm] -> Char -> m ()
compileMacro xs m = return ()