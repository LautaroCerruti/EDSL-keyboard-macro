#include "library_windows/macro_windows.hpp"

// Compile with:
// gcc -c -o macro_windows.o macro_windows.cpp -Wno-deprecated-declarations

int main()
{
    startMain();

    // ---------------------------------------------------

    sleep(5);
    for (int i = 0; i<3; i++) {
        char str[]="qwertyuiopasdfghjklzxcvbnm QWERTYUIOPASDFGHJKLZXCVBNM `1234567890 -= []\\;',./ ~!@#$%^&*()_+{}|:\"<>?\n";
        pressLine(str);
        sleep(1);
    }
    
    {
    INPUT ip;
    pressKey(&ip, VK_CONTROL);
    pressAndReleaseKeyChar('a');
    releaseKey(&ip);
    }
    {
    INPUT ip;
    pressKey(&ip, VK_CONTROL);
    pressAndReleaseKeyChar('c');
    releaseKey(&ip);
    }
    pressAndReleaseKey(VK_RIGHT);
    pressAndReleaseKey(VK_RETURN);
    {
    INPUT ip;
    pressKey(&ip, VK_CONTROL);
    pressAndReleaseKeyChar('v');
    releaseKey(&ip);
    }


    // ---------------------------------------------------
    
    return 0;
}