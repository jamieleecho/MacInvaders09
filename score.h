#ifndef _SCORE_H
#define _SCORE_H

#include "game_screen.h"

typedef struct {
  game_screen screen;
  int score;
  int extra_guy;
  int xscore;
} _score, *score;


score score_create(game_screen g);
void score_display(score s);
void score_add(score s, int a);
void score_reset(score s);
void score_destroy(score s);
void score_reset_extra_guy_flag(score s);
int score_extra_guy(score s);

#endif
