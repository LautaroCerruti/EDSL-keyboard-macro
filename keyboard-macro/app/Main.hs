module Main where

import           Parse                        
import           System.Console.GetOpt
import qualified System.Environment            as Env
--import           PPLis

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
      Just ast   -> if
        | optAST opts       -> print ast
        -- | optPrint opts     -> putStrLn (renderComm ast)
        -- | optLinux opts     -> Compile Linux
        -- | optWindows opts   -> Compile Windows
        -- | otherwise         -> Compile Linux
        | otherwise         -> print ast

parseIO :: String -> (String -> ParseResult a) -> String -> IO (Maybe a)
parseIO f p x = case p x of
  Failed e -> do
    putStrLn (f ++ ": " ++ e)
    return Nothing
  Ok r -> return (Just r)