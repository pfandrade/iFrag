//
//  MServer.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 06/11/09.
//  Copyright 2006 Maracuja Software. All rights reserved.
//

#import "MServer.h"
#import "MGenericGame.h"
#import "MPlayer.h"
#import "MRules.h"


@implementation MServer

static NSLock *existingAddressesLock = nil;
static NSMutableDictionary *existingAddresses = nil;

+ (void)initialize
{
	[self setKeys:[NSArray arrayWithObjects:@"numplayers", @"maxplayers", nil] triggerChangeNotificationsForDependentKey:@"fullness"];
	[self setKeys:[NSArray arrayWithObjects:@"rules", nil] triggerChangeNotificationsForDependentKey:@"serverFlags"];
	existingAddressesLock = [NSLock new];
}

+ (void)initExistingAddresses
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSManagedObjectContext *context = [[NSApp delegate] managedObjectContext];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *ed = [NSEntityDescription entityForName:@"Server" inManagedObjectContext:context];
        [fetchRequest setEntity:ed];
        
        NSArray *results = [context executeFetchRequest:fetchRequest error:nil];
        existingAddresses = [[NSMutableDictionary alloc] initWithObjects:[results valueForKey:@"objectID"]
                                                                 forKeys:[results valueForKey:@"address"]];
    });

	
}

+ (MServer *)createServerWithAddress:(NSString *)address inContext:(NSManagedObjectContext *)context
{
//	NSManagedObjectModel *model = [[NSApp delegate] managedObjectModel];
//	MServer *server;
//	
//	NSError *error = nil;
//	NSDictionary *substitutionDictionary = [NSDictionary dictionaryWithObjectsAndKeys: address, @"ADDR", nil];
//	NSFetchRequest *fetchRequest =
//		[model fetchRequestFromTemplateWithName:@"serverWithAddress"
//						  substitutionVariables:substitutionDictionary];
//	NSEntityDescription *ed = [NSEntityDescription entityForName:@"Server" inManagedObjectContext:context];
//	[fetchRequest setEntity:ed];
//	
//	NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
//
//	if ([results count] == 0){
//		server = [NSEntityDescription insertNewObjectForEntityForName:@"Server"
//											   inManagedObjectContext:context];
//	} else {
//		server = [results objectAtIndex:0];
//	}

	[existingAddressesLock lock];
	if(existingAddresses == nil)
		[MServer initExistingAddresses];
	
	NSManagedObjectID *serverID = [existingAddresses objectForKey:address];
	[existingAddressesLock unlock];
	MServer *server;
	if(serverID == nil){
		server = [NSEntityDescription insertNewObjectForEntityForName:@"Server"
											   inManagedObjectContext:context];
		[server setAddress:address];
	}else{
		server = (MServer *)[context objectWithID:serverID];
	}
	
	return server;
}

- (void)didSave
{
	[existingAddressesLock lock];
	
	if(existingAddresses == nil)
		[MServer initExistingAddresses];
	
	if([self isDeleted]){
		[existingAddresses removeObjectForKey:[self primitiveValueForKey:@"address"]];
		[existingAddressesLock unlock];
		return;
	}
	
	if([existingAddresses objectForKey:[self primitiveValueForKey:@"address"]] == nil)
		[existingAddresses setObject:[self objectID] forKey:[self primitiveValueForKey:@"address"]];
	
	[existingAddressesLock unlock];
}

#pragma mark Derived attributes
- (NSAttributedString *)attributedName 
{
    NSAttributedString * tmpValue;
    
    [self willAccessValueForKey: @"attributedName"];
    tmpValue = [self primitiveValueForKey: @"attributedName"];
    [self didAccessValueForKey: @"attributedName"];
    
	if (tmpValue == nil) {
        MGenericGame *game = [self game];
		tmpValue = [game processName:[self name]];
		[self setPrimitiveValue:tmpValue forKey:@"attributedName"];
    }
	
    return tmpValue;
}

- (void)setAttributedName:(NSAttributedString *)value 
{
    [self willChangeValueForKey: @"attributedName"];
    [self setPrimitiveValue: value forKey: @"attributedName"];
    [self didChangeValueForKey: @"attributedName"];
}

- (NSString *)fullness 
{
    NSString * tmpValue;
    
    [self willAccessValueForKey: @"fullness"];
    tmpValue = [self primitiveValueForKey: @"fullness"];
    [self didAccessValueForKey: @"fullness"];
    
	if(YES){
		NSNumber *num_players = [self numplayers];
		NSNumber *max_players = [self maxplayers];
		tmpValue = [NSString stringWithFormat:@"%@/%@",	([num_players intValue] == -1) ? @"?" : num_players,
														([max_players intValue] == -1) ? @"?" : max_players];
		[self setPrimitiveValue:tmpValue forKey:@"fullness"];
	}
	
    return tmpValue;
}

- (void)setFullness:(NSString *)value 
{
    [self willChangeValueForKey: @"fullness"];
    [self setPrimitiveValue: value forKey: @"fullness"];
    [self didChangeValueForKey: @"fullness"];
}

- (MGenericGame *)game 
{
    MGenericGame * tmpValue;
    
    [self willAccessValueForKey: @"game"];
    tmpValue = [self primitiveValueForKey: @"game"];
    [self didAccessValueForKey: @"game"];
    
	if(tmpValue == nil){
		NSString *gameClassName = [MGenericGame gameClassNameWithServerTypeString:[self serverType]];
		if(gameClassName != nil){
			Class gameClass = objc_getClass([gameClassName UTF8String]);
			tmpValue = (gameClass != nil) ? [gameClass new] : [MGenericGame new];
		}
		[self setPrimitiveValue:tmpValue forKey:@"game"];
	}
	
    return tmpValue;
}

- (void)setGame:(MGenericGame *)value 
{
    [self willChangeValueForKey: @"game"];
    [self setPrimitiveValue: value forKey: @"game"];
    [self didChangeValueForKey: @"game"];
}

- (NSString *)stringRepresentation
{
	return [NSString stringWithFormat:@"%@\t%@\t%@\t%@\t%@\t%@\t%@",[self address], [self serverType],
		[[self attributedName] string], [self map], [self gameType], [self ping], [self fullness]];
}


- (NSAttributedString *)attributedRepresentation
{
	NSMutableAttributedString *mutAttS = [[NSMutableAttributedString alloc] initWithString:
		[NSString stringWithFormat:@"%@\t%@\t",[self address], [self serverType]]];
	
	[mutAttS appendAttributedString:[self attributedName]];
	[mutAttS appendAttributedString:[[[NSAttributedString alloc] initWithString:
		[NSString stringWithFormat:@"\t%@\t%@\t%@\t%@",[self map], [self gameType], [self ping], [self fullness]]] autorelease]];
	
	
	[mutAttS autorelease];
	return [[mutAttS copy] autorelease];
}

- (NSNumber *)isPunkbusterEnabled
{
	MGenericGame *g = [self game];
	return [NSNumber numberWithBool:[g isPunkbusterEnabled:self]];
}
- (NSNumber *)isPrivate
{
	MGenericGame *g = [self game];
	return [NSNumber numberWithBool:[g isPrivate:self]];
}

- (void)setIsPunkbusterEnabled:(NSNumber *)value
{
	//do nothing
}

- (void)setIsPrivate:(NSNumber *)value
{
	//do nothing
}

#pragma mark Property accessors
- (NSString *)address 
{
    NSString * tmpValue;
    
    [self willAccessValueForKey: @"address"];
    tmpValue = [self primitiveValueForKey: @"address"];
    [self didAccessValueForKey: @"address"];
    
    return tmpValue;
}

- (void)setAddress:(NSString *)value 
{
    [self willChangeValueForKey: @"address"];
    [self setPrimitiveValue: value forKey: @"address"];
    [self didChangeValueForKey: @"address"];
}

- (BOOL)validateAddress: (id *)valueRef error:(NSError **)outError 
{
    // Insert custom validation logic here.
    return YES;
}

- (NSString *)gameType 
{
    NSString * tmpValue;
    
    [self willAccessValueForKey: @"gameType"];
    tmpValue = [self primitiveValueForKey: @"gameType"];
    [self didAccessValueForKey: @"gameType"];
    
	if([tmpValue length] == 0){ // get the default gametype
		[self setGameType:[[self game] defaultGameType]];
		tmpValue = [self primitiveValueForKey: @"gameType"];
	}
	
    return tmpValue;
}

- (void)setGameType:(NSString *)value 
{
    [self willChangeValueForKey: @"gameType"];
    [self setPrimitiveValue: value forKey: @"gameType"];
    [self didChangeValueForKey: @"gameType"];
}

- (NSString *)map 
{
    NSString * tmpValue;
    
    [self willAccessValueForKey: @"map"];
    tmpValue = [self primitiveValueForKey: @"map"];
    [self didAccessValueForKey: @"map"];
    
    return tmpValue;
}

- (void)setMap:(NSString *)value 
{
    [self willChangeValueForKey: @"map"];
    [self setPrimitiveValue: value forKey: @"map"];
    [self didChangeValueForKey: @"map"];
}

- (NSNumber *)maxplayers 
{
    NSNumber * tmpValue;
    
    [self willAccessValueForKey: @"maxplayers"];
    tmpValue = [self primitiveValueForKey: @"maxplayers"];
    [self didAccessValueForKey: @"maxplayers"];
    
    return tmpValue;
}

- (void)setMaxplayers:(NSNumber *)value 
{
    [self willChangeValueForKey: @"maxplayers"];
    [self setPrimitiveValue: value forKey: @"maxplayers"];
    [self didChangeValueForKey: @"maxplayers"];
}

- (NSString *)name 
{
    NSString * tmpValue;
    
    [self willAccessValueForKey: @"name"];
    tmpValue = [self primitiveValueForKey: @"name"];
    [self didAccessValueForKey: @"name"];
    
    return tmpValue;
}

- (void)setName:(NSString *)value 
{
    [self willChangeValueForKey: @"name"];
    [self setPrimitiveValue: value forKey: @"name"];
    [self didChangeValueForKey: @"name"];
}

- (NSNumber *)numplayers 
{
    NSNumber * tmpValue;
    
    [self willAccessValueForKey: @"numplayers"];
    tmpValue = [self primitiveValueForKey: @"numplayers"];
    [self didAccessValueForKey: @"numplayers"];
    
    return tmpValue;
}

- (void)setNumplayers:(NSNumber *)value 
{
    [self willChangeValueForKey: @"numplayers"];
    [self setPrimitiveValue: value forKey: @"numplayers"];
    [self didChangeValueForKey: @"numplayers"];
}

- (NSNumber *)ping 
{
    NSNumber * tmpValue;
    
    [self willAccessValueForKey: @"ping"];
    tmpValue = [self primitiveValueForKey: @"ping"];
    [self didAccessValueForKey: @"ping"];
    
    return tmpValue;
}

- (void)setPing:(NSNumber *)value 
{
    [self willChangeValueForKey: @"ping"];
    [self setPrimitiveValue: value forKey: @"ping"];
    [self didChangeValueForKey: @"ping"];
}

- (NSString *)serverType 
{
    NSString * tmpValue;
    
    [self willAccessValueForKey: @"serverType"];
    tmpValue = [self primitiveValueForKey: @"serverType"];
    [self didAccessValueForKey: @"serverType"];
    
    return tmpValue;
}

- (void)setServerType:(NSString *)value 
{
    [self willChangeValueForKey: @"serverType"];
    [self setPrimitiveValue: [value uppercaseString] forKey: @"serverType"];
    [self didChangeValueForKey: @"serverType"];
}

- (BOOL)validateServerType: (id *)valueRef error:(NSError **)outError 
{
    // Insert custom validation logic here.
    return YES;
}

- (NSDate *)lastRefreshDate 
{
    NSDate * tmpValue;
    
    [self willAccessValueForKey: @"lastRefreshDate"];
    tmpValue = [self primitiveValueForKey: @"lastRefreshDate"];
    [self didAccessValueForKey: @"lastRefreshDate"];
    
    return tmpValue;
}

- (void)setLastRefreshDate:(NSDate *)value 
{
    [self willChangeValueForKey: @"lastRefreshDate"];
    [self setPrimitiveValue: value forKey: @"lastRefreshDate"];
    [self didChangeValueForKey: @"lastRefreshDate"];
}

- (MRules *)rules 
{
    id tmpObject;
    
    [self willAccessValueForKey: @"rules"];
    tmpObject = [self primitiveValueForKey: @"rules"];
    [self didAccessValueForKey: @"rules"];
    
    return tmpObject;
}

- (void)setRules:(MRules *)value 
{
    [self willChangeValueForKey: @"rules"];
    [self setPrimitiveValue: value
                     forKey: @"rules"];
    [self didChangeValueForKey: @"rules"];
}

- (NSDictionary *)rulesDict
{
	id tmpObject;
	[self willAccessValueForKey: @"rulesDict"];
	tmpObject = [[self rules] rules];
	[self didAccessValueForKey: @"rulesDict"];
	return tmpObject;
}

- (void)setRulesDict:(NSDictionary *)value
{
	MRules *myRules = [self rules];
	[self willChangeValueForKey: @"rulesDict"];
	if(myRules == nil){
		myRules = [MRules createRulesInContext:[self managedObjectContext]];
		[myRules setRules:value];
		[self setRules:myRules];
	}else{
		[[self rules] setRules:value];
	}
   [self didChangeValueForKey: @"rulesDict"];
}

- (void)addPlayersObject:(MPlayer *)value 
{    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"players" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    
    [[self primitiveValueForKey: @"players"] addObject: value];
    
    [self didChangeValueForKey:@"players" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
}

- (void)removePlayersObject:(MPlayer *)value 
{
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"players" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    
    [[self primitiveValueForKey: @"players"] removeObject: value];
    
    [self didChangeValueForKey:@"players" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    
	[[self managedObjectContext] deleteObject:value];
	
    [changedObjects release];
}

- (void)addInServerListsObject:(MServerList *)value 
{    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"inServerLists" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    
    [[self primitiveValueForKey: @"inServerLists"] addObject: value];
    
    [self didChangeValueForKey:@"inServerLists" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
}

- (void)removeInServerListsObject:(MServerList *)value 
{
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"inServerLists" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    
    [[self primitiveValueForKey: @"inServerLists"] removeObject: value];
    
    [self didChangeValueForKey:@"inServerLists" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
}


@end
