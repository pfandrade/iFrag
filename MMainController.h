//
//  MMainController.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 06/12/21.
//  Copyright 2006 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MThinSplitView.h"
#import "MInnerSplitView.h"
#import "AMButtonBar.h"
#import "MInspectorWindowController.h"
#import "MDrawerController.h"
#import "MAddServerController.h"

NSString *iFragPBoardType = @"iFragPBoardType";

@interface MMainController : NSObject
{
	// Windows
    IBOutlet NSWindow *mainWindow;
	
	// Window Controllers
	NSWindowController *preferencesWindowController;
	MInspectorWindowController *inspectorWindowController;
	MDrawerController *playersDrawerController;
	MAddServerController *addServerWindowController;
	
	// Views
	IBOutlet id gamesOutlineView;
	IBOutlet id serversTableView;
	IBOutlet MThinSplitView *splitView;
	IBOutlet MInnerSplitView *rightSplitView;
	IBOutlet AMButtonBar *filterBar;
	
	// Controllers
    IBOutlet id serversController;
	IBOutlet id serverListsController;
	IBOutlet id serverTreeController;
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

@end
