/* MAddServerController */

#import <Cocoa/Cocoa.h>
#import "MServerList.h"

@interface MAddServerController : NSWindowController
{
    IBOutlet NSButton *addButton;
    IBOutlet NSTextField *address;
    IBOutlet NSImageView *image;
    IBOutlet NSPopUpButton *kind;
    IBOutlet id mainController;
    IBOutlet NSTextField *subTitle;
    IBOutlet NSTextField *title;
	
	MServerList *serverList;
}
- (IBAction)add:(id)sender;
- (IBAction)cancel:(id)sender;

- (void)setupWindow;
@end
