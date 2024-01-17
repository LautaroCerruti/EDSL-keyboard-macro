module C ( prog2C ) where

import           Common
import           Text.PrettyPrint
import           Prelude                 hiding ( (<>) )

tabW :: Int
tabW = 2

isButton :: Key -> Bool
isButton (MouseButton _) = True
isButton _ = False

isSpecialKey :: Key -> Bool
isSpecialKey (SKey _) = True
isSpecialKey _ = False

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

preludeLinux :: FilePath -> Doc
preludeLinux fp =  text "#include \"" <> text fp <> text "/src/linux_c/macro_linux.hpp\""
                $$ text "int main() {"
                $$ nest tabW (
                        text "if (l_startMain()) { // returns 1 if it failed"
                        $$ nest tabW (text "return 1;")
                        $$ text "}"
                        <> line
                )

preludeWindows :: FilePath -> Doc
preludeWindows fp =    text "#include \"" <> text fp <> text "/src/windows_c/macro_windows.hpp\""
                    $$ text "int main() {"
                    $$ nest tabW (
                            text "w_startMain();"
                            <> line
                    )

prelude :: FilePath -> Char -> Doc
prelude fp ('l') = preludeLinux fp
prelude fp ('w') = preludeWindows fp
prelude _ _ = empty

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

tm2DocLinux :: Tm -> Int -> Doc
tm2DocLinux (Var _) _ = empty
tm2DocLinux (Key k@(MouseButton _)) _ = text "l_pressAndReleaseButton(" <> key2DocLinux k <> text ");"
tm2DocLinux (Key k) _ = text "l_pressAndReleaseKey(" <> key2DocLinux k <> text ");"
tm2DocLinux (Mouse x y) _ = text "l_moveMouse(" <> int x <> text ", " <> int y <> text ");"
tm2DocLinux (Usleep n) _ = text "usleep(" <> int n <> text ");"
tm2DocLinux (Sleep n) _ = text "sleep(" <> int n <> text ");"
tm2DocLinux (Line str) _ = 
                           lbrace
                        $$ text "const char *textToType = \"" 
                        <> text str 
                        <> text "\";"
                        $$ text "l_pressLine(textToType);"
                        $$ rbrace
tm2DocLinux (While k tm) i = let ktext = key2DocLinux k in 
                                   (if isButton k then text "l_pressButton(" else text "l_pressKey(")
                                <> ktext 
                                <> text ");" 
                                $$ tm2DocLinux tm i
                                $$ (if isButton k then text "l_releaseButton(" else text "l_releaseKey(")
                                <> ktext 
                                <> text ");"
tm2DocLinux (Repeat n tm) i = let vText = text ("i" ++ show i) in
                                       text "for (int " 
                                    <> vText 
                                    <> text " = 0; " 
                                    <> vText 
                                    <> text " < " 
                                    <> int n 
                                    <> text "; ++" 
                                    <> vText 
                                    <> text ") {" 
                                    $$ nest tabW (tm2DocLinux tm (i+1)) 
                                    $$ rbrace
tm2DocLinux (Seq t1 t2) i = (tm2DocLinux t1 i) $$ (tm2DocLinux t2 i)

tm2DocWindows :: Tm -> Int -> Doc
tm2DocWindows (Var _) _ = empty
tm2DocWindows (Key k@(MouseButton _)) _ = text "w_pressAndReleaseButton(" <> key2DocWindows k <> text ");"
tm2DocWindows (Key k@(SKey _)) _ = text "w_pressAndReleaseKey(" <> key2DocWindows k <> text ");"
tm2DocWindows (Key k@(NKey _)) _ = text "w_pressAndReleaseKeyChar(" <> key2DocWindows k <> text ");"
tm2DocWindows (Mouse x y) _ = text "w_moveMouse(" <> int x <> text ", " <> int y <> text ");"
tm2DocWindows (Usleep n) _ = text "usleep(" <> int n <> text ");"
tm2DocWindows (Sleep n) _ = text "sleep(" <> int n <> text ");"
tm2DocWindows (Line str) _ = 
                               lbrace
                            $$ text "const char *textToType = \"" 
                            <> text str 
                            <> text "\";"
                            $$ text "w_pressLine(textToType);"
                            $$ rbrace
tm2DocWindows (While k tm) i = let ktext = key2DocWindows k in 
                            if (isButton k) then
                                    text "w_pressButton(" <> ktext <> text ");"
                                 $$ tm2DocWindows tm i
                                 $$ text "w_releaseButton(" <> ktext <> text ");"
                            else 
                                    text "w_pressKey" 
                                 <> (if(isSpecialKey k) then empty else text "Char")
                                 <> text "(" <> ktext <> text ");"
                                 $$ tm2DocWindows tm i
                                 $$ text "w_releaseKey" 
                                 <> (if(isSpecialKey k) then empty else text "Char")
                                 <> text "(" <> ktext <> text ");"
tm2DocWindows (Repeat n tm) i = let vText = text ("i" ++ show i) in
                                       text "for (int " 
                                    <> vText 
                                    <> text " = 0; " 
                                    <> vText 
                                    <> text " < " 
                                    <> int n 
                                    <> text "; ++" 
                                    <> vText 
                                    <> text ") {" 
                                    $$ nest tabW (tm2DocWindows tm (i+1)) 
                                    $$ rbrace
tm2DocWindows (Seq t1 t2) i = (tm2DocWindows t1 i) $$ (tm2DocWindows t2 i)

tm2Doc :: Char -> Tm -> Doc
tm2Doc c p = case c of
                'l' -> tm2DocLinux p 0
                'w' -> tm2DocWindows p 0
                _   -> empty

prog2C :: FilePath -> Char -> Tm -> String
prog2C fp m t = render (vcat [prelude fp m, nest tabW (tm2Doc m t), closeMain m])