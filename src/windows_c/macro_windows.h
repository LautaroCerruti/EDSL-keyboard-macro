#ifndef __MACRO_WINDOWS_H__
#define __MACRO_WINDOWS_H__

// Because the SendInput function is only supported in
// Windows 2000 and later, WINVER needs to be set as
// follows so that SendInput gets defined when windows.h
// is included below.
#define WINVER 0x0500
#include <windows.h>
#include <ctype.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>

// Compile with:
// gcc -c -o macro_windows.o macro_windows.c -Wno-deprecated-declarations


/*
    Given a key press that key and dont release it
*/
void pressKey(WORD key);
void pressKeyChar(char key);

/*
    Given a key, release it
*/
void releaseKey(WORD key);
void releaseKeyChar(char key);

/*
    Press a key one time
*/
void pressAndReleaseKey(WORD key);
void pressAndReleaseKeyChar(char key);

/*
    Press a key while holding shift
*/
void pressShiftPLusKey(char key);

/*
    checks if the char needs shift
*/
int needsShift(char key);

/*
    press the char even if it needs shift or not
*/
void upperOrLowerPress(char key);

/*
    Press a series of keys corresponding to an array of char
*/
void pressLine(const char *str);

/*
    Move the mouse to the pos (x, y)
*/
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
void pressAndReleaseButton(int button);

int startMain();

#endif 