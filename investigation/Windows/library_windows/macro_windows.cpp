#include "macro_windows.hpp"

/*
    Given a keycode press it and dont release it
*/
void w_pressKey(WORD key) {
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
void w_pressKeyChar(char key) {
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
void w_releaseKeyChar(char key) {
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
void w_releaseKey(WORD key) {
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
void w_pressAndReleaseKey(WORD key) {
    w_pressKey(key);
    w_releaseKey(key);
}

/*
    Press a key one time
*/
void w_pressAndReleaseKeyChar(char key) {
    w_pressKeyChar(key);
    w_releaseKey(key);
}

/*
    Press a key while holding shift
*/
void w_pressShiftPLusKey(char key) {
    w_pressKey(VK_LSHIFT);
    w_pressAndReleaseKeyChar(key);
    w_releaseKey(VK_LSHIFT);
}

/*
    checks if the char needs shift
*/
bool w_needsShift(char key) {
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
void w_upperOrLowerPress (char key) {
    if (w_needsShift(key)) {
        w_pressShiftPLusKey(key);
    } else if (key == '\n') {
        w_pressAndReleaseKey(VK_RETURN);
    } else {
        w_pressAndReleaseKeyChar(key);
    }
}

/*
    Press a series of keys corresponding to an array of char
*/
void w_pressLine (const char *str) {
    for (size_t i = 0; i < strlen(str); i++) {
        w_upperOrLowerPress(str[i]);
        usleep(10000);  // Add a small delay between key presses (adjust as needed)
    }
}

void w_moveMouse(int x, int y) {
    SetCursorPos(x, y);
}

/*
    Given a button press it and dont release it
*/
void w_pressButton(int button) {
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
void w_releaseButton(int button) {
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
void w_pressAndReleaseButton(int button) {
    w_pressButton(button);
    w_releaseButton(button);
}

int w_startMain() {
    if ((GetKeyState(VK_CAPITAL) & 0x0001)!=0) // Check if CapsLock is on and turn it off
    { 
        cout << "Caps Lock is on. Turning it off..." << endl;
        w_pressAndReleaseKey(VK_CAPITAL);
    } else {
        cout << "Caps Lock is off." << endl;
    }

    return 0;
}
