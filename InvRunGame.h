#import <Cocoa/Cocoa.h>

#import "InvGameScreenController.h"

@interface InvRunGame : NSObject
{
  InvGameScreenController *winController;
}

-(void)normalSize:(id)sender;
-(void)doubleSize:(id)sender;
-(void)terminate:(id)sender;
-(void)performZoom:(id)sender;

@end
