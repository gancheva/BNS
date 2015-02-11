#include <pebble.h>
#include "connector.h"
#include "info.h"
#include "menu.h"
#include "popup.h"


DictionaryIterator *iter;
enum {
  AKEY_NUMBER,
  AKEY_TEXT
};

void out_sent_handler(DictionaryIterator *sent, void *context) {
   // Outgoing message was delivered.
   // Handle the ACK by showing the popup window.
   show_popup();
}

void out_failed_handler(DictionaryIterator *failed, AppMessageResult reason, void *context) {
   // Outgoing message failed. If needed, this method can be used to handle the NACK. In this case this is not necessary. 
}

void in_received_handler(DictionaryIterator *received, void *context) {
   // Incoming message received.  
   // Check for fields you expect to receive.
   Tuple *text_tuple = dict_find(received, AKEY_TEXT);

   // Act on the found fields received.
   if (text_tuple) {
     //Update notification in info window.
     update_info(text_tuple);
   }
}

void in_dropped_handler(AppMessageResult reason, void *context) {
   // Incoming message dropped. If needed, this method can be used to handle the NACK. In this case this is not necessary. 
}

void send_message(void) {
  app_message_outbox_begin(&iter);

  Tuplet value = TupletCString(1, "ALARM");
  dict_write_tuplet(iter, &value);

  app_message_outbox_send();
}

void connector_init(void) {
   // Reduce the sniff interval for more responsive messaging at the expense of
   // increased energy consumption by the Bluetooth module
   // The sniff interval will be restored by the system after the app has been
   // unloaded
   app_comm_set_sniff_interval(SNIFF_INTERVAL_REDUCED);

   const uint32_t inbound_size = 64;
   const uint32_t outbound_size = 32;
   app_message_open(inbound_size, outbound_size);

   app_message_register_inbox_received(in_received_handler);
   app_message_register_inbox_dropped(in_dropped_handler);
   app_message_register_outbox_sent(out_sent_handler);
   app_message_register_outbox_failed(out_failed_handler);
}

void connector_deinit(void) {
   // Nothing to deinit!
}
