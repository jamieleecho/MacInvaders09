#ifndef _BITMAP_H
#define _BITMAP_H

#include <stdio.h>

typedef struct {
  int x, y, x_offset, y_offset;
  char *bitmap;
  char *bitmap1;
  char *bitmap2;
  char *bitmap3;
} _bitmap, *bitmap;

typedef struct {
  int number;
  bitmap *bitmaps;
} _bitmap_list, *bitmap_list;

bitmap bitmap_create(char *filename);
bitmap_list bitmap_list_create(char *filename);
void bitmap_destroy(bitmap b);
void bitmap_list_destroy(bitmap_list b);
void bitmap_unparse(FILE *f, bitmap b);
bitmap bitmap_copy_fade(bitmap b, int i);
int bitmap_block_collision(bitmap b, int x2, int y2, int x0, int y0, int xlen, int ylen);

#endif
	
