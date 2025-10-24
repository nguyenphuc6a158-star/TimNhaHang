#ifndef FLUTTER_MY_APPLICATION_H_
#define FLUTTER_MY_APPLICATION_H_

#include <gtk/gtk.h>

G_DECLARE_FINAL_TYPE(MyApplication, timnhahanglication, MY, APPLICATION,
                     GtkApplication)

/**
 * timnhahanglication_new:
 *
 * Creates a new Flutter-based application.
 *
 * Returns: a new #MyApplication.
 */
MyApplication* timnhahanglication_new();

#endif  // FLUTTER_MY_APPLICATION_H_
