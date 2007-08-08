//
//  MQStatTask.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 06/11/05.
//  Copyright 2006 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define MCantCreateFileException @"Could not create file!"

@interface MQStatTask : NSObject {
	NSTask *qstat;
}

- (NSURL *)queryGameServers:(NSArray *)serverArray;
- (NSURL *)queryGameServer:(NSString *)serverAddress withServerType:(NSString *)serverType;

- (NSTask *)qstat;
- (void)setQstat:(NSTask *)value;

@end
