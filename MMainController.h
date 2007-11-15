//
//  MMainController.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 06/12/21.
//  Copyright 2006 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MInspectorWindowController;
@class MDrawerController;
@class MAddServerController;
@class MOutlineColumnController;
@class MThinSplitView;
@class MInnerSplitView;
@class AMButtonBar;
@class MSmartListEditorController;
@class MServersController;
@class MServerListsController;
@class MServerTreeController;

static NSString *const iFragPBoardType = @"iFragPBoardType";

@interface MMainController : NSObject
{
	// Windows
    IBOutlet NSWindow *mainWindow;
	
	// Window Controllers
	NSWindowController *preferencesWindowController;
	MInspectorWindowController *inspectorWindowController;
	MDrawerController *playersDrawerController;
	MAddServerController *addServerWindowController;
	MSmartListEditorController *smartListEditorWindowController;
	
	// Views
	IBOutlet id gamesOutlineView;
	IBOutlet id serversTableView;
	IBOutlet MThinSplitView *splitView;
	IBOutlet MInnerSplitView *rightSplitView;
	IBOutlet AMButtonBar *filterBar;
	
	// Controllers
    IBOutlet MServersController *serversController;
	IBOutlet MServerListsController *serverListsController;
	IBOutlet MServerTreeController *serverTreeController;
	MOutlineColumnController *outlineColumnController;
}

- (void)resizedSplitView:(id)theSplitView toSize:(float)newSize;

#pragma mark Accessor Methods

- (id)mainSplitView;
- (id)innerRigthSplitView;

#pragma mark Actions
- (IBAction)showPreferences:(id)sender;
- (IBAction)toggleInspector:(id)sender;
- (IBAction)togglePlayers:(id)sender;

- (IBAction)reloadServerList:(id)sender;
- (IBAction)playGame:(id)sender;
- (IBAction)addToFavorites:(id)sender;
- (IBAction)addServer:(id)sender;
- (IBAction)refreshSelectedServers:(id)sender;
- (IBAction)refreshServerList:(id)sender;
- (IBAction)reloadServerList:(id)sender;
- (IBAction)addSmartList:(id)sender;
- (IBAction)editSmartList:(id)sender;

@end
