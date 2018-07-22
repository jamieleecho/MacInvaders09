#ifndef _ROUND_H
#define _ROUND_H

#include "game_screen.h"

typedef struct {
	game_screen screen;
	char round;
} _round_t, *round_t;

round_t round_create(game_screen g);
void round_destroy(round_t r);
void round_reset(round_t r);
void round_increment(round_t r, int step);
void round_draw(round_t r);
int round_get(round_t r);

#endif

