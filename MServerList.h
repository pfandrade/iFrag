//
//  MServerList.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 06/11/11.
//  Copyright 2006 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MGenericGame;
@class MProgressDelegate;
@class MServer;

@interface MServerList : NSManagedObject {
	
}

+ (id)createServerListForGame:(MGenericGame *)theGame inContext:(NSManagedObjectContext *)context;

- (void)refreshServersFromStore:(NSArray *)objectIDs;

#pragma mark Accessors
- (NSString *)gameServerType;
- (void)setGameServerType:(NSString *)value;
- (BOOL)validateGameServerType: (id *)valueRef error:(NSError **)outError;

- (MGenericGame *)game;
- (void)setGame:(MGenericGame *)value;

- (NSNumber *)busyFlag;
- (void)setBusyFlag:(NSNumber *)value;

- (NSData *)serializedProgressDelegate;
- (void)setSerializedProgressDelegate:(NSData *)value;

- (MProgressDelegate *)progressDelegate;
- (void)setProgressDelegate:(MProgressDelegate *)value;

//derived attributes

- (NSDictionary *)infoDict;
- (void)setInfoDict:(NSDictionary *)infoDict;

- (NSString *)name;
- (void)setName:(NSString *)value;

- (NSImage *)icon;
- (void)setIcon:(NSImage *)value;

- (MServer *)serverWithAddress:(NSString *)address;

#pragma mark Modifiers

	// Access to-many relationship via -[NSObject mutableSetValueForKey:]
- (void)addServersObject:(MServer *)value;
- (void)removeServersObject:(MServer *)value;

- (void)addServers:(NSSet *)inServers;
- (void)removeServers:(NSSet *)inServers;

- (void)reload;
- (void)refreshServers:(NSArray *)inServers;

@end
