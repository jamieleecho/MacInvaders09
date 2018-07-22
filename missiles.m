/*
  This file contains missile stuff.
*/

#include <stdio.h>
#include "game_screen.h"
#include "missiles.h"
#include "soundfx.h"

#define MAX_Y 178
static soundfx snd = NULL;

/*
   This creates a missile structure. Missiles are displayed on game_screen
   g. max refers to the absolute maximum number of missiles that can be
   fired at a time. shoot_delay is the minumium amount of times that
   missile_update must be called before a new missile can be fired.
   Returns NULL on a failure.
*/
missiles missiles_create(game_screen g, int max, int shoot_delay, int color)
{
  missiles new;
  int i;
  
  if (snd == NULL)
    if (NULL == (snd = soundfx_load("rdrip.iff")))
      return(NULL);

  /* Allocate memory for the missiles */
  new = (missiles)malloc(sizeof(_missiles));
  if (new == NULL)
    return(NULL);
  new->missiles = (_missile *)calloc(sizeof(_missile), max);
  if (new->missiles == NULL) {
  	free(new);
  	return(NULL);
  }

  /* Make all of the missiles inactive */
  for (i=0; i<max; i++)
    new->missiles[i].active = 0;

  /* Initialize other fields */
  new->shoot_delay = shoot_delay;
  new->counter = 0;
  new->number_active = new->max = max;
  new->screen = g;
  new->pause = 0;
  for (i=MISSILE_INFORM_MAX-1; i>=0; i--)
    new->informs[i].active = 0;
  new->color = color; 
 
  /* All Done !!! */
  return(new);
}


/*
   Frees the resources used by m.
*/
void missiles_destroy(missiles m)
{
  if (m == NULL)
    return;
  
  free(m->missiles);
  free(m);
}

/*
   Resets m to its original state.
*/
void misisles_reset(missiles m)
{
  int i;

  /* Make all of the missiles inactive */
  for (i=0; i<m->max; i++)
    m->missiles[i].active = 0;

  /* Initialize other fields */
  m->counter = 0;
  
  /* All done! */
  return;
}

/*
   This function prepares the missile data to fire a missile.
   If a missile is fired, it returns a 1. Otherwise, zero is
   returned. The directions argument specifies the direction
   the missile will travel. Valid values include MISSILE_UP
   and MISSILE_DOWN. The x and y arguments represent the coordinates
   from which the missile is fired. size is the vertical
   size of the missile in pixels.
*/
int missiles_fire(missiles m, int direction, int x, int y, int size)
{
  register int i;	

  /* First we have to make sure that we are ready to fire.
     The counter == 0 if we are.  */
  if (m->counter) return 0;  /* If non-zero, return */

  /* If pause is set, simply return */
  if (m->pause)
    return 0;
  
  /* Now we have to go through the missiles array and see
     if we can find an inactive missile. */
  for (i=0; i<m->number_active; i++)
    if (m->missiles[i].active == 0) break;
  if (i==m->number_active) return 0;
  
  /* Initialize the missile structure. */
  m->missiles[i].start_y = m->missiles[i].y = y;
  m->missiles[i].x = x;
  m->missiles[i].active = 1;
  m->missiles[i].direction = direction;
  m->missiles[i].size = size;
  m->missiles[i].damage = size>>1;
  
  /* Make sure to reset the missiles counter */
  m->counter = m->shoot_delay;
  
  soundfx_play(m->screen, snd);
  
  /* All done */
  return 1;
}
    
  
/* This function actually draws and updates the missiles on the
   missiles screen. May change the default fore/back ground colors
   of the game_screen. */
void missiles_update(missiles m)
{
  register int i;
  int erase_y, new_y;

  /* Call the informs functions */
  for (i=0; i<MISSILE_INFORM_MAX; i++)
    if (m->informs[i].active)
      m->informs[i].f(m->informs[i].p, m);
    	
  /* update the counter. */
  if (m->counter > 0) m->counter--;
  
  /* Go thru each missile, drawing and updating it if it is active. */
  for (i=0; i<m->max; i++) {
    if (m->missiles[i].active) {
      /* Calculate the next point to draw on the missile. */
      if (m->missiles[i].direction == MISSILE_UP) {
      	m->missiles[i].y -= 3;
        new_y = m->missiles[i].y;
      }
      else {
      	m->missiles[i].y += 3;
        new_y = m->missiles[i].y;
      }

      /* Calculate the next point to erase. */
      if (abs(new_y - m->missiles[i].start_y) < m->missiles[i].size)
        erase_y = -1;
      else
        erase_y = (m->missiles[i].direction == MISSILE_UP) ? m->missiles[i].y + m->missiles[i].size : m->missiles[i].y - m->missiles[i].size;

	  /* Hack. Make sure new_y <= MAX_Y */
	  if (new_y > MAX_Y)
	    new_y = -1;
      
      /* Set/reset the points */
      if (m->missiles[i].direction == MISSILE_UP) {
        game_screen_pset(m->screen, m->missiles[i].x, new_y, m->color);
        game_screen_pset(m->screen, 1+m->missiles[i].x, new_y+1, m->color);
        game_screen_pset(m->screen, m->missiles[i].x, new_y+1, m->color);
        game_screen_pset(m->screen, 1+m->missiles[i].x, new_y+2, m->color);
        game_screen_pset(m->screen, m->missiles[i].x, new_y+2, m->color);
        game_screen_pset(m->screen, 1+m->missiles[i].x, new_y, m->color);        
        game_screen_pset(m->screen, m->missiles[i].x, erase_y, 0);
        game_screen_pset(m->screen, 1+m->missiles[i].x, erase_y, 0);
        game_screen_pset(m->screen, m->missiles[i].x, erase_y+1, 0);
        game_screen_pset(m->screen, 1+m->missiles[i].x, erase_y+1, 0);
        game_screen_pset(m->screen, m->missiles[i].x, erase_y+2, 0);
        game_screen_pset(m->screen, 1+m->missiles[i].x, erase_y+2, 0);
      }
      else {
        game_screen_pset(m->screen, m->missiles[i].x, new_y-2, m->color);
        game_screen_pset(m->screen, 1+m->missiles[i].x, new_y-2, m->color);
        game_screen_pset(m->screen, m->missiles[i].x, new_y-1, m->color);
        game_screen_pset(m->screen, 1+m->missiles[i].x, new_y-1, m->color);
        game_screen_pset(m->screen, m->missiles[i].x, new_y, m->color);
        game_screen_pset(m->screen, 1+m->missiles[i].x, new_y, m->color);
        game_screen_pset(m->screen, m->missiles[i].x, erase_y, 0);
        game_screen_pset(m->screen, 1+m->missiles[i].x, erase_y, 0);
        game_screen_pset(m->screen, m->missiles[i].x, erase_y-1, 0);
        game_screen_pset(m->screen, 1+m->missiles[i].x, erase_y-1, 0);
        game_screen_pset(m->screen, m->missiles[i].x, erase_y-2, 0);
        game_screen_pset(m->screen, 1+m->missiles[i].x, erase_y-2, 0);
      }

      /* The missile may not be on the screen. If so, disable it */
      if ( (m->missiles[i].direction == MISSILE_UP) && (new_y <= -(m->missiles[i].size + 3)) )
        m->missiles[i].active = 0;
      else if ( (erase_y >= MAX_Y) )
        m->missiles[i].active = 0;
    }
  }
}

/*
  If successful, causes m to call f(p, m) when m is updated. Returns
  1 on success and zero on failure. */
int missiles_inform(missiles m, void (*f)(void *, void *), void *p)
{
  int ii;
  
  /* If these is an inform available, fill it and return 1.
     Otherwise return 0 */
  for (ii = 0; ii<MISSILE_INFORM_MAX; ii++) {
    if (m->informs[ii].active == 0) {/* not active --> available */
      m->informs[ii].f = f;
      m->informs[ii].p = p;
      m->informs[ii].active = 1;
      return (1);
    }
  }

  /* Nope, they are all active. Return 0 */
  return(0);
}


/*
  Kills missile m before it goes off the screen.
*/
void missiles_kill(missiles m, int i)
{
  register int delta, size, y, x;
  missile missile_to_kill;

  /* Speed things up? */
  missile_to_kill = &m->missiles[i];
  
  /* Make sure the missile is active, just to be safe . . . */
  if (missile_to_kill->active == 0)
    return;

  /* Deactivate it */ 
  missile_to_kill->active = 0;

  /* Black out the missile */
  delta = (missile_to_kill->direction == MISSILE_UP) ? 1 : -1;
  x=missile_to_kill->x;
  y=missile_to_kill->y;
  for (size = missile_to_kill->size; size > 0; size--, y += delta) {
    if (y > MAX_Y) continue;
    game_screen_pset(m->screen, x, y, 0);
    game_screen_pset(m->screen, x+1, y, 0);
  }

  /* All done */
  return;
}


/*
  Damages missile m. Kill it if it is time to die.
*/
void missiles_damage(missiles m, int i)
{
  missile missile_to_kill;

  /* Speed things up? */
  missile_to_kill = &m->missiles[i];
  
  if (--missile_to_kill->damage == 0)
    missiles_kill(m, i);
}

/* This causes no more missiles from m to be fired until unpause is
   applied to m. */
void missiles_pause(missiles m)
{
  m->pause = 1;
}


/* Allows missiles to be shot from m again */
void missiles_unpause(missiles m)
{
  m->pause = 0;
}

/* Returns the number of active missiles in m */
int missiles_count(missiles m)
{
  int ii=0, count=0;

  /* Count the number of active missiles */
  while (ii < m->max) {
    if (m->missiles[ii].active)
      count++;
    ii++;
  }

  /* All done */
  return(count);
}

/* Limits the number of active missiles to min(m->max, n) */
void missiles_limit(missiles m, int n)
{
  m->number_active = (n > m->max) ? m->max : n;
}
