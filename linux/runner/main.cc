#include "timnhahanglication.h"

int main(int argc, char** argv) {
  g_autoptr(MyApplication) app = timnhahanglication_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
