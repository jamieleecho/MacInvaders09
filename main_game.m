#define MACINVADERS09_VERSION "1.0.5"

#include <stdio.h>
#include <string.h>
#include <assert.h>
#include "main_game.h"
#include "os_dependent.h"
#include "bitmap.h"
#include "game_screen.h"
#include "ship.h"
#include "invaders.h"
#include "shield.h"
#include "ufo.h"
#include "score.h"
#include "round.h"
#include "soundfx.h"


#define SHIELDS_Y 150		/* the y-coordinate of all shields. */
#define SHIELD1_X 40		/* the x-coordinate of shield 1. */
#define SHIELD2_X 148 		/* the x-coordinate of shield 2. */
#define SHIELD3_X 256		/* the x-coordinate of shield 3. */

#define SHIELDS_GONE_Y 134	/* when the invaders reach this point, remove shields. */
#define INVADERS_LANDED_Y 152   /* the point at which the invaders have won. */

static void main_game_init(void);
static void main_game_draw_title(void);
static void main_game_at_title(void);
static void main_game_run(void);
static void main_game_draw_over(void);
static void main_game_over(void);
static void errExit(char *str);

/* All the different states the game can be in. */
typedef enum {
    game_state_init = 0,
    game_state_draw_title,
    game_state_at_title,
    game_state_running,
    game_state_draw_over,
    game_state_game_over
} game_state;

/* Main variables for the game. */
static game_screen g;         /* The game screen. */
static rgb colors[256];	      /* The game screen's palette. */
static ship s;                /* The good guy ship. */
static score sc;	      /* how well our hero is doing. */
static shield sh1, sh2, sh3;  /* Our hero's wimpy shields. */
static int shieldsOK;	      /* The condition of our hero's shields. */
static invaders inv;	      /* The bad guys. */
static ufo u;		      /* Another bad guy. */
static round_t r;		      /* The current wave of bad guys */
static game_state state = game_state_init;      /* the current state of the game. */
static int substate = 0;      /* The current substate of the current state. */
static soundfx snd;	      /* sound used to start the game. */

/* Returns the game screen. */
game_screen main_get_game_screen() { return g; }

/* This function should be called at each iteration. It is responsible for initialzing
   and running each step of the game. */
void main_game_tick() {
    switch(state) {
    case game_state_init:
        main_game_init();
        break;
                
    case game_state_draw_title:
        main_game_draw_title();
        break;
    
    case game_state_at_title:
        main_game_at_title();
        break;
    
    case game_state_running:
        main_game_run();
        break;
    
    case game_state_draw_over:
        main_game_draw_over();
        break;
        
    case game_state_game_over:
        main_game_over();
        break;
    
    default:
        assert(FALSE); /* should never get here. */
    }
}


void main_game_init() {
  int i;
  /* Set the default palette to shades of grey */
  for (i=0; i<256; i++) {
  	colors[i].r = i;
  	colors[i].g = i;
  	colors[i].b = i;
  }
  /* The first 16 colors are derived from the original COCO colors. */
  colors[0].r = colors[0].g = colors[0].b = 0;
  colors[1].r = colors[1].g = colors[1].b = 85;
  colors[2].r = colors[2].g = colors[2].b = 171;
  colors[3].r = colors[3].g = colors[3].b = 255;
  
  colors[4].r = colors[4].g = colors[4].b = 0;
  colors[5].r = colors[5].g = 85; colors[5].b = 0;
  colors[6].r = colors[6].g = 171; colors[6].b = 0;
  colors[7].r = colors[7].g = 255; colors[7].b = 0;

  colors[8].r = colors[8].g = colors[8].b = 0;
  colors[9].r = colors[9].g = 0; colors[9].b = 255;
  colors[10].r = colors[10].b = 85; colors[10].g = 0;
  colors[11].r = colors[11].g = colors[11].b = 171;

  colors[8].r = colors[8].g = colors[8].b = 0;
  colors[13].r = colors[13].b = 85; colors[13].g = 0;
  colors[14].r = 0; colors[14].g = colors[14].b = 171;
  colors[15].r = colors[15].b = colors[15].g = 255;

  colors[16].r = 255; colors[16].g = 0; colors[16].b = 0;
  colors[17].r = colors[17].b = 255;
  colors[18].g = 255;

  /* Initialize the sound */
  soundfx_init();

  /* Open a game_screen */
  g = game_screen_open(colors);
  if (g == NULL) {
  	errExit("Could not open window!!!");
  }
  game_screen_color(g, 0, 0);
  game_screen_cls(g);
  if ( (s = ship_open(g, SHIP_KEYBOARD)) == NULL) {
  	game_screen_close(g);
  	errExit("Could not create ship!!!\n");
  }

  /* Create a score thing */
  sc = score_create(g);
  if (sc == NULL) {
  	errExit("Could not create score output!!!");
  	exit(0);
  }

  r = round_create(g);
  if (r == NULL) {
  	errExit("Could not create round output!!!");
  }

  inv = invaders_open(g, r, sc);
  if (inv == NULL) {
  	errExit("Could not create invaders!!!");
  }

  sh1 = shield_create(g);
  sh2 = shield_create(g);
  sh3 = shield_create(g);
  if ((sh1 == NULL) || (sh2 == NULL) || (sh3 == NULL)) {
  	errExit("main: Could not create shield!!!");
  }

  u = ufo_create(g, r, sc);
  if (u == NULL) {
  	errExit("Could not open ufo!!!");
  }

  snd = soundfx_load("go.iff");
  if (snd == NULL) {
    errExit("Could not load go.iff!!!");
  }

  /* Tell objects about each other . . . */
  ufo_inform(u, ship_shoot_at_ship, s);
  ufo_inform(u, shield_missile_hit, sh1);
  ufo_inform(u, shield_missile_hit, sh2);
  ufo_inform(u, shield_missile_hit, sh3);
  invaders_inform(inv, ship_shoot_at_ship, s);
  ship_inform(s, ufo_shoot_at_ufo, u);
  invaders_inform(inv, shield_missile_hit, sh1);
  invaders_inform(inv, shield_missile_hit, sh2);
  invaders_inform(inv, shield_missile_hit, sh3);
  ship_inform(s, shield_missile_hit, sh1);
  ship_inform(s, shield_missile_hit, sh2);
  ship_inform(s, shield_missile_hit, sh3);
  ship_inform(s, invaders_shoot_at_invaders, inv);
  
  /* Advance to the next game state. */
  state = game_state_draw_title;
  substate = 9;
}


static void main_game_draw_title()
{
  if (substate < 8) {
    /* Clear the screen */
    game_screen_cool_cls0(g, 0, 191, 1);
    substate++;
    return;
  }

  /* Draw the verticle lines (dark grey parts) */
  game_screen_color(g, 0, 64);
  game_screen_line(g, 316, 10, 316, 181);
  game_screen_line(g, 319, 10, 319, 181);
  game_screen_line(g, 0, 10, 0, 181);
  game_screen_line(g, 3, 10, 3, 181);

  /* Draw the verticle lines (grey parts) */
  game_screen_color(g, 0, 192);
  game_screen_line(g, 317, 10, 317, 181);
  game_screen_line(g, 318, 10, 318, 181);
  game_screen_line(g, 1, 10, 1, 181);
  game_screen_line(g, 2, 10, 2, 181);

  /* Draw the bottom horizontal line */
  game_screen_color(g, 0, 255);
  game_screen_line(g, 0, 182, 319, 182);
  
  /* Print the text here. */
  game_screen_color(g, 0, 3);
  game_screen_print(g, 7, 1,   "/) MacInvaders09 V" MACINVADERS09_VERSION " (\\");
  game_screen_color(g, 0, 2);
  game_screen_print(g, 10, 2,  "The Invasion Begins!");
  game_screen_color(g, 0, 3);
  game_screen_print(g, 2, 3,   "Copyright (C) 1994, 2001, 2002 by");
  game_screen_color(g, 0, 1);
  game_screen_print(g, 3, 4,   "Allen C. Huffman, Jamie Cho and");
  game_screen_color(g, 0, 3);
  game_screen_print(g, 11, 5,  "Sub-Etha Software"); 

  game_screen_color(g, 0, 16);
  game_screen_print(g, 14, 8,  "MacOS X Port"); 
  game_screen_print(g, 14, 9,  "by Jamie Cho"); 
  game_screen_print(g, 10, 10, "jamieleecho@yahoo.com"); 
  game_screen_color(g, 0, 2);
  game_screen_print(g, 1, 13,  "Support the future of OS-9 & the CoCo.");
  game_screen_print(g, 3, 14,  "Please do not pirate this program.");
  game_screen_color(g, 0, 3);
  game_screen_print(g, 10, 23, "(K)eyboard   (Q)uit");

  /* Draw the shields */
  shield_draw(sh1, 40,150);
  shield_draw(sh2, 148, 150);
  shield_draw(sh3, 256, 150);
  
  /* Advance to the next game state. */
  state = game_state_at_title;
  substate = 0;
}


void main_game_at_title() {
  int cnt;
  
  /* A key was previously pressed. update the screen. */
  if (substate >= 2) {
    if (substate >= 9) {
      game_screen_print(g, 4, 23, "                                   ");
      score_reset(sc);
      score_display(sc);

      round_reset(r);
      invaders_restore(inv);
      ufo_reset(u);
      ship_complete_reset(s);
     
      /* Draw the shields */
      shield_draw(sh1, SHIELD1_X, SHIELDS_Y);
      shield_draw(sh2, SHIELD2_X, SHIELDS_Y);
      shield_draw(sh3, SHIELD3_X, SHIELDS_Y);
    
      /* Draw the current round */
      round_draw(r);
    
      shieldsOK = 1;  
     
      /* Advance to the next game state. */
      state = game_state_running;
      substate = 0;
    } else {
      substate++;
      game_screen_cool_cls0(g, 0, 181, 1);
    }
  }
  
  cnt = game_screen_chars_in_buffer(g);

  /* wait for a key to be not pressed and then pressed. */
  if (substate < 1) {
    if (cnt > 0)
      game_screen_flush(g);
    else
      substate = 1;  
    return;
  }

  /* wait for a key to be not pressed and then pressed. */
  while(cnt-- > 0) {
    char c = (game_screen_get_char(g) | 64);
    if ((c == 'q') || (c == 'Q')) {
        game_screen_quit(g);
    }
    if ((c == 'k') || (c == 'K'))  {
      game_screen_cool_cls0(g, 0, 181, 1);
      substate++;
    }
  }
}


void main_game_run() {
  int justKilled;
  if (game_screen_is_paused(g)) return;
  justKilled = ship_update(s);
  if (justKilled) {
    ufo_cease_fire(u);
    invaders_cease_fire(inv);
  }
  if (ufo_no_missiles(u) && invaders_no_missiles(inv)) {
    ufo_resume_fire(u);
    invaders_resume_fire(inv);
    ship_go(s);
    justKilled = 0;
  }
	
  ufo_update(u);
  invaders_update(inv);
  if ((invaders_number(inv) == 0) 
      || (main_game_skip_level_mode() && ship_skip_round(s))) {
    game_screen_block(g, 0, 0, 0, 319, 179);
    round_increment(r, 1);
    invaders_restore(inv);
    ufo_reset(u);
    ship_reset(s);
    shield_draw(sh1, SHIELD1_X, SHIELDS_Y);
    shield_draw(sh2, SHIELD2_X, SHIELDS_Y);
    shield_draw(sh3, SHIELD3_X, SHIELDS_Y);
    shieldsOK = 1;
    while(soundfx_busy());
    game_screen_flush(g);
   }
     
  if ((shieldsOK) && (invaders_maxy(inv) > SHIELDS_GONE_Y)) {
    shieldsOK = 0;
    shield_disable(sh1);      
    shield_disable(sh2);      
    shield_disable(sh3);      
  }
  
  if (score_extra_guy(sc)) {
    ship_add(s);
    score_reset_extra_guy_flag(sc);
  }

  if ((invaders_maxy(inv) > INVADERS_LANDED_Y) || (ship_number(s) == 0)) {
    /* Advance to the next game state. */
    state = game_state_draw_over;
    substate = 0;
  }
}

void main_game_draw_over(void) {
  soundfx_wait_and_play(g, snd);
  game_screen_color(g, 0, 16);
  game_screen_print(g, 15, 12,  "Game Over!");
  game_screen_print(g, 7, 13,  "Press any key to continue.");

  /* Advance to the next game state. */
   state = game_state_game_over;
   substate = 0;
}

/* Force the game back to the main menu. */
void main_game_main_menu(void) {
  /* Make certain there are no remaining characters in the buffer. */
  game_screen_flush(g);
    
  /* Advance to the next game state. */
  state = game_state_draw_title;
  substate = 0;
}

static void main_game_over(void) {
  /* get the number of key presses. */
  int cnt = game_screen_chars_in_buffer(g);

  /* wait for sounds to finish */
  while(soundfx_busy()) return;

  /** Wait for buttons to not be pressed. */
  if (substate < 1) {
    if (cnt > 0)
      game_screen_flush(g);
    else
      substate = 1;  
    return;
  }

  if (cnt > 0) {
    /* Make certain there are no remaining characters in the buffer. */
    game_screen_flush(g);
    
    /* Advance to the next game state. */
    state = game_state_draw_title;
    substate = 0;
  }
}


/* Exit do to some unusual condition specified by str. */
static void errExit(char *str) {
  fprintf(stderr, "%s", str);
  exit(1);
}

static int zoop_mode = 0;
static int skip_level_mode = 0;

/* Scans the first *argc entries of *argv, looking for -z, -Z or -*.
   Returns in *argc and *argv the same entries except that all the
   matching entries are removed. 
*/
void main_game_parse_args(int *argc, char ***argv) {
  char **newArgv = calloc(*argc, sizeof(char **));
  int newCnt = 0, ii;
  for (ii = 0; ii < *argc; ii++) {
    if ((strcmp((*argv)[ii], "-z") == 0) 
        || (strcmp((*argv)[ii], "-Z") == 0))
      zoop_mode = 1;
    else if (strcmp((*argv)[ii], "-*") == 0)
      skip_level_mode = 1;
    else
      newArgv[newCnt++] = (*argv)[ii];
  }
  
  *argc = newCnt;
  *argv = newArgv;
}

int main_game_zoop_mode() { return zoop_mode; }

int main_game_skip_level_mode() { return skip_level_mode; }


