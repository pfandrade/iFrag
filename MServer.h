//
//  MServer.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 06/11/09.
//  Copyright 2006 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MGenericGame;
@class MServerList;
@class MPlayer;
@class MRules;

@interface MServer : NSManagedObject {

}

+ (MServer *)createServerWithAddress:(NSString *)address inContext:(NSManagedObjectContext *)context;
+ (void)initExistingAddresses;

#pragma mark Derived properties
- (NSAttributedString *)attributedName;
- (void)setAttributedName:(NSAttributedString *)value;

- (NSString *)fullness;
- (void)setFullness:(NSString *)value;

- (MGenericGame *)game;
- (void)setGame:(MGenericGame *)value;

- (NSString *)stringRepresentation;
- (NSAttributedString *)attributedRepresentation;

- (NSNumber *)isPunkbusterEnabled;
- (void)setIsPunkbusterEnabled:(NSNumber *)value;

- (NSNumber *)isPrivate;
- (void)setIsPrivate:(NSNumber *)value;

#pragma mark Property accessors
- (NSString *)address;
- (void)setAddress:(NSString *)value;
- (BOOL)validateAddress: (id *)valueRef error:(NSError **)outError;

- (NSString *)gameType;
- (void)setGameType:(NSString *)value;

- (NSString *)map;
- (void)setMap:(NSString *)value;

- (NSNumber *)maxplayers;
- (void)setMaxplayers:(NSNumber *)value;

- (NSString *)name;
- (void)setName:(NSString *)value;

- (NSNumber *)numplayers;
- (void)setNumplayers:(NSNumber *)value;

- (NSNumber *)ping;
- (void)setPing:(NSNumber *)value;

- (NSString *)serverType;
- (void)setServerType:(NSString *)value;
- (BOOL)validateServerType: (id *)valueRef error:(NSError **)outError;

- (NSDate *)lastRefreshDate;
- (void)setLastRefreshDate:(NSDate *)value;

- (MRules *)rules;
- (void)setRules:(MRules *)value;

- (NSDictionary *)rulesDict;
- (void)setRulesDict:(NSDictionary *)value;

	// Access to-many relationship via -[NSObject mutableSetValueForKey:]
- (void)addPlayersObject:(MPlayer *)value;
- (void)removePlayersObject:(MPlayer *)value;

	// Access to-many relationship via -[NSObject mutableSetValueForKey:]
- (void)addInServerListsObject:(MServerList *)value;
- (void)removeInServerListsObject:(MServerList *)value;



@end
