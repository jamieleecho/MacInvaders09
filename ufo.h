#ifndef _UFO_H
#define _UFO_H

#include "game_screen.h"
#include "bitmap.h"
#include "missiles.h"
#include "score.h"
#include "round.h"

#define UFO_RIGHT 0
#define UFO_LEFT 1
#define UFO_FRAMES 5

typedef struct {
  game_screen screen;
  bitmap ufo_bitmaps[UFO_FRAMES];
  int x, y;
  int active;
  int pix_num;
  int direction;
  missiles bomb;
  int death_frames_pause;
  int current_frame;
  int wait;
  score score;
  round_t round;
  int fire;
} _ufo, *ufo;

ufo ufo_create(game_screen g, round_t r, score s);
void ufo_destroy(ufo u);
void ufo_draw(ufo u, int x, int y);
void ufo_update(ufo u);
int ufo_inform(ufo u, void (*f)(void *, void *), void *p);
void ufo_reset(ufo u);
void ufo_cease_fire(ufo u);
void ufo_resume_fire(ufo u);
int ufo_no_missiles(ufo u);

#endif

