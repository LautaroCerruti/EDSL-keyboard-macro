#include "macro_linux.hpp"

// Compile with:
// gcc -c -o macro_linux.o macro_linux.cpp -lX11 -lXtst -lX11-xcb

Display *display;

/*
    Given a key press that key and dont release it, 
    commonly used for SHIFT, CTRL or WINDOWS
*/
void pressKey(int keySym) {
    XTestFakeKeyEvent(display, XKeysymToKeycode(display, keySym), True, 0);
    XFlush(display);
}

/*
    Given a key, release it
*/
void releaseKey(int keySym) {
    XTestFakeKeyEvent(display, XKeysymToKeycode(display, keySym), False, 0);
    XFlush(display);
}

/*
    Press a key one time
*/
void pressAndReleaseKey (int c) {
    pressKey(c);
    releaseKey(c);
}

/*
    Press a key while holding shift
*/
void pressShiftPLusKey (char key) {
    pressKey(XK_Shift_L);
    pressAndReleaseKey(key);
    releaseKey(XK_Shift_L);
}

/*
    checks if the char needs shift
*/
bool needsShift(char key) {
    return (isupper(key) || key == '!' || key == '~' || key == '@' || key == '#' ||
        key == '$' || key == '%' || key == '^' || key == '&' || key == '*' ||
        key == '(' || key == ')' || key == '_' || key == '+' || key == '{' ||
        key == '}' || key == '|' || key == ':' || key == '"' || key == '<' ||
        key == '>' || key == '?');
}

/*
    press the char even if it needs shift or not
*/
void upperOrLowerPress (char key) {
    if (needsShift(key)) {
        pressShiftPLusKey(key);
    } else if (key == '\n') {
        pressKey(XK_Return);
        releaseKey(XK_Return);
    } else {
        pressAndReleaseKey(key);
    }
}

/*
    Press a series of keys corresponding to an array of char
*/
void pressLine(const char *str) {
    for (size_t i = 0; i < strlen(str); i++) {
        upperOrLowerPress(str[i]);
        usleep(10000);  // Add a small delay between key presses (adjust as needed)
    }
}

int startMain() {
    display = XOpenDisplay(NULL);
    if (!display) {
        fprintf(stderr, "Unable to open display\n");
        return 1;
    }

    // Check and turn off Caps Lock
    XkbStateRec xkbState;
    XkbGetState(display, XkbUseCoreKbd, &xkbState);

    if (xkbState.locked_mods & LockMask) {
        printf("Caps Lock is on. Turning it off...\n");
        pressAndReleaseKey(XK_Caps_Lock);
    } else {
        printf("Caps Lock is off.\n");
    }

    return 0;
}