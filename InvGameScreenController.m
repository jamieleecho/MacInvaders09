#include <string.h>
#import "InvGameScreenController.h"
#include "main_game.h"

@implementation InvGameScreenController

#define SCREEN_WIDTH 320
#define SCREEN_HEIGHT 192

-(id) initWithWindowNibName:(NSString *)nibName screen:(game_screen)g {
    unsigned char *planes[] = {NULL, NULL};
    NSSize imageSize = {SCREEN_WIDTH, SCREEN_HEIGHT};
    int i;
    [super initWithWindowNibName: nibName];
    myBuffer = g->start;
    gameIsPaused = NO;
    gameIsQuitting = NO;
    gameScreen = g;
    rectCnt = 0;

    // Set the default palette to shades of grey
    for (i=0; i<256; i++) {
		palette[i].r = 0xf;
		palette[i].g = 0xf;
		palette[i].b = 0xf;
        palette[i].a = 0;
    } 

     // the NSImageView Stuff
    myExpandedBuffer = malloc(SCREEN_WIDTH * SCREEN_HEIGHT * 2);
    memset(myExpandedBuffer, 0, SCREEN_WIDTH * SCREEN_HEIGHT * 2);     
    planes[0] = (unsigned char *)myExpandedBuffer;
    myImageRep = [[NSBitmapImageRep alloc]	
                        initWithBitmapDataPlanes: planes
                        pixelsWide: SCREEN_WIDTH
                        pixelsHigh: SCREEN_HEIGHT
                        bitsPerSample: 4
                        samplesPerPixel: 3
                        hasAlpha: NO
                        isPlanar: NO
                        colorSpaceName: NSCalibratedRGBColorSpace
                        bytesPerRow: 640
                        bitsPerPixel: 16];
    myImage = [[NSImage alloc] initWithSize: imageSize];
    [myImage addRepresentation: myImageRep];

    leftPressed = rightPressed = spacePressed = NO;
    if (![[super window] setFrameUsingName:@"MacInvaders09"])
		[[super window] center];
    myImageView.wantsLayer = YES;
  
    return self;
}


-(void) awakeFromNib {
     [NSTimer scheduledTimerWithTimeInterval:
                        main_game_zoop_mode() ? .01 : .05
                        target: self
                        selector: @selector(tick:)
                        userInfo: @"Invaders Framerate Timer"
                        repeats: YES];
    [myImageView setImage: myImage];  
}


-(void)tick:(NSTimer *)theTimer {    
    /* Don't update the game if we are paused. */
    if (gameIsPaused) return;

    /* Update the game */
    main_game_tick();
    
    /* Update the bitmaps */
    if (!gameScreen->is_dirty) return;
    int idxEnd = SCREEN_WIDTH * SCREEN_HEIGHT;
    unsigned char *src = (unsigned char *)myBuffer;
    unsigned short *dest = myExpandedBuffer;
    int ii;
    for (ii=0; ii<idxEnd; ii++)
        dest[ii] = *(unsigned short *)&palette[((unsigned short)src[ii])];
    for (ii=0; ii<rectCnt; ii++)
        [myImageView setNeedsDisplayInRect:rects[ii]];

	/* Update the screens */
	[myImageView setImage:nil];
	[myImageRep release];
	[myImage release];
	unsigned char *planes[] = {(unsigned char *)myExpandedBuffer, NULL};
	NSSize imageSize = {SCREEN_WIDTH, SCREEN_HEIGHT};
    myImage = [[NSImage alloc] initWithSize: imageSize];
    myImageRep = [[NSBitmapImageRep alloc]	
                        initWithBitmapDataPlanes: planes
                        pixelsWide: SCREEN_WIDTH
                        pixelsHigh: SCREEN_HEIGHT
                        bitsPerSample: 4
                        samplesPerPixel: 3
                        hasAlpha: NO
                        isPlanar: NO
                        colorSpaceName: NSCalibratedRGBColorSpace
                        bytesPerRow: 640
                        bitsPerPixel: 16];
    [myImage addRepresentation: myImageRep];
	[myImageView setImage:myImage];
    rectCnt = 0;
    [[super window] makeFirstResponder: self];
    gameScreen->is_dirty = NO;
}

-(void)keyDown:(NSEvent *)theEvent {
    NSString *str = [theEvent charactersIgnoringModifiers];
    size_t len = [str length];
    size_t ii;
    
    for (ii=0; ii<len; ii++) {
        key = [str characterAtIndex: ii] & 0xff;
        switch (key) {
        case 2:
            leftPressed = YES;
            break;
        
        case 3:
            key = 6;
            rightPressed = YES;
            break;
        
        case ' ':
            spacePressed = YES;
            break;
        }
    }
}

-(void)keyUp:(NSEvent *)theEvent {
    NSString *str = [theEvent charactersIgnoringModifiers];
    size_t len = [str length];
    size_t ii;
    
    for (ii=0; ii<len; ii++) {
        int theKey = [str characterAtIndex: ii] & 0xff;
        switch (theKey) {
        case 2:
            leftPressed = NO;
            break;
        
        case 3:
            rightPressed = NO;
            break;
        
        case ' ':
            spacePressed = NO;
            break;
        }
    }
}

-(void)unpressKeys {
    leftPressed = rightPressed = spacePressed = NO;
}

-(int)get_chars_in_buffer {
    return (((key == 0) && !leftPressed && !rightPressed && !spacePressed) ? 0 : 1);
}

-(int)get_char {
    int retVal = key;
    key = 0;
    
    if (retVal == 0) {
        if (leftPressed) return 2;
        if (rightPressed) return 6;
    }
    
    return retVal;
}

-(void)pause {
  if (gameIsPaused) return;
  gameIsPaused = YES;
  NSAlert *alert = [[[NSAlert alloc] init] autorelease];
  alert.alertStyle = NSAlertStyleWarning;
  alert.messageText = @"MacInvaders09 Paused";
  alert.informativeText = @"MacInvaders09 is paused. Press the \"Resume\" button to resume play or the \"Abort\" button to abort the current game and return to the main menu.";
  [alert addButtonWithTitle:@"Resume"];
  [alert addButtonWithTitle:@"Abort"];
  [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
    if (returnCode == NSAlertSecondButtonReturn) // abort game
      main_game_main_menu();
    gameIsPaused = NO;
  }];
}

-(BOOL)isPaused {
  return gameIsPaused || gameIsQuitting;
}

-(void)setPalette:(rgb *)colors {
    int i;
    for (i=0 ; i<256 ; i++) {
		palette[i].r = colors[i].r >> 4;
		palette[i].g = colors[i].g >> 4;
		palette[i].b = colors[i].b >> 4;
		palette[i].a = 0;
    }
}

-(BOOL)windowShouldClose:(id)sender {
    gameIsQuitting = YES;
    gameIsPaused = YES;

    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    alert.alertStyle = NSAlertStyleWarning;
    alert.messageText = @"Quit MacInvaders09";
    alert.informativeText = @"Are you sure that you want to quit MacInvaders09?";
    [alert addButtonWithTitle:@"Resume"];
    [alert addButtonWithTitle:@"Quit"];
    [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
      if (returnCode == NSAlertSecondButtonReturn) { // quit game
        [self.window saveFrameUsingName:@"MacInvaders09"];
        exit(0);
      }
      gameIsPaused = NO;
      gameIsQuitting = NO;
    }];
    return NO;
}

-(void)terminate:(id)sender {
    [self windowShouldClose: sender];
}

-(void)normalSize:(id)sender {
    NSSize imageSize = {SCREEN_WIDTH, SCREEN_HEIGHT};
    [self unpressKeys];
    [[super window] setContentSize: imageSize];
}

-(void)doubleSize:(id)sender {
    NSSize imageSize = {SCREEN_WIDTH*2, SCREEN_HEIGHT*2};
    [self unpressKeys];
    [[super window] setContentSize: imageSize];
}

-(void)performZoom:(id)sender {
    [self unpressKeys];
    [[super window] performZoom: sender];
}

-(void)performMiniaturize:(id)sender {
    [self unpressKeys];
    [[super window] performMiniaturize: sender];
}

-(void)performClose:(id)sender {
    [[super window] performClose: sender];
}

-(void)setNeedsDisplayInRect:(NSRect)r {
    NSSize sz = [myImageView frame].size;
    double scaleX = sz.width / SCREEN_WIDTH;
    double scaleY = sz.height / SCREEN_HEIGHT;
    
    r.origin.y = ((SCREEN_HEIGHT - r.origin.y - r.size.height - 1) * scaleY);
    r.origin.x = ((r.origin.x - 1) * scaleX);
    r.size.height = ((r.size.height + 2) * scaleY);
    r.size.width = ((r.size.width + 2) * scaleX);
    rects[rectCnt++] = r;
    assert(rectCnt < sizeof(rects)/sizeof(NSRect));
}

@end
