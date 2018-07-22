#include "round.h"
#include "game_screen.h"
#include "soundfx.h"

static soundfx snd=NULL;

/*
   Creates and returns a round data structure that starts at round A.
   Future round references are drawn on g. Returns NULL on failure.
*/
round_t round_create(game_screen g)
{
  round_t new;
  
  if (snd == NULL) {
  	snd = soundfx_load("sm.iff");
  	if (snd == NULL) return(NULL);
  }
   

  /* Allocate memory for the new round */
  new = (round_t)malloc(sizeof(_round_t));
  if (new == NULL)
    return(NULL);
  
  /* Initialize the round */
  new->screen = g;
  new->round = 'A';
  
  /* All done */
  return(new);
}

/*
  Frees the memory used by r
*/
void round_destroy(round_t r)
{
  if (r == NULL)
    return;
  
  free(r);
}

/*
  Resets the current level. The screen is updated.
*/
void round_reset(round_t r)
{
  r->round = 'A';
  round_draw(r);
  return;
}

/*
   Increments the current round by step. The change is written to
   r's game_screen.
*/
void round_increment(round_t r, int step)
{
  r->round += step;
  
  /* Make sure the score is within bounds */
  if (r->round < 'A')
    r->round = 'A';
  if (r->round >'Z')
    r->round = 'Z';

  soundfx_wait_and_play(r->screen, snd);
  
  /* Draw the update */
  round_draw(r);
}
 

/*
  Draws the current round on the game_screen.
*/ 
void round_draw(round_t r)
{
  char temp[100];
  
  sprintf(temp, "Round %c", r->round);
  game_screen_color(r->screen, 0, 2);
  game_screen_print(r->screen, 11, 23, temp);
  
  return;
}


/* Returns the current round, a number on [0, 25]. */
int round_get(round_t r)
{
  return(r->round - 'A');
}
