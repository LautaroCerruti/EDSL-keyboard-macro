module Common where

    data Prog = Prog [Def Tm] Tm
        deriving Show
    
    data Def i = Def Name i
        deriving (Show)

    instance Functor Def where
        fmap f (Def s i) = Def s (f i)

    -- Tipos de los nombres
    type Name = String

    data Tm = 
          Var Name
        | Key Key
        | Usleep Int
        | Sleep Int
        | While Key Tm
        | Repeat Int Tm
        | TimeRepeat Int Tm
        | Line String
        | Seq Tm Tm
        | Mouse Int Int
        deriving Show

    data Key = NKey Char | SKey SpecialKey | MouseButton Int
        deriving Show

    data SpecialKey = LARROW | UARROW | DARROW | RARROW
        | SHIFT | LSHIFT | RSHIFT | TAB | RETURN 
        | ENTER | ESC | SPACE | CONTROL | LCONTROL
        | RCONTROL | ALT | LALT | RALT | SUPR 
        | BACKSPACE | SUPER | LSUPER | RSUPER 
        | MENU | Fkey Int
        deriving Show

    data GlEnv = GlEnv {
            glb :: [Def Tm]  -- ^ Entorno con las variables definidas
        }   

    -- | Valor del estado inicial
    initialEnv :: GlEnv
    initialEnv = GlEnv [] 