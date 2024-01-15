module C ( prog2C ) where

import           Common
import           Text.PrettyPrint
import           Prelude                 hiding ( (<>) )

tabW :: Int
tabW = 2

skey2StringLinux :: SpecialKey -> String
skey2StringLinux (LARROW) = "XK_Left"
skey2StringLinux (UARROW) = "XK_Up"
skey2StringLinux (DARROW) = "XK_Down"
skey2StringLinux (RARROW) = "XK_Right"
skey2StringLinux (SHIFT) = "XK_Shift_L"
skey2StringLinux (LSHIFT) = "XK_Shift_L"
skey2StringLinux (RSHIFT) = "XK_Shift_R"
skey2StringLinux (TAB) = "XK_Tab"
skey2StringLinux (RETURN) = "XK_Return"
skey2StringLinux (ENTER) = "XK_Return"
skey2StringLinux (ESC) = "XK_Escape"
skey2StringLinux (SPACE) = "XK_space"
skey2StringLinux (CONTROL) = "XK_Control_L"
skey2StringLinux (LCONTROL) = "XK_Control_L"
skey2StringLinux (RCONTROL) = "XK_Control_R"
skey2StringLinux (ALT) = "XK_Alt_L"
skey2StringLinux (LALT) = "XK_Alt_L"
skey2StringLinux (RALT) = "XK_Alt_R"
skey2StringLinux (SUPR) = "XK_Delete"
skey2StringLinux (BACKSPACE) = "XK_BackSpace"
skey2StringLinux (LSUPER) = "XK_Super_L"
skey2StringLinux (SUPER) = "XK_Super_L"
skey2StringLinux (RSUPER) = "XK_Super_R"
skey2StringLinux (MENU) = "XK_Menu"
skey2StringLinux (Fkey i) = "XK_F" ++ (show i)

key2DocLinux :: Key -> Doc
key2DocLinux (NKey k) = char '\'' <> char k <> char '\''
key2DocLinux (SKey k) = text (skey2StringLinux k)

key2DocWindows :: Key -> Doc
key2DocWindows k = empty

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

tm2Doc :: Char -> Tm -> Doc
tm2Doc c p = case c of
                'l' -> go key2DocLinux p 0
                'w' -> go key2DocWindows p 0
                _   -> empty
            where 
                go :: (Key -> Doc) -> Tm -> Int -> Doc
                go _ (Var _) _ = empty
                go f (Key k) _ = text "pressAndReleaseKey(" <> f k <> text ");"
                go _ (Usleep n) _ = text "usleep(" <> int n <> text ");"
                go _ (Sleep n) _ = text "sleep(" <> int n <> text ");"
                go _ (Line str) _ = 
                       lbrace
                    $$ text "const char *textToType = \"" 
                    <> text str 
                    <> text "\";"
                    $$ text "pressLine(textToType);"
                    $$ rbrace
                go f (While k tm) i = let ktext = f k in 
                                            if (c == 'l') then
                                                   text "pressKey(" 
                                                <> ktext 
                                                <> text ");" 
                                                $$ go f tm i
                                                $$ text "releaseKey(" 
                                                <> ktext 
                                                <> text ");" 
                                            else empty
                go f (Repeat n tm) i = let vText = text ("i" ++ show i) in
                                           text "for (int " 
                                        <> vText 
                                        <> text " = 0; " 
                                        <> vText 
                                        <> text " < " 
                                        <> int n 
                                        <> text "; ++" 
                                        <> vText 
                                        <> text ") {" 
                                        $$ nest tabW (go f tm (i+1)) 
                                        $$ rbrace
                go f (Seq t1 t2) i = (go f t1 i) $$ (go f t2 i)

prog2C :: Char -> Tm -> String
prog2C m t = render (vcat [prelude m, nest tabW (tm2Doc m t), closeMain m])