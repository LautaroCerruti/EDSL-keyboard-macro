module C ( prog2C ) where

import           Common
import           Text.PrettyPrint
import           Prelude                 hiding ( (<>) )

tabW :: Int
tabW = 2

isButton :: Key -> Bool
isButton (MouseButton _) = True
isButton _ = False

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

skey2StringWindows :: SpecialKey -> String
skey2StringWindows (LARROW) = "VK_LEFT"
skey2StringWindows (UARROW) = "VK_UP"
skey2StringWindows (DARROW) = "VK_DOWN"
skey2StringWindows (RARROW) = "VK_RIGHT"
skey2StringWindows (SHIFT) = "VK_SHIFT"
skey2StringWindows (LSHIFT) = "VK_LSHIFT"
skey2StringWindows (RSHIFT) = "VK_RSHIFT"
skey2StringWindows (TAB) = "VK_TAB"
skey2StringWindows (RETURN) = "VK_RETURN"
skey2StringWindows (ENTER) = "VK_RETURN"
skey2StringWindows (ESC) = "VK_ESCAPE"
skey2StringWindows (SPACE) = "VK_SPACE"
skey2StringWindows (CONTROL) = "VK_LCONTROL"
skey2StringWindows (LCONTROL) = "VK_LCONTROL"
skey2StringWindows (RCONTROL) = "VK_RCONTROL"
skey2StringWindows (ALT) = "VK_MENU"
skey2StringWindows (LALT) = "VK_LMENU"
skey2StringWindows (RALT) = "VK_RMENU"
skey2StringWindows (SUPR) = "VK_DELETE"
skey2StringWindows (BACKSPACE) = "VK_BACK"
skey2StringWindows (LSUPER) = "VK_LWIN"
skey2StringWindows (SUPER) = "VK_LWIN"
skey2StringWindows (RSUPER) = "VK_RWIN"
skey2StringWindows (MENU) = "VK_APPS"
skey2StringWindows (Fkey i) = "VK_F" ++ (show i)

key2DocLinux :: Key -> Doc
key2DocLinux (NKey k) = char '\'' <> char k <> char '\''
key2DocLinux (SKey k) = text (skey2StringLinux k)
key2DocLinux (MouseButton n) = int n

key2DocWindows :: Key -> Doc
key2DocWindows (NKey k) = char '\'' <> char k <> char '\''
key2DocWindows (SKey k) = text (skey2StringWindows k)
key2DocWindows (MouseButton n) = int n

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

preludeWindows :: Doc
preludeWindows = text "#include \"macro_windows.hpp\""
            $$ text "int main() {"
            $$ nest tabW (
                    text "startMain();"
                    <> line
            )

prelude :: Char -> Doc
prelude ('l') = preludeLinux
prelude ('w') = preludeWindows
prelude _ = empty

closeMainLinux :: Doc
closeMainLinux = nest tabW (
                       text "XCloseDisplay(display);"
                    $$ text "return 0;"
                )
                $$ text "}"

closeMainWindows :: Doc
closeMainWindows = nest tabW (
                       text "return 0;"
                )
                $$ text "}"

closeMain :: Char -> Doc
closeMain ('l') = closeMainLinux
closeMain ('w') = closeMainWindows
closeMain _ = empty

tm2Doc :: Char -> Tm -> Doc
tm2Doc c p = case c of
                'l' -> go key2DocLinux p 0
                'w' -> go key2DocWindows p 0
                _   -> empty
            where 
                go :: (Key -> Doc) -> Tm -> Int -> Doc
                go _ (Var _) _ = empty
                go f (Key k@(MouseButton _)) _ = text "pressAndReleaseButton(" <> f k <> text ");"
                go f (Key k) _ = text "pressAndReleaseKey(" <> f k <> text ");"
                go _ (Mouse x y) _ = text "moveMouse(" <> int x <> text ", " <> int y <> text ");"
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
                                                   (if isButton k then text "pressButton(" else text "pressKey(")
                                                <> ktext 
                                                <> text ");" 
                                                $$ go f tm i
                                                $$ (if isButton k then text "releaseButton(" else text "releaseKey(")
                                                <> ktext 
                                                <> text ");" 
                                            else 
                                                if (isButton k) then
                                                       text "pressButton(" <> ktext <> text ");"
                                                    $$ go f tm i
                                                    $$ text "releaseButton(" <> ktext <> text ");"
                                                else
                                                       lbrace
                                                    $$ nest tabW (
                                                           text "INPUT ip" <> int i <> text ";"
                                                        $$ text "pressKey(&ip" <> int i <> text ", " <> ktext <> text ");"
                                                        $$ go f tm (i+1)
                                                        $$ text "releaseKey(&ip" <> int i <> text ");"
                                                    ) 
                                                    $$ rbrace
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