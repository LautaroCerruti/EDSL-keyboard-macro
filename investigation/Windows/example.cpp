#include "macro_windows.hpp"

// Compile with:
// gcc -c -o macro_windows.o macro_windows.cpp -Wno-deprecated-declarations

int main() {
    w_startMain();
    // ---------------------------------------------------

    sleep(5);
    w_pressKey(VK_SHIFT);
    const char* l = "holaaaaa";
    w_pressLine(l);
    usleep(10000);
    const char* l2 = "cgauuuuu";
    w_pressLine(l2);
    w_releaseKey(VK_SHIFT);

    // ---------------------------------------------------
    return 0;
}