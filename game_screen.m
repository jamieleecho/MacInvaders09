#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "os_dependent.h"
#include "game_screen.h"
#include "bitmap.h"
#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>
#import "InvGameScreenController.h"

char _font[] = {
 0,87,81,119,20,23,0,0,
 0,87,81,119,20,23,0,0,
 0,87,81,119,20,23,0,0,
 0,87,81,119,20,23,0,0,
 0,87,81,119,20,23,0,0,
 0,87,81,119,20,23,0,0,
 0,87,81,119,20,23,0,0,
 0,87,81,119,20,23,0,0,
 0,87,81,119,20,23,0,0,
 0,87,81,119,20,23,0,0,
 0,87,81,119,20,23,0,0,
 0,87,81,119,20,23,0,0,
 0,87,81,119,20,23,0,0,
 0,87,81,119,20,23,0,0,
 0,87,81,119,20,23,0,0,
 0,87,81,119,20,23,0,0,
 0,87,81,119,20,23,0,0,
 0,87,81,119,20,23,0,0,
 0,87,81,119,20,23,0,0,
 0,87,81,119,20,23,0,0,
 0,87,81,119,20,23,0,0,
 0,87,81,119,20,23,0,0,
 0,87,81,119,20,23,0,0,
 0,87,81,119,20,23,0,0,
 0,87,81,119,20,23,0,0,
 0,87,81,119,20,23,0,0,
 0,87,81,119,20,23,0,0,
 0,87,81,119,20,23,0,0,
 0,87,81,119,20,23,0,0,
 0,87,81,119,20,23,0,0,
 0,87,81,119,20,23,0,0,
 0,87,81,119,20,23,0,0,
 /* * 32 (space) */
 0, 0, 0, 0, 0, 0, 0, 0,
 16, 16, 24, 24, 24, 0, 24, 0,
 102, 102, 204, 0, 0, 0, 0, 0,
 68, 68, 255, 68, 255, 102, 102, 0,
 24, 126, 64, 126, 6, 126, 24, 0,
 98, 68, 8, 16, 49, 99, 0, 0,
 62, 32, 34, 127, 98, 98, 126, 0,
 56, 56, 24, 48, 0, 0, 0, 0,
 12, 24, 48, 48, 56, 28, 12, 0,
 48, 56, 28, 12, 12, 24, 48, 0,
 0, 24, 36, 90, 36, 24, 0, 0,
 0, 24, 24, 124, 16, 16, 0, 0,
 0, 0, 0, 0, 0, 48, 48, 96,
 0, 0, 0, 126, 0, 0, 0, 0,
 0, 0, 0, 0, 0, 48, 48, 0,
/*  47 */
 2, 2, 4, 24, 48, 96, 96, 0,
 126, 66, 66, 70, 70, 70, 126, 0,
 8, 8, 8, 24, 24, 24, 24, 0,
 126, 66, 2, 126, 96, 98, 126, 0,
 124, 68, 4, 62, 6, 70, 126, 0,
 124, 68, 68, 68, 126, 12, 12, 0,
 126, 64, 64, 126, 6, 70, 126, 0,
 126, 66, 64, 126, 70, 70, 126, 0,
 62, 2, 2, 6, 6, 6, 6, 0,
 60, 36, 36, 126, 70, 70, 126, 0,
 126, 66, 66, 126, 6, 6, 6, 0,
 0, 24, 24, 0, 24, 24, 0, 0,
 0, 24, 24, 0, 24, 24, 48, 0,
 6, 12, 24, 48, 28, 14, 7, 0,
 0, 0, 126, 0, 126, 0, 0, 0,
 112, 56, 28, 6, 12, 24, 48, 0,
 126, 6, 6, 126, 96, 0, 96, 0,
 /* 64 */
 60, 66, 74, 78, 76, 64, 62, 0,
 60, 36, 36, 126, 98, 98, 98, 0,
 124, 68, 68, 126, 98, 98, 126, 0,
 126, 66, 64, 96, 96, 98, 126, 0,
 124, 66, 66, 98, 98, 98, 124, 0,
 126, 64, 64, 124, 96, 96, 126, 0,
 126, 64, 64, 124, 96, 96, 96, 0,
 126, 66, 64, 102, 98, 98, 126, 0,
 66, 66, 66, 126, 98, 98, 98, 0,
 16, 16, 16, 24, 24, 24, 24, 0,
 4, 4, 4, 6, 6, 70, 126, 0,
 68, 68, 68, 126, 98, 98, 98, 0,
 64, 64, 64, 96, 96, 96, 124, 0,
 127, 73, 73, 109, 109, 109, 109, 0,
 126, 66, 66, 98, 98, 98, 98, 0,
 126, 66, 66, 98, 98, 98, 126, 0,
 126, 66, 66, 126, 96, 96, 96, 0,
 126, 66, 66, 66, 66, 78, 126, 0,
 124, 68, 68, 126, 98, 98, 98, 0,
 126, 66, 64, 126, 6, 70, 126, 0,
 126, 16, 16, 24, 24, 24, 24, 0,
 66, 66, 66, 98, 98, 98, 126, 0,
 98, 98, 98, 102, 36, 36, 60, 0,
 74, 74, 74, 106, 106, 106, 126, 0,
 66, 66, 66, 60, 98, 98, 98, 0,
 66, 66, 66, 126, 24, 24, 24, 0,
 126, 66, 6, 24, 96, 98, 126, 0,
 126, 64, 64, 96, 96, 96, 126, 0,
/* 92 */
 64,64,32,24,12,6,6,0,
/* 93 ] */
 126, 2, 2, 6, 6, 6, 126, 0,
/* 94 up arrow */
 24,52,98,0,0,0,0,0,
/* * 95 _ */
 0, 0, 0, 0, 0, 0, 0, 255,
/* * 96 ` */
 96, 48, 0, 0, 0, 0, 0, 0,
/* * 97 a */
 0, 0, 62, 2, 126, 98, 126, 0,
 64, 64, 126, 70, 70, 70, 126, 0,
 0, 0, 126, 66, 96, 98, 126, 0,
 2, 2, 126, 66, 70, 70, 126, 0,
 0, 0, 124, 68, 124, 98, 126, 0,
 62, 34, 32, 120, 48, 48, 48, 0,
 0, 0, 126, 66, 98, 126, 2, 62,
 64, 64, 126, 66, 98, 98, 98, 0,
 16, 0, 16, 16, 24, 24, 24, 0,
 0, 2, 0, 2, 2, 2, 98, 126,
 96, 96, 100, 68, 126, 70, 70, 0,
 16, 16, 16, 16, 24, 24, 24, 0,
 0, 0, 98, 126, 74, 106, 106, 0,
 0, 0, 126, 66, 98, 98, 98, 0,
 0, 0, 126, 66, 98, 98, 126, 0,
 0, 0, 126, 66, 66, 126, 96, 96,
 0, 0, 126, 66, 78, 126, 2, 2,
 0, 0, 124, 96, 96, 96, 96, 0,
 0, 0, 126, 64, 126, 6, 126, 0,
 16, 16, 126, 16, 24, 24, 24, 0,
 0, 0, 66, 66, 98, 98, 126, 0,
 0, 0, 98, 98, 98, 36, 24, 0,
 0, 0, 66, 74, 106, 126, 36, 0,
 0, 0, 98, 126, 24, 126, 98, 0,
 0, 0, 98, 98, 98, 36, 24, 112,
 0, 0, 126, 108, 24, 50, 126, 0,
 14, 24, 24, 112, 24, 24, 14, 0,
 24, 24, 24, 0, 24, 24, 24, 0,
 112, 24, 24, 14, 24, 24, 112, 0,
 50, 126, 76, 0, 0, 0, 0, 0,
 102, 51, 153, 204, 102, 51, 153, 204 };


/* The number of currently active game_screens */
int count=0;

/*
   Attempts to open and display a game_screen. If a failure occurs, returns
   NULL. Otherwise initializes the game_screen and displays it. The ith color
   slot of the game_screen will have color[i] as its value. The screen will
   initially be filled with slot zero. The predefined text colors are
   undefined. The border is slot zero. A non NULL value is returned on success.
*/
game_screen game_screen_open(rgb color[256])
{
  game_screen new;
  int screen_size = 320 * 192;
  InvGameScreenController *winController;
    
  /* Allocate memory for the game_screen */
  new = (game_screen)malloc(sizeof(_game_screen));
  if (new == NULL)
    return(NULL);
  
  /* Memorize the begining and end of the screen */
  new->start = (char *)malloc(screen_size);
  if (new->start == NULL) {
    free(new);
    return(NULL);
  }
  new->end = new->start + (screen_size);
  new->is_dirty = YES;

  /* Load the nib that contains the actual game screen. */
  winController = [[InvGameScreenController alloc] initWithWindowNibName:@"InvGameScreen" screen:new];
  [winController showWindow: nil];
  new->winController = winController;

  /* Set up the palette */
  [winController setPalette: color];

  return(new);
}

/*
   If g is NULL, returns with no effect. Otherwise closes the
   game_screen g and returns
*/
void game_screen_close(game_screen g)
{
  if (g == NULL)
    return;

  /* Free the memory */
  if (g->start != NULL) free(g->start);
  free(g);
}

/*
  Prints text at (8 * (x%40), 8 * (y%24)) on g.
*/
void game_screen_print(game_screen g, int x, int y, char *text)
{
  int ii=0;    /* The index into text. */
  NSRect rect = {{x * 8, y * 8}, {strlen(text) * 8, 8}};
  [(InvGameScreenController *)(g->winController) setNeedsDisplayInRect: rect];

  g->is_dirty = YES;
  x = x % 40;
  y = y % 24;

  while(text[ii] != 0) {
    char c = text[ii++];	  /* The character to write. */
    int xx = x * 8, yy  = y * 8;  /* Screen coordinates in pixels. */
    char *font = _font + (c * 8);  /* pointer into _font. */
    
    int kk = 8;              /* The num of bytes in _font to traverse. */
    for (; kk>0; kk--) {
        char b = *font++;    /* one byte of font data */

        int ll = 8;	     /* num of bits in a bytes. */
        for (; ll>0; ll--) {
          g->start[yy*320 + xx++] = (b & 0x80) ? g->fgcolor : g->bgcolor;
          b = b << 1;
        }
        
        // draw next line
        yy++;
        xx-=8;
    }
        
    /* Move the cursor forward */
    x = x + 1;
    if (x >= 40) {
      x = 0;
      y = y + 1;
      if (y > 24)
        y = 23; /* should scroll the screen here. */
    }
  }
}

/*
  Changes the background and foreground color of g
*/
void game_screen_color(game_screen g, int background, int foreground)
{
  g->bgcolor = background & 0xff;
  g->fgcolor = foreground & 0xff;
}

/*
  Draws a line from (x0, y0) to (x1, y1) on g in the current
  foreground color.
*/
void game_screen_line(game_screen g, int x0, int y0, int x1, int y1)
{
  /* XXX Fill this in later. Only handles verticle and/or horizontal lines!!! */
  int isHorizontal = (y0 == y1);
  char *ptr = g->start + (y0 * 320) + x0;
  char *end = ptr + (isHorizontal ? (x1 - x0) : ((y1 - y0) * 320));
  char c = g->fgcolor;
  NSRect rect = {{x0, y0}, {abs(x1 - x0), abs(y1 - y0)}};
  [(InvGameScreenController *)(g->winController) setNeedsDisplayInRect: rect];
  g->is_dirty = YES;

  /* don't do something really stupid. */
  if (ptr > end) {
    char *tmp = ptr;
    ptr = end;
    end = tmp;
  }
  
  /* draw the line. */
  if (isHorizontal)
    while (ptr <= end)
      *ptr++ = c;
  else
    while (ptr <= end) {
      *ptr = c;
      ptr += 320;
    }
}

/*
  Draws a point at (x0, y0)
*/
void game_screen_point(game_screen g, int x0, int y0)
{
  NSRect rect = {{x0, y0}, {1, 1}};
  [(InvGameScreenController *)(g->winController) setNeedsDisplayInRect: rect];
  g->is_dirty = YES;
  *(g->start + (y0 * 320) + x0) = g->fgcolor;
}


/*
  Clears g to the current background color
*/
void game_screen_cls(game_screen g)
{
  char *ptr = g->start;
  char *end = g->end;
  char bcolor = g->bgcolor;
  NSRect rect = {{0, 0}, {320, 192}};
  [(InvGameScreenController *)(g->winController) setNeedsDisplayInRect: rect];
  g->is_dirty = YES;
  while(ptr < end)
    *ptr++ = bcolor;
}


/*
  Clears everything between y1 and y2 to color zero in a cool way.
  The amount that gets cleared can be specified by the a parameter
  where 0 means no clearing and 8 means complete clearing.
  The results are linearly cumulative.
*/
void game_screen_cool_cls0(game_screen g, int y1, int y2, int a)
{
  unsigned *index;
  int j;
  int i, iterations;
  NSRect rect = {{0, y1}, {320, abs(y2-y1)}};
  [(InvGameScreenController *)(g->winController) setNeedsDisplayInRect: rect];
  g->is_dirty = YES;

  /* Trust the caller. NOT! */
  if ( (y1>y2) || (y1 < 0) || (y2 > 191) )
    return;
  
  /* Compute the end point */
  iterations = ((y2+1) - y1) * 5;
  y1 *= 80;
  
  /* Do an lsr >> 4 to each pixel 4 times */
  for (i=0; i<a; i++) {
      index = (unsigned *)g->start + y1;
      for (j=iterations; j>0; j--) {
      *index = (*index >> 4);
      index++;      
      *index = (*index >> 4);      
      index++;      
      *index = (*index >> 4);
      index++;      
      *index = (*index >> 4);      
      index++;
      *index = (*index >> 4);
      index++;      
      *index = (*index >> 4);      
      index++;      
      *index = (*index >> 4);
      index++;      
      *index = (*index >> 4);      
      index++;
      *index = (*index >> 4);
      index++;      
      *index = (*index >> 4);      
      index++;      
      *index = (*index >> 4);
      index++;      
      *index = (*index >> 4);      
      index++;
      *index = (*index >> 4);
      index++;      
      *index = (*index >> 4);      
      index++;      
      *index = (*index >> 4);
      index++;      
      *index = (*index >> 4);      
      index++;      
    }
  }    
  return; /* All done! */
}


/*
  like game_screen_cool_cls0 but more general. Will clear any block between
  (x1, y1) and (x2, y2) on g in some cool way. 
*/
void game_screen_cool_clrblk0(game_screen g, int x1, int y1, int x2, int y2)
{
  register unsigned char *index;
  int i, k, temp;
  register int j;
  NSRect rect = {{x1, y1}, {abs(x2-x1), abs(y2-y1)}};
  [(InvGameScreenController *)(g->winController) setNeedsDisplayInRect: rect];
  g->is_dirty = YES;
  
  /* Trust the caller. Yah right! */
  if ( (x2 <= x1) || (y2 <= y1) || (y1 < 0) || (x1 < 0) || (x2 > 319) ||
       (y2 > 191) )
   return;
 
  /* Compute x2 - x1 */
  temp = (x2+1) - x1;

  /* Perform a >> 2 on each pixel 4 times. This does not give the exact
     effect of cool_cls0, but is pretty close */
  for (i=4; i>0; i--) {
    index = (unsigned char *)g->start + (y1 * 320) + x1;
  	for (k=(y2+1)-y1; k>0; k--) {
  	  for (j=temp; j > 0; j--) {
  	    *index = *index << 2;
  	    index++;
  	  }
  	index = index - temp + 320;
    }
  }
  
  return; /* All done! */
}

/*
   puts the bitmap b at x,y on g
*/
void game_screen_bitmap(game_screen g, bitmap b, int x, int y)
{
  register unsigned char *from, *to;
  int delta_x, nextline;
  register int j;
  NSRect rect = {{x + b->x_offset, y+b->y_offset },
                 {b->x, b->y}};
  [(InvGameScreenController *)(g->winController) setNeedsDisplayInRect: rect];
  g->is_dirty = YES;
  
  /* Add the offsets */
  x += b->x_offset;
  y += b->y_offset;

  /* Make sure the bitmap coordinates are on the screen */
  if ( (x >= 320) || (y >= 192) || (x < 0) || (y < 0) )
    return;

  /* Calculate the starting position. */
  to = (unsigned char *)g->start + x + (y * 320);
  
  /* Compute if the bitmap falls off the edge */
  delta_x = b->x;
  if ( (x + delta_x) >= 320) {
  	delta_x = 320 - x;
  	nextline =  320 -  delta_x;
  }
  else
    nextline = 320 - delta_x;
  
  y = ((y + b->y) > 192) ? (192 - y) : b->y;

  /* Display bitmap on screen. */
  if ( ((x % 4) == 0) && ((b->x % 4) == 0) ) {
  	from = (unsigned char *)b->bitmap;  
  	delta_x /= 4;
    for (; y>0 ;y--) {
	  for(j=delta_x; j>0; j--) {
  	    *(int *)to = *(int *)from;
  	    to += 4;
  	    from += 4;
  	  }
  	  to += nextline;
  	  from = from + (b->x - (4 * delta_x));
    }
  }
  else if ( ((x %  4) == 1) && ((b->x % 4) == 0) ) {
  	delta_x /= 4;
  	from = (unsigned char *)b->bitmap1;  
    for (; y>0 ;y--) {
      from++;
      *to++ = *from++;
      *to++ = *from++;
      *to++ = *from++;
	  for(j=delta_x-1; j>0; j--) {
  	    *(int *)to = *(int *)from;
  	    to += 4;
  	    from += 4;
  	  }
      *to++ = *from;
  	  to += nextline;
  	  from = from + (b->x - (4 * delta_x)) + 4;
    }
  }
  else if ( ((x % 4) == 2) && ((b->x % 4) == 0) ) {
  	from = (unsigned char *)b->bitmap2;  
  	delta_x /= 4;
    for (; y>0 ;y--) {
      from += 2;
      *to++ = *from++;
      *to++ = *from++;
	  for(j=delta_x-1; j>0; j--) {
  	    *(int *)to = *(int *)from;
  	    to += 4;
  	    from += 4;
  	  }
      *to++ = *from++;
      *to++ = *from++;
  	  to += nextline;
  	  from = from + (b->x - (4 * delta_x)) + 2;
    }
  }
  else if ( ((x % 4) == 3) && ((b->x % 4) == 0) ) {
    from = (unsigned char *)b->bitmap3;  
  	delta_x /= 4;
    for (; y>0 ;y--) {
      from += 3;
      *to++ = *from++;
	  for(j=delta_x-1; j>0; j--) {
  	    *(int *)to = *(int *)from;
  	    to += 4;
  	    from += 4;
  	  }
      *to++ = *from++;
      *to++ = *from++;
      *to++ = *from++;
  	  to += nextline;
  	  from = from + (b->x - (4 * delta_x)) + 1;
    }
  }
  else
    from = (unsigned char *)b->bitmap;
    for (; y>0 ;y--) {
	  for(j=delta_x; j>0; j--)
  	    *to++ = *from++;
  	  to += nextline;
  	  from = from + (b->x - delta_x);
    }
  
  /* All done!!! */
  return;
}


/*
   Returns the number of characters waiting to be read.
*/
int game_screen_chars_in_buffer(game_screen g)
{
  return([(InvGameScreenController *)(g->winController) get_chars_in_buffer]);
}

/*
   Returns the next character. If no characters are available,
   will halt flow of control until a character is available.
*/
char game_screen_get_char(game_screen g)
{
  return([(InvGameScreenController *)(g->winController) get_char]);
}

/*
   Flushes the keyboard buffer.
*/
void game_screen_flush(game_screen g)
{
  int cnt = game_screen_chars_in_buffer(g);
  while(cnt-- > 0) game_screen_get_char(g);
}



/*
   Draws a block with color slot c from x0, y0 to x1, y1 inclusive.
   For the box to be drawn the following must hold. . .  0 <= x0 <= x1
   and 0 <= y0 <= y1.
*/
void game_screen_block(game_screen g, int c, int x0, int y0, int x1, int y1)
{
  register char *base;
  register int x_length;
  int to_add, y_length;
  NSRect rect = {{x0, y0}, {abs(x1-x0), abs(y1-y0)}};
  [(InvGameScreenController *)(g->winController) setNeedsDisplayInRect: rect];
  g->is_dirty = YES;
 
  /* Check the bounds of the block */
  if ( (x0 < 0) || (x0 > x1) || (y0 < 0) || (y0 > y1) )
    return;
  y1 = (y1 > 191) ? 191 : y1;
  x1 = (x1 > 319) ? 319 : x1;
  
  /* Calculate the start position of the square */
  base = g->start + (y0 * 320) + x0;
  to_add = 320 - 1 - (x1 - x0);
  
  /* Draw the square . . . */
  for (y_length = (y1-y0)+1; y_length>0; y_length--) {
    for (x_length = (x1-x0)+1; x_length>0; x_length--)
      *base++ = c;
    base += to_add;
  }
  return;
}
      
    
/* Puts a point of color c at (x,y ) of g. */
void game_screen_pset(game_screen g, int x, int y, int c)
{
  register int  _y;	
  NSRect rect = {{x, y}, {1, 1}};
  [(InvGameScreenController *)(g->winController) setNeedsDisplayInRect: rect];
  g->is_dirty = YES;

  /* This may speed things up . . .  */
  _y = y;

  /* Check the args */
  if ( (y > 191) || (y < 0) || (x < 0) || (x > 319) )
    return;
  
  /* Compute the memory location and set the point */
  *(g->start + ((_y * 320) + x)) = c;
  
  /* All done */
  return;
}


/* 
   Pauses the game screen by placing a message and takes
   over input to allow the user to continue.
*/
void game_screen_pause(game_screen g) {
  return([(InvGameScreenController *)(g->winController) pause]);
}


/* Returns whether the game is paused. */
int game_screen_is_paused(game_screen g) {
  return([(InvGameScreenController *)(g->winController) isPaused]);
}


void game_screen_quit(game_screen g) {
    [(InvGameScreenController *)(g->winController) terminate: nil];
}
