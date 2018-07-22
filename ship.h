/* Header file for ship.c */

#ifndef _SHIP_H
#define _SHIP_H

#include "bitmap.h"
#include "game_screen.h"
#include "missiles.h"

#define SHIP_JOYSTICK 0
#define SHIP_MOUSE 1
#define SHIP_KEYBOARD 2
#define SHIP_PICTURES 5

typedef struct {
  int x, y;
} _coord, *coord;

typedef struct {
  int pause;
  int x;
  missiles missiles;
  bitmap ship_bitmaps[SHIP_PICTURES];
  game_screen g;
  int control_mode;
  int last_dir;
  int number;
  int refresh_number;
  int active;
  int frames_till_death;
  int death_frame_pause;
  int skip;
} _ship, *ship;

ship ship_open(game_screen g, int mode);
void ship_close(ship s);
void ship_draw(ship s, int x, int y);
int ship_update(ship s);
int ship_number(ship s);
void ship_shoot_at_ship(void *s, void *m);
void ufo_shoot_at_ufo(void *u, void *m);
int ship_inform(ship s, void (*f)(void *, void *), void *p);
void ship_reset(ship s);
void ship_add(ship s);
void ship_go(ship s);
void ship_complete_reset(ship s);
int ship_skip_round(ship s);

#endif
