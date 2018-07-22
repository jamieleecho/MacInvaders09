/*
  This file contains stuff to draw and control the invaders
*/

#include <stdio.h>
#include "os_dependent.h"
#include "bitmap.h"
#include "invaders.h"
#include "missiles.h"
#include "soundfx.h"
#include "myrand.h"

#define INVADERS_LEFT 0
#define INVADERS_RIGHT 1;

#define INVADERS_FRAMES 6;

#define INVADERS_MISSILES_MAX 15
#define INVADERS_MISSILES_START 5
#define INVADERS_MISSILES_DELAY 0
#define INVADERS_MISSILE_SIZE 10

#define INVADERS_GO_DOWN_WAIT_TIME(lvl) (10 + (50/(1+lvl)))

#define INVADER_VALUE 50

#define INVADER_Y_OFFSET 12
#define INVADER_Y_SPACING 20
#define INVADER_X_OFFSET 40
#define INVADER_X_SPACING 24

#define INVADER_MAX_RIGHT 295
#define INVADER_MAX_LEFT 10
#define INVADER_DELTA_X 5
#define INVADER_DELTA_Y 1
#define INVADERS_MAX_Y 154

#define INVADER_RANDOM_KLUDGE1 60000
#define INVADER_RANDOM_KLUDGE2 6000

#define MISSILE_COLOR 18

static soundfx snd = NULL;
static int CanGoDown(invaders i, int y);


/*
   If an error occurs, returns NULL. Otherwise creates and returns
   invader data. All drawing operations performed on this data
   structure will draw the invaders on the game_screen g */
invaders invaders_open(game_screen g, round_t r, score s)
{
  invaders new;

  if (NULL == snd) {
    snd = soundfx_load("gurp.iff");
    if (NULL == snd) return(NULL);
  }
  
  /* First try to allocate memory needed for invader data
     structure */
  new = (invaders)malloc(sizeof(_invaders));
  if (new == NULL)
    return NULL;
  
  /* Get the invader picture frames */
  new->frame = bitmap_list_create("inv");
  if (new->frame == NULL) {
  	free(new);
    return NULL;
  }

  /* Get the missiles */
  new->missiles = missiles_create(g, INVADERS_MISSILES_MAX, INVADERS_MISSILES_DELAY, MISSILE_COLOR);
  if (new->missiles == NULL) {
  	bitmap_list_destroy(new->frame);
  	free(NULL);
  	return NULL;
  }

  new->screen = g;  
  new->round = r;
  new->score = s;
  invaders_restore(new);

  return(new);
}


/*
   If i is NULL, returns without effect. Otherwise frees the
   resources used by i.
*/
void invaders_close(invaders i)
{
  if (i==NULL)
    return;
  
  bitmap_list_destroy(i->frame);
  missiles_destroy(i->missiles);
  free(i);
}

/*
   Displays the invaders.
*/
void invaders_display(invaders i)
{
  register int x;
  register bitmap b;
  int y;

  for (y=0; y<INVADERS_Y; y++) {
  	b = i->frame->bitmaps[i->current_frames[y]];
    for (x=0; x<INVADERS_X; x++)
      if (i->is_alive[x][y])
        game_screen_bitmap(i->screen, b, i->position[x][y].x,i->position[x][y].y);
  }
}

/*
   Update invader positions.
*/
void invaders_update(invaders i)
{
  register int x, y, z;
  int counter, number_updated;
  bitmap b, oldb;
  int deltaY=0;

  /* Update the missiles */
  missiles_update(i->missiles);

  if (i->number == 0)
    return;

  /* Update the current animation frame */
  do {
    y = i->to_update = (i->to_update + 1) % INVADERS_Y;
    oldb = i->frame->bitmaps[i->current_frames[y]];
    i->current_frames[y] = (i->current_frames[y] + 1) % INVADERS_FRAMES;
    b = i->frame->bitmaps[i->current_frames[y]];
    for (number_updated=x=0; x<INVADERS_X; x++)
      if (i->is_alive[x][y]) {
      	number_updated++;
      	break;
      }

  
  /* If the invaders are moving left, then move them left. Otherwise
     move them right. */
  if (i->left_right == INVADERS_LEFT) {

    /* Extreme Left? */
    for (x=0; x<INVADERS_X; x++)
      if ((i->is_alive[x][y]) && (i->position[x][y].x <= INVADER_MAX_LEFT))
  	    i->next_move = INVADERS_RIGHT;

    /* Go down? */
    if (--i->go_down[y] <= 0) {
      i->go_down[y] = INVADERS_GO_DOWN_WAIT_TIME(round_get(i->round));
      for (x = 0; x<INVADERS_X; x++)
        if (i->is_alive[x][y]) {
          if (i->position[x][y].y < INVADERS_MAX_Y)
            if ( ((y+1) == INVADERS_Y) || CanGoDown(i, y) ) {
              game_screen_block(i->screen, 0, i->position[x][y].x+oldb->x_offset, i->position[x][y].y+oldb->y_offset, i->position[x][y].x+oldb->x_offset+oldb->x, i->position[x][y].y+oldb->y_offset+INVADER_DELTA_Y);
              i->position[x][y].y++;
              deltaY = INVADER_DELTA_Y;
            }   
        }   
   }   
   if (deltaY) {
   	 for (x=0; x<INVADERS_X; x++)
   	   if (i->is_alive[x][y]) {
     	 i->RowY[y] = i->position[x][y].y;
     	 i->maxY = (i->maxY > i->RowY[y]) ? i->maxY : i->RowY[y];
     	 break;
       }
   }

   /* Plot the invaders */ 
   for (x=0; x<INVADERS_X; x++)
      if (i->is_alive[x][y]) {
      	game_screen_block(i->screen, 0, i->position[x][y].x+oldb->x-INVADER_DELTA_X-oldb->x+b->x, i->position[x][y].y+oldb->y_offset+oldb->y_offset-deltaY, i->position[x][y].x+oldb->x_offset+oldb->x, i->position[x][y].y+oldb->y_offset+oldb->y);
	    i->position[x][y].x = i->position[x][y].x - INVADER_DELTA_X;
	    game_screen_bitmap(i->screen, b, i->position[x][y].x,i->position[x][y].y);
 	  }
  }
  else { /* INVADERS_RIGHT */

 	/* Extreme right??? */
    for (x=INVADERS_X-1; x>=0; x--)
      if ((i->is_alive[x][y]) && (i->position[x][y].x >= INVADER_MAX_RIGHT))
  	    i->next_move = INVADERS_LEFT;

    /* Go down? */
    if (--i->go_down[y] <= 0) {
      i->go_down[y] = INVADERS_GO_DOWN_WAIT_TIME(round_get(i->round));
      for (x = 0; x<INVADERS_X; x++)
        if (i->is_alive[x][y]) {
          if (i->position[x][y].y < INVADERS_MAX_Y)
            if ( ((y+1) == INVADERS_Y) || CanGoDown(i, y) ) {
              game_screen_block(i->screen, 0, i->position[x][y].x+oldb->x_offset, i->position[x][y].y+oldb->y_offset, i->position[x][y].x+oldb->x_offset+oldb->x, i->position[x][y].y+oldb->y_offset+INVADER_DELTA_Y);
              ++i->position[x][y].y;
              deltaY = INVADER_DELTA_Y;
            }
        }   
   }   
   if (deltaY) {
   	 for (x=0; x<INVADERS_X; x++)
   	   if (i->is_alive[x][y]) {
     	 i->RowY[y] = i->position[x][y].y;
     	 i->maxY = (i->maxY > i->RowY[y]) ? i->maxY : i->RowY[y];
     	 break;
       }
   }

   /* Plot the invaders */ 
    for (x = 0; x<INVADERS_X; x++) {
 	  if (i->is_alive[x][y]) {
        game_screen_block(i->screen, 0, i->position[x][y].x+oldb->x_offset, i->position[x][y].y+oldb->y_offset+oldb->y_offset-deltaY, i->position[x][y].x+b->x_offset+INVADER_DELTA_X, i->position[x][y].y+oldb->y_offset+oldb->y);
 	    i->position[x][y].x = i->position[x][y].x + INVADER_DELTA_X;
 	    game_screen_bitmap(i->screen, b, i->position[x][y].x,i->position[x][y].y);
 	  }
    }
  }
  if (y == (INVADERS_Y-1))
    i->left_right = i->next_move;

  /* Shoot missiles. Only the bottommost invaders may fire them . . . */
  counter = 52429;
  for(x=0; x<INVADERS_X; x++) {
  	for (z=INVADERS_Y-1; z>=0; z--)
  	  if (i->is_alive[x][z])
  	    break;
  	if (z >= 0) {
  	  if (myrand() >= INVADER_RANDOM_KLUDGE1) {
 	    b = i->frame->bitmaps[i->current_frames[z]];
 	    if (i->fire)
  	      missiles_fire(i->missiles, MISSILE_DOWN, b->x_offset + i->position[x][z].x, i->position[x][z].y + b->y_offset + b->y, INVADERS_MISSILE_SIZE);
  	    counter -= INVADER_RANDOM_KLUDGE2;
  	  }
    }
  }

  } while (number_updated == 0);
}  	  


/* If successful, causes i to call f(p, m) when m is updated where m
   is the missiles of i. Returns 1 on success and zero on failure. */
int invaders_inform(invaders i, void (*f)(void *, void *), void *p)
{
  return(missiles_inform(i->missiles, f, p));
}



/* i must be a valid invaders and m must be a valid missiles. Destroys
   all invaders in i hit by missiles in m. */
void invaders_shoot_at_invaders(void *i, void *m)
{
  register int ii, jj, kk;
  register missile current_missile;
  
  /* Check to see if each missile is hitting each invader. */
  for (ii = 0; ii < ((missiles)m)->max; ii++) {
  	/* If the missile is inactive, skip to the next one. */
    if (!((missiles)m)->missiles[ii].active)
      continue;
    current_missile = &((missiles)m)->missiles[ii];

      for (jj=0; jj<INVADERS_X; jj++) {
      	if (myrand() > 32767) continue;
      	for (kk=0; kk<INVADERS_Y; kk++) {
      	  if (!((invaders)i)->is_alive[jj][kk]) continue;
	     /* Check for collisions */
	     if (bitmap_block_collision(((invaders)i)->frame->bitmaps[((invaders)i)->current_frames[kk]], ((invaders)i)->position[jj][kk].x, ((invaders)i)->position[jj][kk].y, current_missile->x, current_missile->y, 2, current_missile->size)) {
	       score_add(((invaders) i)->score, INVADER_VALUE);
	       score_display(((invaders) i)->score);
	       ((invaders)i)->is_alive[jj][kk] = FALSE;
	       missiles_kill(m, ii);
	       game_screen_block(((invaders)i)->screen, 0, ((invaders)i)->position[jj][kk].x, ((invaders)i)->position[jj][kk].y, ((invaders)i)->position[jj][kk].x+16, ((invaders)i)->position[jj][kk].y+12);
	       ((invaders) i)->RowCount[kk]--;
	       jj = INVADERS_X;
	       kk = INVADERS_Y;
	       ((invaders)i)->number--;
	       soundfx_play(((invaders)i)->screen, snd);
	       continue;
        }
      }
    }
  }
  /* All done. (No Collision) */
  return;
}

/* Returns the number of active invaders . . . */
int invaders_number(invaders i)
{
  return(i->number);
}


/* Resets i to a start state. */
void invaders_restore(invaders i)
{
  int x, y, ii;
  
  /* Initialize position fields and is_alive of invaders */
  for (x=0; x<INVADERS_X; x++)
    for (y=0; y<INVADERS_Y; y++) {
      i->position[x][y].x = (x * INVADER_X_SPACING) + INVADER_X_OFFSET;
      i->RowY[y] = i->position[x][y].y = (y * INVADER_Y_SPACING)+INVADER_Y_OFFSET;
      i->is_alive[x][y] = TRUE;
    }
  
  /* Initialize direction fields and current_frames  */
   for (y=0; y<INVADERS_Y; y++) {
    i->current_frames[y] = 0;
    i->go_down[y] = INVADERS_GO_DOWN_WAIT_TIME(round_get(i->round));
    i->RowCount[y] = INVADERS_X; 
   }
   i->next_move = i->left_right = INVADERS_RIGHT; 

  /* Intialize other stuff here */
  i->to_update = INVADERS_Y-1;
  i->number = INVADERS_X * INVADERS_Y;

  /* Make sure all of the missiles are killed . . . */
  for (ii=0; ii<INVADERS_MISSILES_MAX; ii++)
    missiles_kill(i->missiles, ii);

  i->maxY = 0;

  /* The number of active missiles depends upon the current level. */
  missiles_limit(i->missiles, round_get(i->round) + INVADERS_MISSILES_START);
 
  return;
}


/* Puts the invaders that are alive back in their original position. */
void invaders_reset(invaders i)
{
  int x, y;
  int ii;

  /* We can initially fire. */
  i->fire = 1;
  
  /* Initialize position fields and is_alive of invaders */
  for (x=0; x<INVADERS_X; x++)
    for (y=0; y<INVADERS_Y; y++) {
      i->position[x][y].x = (x * INVADER_X_SPACING) + INVADER_X_OFFSET;
      i->RowY[y] = i->position[x][y].y = (y * INVADER_Y_SPACING)+INVADER_Y_OFFSET;
    }
  
  /* Initialize direction fields and current_frames  */
   for (y=0; y<INVADERS_Y; y++) {
    i->go_down[y] = INVADERS_GO_DOWN_WAIT_TIME(round_get(i->round));
    i->current_frames[y] = 0; 
    i->RowCount[y] = INVADERS_X; 
   }
   i->next_move = i->left_right = INVADERS_RIGHT; 
   i->maxY = 0;

  /* Make sure all of the missiles are killed . . . */
  for (ii=0; ii<INVADERS_MISSILES_MAX; ii++)
    missiles_kill(i->missiles, ii);

  /* The number of active missiles depends upon the current level. */
  missiles_limit(i->missiles, round_get(i->round) + INVADERS_MISSILES_START);
 
  return;
}


static int CanGoDown(invaders i, int y)
{
  int ii;

  for (ii=y+1; ii<INVADERS_Y; ii++) {
  	if (i->RowCount[ii] == 0)
  	  continue;
  	if ((i->RowY[ii] - i->RowY[y]) < (INVADER_Y_SPACING-1))
  	  return(0);
  	else
  	  return(1);
  }

  return(1);
}



void invaders_cease_fire(invaders i)
{
  i->fire=0;
}


void invaders_resume_fire(invaders i)
{
  i->fire=1;
}


int invaders_no_missiles(invaders i)
{
  return(!missiles_count(i->missiles));
}

int invaders_maxy(invaders i)
{
  return(i->maxY);
}
