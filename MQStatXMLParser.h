//
//  MQStatXMLParser.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 06/11/11.
//  Copyright 2006 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MServer;
@class MPlayer;
@class MServerList;

@interface MQStatXMLParser : NSObject {
	BOOL shouldStop;
	@private
	id progressDelegate;
//	NSManagedObjectContext *context;
	MServerList *sl;
	NSNumber *count;
	NSMutableArray *currentServers;
	NSMutableDictionary *currentServer;
	NSMutableDictionary *currentRules;
	NSString *currentRuleName;
	NSMutableArray *currentPlayers;
	NSDictionary *currentPlayer;
	NSMutableString *currentString;
	BOOL inElement, inPlayers;
	NSAutoreleasePool *innerPool;
	int serverSyncStep, serverCount;
	NSPort *port;
//	NSMutableArray *objectsToSync;
}

- (id)progressDelegate;
- (void)setProgressDelegate:(id)value;

- (BOOL)shouldStop;
- (void)setShouldStop:(BOOL)value;

- (void)sendTerminateMessage;

- (void)parseServers:(NSArray *)args;

//private
- (NSString *)replaceEscapedCharacters:(NSString *)string;
- (void)syncObjectsWithMainThread;

@end
