module PrettyPrinter where

import           Common
import           Text.PrettyPrint
import           Prelude                 hiding ( (<>) )

tabW :: Int
tabW = 2

isKeyOrVar :: Tm -> Bool
isKeyOrVar (Key _) = True
isKeyOrVar (Var _) = True
isKeyOrVar _ = False

parensIf :: Bool -> Doc -> Doc
parensIf True  = parens
parensIf False = id

pSK :: SpecialKey -> Doc
pSK (Fkey n)= text "F" <> int n
pSK k = text (show k)

pK :: Key -> Doc
pK (NKey k) = char k
pK (SKey k) = pSK k
pK (MouseButton n) = case n of 
                        1 -> text "LMB"
                        2 -> text "MMB"
                        3 -> text "RMB"
                        _ -> empty

pTm :: Tm -> Doc
pTm (Var n)        = text n
pTm (Key k)        = pK k
pTm (Mouse x y)    = text "mouse" <+> int x <+> int y
pTm (Usleep n)     = text "usleep" <+> int n
pTm (Sleep n)      = text "sleep" <+> int n
pTm (While k t)    = pK k <> text "+" <> parensIf (not (isKeyOrVar t)) (pTm t)
pTm (Repeat n t)   = 
    text "repeat" 
        <+> int n 
        <+> lparen 
        $$ nest tabW (pTm t) 
        $$ rparen
pTm (TimeRepeat n t)   = 
    text "timeRepeat" 
        <+> int n 
        <+> lparen 
        $$ nest tabW (pTm t) 
        $$ rparen
pTm (Line l)       = text "line \"" <> text l <> text "\""
pTm (Seq a b)      = pTm a <> semi <+> pTm b

pDef :: Def Tm -> Doc
pDef (Def name t) = text "def" <+> text name <+> text "=" <+> pTm t

pProg :: Prog -> Doc
pProg (Prog defs t) = (vcat (map pDef defs)) $$ (text "\n\n-- Macro:\n" <> pTm t)

renderProg :: Prog -> String
renderProg = render . pProg