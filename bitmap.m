#include <stdio.h>
#include <stdlib.h>
#include "bitmap.h"

static bitmap _bitmap_create(FILE *filename);
static void FadeBitmapData(unsigned char *BitmapData, int size, int i);


/*
  Opens the file filename for a bitmap file. Returns NULL on
  failure and a bitmap on success
*/
bitmap bitmap_create(char *filename)
{
  FILE *f;
  bitmap new;
  
  /* Open the file. If a failure occurs, return NULL */
  f = fopen(filename, "r");
  if (f == NULL)
    return(NULL);
  
  /* Get the bitmap via the stream f */
  new = _bitmap_create(f);

  fclose(f);
  return(new);
}


/*
   Reads f for bitmap data. Returns NULL on failure and a non-NULL value
   on success. Does NOT close f in any event.
*/
static bitmap _bitmap_create(FILE *f)
{
  int x, y, i, j, temp, x_offset, y_offset;
  bitmap new;
  
  /* Get the x and y size */
  if (fscanf(f, "%d %d %d %d", &x, &y, &x_offset, &y_offset) != 4) {
  	return(NULL);
  }
  
  /* Allocate memory here */
  new = (bitmap)malloc(sizeof(_bitmap));
  if (new == NULL) {
  	return(NULL);
  }
  new->bitmap = (char *)malloc(x * y);
  if (new->bitmap == NULL) {
  	free(new);
  	return(NULL);
  }
  new->bitmap1 = (char *)malloc((x+4) * y);
  if (new->bitmap1 == NULL) {
  	free(new->bitmap);
  	free(new);
  	return(NULL);
  }
  new->bitmap2 = (char *)malloc((x+4) * y);
  if (new->bitmap2 == NULL) {
  	free(new->bitmap1);
  	free(new->bitmap);
  	free(new);
  	return(NULL);
  }
  new->bitmap3 = (char *)malloc((x+4) * y);
  if (new->bitmap3 == NULL) {
   	free(new->bitmap2);
  	free(new->bitmap1);
  	free(new->bitmap);
  	free(new);
  	return(NULL);
  }
  new->x = x;
  new->y = y;
  new->x_offset = x_offset;
  new->y_offset = y_offset;
  
  /* Store the bitmap! */
  j = 0;
  for (i=x*y; i>0; i--) {
  	if (fscanf(f, "%d", &temp) != 1) {
  	   	free(new->bitmap3);
  	   	free(new->bitmap2);
	  	free(new->bitmap1);
	  	free(new->bitmap);
  		free(new);
  		return(NULL);
  	}
  	new->bitmap[j++] = temp;
  }
  
  /* Store the bitmap shifted right by one pixel */
  for (j=0,i=x*y; i>0; i--) { 
    new->bitmap1[j + 1 + (4 * (j / x))] = new->bitmap[j];
    j++;
  } 

  /* Store the bitmap shifted right by two pixels */
  for (j=0,i=x*y; i>0; i--) { 
    new->bitmap2[j + 2 + (4 * (j / x))] = new->bitmap[j];
    j++;
  }

  /* Store the bitmap shifted right by three pixels */
  for (j=0,i=x*y; i>0; i--) { 
    new->bitmap3[j + 3 + (4 * (j / x))] = new->bitmap[j];
    j++;
  }

  return(new);
}


/*
   Reads the file filename for a bitmap_list. Returns NULL on failure
   and a non-NULL value if successful. 
*/
bitmap_list bitmap_list_create(char *filename)
{
  FILE *f;
  int i, number;
  bitmap_list new;

  /* Open the file. If a failure occurs, return NULL */
  f = fopen(filename, "r");
  if (f == NULL)
    return(NULL); 

  /* Allocate memory for the bitmap_list */
  new = (bitmap_list)malloc(sizeof(_bitmap_list));
  if (new == NULL) {
  	fclose(f);
  	return(NULL);
  }

  /* Get the number of bitmaps in the file */
  if (fscanf(f, "%d", &number) != 1) {
  	free(new);
  	fclose(f);
  	return(NULL);
  }
  new->number = number;

  /* Allocate stoarge for the _bitmap pointers */
  new->bitmaps = (bitmap *)calloc(number, sizeof(bitmap));
  if (new->bitmaps == NULL) {
  	free(new);
  	fclose(f);
  	return(NULL);
  }
  
  /* Get the actual bitmaps */
  for (i=0; i<number; i++) {
  	new->bitmaps[i] = _bitmap_create(f);
  	if (new->bitmaps[i] == NULL) {
  	  while(i > 0)
  	    bitmap_destroy(new->bitmaps[i]);
  	  free(new->bitmaps);
  	  free(new);
  	  return(NULL);
  	}
  }
  
  /* Close the file and return the list! */
  fclose(f);
  return(new);
  
}

/*
  Frees the resources used by b and returns.
*/
void bitmap_destroy(bitmap b)
{
  if (b == NULL)
    return;
  free(b->bitmap3);
  free(b->bitmap2);
  free(b->bitmap1);
  free(b->bitmap);
  free(b);
}


/*
  Frees the resources used by b and returns.
*/
void bitmap_list_destroy(bitmap_list b)
{
  int i;
  
  if (b == NULL)
    return;
  
  /* Free the individual bitmaps */
  for (i=b->number; i>0; i--)
    bitmap_destroy(b->bitmaps[i]);
  
  /* Free b */  
  free(b);
}


/*
  prints a human readable form of b to f
*/
void bitmap_unparse(FILE *f, bitmap b)
{
  int i, j, k;
  printf("\n%d %d\n", b->x, b->y);

  for (i=b->y, k=0; i>0; i--) {
    for (j=b->x; j>0; j--)
      printf("%3d ", (int)b->bitmap[k++]);
    printf("\n");
  }
}
    
  
/*
   Creates and returns a copy of b except that it is "faded." Applying
   this recursively to a bitmap with i = 0, 1, 2, and 3 recursively
   results in a black bitmap.
*/
bitmap bitmap_copy_fade(bitmap b, int i)
{
  bitmap new;
  int x, y;
  
  /* Init vars */
  x= b->x;
  y = b->y;
  i &= 3;
  
  /* Allocate memory for the new bitmap. */
  new = (bitmap)malloc(sizeof(_bitmap));
  if (new == NULL)
    return(NULL);

  /* Copy b's stuff into new */
  memcpy(new, b, sizeof(_bitmap));
  
  /* Allocate memory for the individual bitmap buffers */
  new->bitmap = (char *)malloc(x * y);
  new->bitmap1 = (char *)malloc((x+4) * y);
  new->bitmap2 = (char *)malloc((x+4) * y);
  new->bitmap3 = (char *)malloc((x+4) * y);
  
  /* Make sure the buffers were allocated ok */
  if ( (new->bitmap == NULL) || (new->bitmap1 == NULL) ||
        (new->bitmap2 == NULL) || (new->bitmap3 == NULL) ) {
    if (new->bitmap == NULL) free(new->bitmap);
    if (new->bitmap1 == NULL) free(new->bitmap1);
    if (new->bitmap2 == NULL) free(new->bitmap2);
    if (new->bitmap3 == NULL) free(new->bitmap3);
    return(NULL);
  }
  
  /* Copy the data */
  memcpy(new->bitmap, b->bitmap, x * y);
  memcpy(new->bitmap1, b->bitmap1, (x+4) * y);
  memcpy(new->bitmap2, b->bitmap2, (x+4) * y);
  memcpy(new->bitmap3, b->bitmap3, (x+4) * y);
  
  /* Fade the data */
  FadeBitmapData((unsigned char *)new->bitmap, x*y, i);
  FadeBitmapData((unsigned char *)new->bitmap1, (x+4)*y, i);
  FadeBitmapData((unsigned char *)new->bitmap2, (x+4)*y, i);
  FadeBitmapData((unsigned char *)new->bitmap3, (x+4)*y, i);
  
  /* All Done! */
  return(new);
}


static void FadeBitmapData(unsigned char *BitmapData, int size, int i)
{
  register int x;
  
  /* Shift each element right by two */
  for (x=i; x<size; x+=4)
    BitmapData[x] = 0;
    
 /* All done */
 return;
 
}

/*
   Returns 1 if the block located at (x0,y0) - (x0+xlen, y0+ylen)
   collides with a non-zero region of the bitmap b if it is located
   at (x2, y2). Note that xlen and ylen must be positive.
*/
int bitmap_block_collision(bitmap b, int x2, int y2, int x0, int y0, int xlen, int ylen)
{
  register char *pixel_ptr, ii;
  int x1, y1, x3, y3;
  int start_x, start_y, end_x, end_y;
  int next_line;
  
  /* Init Vars */
  x1 = x0 + xlen;
  y1 = y0 + ylen;

  x3 = x2 + b->x + b->x_offset - 1;
  y3 = y2 + b->y + b->y_offset - 1;
  
  /* Make sure that the rectangles intersect */
  if ( (x3 < x0) || (x1 < x2) || (y3 < y0) || (y1 < y2) ) {
    return(0);
  }
  
  /* We must scan the intersected area of the bitmap. To do this
     we must calculate the start and end coordinates of the
     intersection relative to the bitmap */
  start_x = (x2 > x0) ? 0 : (x0 - x2);
  start_y = (y2 > y0) ? 0 : (y0 - y2);
  end_x = (x1 > x3) ? b->x -1 : (x1 - x2);
  end_y = (y1 > y3) ? b->y -1 : (y1 - y2);
 
  /* printf("(%d, %d) (%d, %d)\n", start_x, start_y, end_x, end_y); */

  /* Scan the intersected area. If we hit a nonzero, that
     means a collision happened. */
  next_line = (b->x - (end_x - start_x)) - 1;
  pixel_ptr = b->bitmap + start_x + ((start_y) * b->x);
  /* printf("\n012345678901234567890\n"); */
  for (end_y = end_y - start_y; end_y >= 0; end_y--) {
  	/* old_ptr = pixel_ptr; */
  	/* printf("\n"); */
  	for (ii=start_x; ii <= end_x; ii++) {
      if ((int)(b->bitmap + (b->x * b->y)) <= (int)(pixel_ptr) ) {
      	pixel_ptr++;
      	/* printf("X"); */
      }
  	  else if (*pixel_ptr++) {/* Collision ? */
  	    /* printf("*"); */
  	    return(1);
  	  }
  	  else ;
  	    /* printf(" "); */
    }
    pixel_ptr += next_line;
    /* if (pixel_ptr != (old_ptr + b->x))
      printf("Next Line Problem! %d\n", (int)pixel_ptr - (int)old_ptr); */
  }

  /* No Collision */
  return(0);
}
