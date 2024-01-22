#include "library_linux/macro_linux.hpp"
#include <time.h>

// Compile with:
// gcc -o example example.cpp macro_linux.o -lX11 -lXtst -lX11-xcb

int main() {
    if (l_startMain()) { // returns 1 if it failed
        return 1;
    }

    // ---------------------------------------------------

    {
        time_t start_time = time(NULL); // Get current time
        while ((time(NULL) - start_time) < 5) {
            
            l_moveMouse(200, 200);
            usleep(100000);
            l_moveMouse(300, 300);
            usleep(100000);
            l_moveMouse(400, 400);
            usleep(100000);
            l_moveMouse(500, 500);
            usleep(100000);
            l_moveMouse(600, 600);
            usleep(100000);
            l_moveMouse(700, 700);
            usleep(100000);
            l_moveMouse(800, 800);
            usleep(100000);

        }
    }
    // ---------------------------------------------------

    XCloseDisplay(display);
    return 0;
}