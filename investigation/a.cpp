// Because the SendInput function is only supported in
// Windows 2000 and later, WINVER needs to be set as
// follows so that SendInput gets defined when windows.h
// is included below.
#define WINVER 0x0500
#include <windows.h>
#include <iostream>
#include <ctype.h>

using namespace std;

/*
    Given an INPUT and a key press that key and dont release it, 
    commonly used for SHIFT, CTRL or WINDOWS
*/
void pressHoldKey (INPUT* ip, char key) {
    // Set up a generic keyboard event.
    ip->type = INPUT_KEYBOARD;
    ip->ki.wScan = 0; // hardware scan code for key
    ip->ki.time = 0;
    ip->ki.dwExtraInfo = 0;
    // Press the key
    ip->ki.wVk = key; 
    ip->ki.dwFlags = 0; // 0 for key press
    SendInput(1, ip, sizeof(INPUT));
}

/*
    Given an INPUT release it
*/
void releaseKey (INPUT* ip) {
    ip->ki.dwFlags = KEYEVENTF_KEYUP; // KEYEVENTF_KEYUP for key release
    SendInput(1, ip, sizeof(INPUT));
}

/*
    Press a key one time
*/
void pressKey (char key) {
    INPUT ip;
    pressHoldKey(&ip, key);
    releaseKey(&ip);
}

/*
    Press a key while holding shift
*/
void pressShiftPLusKey (char key) {
    INPUT ip;
    pressHoldKey(&ip, VK_LSHIFT);
    pressKey(key);
    releaseKey(&ip);
}

void upperOrLowerPress (char key) {
    if (isdigit(key) || islower(key)) {
        pressKey(toupper(key));
    } else if (isupper(key)) {
        pressShiftPLusKey(key);
    }
}

void pressKeyWithSymbols (char key) {
    if (isalnum(key)) {
        upperOrLowerPress(key);
        return;
    }
    switch (key)
    {
    case '+':
        pressKey(VK_OEM_PLUS);
        break;
    case '-':
        pressKey(VK_OEM_MINUS);
        break;
    case '_':
        pressShiftPLusKey(VK_OEM_MINUS);
        break;
    case '*':
        pressShiftPLusKey(VK_OEM_PLUS);
        break;
    case ' ':
        pressKey(VK_SPACE);
        break;
    case '=':
        pressShiftPLusKey('0');
        break;
    case '(':
        pressShiftPLusKey('8');
        break;
    case ')':
        pressShiftPLusKey('9');
        break;
    case ',':
        pressKey(VK_OEM_COMMA);
        break;
    case ';':
        pressShiftPLusKey(VK_OEM_COMMA);
        break;
    case '\"':
        pressShiftPLusKey('2');
        break;
    case '.':
        pressKey(VK_OEM_PERIOD);
        break;
    case ':':
        pressShiftPLusKey(VK_OEM_PERIOD);
        break;
    case '#':
        pressShiftPLusKey('3');
        break;
    case '$':
        pressShiftPLusKey('4');
        break;
    case '%':
        pressShiftPLusKey('5');
        break;
    case '&':
        pressShiftPLusKey('6');
        break;
    case '/':
        pressShiftPLusKey('7');
        break;
    case '!':
        pressShiftPLusKey('1');
        break;
    default:
        break;
    }
}

/*
    Press a series of keys corresponding to an array of char
*/
void pressLine (char* keys) {
    while (*keys != '\0') {
        pressKeyWithSymbols(*keys);
        keys++;
    }
}

int main()
{
    if ((GetKeyState(VK_CAPITAL) & 0x0001)!=0) // Check if CapsLock is on and turn it off
    { 
        cout << "IS ON" << endl;
        pressKey(VK_CAPITAL);
    }
    Sleep(5000);
    for (int i = 0; i<20; i++) {
        char str[]="hola linda";
        pressLine(str);
        pressKey(VK_RETURN);
        Sleep(1000);
    }
    
    // {
    // INPUT ip;
    // pressHoldKey(&ip, VK_CONTROL);
    // UpperOrLowerPress('a');
    // releaseKey(&ip);
    // }
    // {
    // INPUT ip;
    // pressHoldKey(&ip, VK_CONTROL);
    // UpperOrLowerPress('c');
    // releaseKey(&ip);
    // }
    // pressKey(VK_RIGHT);
    // pressKey(VK_RETURN);
    // {
    // INPUT ip;
    // pressHoldKey(&ip, VK_CONTROL);
    // UpperOrLowerPress('v');
    // releaseKey(&ip);
    // }

    return 0;
}