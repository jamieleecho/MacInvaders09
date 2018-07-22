#include <stdlib.h>
#include <stdio.h>

#include "game_screen.h"

#ifndef _SOUNDFX_H
#define _SOUNDFX_H

typedef struct {
  int size;
  int freq;
  int dataoffset;
  char *buffer;
  float *caBuffer;
  int caSize;
} _soundfx, *soundfx;

void soundfx_init(void);
soundfx soundfx_load(const char *filename);
void soundfx_destroy(soundfx snd);
void soundfx_play(game_screen g, soundfx snd);
int soundfx_signal_handler(int signal);
void soundfx_wait_and_play(game_screen g, soundfx snd);
int soundfx_busy(void);

#endif
