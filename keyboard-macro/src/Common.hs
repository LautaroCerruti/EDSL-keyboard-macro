module Common where

    -- Comandos de archivos
    data Stmt i = Def Name i
                | Macro Name i
        deriving (Show)

    instance Functor Stmt where
        fmap f (Def s i) = Def s (f i)
        fmap f (Macro s i)  = Macro s (f i)

    -- Tipos de los nombres
    type Name = String

    -- Entornos
    type NameEnv v = [(Name, v)]

    data Tm = 
          Var Name
        | Key Key
        | Usleep Int
        | Sleep Int
        | While Key Tm
        | Repeat Int Tm
        | Line String
        | Seq Tm Tm
        deriving Show

    data Key = NKey Char | Skey SpecialKey
        deriving Show

    data SpecialKey = LARROW | UARROW | DARROW | RARROW
        | SHIFT | LSHIFT | RSHIFT | TAB | RETURN 
        | ENTER | ESC | SPACE | CONTROL | LCONTROL
        | RCONTROL | ALT | LALT | RALT | SUPR 
        | BACKSPACE | SUPER | LSUPER | RSUPER 
        | MENU | Fkey Int
        deriving Show
