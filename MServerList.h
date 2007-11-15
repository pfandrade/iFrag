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
@property (retain) NSString * gameServerType;
@property (retain) MGenericGame * game;
@property (retain) NSSet* servers;
@property (retain) NSSet* smartLists;

+ (id)createServerListForGame:(MGenericGame *)theGame inContext:(NSManagedObjectContext *)context;

- (void)mergeChanges:(NSNotification *)saveChangesNotification;

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
- (BOOL)reload;
- (BOOL)refreshServers:(NSArray *)inServers;

#pragma mark Actions
- (void)terminateQuery;
- (void)queryTerminated;

@end

@interface MServerList (CoreDataGeneratedAccessors)

- (void)addServersObject:(MServer *)value;
- (void)removeServersObject:(MServer *)value;
- (void)addServers:(NSSet *)value;
- (void)removeServers:(NSSet *)value;

- (void)addSmartListsObject:(NSManagedObject *)value;
- (void)removeSmartListsObject:(NSManagedObject *)value;
- (void)addSmartLists:(NSSet *)value;
- (void)removeSmartLists:(NSSet *)value;

@end
