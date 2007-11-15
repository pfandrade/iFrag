/* MAddServerController */

#import <Cocoa/Cocoa.h>

@class MServerList;
@class MServerTreeController;

@interface MAddServerController : NSWindowController
{
    IBOutlet NSButton *addButton;
    IBOutlet NSTextField *address;
    IBOutlet NSImageView *image;
    IBOutlet NSPopUpButton *kind;
    IBOutlet NSTextField *subTitle;
    IBOutlet NSTextField *title;

	MServerTreeController *serverListsTreeController;
	NSArrayController *serversController;
	MServerList *serverList;
}

- (id)serverListsTreeController;
- (void)setServerListsTreeController:(id)value;

- (NSArrayController *)serversController;
- (void)setServersController:(NSArrayController *)value;

- (IBAction)add:(id)sender;
- (IBAction)cancel:(id)sender;

- (void)setupWindow;

- (IBAction)popUpMenuSelectionDidChange:(id)sender;

- (void)runModalSheetForWindow:(NSWindow *)window;
@end
