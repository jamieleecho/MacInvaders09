/*
   This file contains ufo stuff . . .
*/

#include <stdio.h>
#include "game_screen.h"
#include "bitmap.h"
#include "ufo.h"
#include "missiles.h"
#include "soundfx.h"
#include "myrand.h"


#define UFO_BOMB_SIZE 2
#define UFO_DEATH_FRAMES_PAUSE 5
#define UFO_MISSILE_WAIT_TIME 2000
#define UFO_REGENERATE_DIVISOR 300
#define UFO_VALUE 200
#define UFO_Y 0
#define UFO_MISSILES 1
#define UFO_SHOOT_DELAY 100
#define UFO_MAX_LEFT 10
#define UFO_MAX_RIGHT 300
#define UFO_Y_SIZE 10
#define UFO_X_SIZE 15
#define UFO_X_DELTA 2
#define MISSILE_COLOR 16

static soundfx snd = NULL;

/*
   If a failure occurs, returns NULL. Otherwise creates and returns
   ufo data.
*/
ufo ufo_create(game_screen g, round_t r, score s)
{
  ufo new;
  int ii, jj;

  if (snd == NULL)
    if ((snd = soundfx_load("uexpl.iff")) == NULL)
      return(NULL);
  
  /* Alocate memory for the new UFO */
  new = (ufo)malloc(sizeof(_ufo));
  if (new == NULL)
    return (NULL);
  
  /* Load in the UFO bitmap */
  new->ufo_bitmaps[UFO_FRAMES-1] = bitmap_create("ufo");
  if (new->ufo_bitmaps[UFO_FRAMES-1] == NULL) {
  	free(new);
  	return(NULL);
  }

  /* Fade the ufo bitmap */
  for (jj=0, ii=UFO_FRAMES-2; ii>=0; ii--, jj++) {
  	new->ufo_bitmaps[ii] = bitmap_copy_fade(new->ufo_bitmaps[ii + 1], jj);
  	if (new->ufo_bitmaps[ii] == NULL) {
  	  for (jj=ii-1; jj >= 0; jj--)
  	    bitmap_destroy(new->ufo_bitmaps[jj]);
  	  free(new);
  	  return(NULL);
    }
  }	    

  /* Make a bomb */
  new->bomb = missiles_create(g, UFO_MISSILES, UFO_SHOOT_DELAY, MISSILE_COLOR);
  if (new->bomb == NULL) {
  	for (jj=0; jj<UFO_FRAMES; jj++)
  	  bitmap_destroy(new->ufo_bitmaps[jj]);
  	free(new);
  	return(NULL);
  }
  
  /* Set the other fields */
  new->screen = g;
  new->x = UFO_MAX_LEFT;
  new->y = UFO_Y;
  new->active = 1;
  new->direction = UFO_RIGHT;
  new->current_frame = UFO_FRAMES-1;
  new->wait = myrand()/UFO_REGENERATE_DIVISOR;
  new->round = r;
  new->score = s;
  new->fire = 1;
  
  /* All done */
  return(new);
}

/*
  Frees the resources used by u.
*/
void ufo_destroy(ufo u)
{
  int jj;
  
  if (u == NULL)
    return;
  
  for (jj=0; jj<UFO_FRAMES; jj--)
    bitmap_destroy(u->ufo_bitmaps[jj]);
  missiles_destroy(u->bomb);
  free(u);
}

/*
  Draws the ufo u at (x, y). Updates the ufo parameters so that it is
  located at (x, y);
*/
void ufo_draw(ufo u, int x, int y)
{
  /* Make sure we are within the drawing area */
  u->x = x % 320;
  u->y = y % 192;
  
  /* Draw the bitmap */
  game_screen_bitmap(u->screen, u->ufo_bitmaps[UFO_FRAMES-1], u->x, u->y);
}

/*
  Updates the UFO position and puts it on the screen.
*/
void ufo_update(ufo u)
{
  /* If the ufo is not active, figure out what frame to display.
     Also see if we have to reset UFO . . . */
  if (!(u->active)) {
    if ( (u->death_frames_pause == 0) && (u->current_frame == 0) ) { /* Should we reset UFO? */
      u->active = 1;
      u->wait = myrand()/UFO_REGENERATE_DIVISOR;
      u->current_frame = UFO_FRAMES-1;
      if (myrand() >= 32767) {
        u->direction = UFO_RIGHT;
        u->x = UFO_MAX_RIGHT;
      }
      else {
        u->direction = UFO_LEFT;
        u->x = UFO_MAX_LEFT;
      }
    }
    else {
      if (u->death_frames_pause == 0) {
        u->death_frames_pause = UFO_DEATH_FRAMES_PAUSE;
        u->current_frame--;
      }
      else
        u->death_frames_pause--;
    }
  }

  /* Update the ufo's bomb */
  missiles_update(u->bomb);
  if ((u->wait <= 0) && (myrand() <= UFO_MISSILE_WAIT_TIME))
    if (u->fire)
      missiles_fire(u->bomb, MISSILE_DOWN, u->x, 12, UFO_BOMB_SIZE);
 
  /* Go right or left. If we hit the end, switch directions */
  if (u->wait > 0) {
    u->wait--;
    return;
  }
  
  if (u->direction == UFO_LEFT) {
  	if (u->x <= UFO_MAX_LEFT) {
  	  u->direction = UFO_RIGHT;
   	  game_screen_bitmap(u->screen, u->ufo_bitmaps[0], u->x, u->y);
      u->wait = myrand()/UFO_REGENERATE_DIVISOR;
      return;
    }
  	else {
  	  game_screen_block(u->screen, 0, u->x+UFO_X_SIZE-UFO_X_DELTA, u->y, u->x+UFO_X_SIZE, u->y+UFO_Y_SIZE);
      u->x-=UFO_X_DELTA;
    }
  }
  else {
  	if (u->x >= UFO_MAX_RIGHT) {
  	  u->direction = UFO_LEFT;
  	  game_screen_bitmap(u->screen, u->ufo_bitmaps[0], u->x, u->y);
      u->wait = myrand()/UFO_REGENERATE_DIVISOR;
      return;
    }
  	else {
   	  game_screen_block(u->screen, 0, u->x, u->y, u->x+UFO_X_DELTA, u->y+UFO_Y_SIZE);
  	  u->x+=UFO_X_DELTA;
  	}
  }
  
  /* Draw the bitmap */
  game_screen_bitmap(u->screen, u->ufo_bitmaps[u->current_frame], u->x, u->y);
}

/*
  If successful, causes u to call f(p, m) when m is updated where m
  is the missiles of u. Returns 1 on success and zero on failure. */
int ufo_inform(ufo u, void (*f)(void *, void *), void *p)
{
  return(missiles_inform(u->bomb, f, p));
}


/* u must be a valid ufo and m must be a valid missiles. If a missile
   in m has hit u, blows u up. */
void ufo_shoot_at_ufo(void *u, void *m)
{
  register int ii;
  register missile current_missile;
  
  /* Already hit??? */ 
  if ( (((ufo) u)->active == 0) || (((ufo) u)->wait > 0) )
    return;

  /* Check each active missile in m to see if it is hitting s */
  for (ii = 0; ii < ((missiles)m)->max; ii++) {
  	/* If the missile is inactive, skip to the next one. */
    if (!((missiles)m)->missiles[ii].active)
      continue;

	/* Figure out the vertical position of the missile */
	current_missile = &((missiles)m)->missiles[ii];

	/* Assume only up going missiles will hit ufo. Do a quickie
	   test to see if it might be hit */
	if (current_missile->y > ((ufo)u)->ufo_bitmaps[UFO_FRAMES-1]->y + ((ufo) u)->y)
	  continue;

	/* Check for collisions */
	if (bitmap_block_collision(((ufo)u)->ufo_bitmaps[UFO_FRAMES-1], ((ufo)u)->x, ((ufo)u)->y, current_missile->x, current_missile->y, 2, current_missile->size)) {
	  ((ufo) u)->active = 0;
	  ((ufo) u)->death_frames_pause = UFO_DEATH_FRAMES_PAUSE;
	  score_add(((ufo) u)->score, UFO_VALUE);
	  score_display(((ufo) u)->score);
	  missiles_kill(m, ii);
	  soundfx_play(((ufo)u)->screen, snd);
    }
  }

  /* All done. (No Collision) */
  return;
}


/* Resets the UFO to a starting state. */
void ufo_reset(ufo u)
{
  int ii;
  
  for (ii=0; ii<UFO_MISSILES; ii++)
    missiles_kill(u->bomb, ii);
  game_screen_bitmap(u->screen, u->ufo_bitmaps[0], u->x, u->y);
  u->x = UFO_MAX_LEFT;
  u->y = UFO_Y;
  u->active = 1;
  u->direction = UFO_RIGHT;
  u->current_frame = UFO_FRAMES-1;
  u->wait = myrand()/UFO_REGENERATE_DIVISOR;
  u->fire = 1;
}

void ufo_cease_fire(ufo u)
{
  u->fire = 0;
}

void ufo_resume_fire(ufo u)
{
 u->fire = 1;
}

int ufo_no_missiles(ufo u)
{
  return(!missiles_count(u->bomb));
}

