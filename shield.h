#ifndef _SHIELD_H
#define _SHIELD_H

#include "game_screen.h"
#include "bitmap.h"

typedef struct {
  bitmap shield_bitmap;
  game_screen screen;
  int x, y;
  char *image;
} _shield, *shield;

shield shield_create(game_screen g);
void shield_destroy(shield s);
void shield_draw(shield s, int x, int y);
void shield_missile_hit(void *sh, void *ms);
void shield_disable(shield s);
int shield_missile_collide(shield s, int x0, int y0, int dx, int dy);

#endif
