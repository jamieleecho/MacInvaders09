#import <Cocoa/Cocoa.h>

#include "game_screen.h"

@interface InvGameScreenController : NSWindowController
{
    char *myBuffer;
    unsigned short *myExpandedBuffer;
    NSBitmapImageRep *myImageRep;
    NSImage *myImage;
    NSImageView *myImageView;
    BOOL leftPressed, rightPressed, spacePressed;
    struct {
#if __BIG_ENDIAN__
        unsigned int   r:4,
                       g:4,
                       b:4,
                       a:4;
#else
        unsigned int   g:4,
                       r:4,
                       a:4,
                       b:4;
#endif
    } palette[256];
    int key;
    BOOL gameIsQuitting;
    BOOL gameIsPaused;
    game_screen gameScreen;
    
    // invalidation rectangles
    NSRect rects[1000];
    int rectCnt;
}
-(id) initWithWindowNibName:(NSString *)nibName screen:(game_screen)g;
-(int)get_chars_in_buffer;
-(int)get_char;
-(void)pause;
-(BOOL)isPaused;
-(void)setPalette:(rgb *)colors;
-(BOOL)windowShouldClose:(id)sender;
-(void)terminate:(id)sender;
-(void)normalSize:(id)sender;
-(void)doubleSize:(id)sender;
-(void)performZoom:(id)sender;
-(void)performMiniaturize:(id)sender;
-(void)performClose:(id)sender;
-(void)setNeedsDisplayInRect:(NSRect)r;

@end
