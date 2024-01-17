#include "macro_linux.hpp"

// Compile with:
// gcc -o example example.cpp macro_linux.o -lX11 -lXtst -lX11-xcb

int main() {
    if (startMain()) { // returns 1 if it failed
        return 1;
    }

    // ---------------------------------------------------

    pressAndReleaseButton(1);
    sleep(1);
    sleep(1);
	moveMouse(200, 200);
    sleep(1);
	moveMouse(300, 300);
    sleep(1);
	moveMouse(400, 400);
    sleep(1);
	moveMouse(500, 500);
    sleep(1);
	moveMouse(600, 600);
    sleep(1);
	moveMouse(700, 700);
    sleep(1);
	moveMouse(800, 800);

    // ---------------------------------------------------

    XCloseDisplay(display);
    return 0;
}