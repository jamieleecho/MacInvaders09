#ifndef _INVADERS_H
#define _INVADERS_H

#include "game_screen.h"
#include "bitmap.h"
#include "missiles.h"
#include "round.h"
#include "score.h"

#define INVADERS_X 10
#define INVADERS_Y 5

typedef struct {
	int x;
	int y;
} cart;

typedef struct {
	bitmap_list frame;
	int framenum;
	cart position[INVADERS_X][INVADERS_Y];
	game_screen screen;
	int left_right; /* moving:0=right, 1=left */
	int next_move; /* moving:0=right, 1=left */
	int is_alive[INVADERS_X][INVADERS_Y];
	int current_frames[INVADERS_Y];
	int go_down[INVADERS_Y];
	int RowCount[INVADERS_Y];
    int RowY[INVADERS_Y];
	int to_update;
	missiles missiles;
	round_t round;
	score score;
	int number;
	int fire;
	int maxY;
} _invaders, *invaders;

invaders invaders_open(game_screen g, round_t r, score s);
void invaders_close(invaders i);
void invaders_display(invaders i);
void invaders_update(invaders i);
int invaders_inform(invaders i, void (*f)(void *, void *), void *p);
void invaders_shoot_at_invaders(void *i, void *m);
int invaders_number(invaders i);
void invaders_restore(invaders i);
void invaders_reset(invaders i);
void invaders_cease_fire(invaders i);
void invaders_resume_fire(invaders i);
int invaders_no_missiles(invaders i);
int invaders_maxy(invaders i);
	
#endif
