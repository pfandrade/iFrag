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

@interface MQStatXMLParser : NSObject {
	NSXMLParser *qstatParser;
	id progressDelegate;
	id serverList;
@private
	NSNumber *count;
	NSMutableArray *parsedServers;
	MServer *currentServer;
//	NSMutableDictionary *currentRules;
	NSString *currentRuleName;
//	NSMutableArray *currentPlayers;
	MPlayer *currentPlayer;
	NSMutableString *currentString;
	BOOL inElement, inPlayers;
}

- (NSArray *)parseServersInURL:(NSURL *)file fromServerList:(id)sl withDelegate:(id)delegate count:(NSNumber *)n;

//private
- (NSString *)replaceEscapedCharacters:(NSString *)string;

@end
