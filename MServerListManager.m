//
//  MServerListManager.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/02/28.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import "MServerListManager.h"
#import "MGenericGame.h"
#import "MErrorCodes.h"


@implementation MServerListManager

static MServerListManager *sharedServerListManager = nil;

+ (MServerListManager *)sharedManager
{
    @synchronized(self) {
        if (sharedServerListManager == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedServerListManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedServerListManager == nil) {
            sharedServerListManager = [super allocWithZone:zone];

            return sharedServerListManager;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
	return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

- (id)init
{
	self = [super init];
	
	serverLists = [[NSMutableDictionary alloc] init];
	psCoordinator = [[NSApp delegate] persistentStoreCoordinator];
	context = [[NSApp delegate] managedObjectContext];
	
	[self load];
	[self refreshInstalledGames];
	NSError *error = nil;
	[context save:&error];
	
	return self;
}

#pragma mark Interface methods

- (id)delegate {
    return [[delegate retain] autorelease];
}

- (void)setDelegate:(id)value {
    if (delegate != value) {
        [delegate release];
        delegate = [value retain];
    }
}

- (void)refreshInstalledGames
{
	NSArray *inst_games = [MGenericGame installedGames];
	NSEnumerator *inst_enum = [inst_games objectEnumerator];
	
	MGenericGame *current_game;
	MServerList *current_sl;
	while(current_game = [inst_enum nextObject]){
		current_sl = [serverLists objectForKey:current_game];
		if(current_sl == nil){
			[self installServerListForGame:current_game];
		}
	}
	
	NSEnumerator *existing_SLs = [[serverLists allValues] objectEnumerator];
	NSString *errorDesc;
	NSString *recoveryDesc;
	NSArray *recoveryOpts;
	NSDictionary *userInfo;
	
	while(current_sl = [existing_SLs nextObject]){
		if(![inst_games containsObject:[current_sl game]]){
			// Let's try and ask what to do
			errorDesc = [NSString stringWithFormat:@"%@ appears to no longer be installed.", [current_sl name]];
			recoveryDesc = @"It will be removed from the list.";
			recoveryOpts = [NSArray arrayWithObjects:@"OK", nil];
			userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:errorDesc,recoveryDesc,recoveryOpts,nil]
												   forKeys:[NSArray arrayWithObjects:NSLocalizedDescriptionKey,NSLocalizedRecoverySuggestionErrorKey,NSLocalizedRecoveryOptionsErrorKey,nil]];
			[delegate willRemoveGame:[current_sl game] reason:[NSError errorWithDomain:MIFragErrorDomain code:MEGNLI userInfo:userInfo]];
			[self uninstallServerListForGame:[current_sl game]];
		}
	}
}

- (NSError *)installServerListForGame:(MGenericGame *)game
{
	if([self isServerListInstalledForGame:game]){
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@ is already listed.", [game name]]
															 forKey:NSLocalizedDescriptionKey];
		return [NSError errorWithDomain:MIFragErrorDomain code:MEGAL userInfo:userInfo];
	}
	
	MServerList *new_sl = [MServerList createServerListForGame:game];
	[serverLists setObject:new_sl forKey:game];
	return nil;
}

- (NSError *)uninstallServerListForGame:(MGenericGame *)game
{
	if(![self isServerListInstalledForGame:game]){
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@ isn't listed.", [game name]]
															 forKey:NSLocalizedDescriptionKey];
		return [NSError errorWithDomain:MIFragErrorDomain code:MEGINL userInfo:userInfo];
	}
	[serverLists removeObjectForKey:game];
	return nil;
}

- (BOOL)isServerListInstalledForGame:(MGenericGame *)game
{
	return [serverLists objectForKey:game] != nil;
}

- (MServerList *)getServerListForGame:(MGenericGame *)game
{
	return [serverLists objectForKey:game];
}

- (NSArray *)installedServerLists
{
	return [serverLists allValues];
}

- (void)load
{
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ServerList"
														 inManagedObjectContext:context];
	[request setEntity:entityDescription];
	
	NSError *error = nil;
	NSArray *lists = [context executeFetchRequest:request error:&error];
	NSEnumerator *lists_enum = [lists objectEnumerator];
	MServerList *sl;
	while(sl = [lists_enum nextObject]){
		[serverLists setObject:sl forKey:[sl game]];
	}
}

@end
