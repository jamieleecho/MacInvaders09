#ifndef _GAME_SCREEN_H
#define _GAME_SCREEN_H

#include "bitmap.h"

typedef struct {
  void *winController;
  char *start;
  char *end;
  int bgcolor, fgcolor;
  int is_dirty;
} _game_screen, *game_screen;


typedef struct {
	unsigned char r;
	unsigned char g;
	unsigned char b;
} rgb;

  
game_screen game_screen_open(rgb color[256]);
void game_screen_close(game_screen g);
void game_screen_print(game_screen g, int x, int y, char *text);
void game_screen_color(game_screen g, int background, int foreground);
void game_screen_cls(game_screen g);
void game_screen_cool_cls0(game_screen g, int y1, int y2, int a);
void game_screen_cool_clrblk0(game_screen g, int x1, int y1, int x2, int y2);
int game_screen_chars_in_buffer(game_screen g);
char game_screen_get_char(game_screen g);
void game_screen_bitmap(game_screen g, bitmap b, int x, int y);
void game_screen_block(game_screen g, int c, int x0, int y0, int x1, int y1);
void game_screen_line(game_screen g, int x0, int y0, int x1, int y1);
void game_screen_point(game_screen g, int x0, int y0);
void game_screen_pset(game_screen g, int x, int y, int c);
void game_screen_flush(game_screen g);
void game_screen_pause(game_screen g);
int game_screen_is_paused(game_screen g);
void game_screen_quit(game_screen g);

#endif
