#include "macro_windows.hpp"

// Compile with:
// gcc -c -o macro_windows.o macro_windows.cpp -Wno-deprecated-declarations

int main() {
    startMain();
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
    return 0;
}