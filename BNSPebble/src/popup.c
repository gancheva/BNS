#include <pebble.h>
#include "popup.h"

Window *window;
static BitmapLayer *image_layer;
static GBitmap *image;
static AppTimer *timer;

static void timer_callback(void *data) {
  window_stack_pop(false);
}

static void window_load(Window *window) {
  Layer *window_layer = window_get_root_layer(window);
  GRect bounds = layer_get_bounds(window_layer);

  image = gbitmap_create_with_resource(RESOURCE_ID_IMAGE_OK_POPUP);
  image_layer = bitmap_layer_create(bounds);
  bitmap_layer_set_bitmap(image_layer, image);
  bitmap_layer_set_alignment(image_layer, GAlignCenter);
  layer_add_child(window_layer, bitmap_layer_get_layer(image_layer));
  timer = app_timer_register(1200, timer_callback, NULL);  
}

static void window_unload(Window *window) {
  app_timer_cancel(timer);
  gbitmap_destroy(image);
  bitmap_layer_destroy(image_layer);
}

void show_popup(void) {
  window_stack_push(window, false);
}

void popup_init(void) {
  window = window_create();
  window_set_window_handlers(window, (WindowHandlers) {
    .load = window_load,
    .unload = window_unload
  });
}

void popup_deinit(void) {
  window_destroy(window);
}
