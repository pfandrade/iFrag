//
//  MServerListsController.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/05/01.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MServerList;

@interface MServerListsController : NSArrayController {
	IBOutlet id serverListsOutlineView;
	// for drag&drop we need a reference to the servers controller
	// to verify that we can paste something
	IBOutlet id serversController;
	IBOutlet id treeController;
}

- (void)refreshInstalledGames;

@end
