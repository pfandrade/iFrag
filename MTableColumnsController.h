//
//  MTableColumnsController.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/07/22.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MServerTreeController;

@interface MTableColumnsController : NSObject {
	IBOutlet NSTableView *serversTableView;
	IBOutlet NSOutlineView *serverListsOutlineView;
	IBOutlet MServerTreeController *serverListsController;
	IBOutlet NSArrayController *serversController;
	IBOutlet NSMenu *columnsMenu;
	NSMutableDictionary *columnsForGames;
	/*set up at init*/
	NSArray *availableTableColumnsIdentifiers;
}

- (IBAction)toggleColumn:(id)sender;

@end
