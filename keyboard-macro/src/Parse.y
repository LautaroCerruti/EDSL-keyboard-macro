{
module Parse where
import Common 
import Data.Maybe
import Data.Char
}

%monad { P } { thenP } { returnP }
%name parseStmt Def
%name parseStmts Defs

%tokentype { Token }
%lexer {lexer} {TEOF}

%token
    '='     { TEquals }
    ';'     { TSemicolon }
    '('     { TOpen }
    ')'     { TClose }
    DEF     { TDef }
    MACRO   { TMacro }
    REPEAT  { TRepeat }
    WHILE   { TWhile }
    SLEEP   { TSleep }
    USLEEP  { TUSleep }
    CHAR    { TChar $$ }
    INT     { TInt $$ }
    STRING  { TString $$ }
    LINE  { TLine $$ }

%left '=' 
%right ';' 

%%

Def     :  DEF VAR '=' Macro           { Def $2 $4 }
        |  MACRO VAR '=' Macro	       { Macro $2 $4 }

Macro   :: { Tm }
        : Cont ';' Macro               { Seq $1 $3}
        | Cont                         { $1 }

Cont    :: { Tm }
        : '(' Macro ')'                 { $2 }
        | LINE                          { Line $1}
        | REPEAT INT '(' Macro ')'      { Repeat $2 $4}
        | WHILE Key '(' Macro ')'       { While $2 $4 }
        | SLEEP INT                     { Sleep $2 }
        | USLEEP INT                    { Usleep $2 }
        | VAR                           { Var $1 }
        | Key                           { Key $1 }

Key     :: { Key }
        : CHAR                           { NKey $1 }

Defs    : Def Defs                   { $1 : $2 }
        |                               { [] }

{

data ParseResult a = Ok a | Failed String
                     deriving Show                     
type LineNumber = Int
type P a = String -> LineNumber -> ParseResult a

getLineNo :: P LineNumber
getLineNo = \s l -> Ok l

thenP :: P a -> (a -> P b) -> P b
m `thenP` k = \s l-> case m s l of
                         Ok a     -> k a s l
                         Failed e -> Failed e
                         
returnP :: a -> P a
returnP a = \s l-> Ok a

failP :: String -> P a
failP err = \s l -> Failed err

catchP :: P a -> (String -> P a) -> P a
catchP m k = \s l -> case m s l of
                        Ok a     -> Ok a
                        Failed e -> k e s l

happyError :: P a
happyError = \ s i -> Failed $ "Línea "++(show (i::LineNumber))++": Error de parseo\n"++(s)

data Token = TString String
               | TInt Int
               | TChar Char
               | TLine String
               | TDef
               | TOpen
               | TClose 
               | TSemicolon
               | TEquals
               | TMacro
               | TRepeat
               | TWhile
               | TSleep
               | TUSleep
               | TEOF
               deriving Show

----------------------------------
lexer cont s = case s of
                    [] -> cont TEOF []
                    ('\n':s)  ->  \line -> lexer cont s (line + 1)
                    (c:cs)
                          | isSpace c -> lexer cont cs
                          | isAlpha c -> lexVar (c:cs)
                          | isDigit c = lexNum (c:cs)
                    ('-':('-':cs)) -> lexer cont $ dropWhile ((/=) '\n') cs
                    ('{':('-':cs)) -> consumirBK 0 0 cont cs	
                    ('-':('}':cs)) -> \ line -> Failed $ "Línea "++(show line)++": Comentario no abierto"
                    ('(':cs) -> cont TOpen cs
                    (')':cs) -> cont TClose cs
                    ('=':cs) -> cont TEquals cs
                    (';':cs) -> cont TSemicolon cs
                    unknown -> \line -> Failed $ 
                     "Línea "++(show line)++": No se puede reconocer "++(show $ take 10 unknown)++ "..."
                    where lexVar cs = case span isAlpha cs of
                              ("def",rest)  -> cont TDef rest
                              ("macro",rest)  -> cont TMacro rest
                              ("line",([' ', '\"']:rest))  -> if elem '\"' rest then cont (TLine (takeTillChar '\"' rest)) (dropTillChar '\"' rest) else \ line -> Failed $ "Línea "++(show line)++": Unmatched \""
                              ("repeat",rest)  -> cont TRepeat rest
                              ("while",rest)  -> cont TWhile rest
                              ("sleep",rest)  -> cont TSleep rest
                              ("usleep",rest) -> cont TUSleep rest
                              (var,rest)      -> if (length(var) > 1) then cont (TString var) rest else cont (TChar var) rest
                          lexNum cs = let (num,rest) = span isDigit cs in cont (TInt (read num)) rest
                          consumirBK anidado cl cont s = case s of
                              ('-':('-':cs)) -> consumirBK anidado cl cont $ dropWhile ((/=) '\n') cs
                              ('{':('-':cs)) -> consumirBK (anidado+1) cl cont cs	
                              ('-':('}':cs)) -> case anidado of
                                                  0 -> \line -> lexer cont cs (line+cl)
                                                  _ -> consumirBK (anidado-1) cl cont cs
                              ('\n':cs) -> consumirBK anidado (cl+1) cont cs
                              (_:cs) -> consumirBK anidado cl cont cs     
                          takeTillChar c (f:rest) = if (c == f) then [] else f : (takeTillChar c rest)
                          dropTillChar c (f:rest) = if (c == f) then rest else dropTillChar c rest

stmts_parse s = parseStmts s 1
stmt_parse s = parseStmt s 1
}