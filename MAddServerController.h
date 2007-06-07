/* MAddServerController */

#import <Cocoa/Cocoa.h>
#import "MServerList.h"

@interface MAddServerController : NSWindowController
{
    IBOutlet NSButton *addButton;
    IBOutlet NSTextField *address;
    IBOutlet NSImageView *image;
    IBOutlet NSPopUpButton *kind;
    IBOutlet NSTextField *subTitle;
    IBOutlet NSTextField *title;

	NSTreeController *serverListsTreeController;
	MServerList *serverList;
}

- (id)serverListsTreeController;
- (void)setServerListsTreeController:(id)value;

- (IBAction)add:(id)sender;
- (IBAction)cancel:(id)sender;

- (void)setupWindow;
@end
