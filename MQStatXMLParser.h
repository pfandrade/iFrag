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
	NSManagedObjectContext *context;
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

- (id)progressDelegate;
- (void)setProgressDelegate:(id)value;


- (NSArray *)parseServersInURL:(NSURL *)file count:(NSNumber *)n context:(NSManagedObjectContext *)moc;

//private
- (NSString *)replaceEscapedCharacters:(NSString *)string;

@end
