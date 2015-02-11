#include <pebble.h>
#include "info.h"
#include "menu.h"
#include "connector.h"

static Window *window;
static ScrollLayer *scroll_layer;
static const int vert_scroll_text_padding = 4;
static TextLayer *text_layer_location;
static TextLayer *text_layer_instructions;

static void select_click_handler(ClickRecognizerRef recognizer, void *context) {  
  show_menu();
}

static void click_config_provider(void *context) {
  window_set_click_context(BUTTON_ID_SELECT, context);
  window_single_click_subscribe(BUTTON_ID_SELECT, select_click_handler);
}

static void window_load(Window *window) {
  Layer *window_layer = window_get_root_layer(window);
  GRect bounds = layer_get_bounds(window_layer);
  GRect max_text_bounds = GRect(0, 0, bounds.size.w, 2000);

  scroll_layer = scroll_layer_create(bounds);
  scroll_layer_set_click_config_onto_window(scroll_layer, window);                                                
  scroll_layer_set_callbacks(scroll_layer, (ScrollLayerCallbacks){.click_config_provider=click_config_provider});

  text_layer_location = text_layer_create(max_text_bounds);   
  text_layer_set_text(text_layer_location, "Unknown location ...");
  text_layer_set_text_alignment(text_layer_location, GAlignTopLeft);
  text_layer_set_overflow_mode(text_layer_location, GTextOverflowModeWordWrap);
  
  GSize max_size_location = text_layer_get_content_size(text_layer_location);
  text_layer_set_size(text_layer_location, max_size_location);
 
  text_layer_instructions = text_layer_create(GRect(0, max_size_location.h + 2, bounds.size.w, 2000));     
  text_layer_set_text(text_layer_instructions, "Currently there are no notifications received from the phone. Please wait ...");
  text_layer_set_text_alignment(text_layer_instructions, GAlignLeft);
  text_layer_set_font(text_layer_instructions, fonts_get_system_font(FONT_KEY_GOTHIC_28_BOLD));
  text_layer_set_overflow_mode(text_layer_instructions, GTextOverflowModeWordWrap);
  GSize max_size_instructions = text_layer_get_content_size(text_layer_instructions);
  text_layer_set_size(text_layer_instructions, max_size_instructions);

  scroll_layer_set_content_size(scroll_layer, GSize(bounds.size.w, max_size_location.h + max_size_instructions.h + vert_scroll_text_padding));

  scroll_layer_add_child(scroll_layer, text_layer_get_layer(text_layer_location));
  scroll_layer_add_child(scroll_layer, text_layer_get_layer(text_layer_instructions));

  layer_add_child(window_layer, scroll_layer_get_layer(scroll_layer));
}

static void window_unload(Window *window) {
  text_layer_destroy(text_layer_location);
  text_layer_destroy(text_layer_instructions);
  scroll_layer_destroy(scroll_layer);
}

void update_info(Tuple *text_tuple) {
  text_layer_set_text(text_layer_instructions, text_tuple->value->cstring);
}

void info_init(void) {
  window = window_create();
  window_set_window_handlers(window, (WindowHandlers) {
    .load = window_load,
    .unload = window_unload
  });
  window_stack_push(window, true);
}

void info_deinit(void) {
  window_destroy(window);
}
