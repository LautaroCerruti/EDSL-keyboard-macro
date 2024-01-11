module PrettyPrinter where

import           Common
import           Text.PrettyPrint
import           Prelude                 hiding ( (<>) )

tabW :: Int
tabW = 2

pSK :: SpecialKey -> Doc
pSK (Fkey n)= text "F" <> int n
pSK k = text (show k)

pK :: Key -> Doc
pK (NKey k) = char k
pK (Skey k) = pSK k

pTm :: Tm -> Doc
pTm (Var n)        = text n
pTm (Key k)        = pK k
pTm (Usleep n)     = text "usleep" <+> int n
pTm (Sleep n)      = text "sleep" <+> int n
pTm (While k t)    = text "while" <+> pK k <+> parens (pTm t)
pTm (Repeat n t)   = text "repeat" <+> int n <+> parens (pTm t)
pTm (Line l)       = text "line \"" <> text l <> text "\""
pTm (Seq a b)      = pTm a <+> semi <+> pTm b

pStmt :: Stmt Tm -> Doc
pStmt (Def name t) = text "def" <+> text name <+> text "=" <+> pTm t
pStmt (Macro name t) = text "macro" <+> text name <+> text "=" <+> pTm t

renderStmt :: Stmt Tm -> String
renderStmt = render . pStmt