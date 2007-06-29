//
//  MServerListsController.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/05/01.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MServerListsController : NSArrayController {
	IBOutlet id serverListsOutlineView;
}

- (void)refreshInstalledGames;

@end
