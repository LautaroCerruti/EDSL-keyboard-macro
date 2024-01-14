#include "macro_linux.hpp"

// Compile with:
// gcc -o example example.cpp macro_linux.o -lX11 -lXtst -lX11-xcb

int main() {
    if (startMain()) { // returns 1 if it failed
        return 1;
    }

    // ---------------------------------------------------

	sleep(5);

    // Press and release 'A' key
    // pressKey(XK_A);
    // releaseKey(XK_A);
    // for (int i = 0; i < 3; ++i) {
    //     const char *textToType = "estoy haciendo el programa que tipea en linux y soy re basado (esto lo escribi con el programa xd)\n";
    //     pressLine(textToType);
    // }

    pressKey(XK_Control_L);
    upperOrLowerPress('a');
    releaseKey(XK_Control_L);
    pressKey(XK_Control_L);
    upperOrLowerPress('c');
    releaseKey(XK_Control_L);
    pressAndReleaseKey(XK_Right);
    pressAndReleaseKey(XK_Return);
    pressAndReleaseKey(XK_Return);
    pressKey(XK_Control_L);
    upperOrLowerPress('v');
    releaseKey(XK_Control_L);

    // ---------------------------------------------------

    XCloseDisplay(display);
    return 0;
}