//
//  MToolbarController.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 06/12/21.
//  Copyright 2006 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MMainController.h"

NSString *const MServerInfoItemIdentifier =	@"ServerInfoItem";
NSString *const MPlayersDrawerIdentifier  =	@"PlayersDrawerItem";
NSString *const MReloadServerList		  =	@"ReloadServerListItem";
NSString *const MRefreshServerList		  =	@"RefreshServerListItem";
NSString *const MPlayGame				  = @"PlayGameItem";
NSString *const MAddServer				  = @"AddServerItem";
NSString *const MDeleteServer			  = @"DeleteServerItem";

@interface  MToolbarController : NSObject
{
	IBOutlet id mainController;
	IBOutlet id serversController;
}

@end
