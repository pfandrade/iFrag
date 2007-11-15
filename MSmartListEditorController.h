#import <Cocoa/Cocoa.h>
@class MSmartServerList;
@class MServerList;

@interface MSmartListEditorController : NSWindowController {
	NSPredicate *predicate;
	MSmartServerList *smartServerList;
	MServerList *serverList;
    IBOutlet NSTextField *smartListNameTextFiled;
	IBOutlet NSImageView *imageView;
	IBOutlet NSButton *saveButton;
}

@property (copy)	NSPredicate *predicate;
@property (retain) 	MSmartServerList *smartServerList;
@property (retain)	MServerList *serverList;

- (void)setSmartListName:(NSString *)name;
- (NSString *)smartListName;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

- (void)runModalSheetForWindow:(NSWindow *)window;

@end
