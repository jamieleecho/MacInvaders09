/*
   This file contains score stuff
*/

#include <stdio.h>
#include <stdlib.h>
#include "game_screen.h"
#include "score.h"

#define EXTRA_GUY_START 9999
#define EXTRA_GUY 10000

/*
  Creates a score thing that is initialized to zero. The score will
  not be displayed initilly on g. Returns NULL on a failure.
*/
score score_create(game_screen g)
{
  score new;
  
  /* Allocate memory for the new score */
  new = (score)malloc(sizeof(_score));
  if (new == NULL)
    return(NULL);
  
  /* initialize the fields */
  new->screen = g;
  new->score = new->extra_guy = 0;
  new->xscore = EXTRA_GUY_START;
  return new;
}


/*
   Displays the score s on its game_screen. May modify the default
   colors on the game_screen.
*/
void score_display(score s)
{
  char score_str[6];
  int index, digit, temp;
  
  /* Convert s to a string. Probaly a better way to do this but. . . */
  digit = 100000;
  for (index = 0; index < 5; index++) {
  	temp = ((s->score % digit) * 10)/digit;
  	temp += '0';
  	score_str[index] = temp;
  	digit /= 10;
  }
  score_str[5] = 0;
  
  /* Now print the string on the game_screen */
  game_screen_color(s->screen, 0, 2);
  game_screen_print(s->screen, 1, 23, score_str);
  
  /* All done */
  return;
}
  

/*
  Increments s by a - the updated result, however is not displayed.
*/
void score_add(score s, int a)
{
  /* Update the score. Watch for OV */
  s->score += a;
  
  if (s->score > s->xscore) {
    s->extra_guy = 1;
    s->xscore += EXTRA_GUY;
  }

  if ( (s->score > 99999) || (s->score < 0) ) {
    s->score = 0;
    s->xscore = EXTRA_GUY_START;
  }
}


/*
   Frees the resources used by s.
*/
void score_destroy(score s)
{
  if (s == NULL)
    return;
  free(s);
}


/*
   Resets the score s, but does not update the screen.
*/
void score_reset(score s)
{
  s->score = 0;
  s->extra_guy = 0;
  s->xscore = EXTRA_GUY_START;
}


int score_extra_guy(score s)
{
  return(s->extra_guy);
}

void score_reset_extra_guy_flag(score s)
{
  s->extra_guy = 0;
}
