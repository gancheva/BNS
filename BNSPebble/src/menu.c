#include <pebble.h>
#include "menu.h"
#include "connector.h"


static Window *window;

static BitmapLayer *image_layer;
static GBitmap *image;

static void select_click_handler(ClickRecognizerRef recognizer, void *context) {
   send_message();
}

static void click_config_provider(void *context) {
  window_single_click_subscribe(BUTTON_ID_SELECT, select_click_handler);
  // In the cases when the button SELECT must not be pressed by accident, the above code can be replaced with 
  // window_long_click_subscribe(BUTTON_ID_SELECT, 300, NULL, select_click_handler);
}

static void window_load(Window *window) {
  Layer *window_layer = window_get_root_layer(window);
  GRect bounds = layer_get_bounds(window_layer);
  
  image = gbitmap_create_with_resource(RESOURCE_ID_IMAGE_ALARM_BUTTON);
  image_layer = bitmap_layer_create(bounds);
  bitmap_layer_set_bitmap(image_layer, image);
  bitmap_layer_set_alignment(image_layer, GAlignCenter);
  layer_add_child(window_layer, bitmap_layer_get_layer(image_layer));
}

static void window_unload(Window *window) { 
  gbitmap_destroy(image);
  bitmap_layer_destroy(image_layer);
}

void show_menu(void) {
  window_stack_push(window, true);
}

void menu_init(void) {
  window = window_create();
  window_set_click_config_provider(window, click_config_provider);
  window_set_window_handlers(window, (WindowHandlers) {
    .load = window_load,
    .unload = window_unload
  });
}

void menu_deinit(void) {
  window_destroy(window);
}


