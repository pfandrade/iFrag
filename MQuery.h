//
//  MQuery.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/04/23.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MServer;
@class MServerList;

static NSString *const MQueryDidTerminateNotification = @"QueryDidTerminate";

@interface MQuery : NSObject {
	@private
	id progressDelegate;
}

- (id)progressDelegate;
- (void)setProgressDelegate:(id)value;


- (void)reloadServerList:(MServerList *)sl;
- (void)refreshGameServers:(NSArray *)servers;

@end
