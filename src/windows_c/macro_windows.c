#include "macro_windows.h"

/*
    Given a keycode press it and dont release it
*/
void pressKey(WORD key) {
    // keybd_event(key, 0, 0, 0);

    INPUT ip;
    // Set up a generic keyboard event.
    ip.type = INPUT_KEYBOARD;
    ip.ki.wScan = 0; // hardware scan code for key
    ip.ki.time = 0;
    ip.ki.dwExtraInfo = 0;
    // Press the key
    ip.ki.wVk = key;
    ip.ki.dwFlags = 0; // 0 for key press
    SendInput(1, &ip, sizeof(INPUT));
}

/*
    Given a char press that key and dont release it
*/
void pressKeyChar(char key) {
    // SHORT vkCode = VkKeyScan(key);
    // keybd_event(LOBYTE(vkCode), 0, 0, 0);

    INPUT ip;
    // Set up a generic keyboard event.
    ip.type = INPUT_KEYBOARD;
    // Press the key
    SHORT vkCode = VkKeyScan(key);
    ip.ki.wVk = LOBYTE(vkCode);
    ip.ki.dwFlags = 0; // 0 for key press
    SendInput(1, &ip, sizeof(INPUT));
}

/*
    Given an INPUT release it
*/
void releaseKeyChar(char key) {
    // SHORT vkCode = VkKeyScan(key);
    // keybd_event(LOBYTE(vkCode), 0, KEYEVENTF_KEYUP, 0);

    INPUT ip;
    // Set up a generic keyboard event.
    ip.type = INPUT_KEYBOARD;
    // Press the key
    SHORT vkCode = VkKeyScan(key);
    ip.ki.wVk = LOBYTE(vkCode);
    ip.ki.dwFlags = KEYEVENTF_KEYUP; // 0 for key press
    SendInput(1, &ip, sizeof(INPUT));
}

/*
    Given an INPUT release it
*/
void releaseKey(WORD key) {
    //keybd_event(key, 0, KEYEVENTF_KEYUP, 0);

    INPUT ip;
    // Set up a generic keyboard event.
    ip.type = INPUT_KEYBOARD;
    ip.ki.wScan = 0; // hardware scan code for key
    ip.ki.time = 0;
    ip.ki.dwExtraInfo = 0;
    // Press the key
    ip.ki.wVk = key;
    ip.ki.dwFlags = KEYEVENTF_KEYUP; // 0 for key press
    SendInput(1, &ip, sizeof(INPUT));
}

/*
    Press a key one time
*/
void pressAndReleaseKey(WORD key) {
    pressKey(key);
    releaseKey(key);
}

/*
    Press a key one time
*/
void pressAndReleaseKeyChar(char key) {
    pressKeyChar(key);
    releaseKey(key);
}

/*
    Press a key while holding shift
*/
void pressShiftPLusKey(char key) {
    pressKey(VK_LSHIFT);
    pressAndReleaseKeyChar(key);
    releaseKey(VK_LSHIFT);
}

/*
    checks if the char needs shift
*/
int needsShift(char key) {
    return (isupper(key) || key == '!' || key == '~' || key == '@' || key == '#' ||
        key == '$' || key == '%' || key == '^' || key == '&' || key == '*' ||
        key == '(' || key == ')' || key == '_' || key == '+' || key == '{' ||
        key == '}' || key == '|' || key == ':' || key == '"' || key == '<' ||
        key == '>' || key == '?');
}

/*
    press the char even if it needs shift or not
    TO DO revise
*/
void upperOrLowerPress (char key) {
    if (needsShift(key)) {
        pressShiftPLusKey(key);
    } else if (key == '\n') {
        pressAndReleaseKey(VK_RETURN);
    } else {
        pressAndReleaseKeyChar(key);
    }
}

/*
    Press a series of keys corresponding to an array of char
*/
void pressLine (const char *str) {
    for (size_t i = 0; i < strlen(str); i++) {
        upperOrLowerPress(str[i]);
        usleep(10000);  // Add a small delay between key presses (adjust as needed)
    }
}

void moveMouse(int x, int y) {
    SetCursorPos(x, y);
}

/*
    Given a button press it and dont release it
*/
void pressButton(int button) {
    int bcode;
    if (button == 1) {
        bcode = MOUSEEVENTF_LEFTDOWN;
    } else if (button == 2) {
        bcode = MOUSEEVENTF_MIDDLEDOWN;
    } else {
        bcode = MOUSEEVENTF_RIGHTDOWN;
    }
    mouse_event(bcode, 0, 0, 0, 0);
}

/*
    Given a button, release it
*/
void releaseButton(int button) {
    int bcode;
    if (button == 1) {
        bcode = MOUSEEVENTF_LEFTUP;
    } else if (button == 2) {
        bcode = MOUSEEVENTF_MIDDLEUP;
    } else {
        bcode = MOUSEEVENTF_RIGHTUP;
    }
    mouse_event(bcode, 0, 0, 0, 0);
}

/*
    Press a button one time
*/
void pressAndReleaseButton(int button) {
    pressButton(button);
    releaseButton(button);
}

int startMain() {
    if ((GetKeyState(VK_CAPITAL) & 0x0001)!=0) // Check if CapsLock is on and turn it off
    { 
        printf("Caps Lock is on. Turning it off...\n");
        pressAndReleaseKey(VK_CAPITAL);
    } else {
        printf("Caps Lock is off.\n");
    }

    return 0;
}
