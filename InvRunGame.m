#import <Foundation/Foundation.h>
#import "InvGameScreenController.h"
#import "InvRunGame.h"
#include "main_game.h"

@implementation InvRunGame

-(void) awakeFromNib {
  game_screen g;
  
  [[NSFileManager defaultManager] changeCurrentDirectoryPath: [[NSBundle mainBundle] resourcePath]];
  main_game_tick();
  
  g = main_get_game_screen();
  winController = (InvGameScreenController *)g->winController;
}

-(void)normalSize:(id)sender {
    [winController normalSize: sender];
}

-(void)doubleSize:(id)sender {
    [winController doubleSize: sender];
}

-(void)performZoom:(id)sender {
    [winController performZoom: sender];
}

-(void)terminate:(id)sender {
    [winController windowShouldClose: sender];
}

@end
