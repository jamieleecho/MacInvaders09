/*
   This file contains routines that control the ship of the
   good guy.
*/


#include <stdio.h>
#include "ship.h"
#include "game_screen.h"
#include "bitmap.h"
#include "missiles.h"
#include "soundfx.h"

#define Y_POS 168
#define MAX_LEFT 4
#define MAX_RIGHT 300

#define SHIP_LEFT 0
#define SHIP_RIGHT 1
#define SHIP_STILL 2

#define SHIP_MISSILES 3
#define SHIP_MISSILE_SIZE 10
#define SHIP_MISSILE_DELAY (SHIP_MISSILE_SIZE * 2)
#define SHIP_MISSILE_OFFSET 7
#define SHIP_NUMBER 3
#define SHIP_DEATH_FRAME_PAUSE 5

#define SHIP_X_SIZE 16
#define SHIP_Y_SIZE 12
#define SHIP_DELTA 3

#define SHIP_LEFT_KEY 2
#define SHIP_RIGHT_KEY 6
#define SHIP_FIRE ' '

#define MISSILE_COLOR 17

static void wait_around(game_screen g);

static soundfx snd = NULL;
static soundfx snd2 = NULL;

/*
   If an error occurs, returns NULL. Otherwise creates and
   returns a ship data. On success, a non-NULL value is returned.
   The ship movement is on the line y=Y_POS
   where y refers to the top portion of the ship bitmap. The ship
   can be moved left to x=MAX_LEFT and right to x=MAX_RIGHT where each coordinate
   refers to the extreme values of the left side of the bitmap. The
   ship is initially NOT displayed on g. The internal position
   of the ship is initialized to the middle. Mode sets the inputs
   means for the ship. It can be SHIP_MOUSE or SHIP_KEYBOARD. Other
   values can lead to unpredictable results.
*/
ship ship_open(game_screen g, int mode)
{
  ship new;
  int i, j;
  
  if (snd == NULL) {
  	snd = soundfx_load("expl.iff"); 
  	if (snd == NULL) return(NULL);
  }

  if (snd2 == NULL) {
  	snd2 = soundfx_load("wohoo.iff"); 
  	if (snd2 == NULL) return(NULL);
  }

  /* Allocate memory for the new ship */
  new = (ship)malloc(sizeof(_ship));
  if (new == NULL)
    return(NULL);

  /* Allocate memory for missiles */
  new->missiles = missiles_create(g, SHIP_MISSILES, SHIP_MISSILE_DELAY, MISSILE_COLOR);
  if (new->missiles == NULL) {
  	free(new);
  	return(NULL);
  }
  
  /* Get the ship bitmap */
  new->ship_bitmaps[SHIP_PICTURES-1] = (bitmap)bitmap_create("ship");
  if (new->ship_bitmaps[SHIP_PICTURES-1] == NULL) {
  	free(new);
  	missiles_destroy(new->missiles);
  	return(NULL);
  }

  /* Fade the retrieved bitmap */
  for (j=0,i=SHIP_PICTURES-2; i>=0; i--, j++) {
    new->ship_bitmaps[i] = bitmap_copy_fade(new->ship_bitmaps[i+1], j);
    if (new->ship_bitmaps[i] == NULL) {
      for (i=i-1; i<SHIP_PICTURES; i++)
        bitmap_destroy(new->ship_bitmaps[i]);
      return(NULL);
    }
  }
  
  /* initialize fields */
  new->g = g;
  new->x = MAX_LEFT + (MAX_RIGHT - MAX_LEFT)/2;
  new->control_mode = mode;
  new->last_dir = SHIP_STILL;  
  new->number = SHIP_NUMBER;
  new->refresh_number = 1;
  new->active = 1;
  new->pause = 0;
  new->skip = 0;
  return(new);
}


/*
   If s is NULL, returns with no effect. Otherwise frees the resources
   used by s and returns.
*/
void ship_close(ship s)
{
  int ii;
  
  if (s == NULL)
    return;
    
  for (ii=0; ii<SHIP_PICTURES; ii++)
    bitmap_destroy(s->ship_bitmaps[ii]);

  missiles_destroy(s->missiles);
  free(s);
  return;
}

/*
   Displays the ship at x, y.
*/
void ship_draw(ship s, int x, int y)
{
  game_screen_bitmap(s->g, s->ship_bitmaps[SHIP_PICTURES-1], x, y);
}

/*
   Reads user input, updates the ship and draws the ship
   in its new location. Returns true if the ship was just hit.  
*/
int ship_update(ship s)
{
  int cnum, c;
  int move, shoot;

  /* Update the ship's missiles */
  missiles_update(s->missiles);

  if (s->pause) {
    if (s->death_frame_pause > 0) {
     	s->death_frame_pause--;
      }
    return(1);
  }

  /* If the ship is inactive then we don't allow further movement.
     furthermore, we have to start fading the ship. */
  if (!s->active) {
  	/* Are we completely faded? */
    if (s->frames_till_death == 0) {
      s->refresh_number = 1;
      s->number--;
      s->x = MAX_LEFT + (MAX_RIGHT - MAX_LEFT)/2;
      s->active = 1;
      s->last_dir = SHIP_STILL;  
      return(0);
    }
    game_screen_bitmap(s->g, s->ship_bitmaps[s->frames_till_death], s->x, Y_POS);
    if (--s->death_frame_pause == 0) {
      s->frames_till_death--;
      s->death_frame_pause = SHIP_DEATH_FRAME_PAUSE;
      if (s->frames_till_death == 0) {
        game_screen_block(s->g, 0, s->x, Y_POS, s->x+SHIP_X_SIZE, Y_POS + SHIP_Y_SIZE);
        s->pause = 1;
      }
    }
    return(s->frames_till_death == 0);
  }
    
  /* Update the number of ships . . . if we have to */
  if (s->refresh_number) {
    ship_number(s);
    s->refresh_number = 0;
  } 
 
  /* Don't shoot, by default */
  shoot = 0;

  move = s->last_dir;
  if (s->control_mode  == SHIP_KEYBOARD) {
    /* Flush the keyboard input */
    if (game_screen_chars_in_buffer(s->g) < 0)
      move = s->last_dir;
    else {
      for (cnum=game_screen_chars_in_buffer(s->g); cnum>1;cnum--)
        game_screen_get_char(s->g);
      /* Are we going left or right ??? */
      c = game_screen_get_char(s->g);
      if ((c == 'p') || (c == 'P') || (c == 27)) game_screen_pause(s->g);
      if (c == SHIP_LEFT_KEY)
        move = SHIP_LEFT;
      else if (c == SHIP_RIGHT_KEY)
        move = SHIP_RIGHT;
      else if (c == SHIP_FIRE)
        shoot = 1;
      else if ((c == 'p') || (c == 'P'))
        wait_around(s->g);
      else if (c == '*')
        s->skip = 1;
      else
        move = SHIP_STILL;
     }
  }

  /* Should we shoot a missile? */
  if (shoot)
    missiles_fire(s->missiles, MISSILE_UP, s->x + SHIP_MISSILE_OFFSET, Y_POS, SHIP_MISSILE_SIZE);

  s->last_dir = move;
  if (move == SHIP_LEFT) {
    if (s->x > MAX_LEFT) {
      game_screen_block(s->g, 0, s->x+SHIP_X_SIZE-SHIP_DELTA, Y_POS, s->x+SHIP_X_SIZE, Y_POS+SHIP_Y_SIZE);
	  s->x -= SHIP_DELTA;
	}
  }
  else if (move == SHIP_RIGHT) {
    if (s->x < MAX_RIGHT) {
      game_screen_block(s->g, 0, s->x, Y_POS, s->x+SHIP_DELTA, Y_POS+SHIP_Y_SIZE);
  	  s->x += SHIP_DELTA;
    }
  }

  /* Display the bitmap */
  game_screen_bitmap(s->g, s->ship_bitmaps[SHIP_PICTURES-1], s->x, Y_POS);
        
  return(0);
}


/*
   Displays the number of available ships.
*/
int ship_number(ship s)
{
  char temp[10];
  if (s->number < 0)
    s->number = 0;
  if (s->number > 9)
    s->number = 9;
  sprintf(temp, "Lives %2d", s->number);
  game_screen_color(s->g, 0, 192);
  game_screen_print(s->g, 30, 23, temp);
  return(s->number);
}

/* Increases the number of lives of s by one (if possible). */
void ship_add(ship s)
{
  s->number++;
  if (s->number > 9)
    s->number=9;
  ship_number(s);
  soundfx_wait_and_play(s->g, snd2);
}

/*
   Blows up the ship if any of the missiles in m hit it. Note
   that s is assumed to be a valid ship and m a valid missiles.
*/
void ship_shoot_at_ship(void *s, void *m)
{
  register int ii;
  register missile current_missile;
  
  /* If we are not active, do nothing. */
  if (!((ship) s)->active) return; 

  /* Check each active missile in m to see if it is hitting s */
  for (ii = 0; ii < ((missiles)m)->max; ii++) {
  	/* If the missile is inactive, skip to the next one. */
    if (!((missiles)m)->missiles[ii].active)
      continue;

	/* Figure out the vertical position of the missile */
	current_missile = &((missiles)m)->missiles[ii];

	/* Assume only down going missiles will hit ship. Do a quickie
	   test to see if we might be hit */
	if (current_missile->y < Y_POS)
	  continue;

	/* Check for collisions */
	if (bitmap_block_collision(((ship)s)->ship_bitmaps[SHIP_PICTURES-1], ((ship)s)->x, Y_POS, current_missile->x, current_missile->y, 2, current_missile->size)) {
	  soundfx_wait_and_play(((ship) s)->g, snd);
	  ((ship)s)->active = 0;
	  ((ship)s)->frames_till_death = SHIP_PICTURES-2;
	  ((ship)s)->death_frame_pause = SHIP_DEATH_FRAME_PAUSE;
	  missiles_kill(m, ii);
	  continue;
    }
	  
  }
  
  /* All done. (No collision) */
  return;
}

/* If successful, causes s to call f(p, m) when m is updated where m
   is the missiles of s. Returns 1 on success and zero on failure.   */
int ship_inform(ship s, void (*f)(void *, void *), void *p)
{
  return(missiles_inform(s->missiles, f, p));
}


/* Resets the ship to a starting state. */
void ship_reset(ship s)
{
  int ii;

  game_screen_block(s->g, 0, s->x, Y_POS, s->x+SHIP_X_SIZE, Y_POS+SHIP_Y_SIZE);
  
  /* Make sure all of the missiles are killed . . . */
  for (ii=0; ii<SHIP_MISSILES; ii++)
    missiles_kill(s->missiles, ii);

  s->x = MAX_LEFT + (MAX_RIGHT - MAX_LEFT)/2;
  s->last_dir = SHIP_STILL;  
  s->refresh_number = 1;
  s->active = 1;
  s->pause = 0;
  s->last_dir = SHIP_STILL;  
}


void ship_go(ship s)
{
  s->pause = 0;
}


static void wait_around(game_screen g)
{
  game_screen_flush(g);
  game_screen_get_char(g);
}

void ship_complete_reset(ship s)
{
  int ii;

  game_screen_block(s->g, 0, s->x, Y_POS, s->x+SHIP_X_SIZE, Y_POS+SHIP_Y_SIZE);
  
  /* Make sure all of the missiles are killed . . . */
  for (ii=0; ii<SHIP_MISSILES; ii++)
    missiles_kill(s->missiles, ii);

  s->x = MAX_LEFT + (MAX_RIGHT - MAX_LEFT)/2;
  s->last_dir = SHIP_STILL;  
  s->refresh_number = 1;
  s->active = 1;
  s->pause = 0;
  s->number = SHIP_NUMBER;
}

int ship_skip_round(ship s) 
{
  int ret_val = s->skip;
  s->skip = 0;
  return ret_val;
}

