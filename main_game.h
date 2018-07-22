#ifndef _MAIN_GAME_H
#define _MAIN_GAME_H

#include "game_screen.h"

void main_game_tick(void);
game_screen main_get_game_screen(void);
void main_game_parse_args(int *argc, char ***argv);
int main_game_zoop_mode(void);
int main_game_skip_level_mode(void);
void main_game_main_menu(void);

#endif