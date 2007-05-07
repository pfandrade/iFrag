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

@interface MMainController : NSObject
{
	// Windows
    IBOutlet NSWindow *mainWindow;
	IBOutlet NSWindow *preferencesWindow;
	IBOutlet NSWindowController *addServerWindowController;
	
	// Views
	IBOutlet id gamesOutlineView;
	IBOutlet MThinSplitView *splitView;
	IBOutlet MInnerSplitView *rightSplitView;
	IBOutlet AMButtonBar *filterBar;
	
	// Controllers
    IBOutlet id serversController;
	IBOutlet id serverListsController;
	
}

- (void)resizedSplitView:(id)theSplitView toSize:(float)newSize;

#pragma mark Accessor Methods

- (id)mainSplitView;
- (id)innerRigthSplitView;

#pragma mark Actions
- (IBAction)showPreferences:(id)sender;

- (IBAction)reloadServerList:(id)sender;
- (IBAction)playGame:(id)sender;
- (IBAction)addToFavorites:(id)sender;
- (IBAction)addServer:(id)sender;
- (IBAction)removeServers:(id)sender;
- (IBAction)refreshSelectedServers:(id)sender;
- (IBAction)refreshServerList:(id)sender;

@end
