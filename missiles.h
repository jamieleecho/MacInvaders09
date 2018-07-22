#ifndef _MISSILES_H
#define _MISSILES_H

#include "game_screen.h"

#define MISSILE_UP 1
#define MISSILE_DOWN 2
#define MISSILE_INFORM_MAX 6

typedef struct {
  void *p;
  void (*f)(void *, void *);
  int active;
} inform;

typedef struct {
  int start_y;
  int size;
  int x;
  int y;
  int active;
  int direction;
  int damage;
} _missile, *missile;


typedef struct {
  game_screen screen;
  missile missiles;
  int shoot_delay;
  int counter;
  int max;
  inform informs[MISSILE_INFORM_MAX];
  int pause;
  int number_active;
  int color;
} _missiles, *missiles;

missiles missiles_create(game_screen g, int max, int shoot_delay, int color);
void missiles_destroy(missiles m);
void missiles_reset(missiles m);
int missiles_fire(missiles m, int direction, int x, int y, int size);
void missiles_update(missiles m);
int missiles_inform(missiles m, void (*f)(void *, void *), void *p);
void missiles_kill(missiles m, int i);
void missiles_damage(missiles m, int i);
void missiles_pause(missiles m);
void missiles_unpause(missiles m);
int missiles_count(missiles m);
void missiles_limit(missiles m, int n);

#endif
