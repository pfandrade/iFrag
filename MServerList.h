//
//  MServerList.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 06/11/11.
//  Copyright 2006 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

static NSString *const MQueryTerminatedNotification = @"QueryTerminatedNotification";

@class MGenericGame;
@class MProgressDelegate;
@class MServer;
@class MQuery;

@interface MServerList : NSManagedObject {
	BOOL busyFlag;
	BOOL needsReload;
	MProgressDelegate *progressDelegate;
	MQuery *currentQuery;	
}
+ (id)createServerListForGame:(MGenericGame *)theGame inContext:(NSManagedObjectContext *)context;

- (void)insertServers:(NSArray *)servers;

#pragma mark Accessors
- (NSString *)gameServerType;
- (void)setGameServerType:(NSString *)value;

- (MGenericGame *)game;
- (void)setGame:(MGenericGame *)value;

#pragma mark Temporary attributes
- (BOOL)busyFlag;
- (void)setBusyFlag:(BOOL)value;

- (BOOL)needsReload;
- (void)setNeedsReload:(BOOL)value;

- (MProgressDelegate *)progressDelegate;
- (void)setProgressDelegate:(MProgressDelegate *)value;

#pragma mark Derived attributes

- (NSDictionary *)infoDict;
- (void)setInfoDict:(NSDictionary *)infoDict;

- (NSString *)name;
- (void)setName:(NSString *)value;

- (NSImage *)icon;
- (void)setIcon:(NSImage *)value;

#pragma mark Modifiers

	// Access to-many relationship via -[NSObject mutableSetValueForKey:]
- (void)addServersObject:(MServer *)value;
- (void)removeServersObject:(MServer *)value;

- (void)addServers:(NSSet *)inServers;
- (void)removeServers:(NSSet *)inServers;

- (BOOL)reload;
- (BOOL)refreshServers:(NSArray *)inServers;

#pragma mark Actions
- (void)terminateQuery;
- (void)queryTerminated;

@end
