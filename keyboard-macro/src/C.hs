module C ( prog2C ) where

import           Common
import           Text.PrettyPrint
import           Prelude                 hiding ( (<>) )

tabW :: Int
tabW = 2

line :: Doc
line = text "\n"

preludeLinux :: Doc
preludeLinux = text "#include \"macro_linux.hpp\""
            $$ text "int main() {"
            $$ nest tabW (
                    text "if (startMain()) { // returns 1 if it failed"
                    $$ nest tabW (text "return 1;")
                    $$ text "}"
                    <> line
            )

prelude :: Char -> Doc
prelude ('l') = preludeLinux
prelude ('w') = undefined
prelude _ = empty

closeMainLinux :: Doc
closeMainLinux = nest tabW (
                       text "XCloseDisplay(display);"
                    $$ text "return 0;"
                )
                $$ text "}"

closeMain :: Char -> Doc
closeMain ('l') = closeMainLinux
closeMain ('w') = undefined
closeMain _ = empty

-- Simplemente llamar a esta función con las irDecls.
prog2C :: Char -> Tm -> String
prog2C m t = render (vcat [prelude m, closeMain m])