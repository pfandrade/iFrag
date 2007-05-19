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

- (void)sendTerminateMessage
{
	NSPortMessage *message = [[NSPortMessage alloc] initWithSendPort:sendPort receivePort:nil components:nil];
	[message setMsgid:kQueryTerminated];
	[message sendBeforeDate:[NSDate date]];
	
	[message release];	
}

- (void)reloadServerList:(NSArray *)args
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	// create new context for this thread
	NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
	[context setPersistentStoreCoordinator:[[NSApp delegate] persistentStoreCoordinator]];
	[context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
	[context setUndoManager:nil];
	
	MServerList *sl = (MServerList *)[context objectWithID:[args objectAtIndex:0]];
	sendPort = [args objectAtIndex:1];
	
	[progressDelegate started];
	
	/*** qstat  ***/
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
//		//TODO: NSAlert instead? E AQUI N PODE SER RETURN! E PRECISO IR ENVIAR A MSG
//		return;
//	}
//	[qstat release];
	/*************/
	
	NSURL *qstatQueryResultingXMLFile = [NSURL fileURLWithPath:@"/Users/cereal/Desktop/stuff/iFrag_stuff/qstat_out.xml"];
	
	/*** xmlParser ***/
	MQStatXMLParser *qParser = [MQStatXMLParser new];
	[qParser setProgressDelegate:progressDelegate];
	
	[qParser parseServersInURL:qstatQueryResultingXMLFile
				  toServerList:sl
						 count:nil
					   context:context];
	[qParser release];

//	[[NSFileManager defaultManager] removeFileAtPath:[qstatQueryResultingXMLFile path] handler:nil];
	/****************/
	[progressDelegate finished];
	
	[context release];
	[self sendTerminateMessage];
	[pool release];
}

- (void)refreshGameServers:(NSArray *)args
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	// create new context for this thread
	NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
	[context setPersistentStoreCoordinator:[[NSApp delegate] persistentStoreCoordinator]];
	[context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
	[context setUndoManager:nil];
	
	MServerList *sl = (MServerList *)[context objectWithID:[args objectAtIndex:0]];
	NSArray *servers = (NSArray *)[args objectAtIndex:1];
	sendPort = [args objectAtIndex:2];
	
	[progressDelegate started];
	
	/*** qstat  ***/
	MQStatTask *qstat = [[MQStatTask alloc] init];
	NSURL *qstatQueryResultingXMLFile;

	qstatQueryResultingXMLFile = [qstat queryGameServers:servers];
	
	[(NSTask *)qstat waitUntilExit];
	[qstat release];
	/*************/
	/*** xmlParser ***/
	MQStatXMLParser *qParser = [MQStatXMLParser new];
	[qParser setProgressDelegate:progressDelegate];
	
	//TODO: try catch aqui por causa do NoInternetConnection etc.
	[qParser parseServersInURL:qstatQueryResultingXMLFile
				  toServerList:sl
						 count:[NSNumber numberWithInt:[servers count]]
					   context:context];
	[qParser release];
	[[NSFileManager defaultManager] removeFileAtPath:[qstatQueryResultingXMLFile path] handler:nil]; 
	/****************/
	[progressDelegate finished];

	[context release];
	[self sendTerminateMessage];	
	[pool release];
}

@end
