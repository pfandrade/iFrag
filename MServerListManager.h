//
//  MServerListManager.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/02/28.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MServerList.h"

@interface MServerListManager : NSObject {
	NSMutableDictionary *serverLists;
	NSPersistentStoreCoordinator *psCoordinator;
	NSManagedObjectContext *context;
	id delegate;
	
}

+ (MServerListManager *)sharedManager;

- (void)setDelegate:(id)delegate;
- (id)delegate;

- (void)refreshInstalledGames;
- (MServerList *)serverListWithGame:(MGenericGame *)game;

- (unsigned int)countOfServerLists;
- (id)objectInServerListsAtIndex:(unsigned int)index;

@end

@interface NSObject (MServerListManagerDelegate)

- (void)willRemoveGame:(MGenericGame *)game reason:(NSError *)theError;

@end