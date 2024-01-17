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

extern Display *display;

/*
    Given a key press that key and dont release it, 
    commonly used for SHIFT, CTRL or WINDOWS
*/
void l_pressKey(int keySym);

/*
    Given a key, release it
*/
void l_releaseKey(int keySym);

/*
    Press a key one time
*/
void l_pressAndReleaseKey(int c);

/*
    Press a key while holding shift
*/
void l_pressShiftPLusKey(char key);

/*
    checks if the char needs shift
*/
bool l_needsShift(char key);

/*
    press the char even if it needs shift or not
*/
void l_upperOrLowerPress(char key);

/*
    Press a series of keys corresponding to an array of char
*/
void l_pressLine(const char *str);

void l_moveMouse(int x, int y);

/*
    Given a button press it and dont release it
*/
void l_pressButton(int button);

/*
    Given a button, release it
*/
void l_releaseButton(int button);

/*
    Press a button one time
*/
void l_pressAndReleaseButton(int button);

int l_startMain();

#endif 