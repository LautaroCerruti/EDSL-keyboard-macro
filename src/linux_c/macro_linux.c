#include "macro_linux.h"

// Compile with:
// gcc -c -o macro_linux.o macro_linux.cpp -lX11 -lXtst -lX11-xcb

Display *display;

/*
    Given a key press that key and dont release it, 
    commonly used for SHIFT, CTRL or WINDOWS
*/
void l_pressKey(int keySym) {
    XTestFakeKeyEvent(display, XKeysymToKeycode(display, keySym), True, 0);
    XFlush(display);
}

/*
    Given a key, release it
*/
void l_releaseKey(int keySym) {
    XTestFakeKeyEvent(display, XKeysymToKeycode(display, keySym), False, 0);
    XFlush(display);
}

/*
    Press a key one time
*/
void l_pressAndReleaseKey(int c) {
    l_pressKey(c);
    l_releaseKey(c);
}

/*
    Press a key while holding shift
*/
void l_pressShiftPLusKey(char key) {
    l_pressKey(XK_Shift_L);
    l_pressAndReleaseKey(key);
    l_releaseKey(XK_Shift_L);
}

/*
    checks if the char needs shift
*/
int l_needsShift(char key) {
    return (isupper(key) || key == '!' || key == '~' || key == '@' || key == '#' ||
        key == '$' || key == '%' || key == '^' || key == '&' || key == '*' ||
        key == '(' || key == ')' || key == '_' || key == '+' || key == '{' ||
        key == '}' || key == '|' || key == ':' || key == '"' || key == '<' ||
        key == '>' || key == '?');
}

/*
    press the char even if it needs shift or not
*/
void l_upperOrLowerPress(char key) {
    if (l_needsShift(key)) {
        l_pressShiftPLusKey(key);
    } else if (key == '\n') {
        l_pressAndReleaseKey(XK_Return);
    } else {
        l_pressAndReleaseKey(key);
    }
}

/*
    Press a series of keys corresponding to an array of char
*/
void l_pressLine(const char *str) {
    for (size_t i = 0; i < strlen(str); i++) {
        l_upperOrLowerPress(str[i]);
        usleep(10000);  // Add a small delay between key presses (adjust as needed)
    }
}

void l_moveMouse(int x, int y) {
    XWarpPointer(display, None, DefaultRootWindow(display), 0, 0, 0, 0, x, y);
    XFlush(display);
}

/*
    Given a button press it and dont release it
*/
void l_pressButton(int button) {
    XTestFakeButtonEvent(display, button, True, 0);
    XFlush(display);
}

/*
    Given a button, release it
*/
void l_releaseButton(int button) {
    XTestFakeButtonEvent(display, button, False, 0);
    XFlush(display);
}

/*
    Press a button one time
*/
void l_pressAndReleaseButton(int button) {
    l_pressButton(button);
    l_releaseButton(button);
}

int l_startMain() {
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
        l_pressAndReleaseKey(XK_Caps_Lock);
    } else {
        printf("Caps Lock is off.\n");
    }

    return 0;
}