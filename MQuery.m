//
//  MQuery.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/04/23.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import "MQuery.h"
#import "MProgressDelegate.h"
#import "MQStatTask.h"
#import "MGenericGame.h"
#import "MServerList.h"
#import "MServer.h"
#import "MQStatXMLParser.h"

@implementation MQuery

- (void) dealloc {
	[progressDelegate finished];
	[progressDelegate release];
	[super dealloc];
}

- (id)progressDelegate {
    return [[progressDelegate retain] autorelease];
}

- (void)setProgressDelegate:(id)value {
    if (progressDelegate != value) {
        [progressDelegate release];
        progressDelegate = [value retain];
    }
}

- (void)reloadServerList:(MServerList *)sl
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[progressDelegate started];
//	id qstat = [[MQStatTask alloc] init];
//	NSURL *qstatQueryResultingXMLFile;
//	
//	qstatQueryResultingXMLFile = [qstat queryGameServer:[[sl game] masterServerAddress]
//										 withServerType:[[sl game] masterServerFlag]];
//	
//	[qstat waitUntilExit];
//	
//	if ([qstat terminationStatus] != 0){ //ups something went wrong
//		[progressDelegate finished];
//		//@throw [[NSException alloc] initWithName:@"QStat query failed" reason:@"No Internet connection?" userInfo:nil];
//		//TODO: NSAlert instead?
//		return;
//	}
//	[qstat release];

	NSURL *qstatQueryResultingXMLFile = [NSURL fileURLWithPath:@"/Users/cereal/Desktop/iFrag_stuff/qstat_small.xml"];
	MQStatXMLParser *qParser = [MQStatXMLParser new];
	NSArray *parsedServers = [qParser parseServersInURL:qstatQueryResultingXMLFile 
										 fromServerList:sl 
										   withDelegate:[self progressDelegate]
												  count:nil];
	[progressDelegate finished];
	[qParser release];
	
	[sl addServers:[NSSet setWithArray:parsedServers]];
	[[NSNotificationCenter defaultCenter] postNotificationName:MQueryDidTerminateNotification 
														object:self];
	[pool release];
}

- (void)refreshGameServers:(NSArray *)servers
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if(servers == nil || [servers count] == 0){
		return;
	}
	MServerList *sl = [[servers objectAtIndex:0] inServerList];
	
	[progressDelegate started];
	MQStatTask *qstat = [[MQStatTask alloc] init];
	NSURL *qstatQueryResultingXMLFile;

	qstatQueryResultingXMLFile = [qstat queryGameServers:servers];
	
	[(NSTask *)qstat waitUntilExit];
	
	MQStatXMLParser *qParser = [MQStatXMLParser new];
	[qParser parseServersInURL:qstatQueryResultingXMLFile 
				fromServerList:sl 
				  withDelegate:[self progressDelegate]
						 count:[NSNumber numberWithInt:[servers count]]];
	
	[progressDelegate finished];
	[qParser release];
	[qstat release];
	[[NSNotificationCenter defaultCenter] postNotificationName:MQueryDidTerminateNotification 
														object:self];
	[pool release];
}

@end
