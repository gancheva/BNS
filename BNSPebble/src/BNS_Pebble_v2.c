#include <pebble.h>
#include "info.h"
#include "menu.h"
#include "popup.h"
#include "connector.h"

static void init(void) {
  connector_init();
  popup_init();
  menu_init();
  info_init();
}

static void deinit(void) {
  connector_deinit();
  popup_deinit();
  menu_deinit();
  info_deinit();
}

int main(void) {
  init();
  app_event_loop();
  deinit();

  return 0;
}


