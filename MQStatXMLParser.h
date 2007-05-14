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
	@private
	NSXMLParser *qstatParser;
	id progressDelegate;
	NSManagedObjectContext *context;
	MServerList *sl;
	NSNumber *count;
	NSMutableSet *currentServers;
	MServer *currentServer;
	NSMutableSet *currentRules;
	NSString *currentRuleName;
	NSMutableSet *currentPlayers;
	MPlayer *currentPlayer;
	NSMutableString *currentString;
	BOOL inElement, inPlayers;
	NSAutoreleasePool *pool;
	int serverSyncStep, serverCount;
}

- (id)progressDelegate;
- (void)setProgressDelegate:(id)value;

- (void)parseServersInURL:(NSURL *)file toServerList:(MServerList *)slist count:(NSNumber *)n context:(NSManagedObjectContext *)moc;

//private
- (NSString *)replaceEscapedCharacters:(NSString *)string;
- (void)syncObjectsWithMainThread;

@end
