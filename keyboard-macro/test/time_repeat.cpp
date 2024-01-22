#include "/home/noemi/Escritorio/EDSL-keyboard-macro/keyboard-macro/src/linux_c/macro_linux.hpp"
#include <time.h>
int main() {
  if (l_startMain()) { // returns 1 if it failed
    return 1;
  }

  {time_t start_time0 = time(NULL);
   while((time(NULL) - start_time0) < 10) {
     l_moveMouse(200, 200);
     sleep(1);
     l_moveMouse(400, 400);
     sleep(1);
   }}
  XCloseDisplay(display);
  return 0;
}