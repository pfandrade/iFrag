//
//  MServerListsController.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/05/01.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import "MServerListsController.h"
#import "MGenericGame.h"
#import "MServerList.h"

@implementation MServerListsController

- (void)awakeFromNib
{
	[self refreshInstalledGames];
}

- (void)refreshInstalledGames
{
	NSArray *serverLists = [self arrangedObjects];
	if([serverLists count] == 0){ //Favorites is always installed, so this means it hasn't been initialized
		NSError *error;
		[self fetchWithRequest:nil merge:NO error:&error];
		serverLists = [self arrangedObjects];
	}
	NSArray *installedGames = [MGenericGame installedGames];
	
	NSArray *installedGamesStrings	= [installedGames valueForKey:@"serverTypeString"];
	NSLog(@"%@",installedGamesStrings);
	NSArray *serverListsStrings		= [serverLists valueForKey:@"gameServerType"];
	NSLog(@"%@",serverListsStrings);
	NSString *gameString;
	int i;
	for( i = 0 ; i < [installedGamesStrings count]; i++){
		gameString = [installedGamesStrings objectAtIndex:i];
		
		if(![serverListsStrings containsObject:[gameString uppercaseString]]){ //if we don't have this game yet
			[self addObject:[MServerList createServerListForGame:[installedGames objectAtIndex:i] inContext:[self managedObjectContext]]];
		}
	}
//TODO: retirar os jogos que ja nao estao instalados	
//	NSEnumerator *existing_SLs = [[serverLists allValues] objectEnumerator];
//	NSString *errorDesc;
//	NSString *recoveryDesc;
//	NSArray *recoveryOpts;
//	NSDictionary *userInfo;
//	
//	while(current_sl = [existing_SLs nextObject]){
//		if(![inst_games containsObject:[current_sl game]]){
//			// Let's try and ask what to do
//			errorDesc = [NSString stringWithFormat:@"%@ appears to no longer be installed.", [current_sl name]];
//			recoveryDesc = @"It will be removed from the list.";
//			recoveryOpts = [NSArray arrayWithObjects:@"OK", nil];
//			userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:errorDesc,recoveryDesc,recoveryOpts,nil]
//												   forKeys:[NSArray arrayWithObjects:NSLocalizedDescriptionKey,NSLocalizedRecoverySuggestionErrorKey,NSLocalizedRecoveryOptionsErrorKey,nil]];
//			[delegate willRemoveGame:[current_sl game] reason:[NSError errorWithDomain:MIFragErrorDomain code:MEGNLI userInfo:userInfo]];
//			[self uninstallServerListForGame:[current_sl game]];
//		}
//	}
}

@end
