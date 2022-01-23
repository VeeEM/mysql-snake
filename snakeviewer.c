#include <stdio.h>
#include <mysql.h>
#include <unistd.h>
#include <gtk/gtk.h>
#include <bsd/string.h>
#include <pthread.h>

#define DB_ADDRESS "localhost"
#define DB_NAME "db_name"
#define DB_USER "mysql_user"
#define DB_PASSWORD "mysql_password"

// All MySQL contact is done through this connection.
MYSQL *conn = NULL;

void exit_with_error(char *);
int update_text(gpointer);
void *update_text_thread(void *);
char *get_game_text();
void app_activate(GApplication *app, gpointer user_data);
int main(int, char**);

void exit_with_error(char *comment) {
  fprintf(stderr, "%s\n%s\n", mysql_error(conn), comment);
  mysql_close(conn);
  exit(1);
}

// Retrieve new game text from database and display it in the 
// TextView received as argument.
int update_text(gpointer tv_ptr) {
  GtkTextView *tv = GTK_TEXT_VIEW(tv_ptr);
  GtkTextBuffer *tb = gtk_text_view_get_buffer(tv);
  char *new_text = get_game_text();
  gtk_text_buffer_set_text(tb, new_text, -1);
  free(new_text);
  return 0;
}

void *update_text_thread(void *vargp) {
  GtkTextView *tv = GTK_TEXT_VIEW(vargp);
  while (1) {
    usleep(250 * 1000);
    g_idle_add(update_text, tv);
  }
}

// Fetch game text from database.
char *get_game_text() {
  if (mysql_query(conn, "CALL renderGame();")) {
    exit_with_error("Could not call MySQL procedure renderGame.");
  }
  MYSQL_RES *result = mysql_store_result(conn);
  if (result == NULL) {
    exit_with_error("Store result");
  }

  char *column_str = mysql_fetch_row(result)[0];
  unsigned long column_length = mysql_fetch_lengths(result)[0];
  char *retval = malloc(sizeof(char) * column_length);
  strlcpy(retval, column_str, column_length);

  mysql_free_result(result);
  // mysql_next_result must be called after CALLing a stored procedure
  // a 0 will be returned indicating that another result is available.
  // That result should be empty and mysql_store_result does not have
  // to be called here.
  mysql_next_result(conn);
  
  return retval;
}

void app_activate(GApplication *app, gpointer user_data) {
  GtkWidget *win;
  GtkWidget *tv;
  
  win = gtk_application_window_new(GTK_APPLICATION(app));
  gtk_window_set_title(GTK_WINDOW(win), "Snake Viewer");
  
  tv = gtk_text_view_new();
  gtk_text_view_set_editable(GTK_TEXT_VIEW(tv), 0);
  gtk_text_view_set_cursor_visible(GTK_TEXT_VIEW(tv), 0);

  gtk_window_set_child(GTK_WINDOW(win), tv);

  gtk_widget_show(win);

  GtkStyleContext *tv_style_context = gtk_widget_get_style_context(tv);
  GtkCssProvider *css_provider = gtk_css_provider_new();
  char* style_str = "textview { font-size: 24px; min-width: 300px; }";
  gtk_css_provider_load_from_data(css_provider, style_str, strlen(style_str));
  
  // Last argument to gtk_style_context_add_provider is guint priority
  // "Typically this will be in the range
  // GTK_STYLE_PROVIDER_PRIORITY_FALLBACK and GTK_STYLE_PROVIDER_PRIORITY_USER"
  gtk_style_context_add_provider(tv_style_context, GTK_STYLE_PROVIDER(css_provider), 600);

  pthread_t thread_id;
  pthread_create(&thread_id, NULL, update_text_thread, (void *)tv);
  
}

int main(int argc, char **argv) {
  conn = mysql_init(NULL);
  if (conn == NULL) {
    exit_with_error("Failed to initialize MySQL connection.");
  }
  if (mysql_real_connect(conn, DB_ADDRESS, DB_USER, DB_PASSWORD, 
			 DB_NAME, 0, NULL, 0) == NULL) {
    exit_with_error("Failed to connect to snake database.");
  }
  
  GtkApplication *app;
  int stat;

  app = gtk_application_new("com.github.VeeEM.mysql-snake-viewer", G_APPLICATION_FLAGS_NONE);
  g_signal_connect(app, "activate", G_CALLBACK(app_activate), NULL);
  stat = g_application_run(G_APPLICATION(app), argc, argv);
  g_object_unref(app);

  mysql_close(conn);
  return stat;
}
