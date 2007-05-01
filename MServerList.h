//
//  MServerList.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 06/11/11.
//  Copyright 2006 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MGenericGame.h"

@interface MServerList : NSManagedObject {
	
}

+ (id)createServerListForGame:(MGenericGame *)theGame;

#pragma mark Accessors
- (NSString *)gameServerType;
- (void)setGameServerType:(NSString *)value;
- (BOOL)validateGameServerType: (id *)valueRef error:(NSError **)outError;

- (MGenericGame *)game;
- (void)setGame:(MGenericGame *)value;

- (NSNumber *)busyFlag;
- (void)setBusyFlag:(NSNumber *)value;

- (MServer *)serverWithAddress:(NSString *)address;

- (NSString *)name;
- (NSImage *)icon;

#pragma mark Modifiers

	// Access to-many relationship via -[NSObject mutableSetValueForKey:]
- (void)addServersObject:(MServer *)value;
- (void)removeServersObject:(MServer *)value;

- (void)addServers:(NSSet *)inServers;
- (void)removeServers:(NSSet *)inServers;

- (void)reloadWithProgressDelegate:(id)delegate;
- (void)refreshServers:(NSArray *)inServers withProgressDelegate:(id)delegate;

@end
