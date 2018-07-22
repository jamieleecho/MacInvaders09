#import <Cocoa/Cocoa.h>
#include "main_game.h"

int main(int argc, char *argv[]) {
    int myArgc = argc;
    main_game_parse_args(&myArgc, &argv);
    return NSApplicationMain(myArgc, (const char **)argv);
}
