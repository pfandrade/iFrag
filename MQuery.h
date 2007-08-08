//
//  MQuery.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/04/23.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define kCheckinMessage 100
#define kQueryTerminated 101
#define kParserTerminated 102
#define kTerminateMessage 103

@class MServer;
@class MServerList;
@class MQStatTask;
@class MQStatXMLParser;

@interface MQuery : NSObject {
	@private
	MQStatTask *qstatTask;
	MQStatXMLParser *qParser;
	MServerList *serverList;
	NSNumber *serverCount;
	NSURL *qstatQueryResultingXMLFile;
}

- (void)terminate;
- (void)reloadServerList:(MServerList *)args;
- (void)refreshGameServers:(NSArray *)servers inServerList:(MServerList *)sl;

@end
