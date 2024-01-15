{
module Parse where
import Common 
import Data.Maybe
import Data.Char
}

%monad { P } { thenP } { returnP }
%name parseProg Prog

%tokentype { Token }
%lexer {lexer} {TEOF}

%token
    '='         { TEquals }
    ';'         { TSemicolon }
    '+'         { TPLus }
    '('         { TOpen }
    ')'         { TClose }
    DEF         { TDef }
    REPEAT      { TRepeat }
    SLEEP       { TSleep }
    USLEEP      { TUSleep }
    MOUSE       { TMouse }
    CHAR        { TChar $$ }
    INT         { TInt $$ }
    MBUTTON     { TMButton $$ }
    STRING      { TString $$ }
    LINE        { TLine $$ }
    LARROW      { TLARROW }
    UARROW      { TUARROW }
    DARROW      { TDARROW }
    RARROW      { TRARROW }
    SHIFT       { TSHIFT }
    LSHIFT      { TLSHIFT }
    RSHIFT      { TRSHIFT }
    TAB         { TTAB }
    RETURN      { TRETURN }
    ENTER       { TENTER }
    ESC         { TESC }
    SPACE       { TSPACE }
    CONTROL     { TCONTROL }
    LCONTROL    { TLCONTROL }
    RCONTROL    { TRCONTROL }
    ALT         { TALT }
    LALT        { TLALT }
    RALT        { TRALT }
    SUPR        { TSUPR }
    BACKSPACE   { TBACKSPACE }
    SUPER       { TSUPER }
    LSUPER      { TLSUPER }
    RSUPER      { TRSUPER }
    MENU        { TMENU }
    FKEY        { TFKey $$ }

%left '=' 
%left ';'  
%right '+'

%%

Def     :  DEF STRING '=' Macro         { Def $2 $4 }

Macro   :: { Tm }
        : Macro ';' Macro                { Seq $1 $3}
        | LINE                          { Line $1}
        | REPEAT INT Macro              { Repeat $2 $3}
        | Key '+' Macro                 { While $1 $3 }
        | SLEEP INT                     { Sleep $2 }
        | USLEEP INT                    { Usleep $2 }
        | MOUSE INT INT                 { Mouse $2 $3 }
        | STRING                        { Var $1 }
        | Key                           { Key $1 }
        | '(' Macro ')'                 { $2 }

Key     :: { Key }
        : CHAR                          { NKey $1 }
        | INT                           { NKey (head (show $1))}
        | MBUTTON                       { MouseButton $1 }
        | Special                       { SKey $1 }

Special :: { SpecialKey }
        : LARROW                        { LARROW }
        | UARROW                        { UARROW }
        | DARROW                        { DARROW }
        | RARROW                        { RARROW }
        | SHIFT                         { SHIFT }
        | LSHIFT                        { LSHIFT }
        | RSHIFT                        { RSHIFT }
        | TAB                           { TAB }
        | RETURN                        { RETURN }
        | ENTER                         { ENTER }
        | ESC                           { ESC }
        | SPACE                         { SPACE }
        | CONTROL                       { CONTROL }
        | LCONTROL                      { LCONTROL }
        | RCONTROL                      { RCONTROL }
        | ALT                           { ALT }
        | LALT                          { LALT }
        | RALT                          { RALT }
        | SUPR                          { SUPR }
        | BACKSPACE                     { BACKSPACE }
        | SUPER                         { SUPER }
        | LSUPER                        { LSUPER }
        | RSUPER                        { RSUPER }
        | MENU                          { MENU }
        | FKEY                          { Fkey $1 }

Defs    : Def Defs                      { $1 : $2 }
        |                               { [] }

Prog    :: { Prog }
        : Defs Macro                    { Prog $1 $2}
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
               | TFKey Int
               | TMButton Int
               | TDef
               | TMouse
               | TOpen
               | TPLus
               | TClose 
               | TSemicolon
               | TEquals
               | TRepeat
               | TSleep
               | TUSleep
               | TLARROW
               | TUARROW
               | TDARROW
               | TRARROW
               | TSHIFT
               | TLSHIFT
               | TRSHIFT
               | TTAB
               | TRETURN
               | TENTER
               | TESC
               | TSPACE
               | TCONTROL
               | TLCONTROL
               | TRCONTROL
               | TALT
               | TLALT
               | TRALT
               | TSUPR
               | TBACKSPACE
               | TSUPER
               | TLSUPER
               | TRSUPER
               | TMENU
               | TEOF
               deriving Show

----------------------------------
lexer cont s = case s of
                    [] -> cont TEOF []
                    ('\n':s)  ->  \line -> lexer cont s (line + 1)
                    (c:cs)
                          | isSpace c -> lexer cont cs
                          | isAlpha c -> lexVar (c:cs)
                          | isDigit c -> lexNum (c:cs)
                    ('-':('-':cs)) -> lexer cont $ dropWhile ((/=) '\n') cs
                    ('{':('-':cs)) -> consumirBK 0 0 cont cs	
                    ('-':('}':cs)) -> \ line -> Failed $ "Línea "++(show line)++": Comentario no abierto"
                    ('(':cs) -> cont TOpen cs
                    (')':cs) -> cont TClose cs
                    ('=':cs) -> cont TEquals cs
                    ('+':cs) -> cont TPLus cs
                    (';':cs) -> cont TSemicolon cs
                    unknown -> \line -> Failed $ 
                     "Línea "++(show line)++": No se puede reconocer "++(show $ take 10 unknown)++ "..."
                    where lexVar cs = case span isAlpha cs of
                              ("def",rest)  -> cont TDef rest
                              ("line",(' ':('\"':rest)))  -> if elem '\"' rest then cont (TLine (takeTillChar '\"' rest)) (dropTillChar '\"' rest) else \ line -> Failed $ "Línea "++(show line)++": Unmatched \""
                              ("repeat",rest)  -> cont TRepeat rest
                              ("sleep",rest)  -> cont TSleep rest
                              ("usleep",rest) -> cont TUSleep rest
                              ("mouse",rest) -> cont TMouse rest
                              ("LMB", rest) -> cont (TMButton 1) rest 
                              ("MMB", rest) -> cont (TMButton 2) rest 
                              ("RMB", rest) -> cont (TMButton 3) rest 
                              ("LARROW", rest) -> cont TLARROW rest 
                              ("UARROW", rest) -> cont TUARROW rest 
                              ("DARROW", rest) -> cont TDARROW rest 
                              ("RARROW", rest) -> cont TRARROW rest 
                              ("SHIFT", rest) -> cont TSHIFT rest 
                              ("LSHIFT", rest) -> cont TLSHIFT rest 
                              ("RSHIFT", rest) -> cont TRSHIFT rest 
                              ("TAB", rest) -> cont TTAB rest 
                              ("RETURN", rest) -> cont TRETURN rest 
                              ("ENTER", rest) -> cont TENTER rest 
                              ("ESC", rest) -> cont TESC rest 
                              ("SPACE", rest) -> cont TSPACE rest 
                              ("CONTROL", rest) -> cont TCONTROL rest 
                              ("CTRL", rest) -> cont TCONTROL rest 
                              ("LCONTROL", rest) -> cont TLCONTROL rest 
                              ("RCONTROL", rest) -> cont TRCONTROL rest 
                              ("ALT", rest) -> cont TALT rest 
                              ("LALT", rest) -> cont TLALT rest 
                              ("RALT", rest) -> cont TRALT rest 
                              ("SUPR", rest) -> cont TSUPR rest 
                              ("BACKSPACE", rest) -> cont TBACKSPACE rest 
                              ("SUPER", rest) -> cont TSUPER rest 
                              ("LSUPER", rest) -> cont TLSUPER rest 
                              ("RSUPER", rest) -> cont TRSUPER rest 
                              ("MENU", rest) -> cont TMENU rest 
                              ("F",'1':('0':rest)) -> cont (TFKey 10) rest
                              ("F",'1':('1':rest)) -> cont (TFKey 11) rest
                              ("F",'1':('2':rest)) -> cont (TFKey 12) rest
                              ("F",'1':rest) -> cont (TFKey 1) rest
                              ("F",'2':rest) -> cont (TFKey 2) rest
                              ("F",'3':rest) -> cont (TFKey 3) rest
                              ("F",'4':rest) -> cont (TFKey 4) rest
                              ("F",'5':rest) -> cont (TFKey 5) rest
                              ("F",'6':rest) -> cont (TFKey 6) rest
                              ("F",'7':rest) -> cont (TFKey 7) rest
                              ("F",'8':rest) -> cont (TFKey 8) rest
                              ("F",'9':rest) -> cont (TFKey 9) rest
                              (var,rest)      -> if (length(var) > 1) then cont (TString var) rest else cont (TChar (head var)) rest
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

prog_parse s = parseProg s 1
}