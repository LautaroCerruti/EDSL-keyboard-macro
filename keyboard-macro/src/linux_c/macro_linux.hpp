#ifndef __MACRO_LINUX_H__
#define __MACRO_LINUX_H__

#include <X11/Xlib.h>
#include <X11/XKBlib.h>
#include <X11/extensions/XTest.h>
#include <X11/keysym.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <ctype.h>

// Compile with:
// gcc -c -o macro_linux.o macro_linux.cpp -lX11 -lXtst -lX11-xcb
// Compile files in Linux with:
// gcc -o NAME NAME.cpp macro_linux.o -lX11 -lXtst -lX11-xcb

extern Display *display;

/*
    Given a key press that key and dont release it, 
    commonly used for SHIFT, CTRL or WINDOWS
*/
void pressKey(int keySym);

/*
    Given a key, release it
*/
void releaseKey(int keySym);

/*
    Press a key one time
*/
void pressAndReleaseKey (int c);

/*
    Press a key while holding shift
*/
void pressShiftPLusKey (char key);

/*
    checks if the char needs shift
*/
bool needsShift(char key);

/*
    press the char even if it needs shift or not
*/
void upperOrLowerPress (char key);

/*
    Press a series of keys corresponding to an array of char
*/
void pressLine(const char *str);

void moveMouse(int x, int y);

/*
    Given a button press it and dont release it
*/
void pressButton(int button);

/*
    Given a button, release it
*/
void releaseButton(int button);

/*
    Press a button one time
*/
void pressAndReleaseButton (int button);

int startMain();

#endif 