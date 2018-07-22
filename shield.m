/*  This file contains stuff to draw invaders. */

#include <stdlib.h>

#include "os_dependent.h"
#include "shield.h"
#include "game_screen.h"
#include "bitmap.h"
#include "missiles.h"

/*
   If an error occurs, return NULL. Otherwise creates and returns
   a shield associated with game_screen g.
*/
shield shield_create(game_screen g)
{
  shield new;
  
  /* Allocate memory for the new shield */
  new = (shield)malloc(sizeof(_shield));
  if (new == NULL)
    return NULL;
  
  /* Get the shield bitmap */
  new->shield_bitmap = bitmap_create("shield");
  if (new->shield_bitmap == NULL)
    return NULL;

  /* Allocate memory for an image of the bitmap. */
  new->image = (char *)malloc(new->shield_bitmap->x * new->shield_bitmap->y);
  if (new->image == NULL) {
  	bitmap_destroy(new->shield_bitmap);
  	return(NULL);
  }
  
  /* Set other stuff */
  new->screen = g;
  
  /* All done */
  return (new);
}


/*
  Frees the resources used by s.
*/
void shield_destroy(shield s)
{
  if (s == NULL)
    return;
  
  /* Free up the memory!!! */
  bitmap_destroy(s->shield_bitmap);
  free(s->image);
  free(s);
}

/*
  Draws the shield s at (x,y) on its game_scren;
*/
void shield_draw(shield s, int x, int y)
{
  register int ii, jj;	
  s->x = x;
  s->y = y;
  game_screen_bitmap(s->screen, s->shield_bitmap, x, y);
  
  /* Refresh the image cache. */
  jj = s->shield_bitmap->x * s->shield_bitmap->y;
  for (ii=0; ii<jj; ii++)
    s->image[ii] = s->shield_bitmap->bitmap[ii];
}


/* If any missile in ms hits shield sh, updates s accordingly. */
void shield_missile_hit(void *sh, void *ms)
{
  register int ii;
  register missile current_missile;
  shield s = sh;
  missiles m = ms;
  
  
  /* Check each active missile in m to see if it is hitting s */
  for (ii = 0; ii < m->max; ii++) {
  	/* If the missile is inactive, skip to the next one. */
    if (!m->missiles[ii].active)
      continue;

	/* Figure out the vertical position of the missile */
	current_missile = &(m->missiles[ii]);

	/* Check for collisions */
	if (current_missile->direction == MISSILE_UP) {
	  if (shield_missile_collide(s, current_missile->x, current_missile->y, 2, current_missile->size)) {
	    missiles_damage(m, ii);
   	    missiles_damage(m, ii);
   	    missiles_damage(m, ii);
	    continue;
      }
    }
  	if (current_missile->direction == MISSILE_DOWN) {
      if (shield_missile_collide(s, current_missile->x, current_missile->y-current_missile->size, 2, current_missile->size)) {
        missiles_damage(m, ii);
	    missiles_damage(m, ii);
	    missiles_damage(m, ii);
	    continue;
      }
    }
  }  
  /* All done. (No collision) */
  return;
}


/* If the shield s is colliding with the block that starts at (x0, y0) and
   ends at (x0+dx,y0+dy), modifies the image data of s to reflect the
   collision and returns TRUE. */
int shield_missile_collide(shield s, int x0, int y0, int dx, int dy)
{
  register char *pixel_ptr, ii;
  int x1, y1, x3, y3;
  int start_x, start_y, end_x, end_y;
  int next_line;
  int flag;
  int counter=1;
  
  /* Init Vars */
  x1 = x0 + dx;
  y1 = y0 + dy;

  x3 = s->x + s->shield_bitmap->x + s->shield_bitmap->x_offset - 1;
  y3 = s->y + s->shield_bitmap->y + s->shield_bitmap->y_offset - 1;
  
  /* Make sure that the rectangles intersect */
  if ( (x3 < x0) || (x1 < s->x) || (y3 < y0) || (y1 < s->y) ) {
    return(0);
  }
  
  /* We must scan the intersected area of the image. To do this
     we must calculate the start and end coordinates of the
     intersection relative to the image */
  start_x = (s->x > x0) ? 0 : (x0 - s->x);
  start_y = (s->y > y0) ? 0 : (y0 - s->y);
  end_x = (x1 > x3) ? s->shield_bitmap->x -1 : (x1 - s->x);
  end_y = (y1 > y3) ? s->shield_bitmap->y -1 : (y1 - s->y);
 
  /* Scan the intersected area. If we hit a nonzero, that
     means a collision happened. */
  next_line = (s->shield_bitmap->x - (end_x - start_x)) - 1;
  pixel_ptr = s->image + start_x + ((start_y) * s->shield_bitmap->x);

  for (end_y = end_y - start_y; end_y >= 0; end_y--) {
    flag = FALSE;
  	for (ii=start_x; ii <= end_x; ii++) {
  	  if (*pixel_ptr) {/* Collision ? */
   	    *pixel_ptr = 0;
 	    flag = TRUE;
  	  }
  	  pixel_ptr++;
    }
    if (flag) {
      counter--;
      if (counter <= 0) {
        return(1);
      }
    }
    pixel_ptr += next_line;
  }

  /* No Collision */
  return(0);
}


void shield_disable(shield s)
{
  int ii, jj;

  /* Clear the image cache. */
  jj = s->shield_bitmap->x * s->shield_bitmap->y;
  for (ii=0; ii<jj; ii++)
    s->image[ii] = 0;
  
  /* Clear the image. */
  game_screen_block(s->screen, 0, s->x, s->y, s->x + s->shield_bitmap->x, s->y + s->shield_bitmap->y);
  
}

