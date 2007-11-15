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

+ (void)initialize{
	
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary
								 dictionaryWithObject:[NSNumber numberWithBool:NO]  forKey:@"pipeQstatOutput"];
	
    [defaults registerDefaults:appDefaults];
}

- (void) dealloc {
	[qstatTask release];
	[serverList release];
	[serverCount release];
	[qParser release];
	[qstatQueryResultingXMLFile release];
	[super dealloc];
}


- (void)terminate
{
	if(qstatTask != nil) {
		[[NSNotificationCenter defaultCenter] removeObserver:self 
														name:NSTaskDidTerminateNotification
													  object:[qstatTask qstat]];
		[[NSFileManager defaultManager] removeFileAtPath:[qstatQueryResultingXMLFile path] handler:nil];
		[[qstatTask qstat] terminate];		
		[[serverList progressDelegate] finished];
		[serverList queryTerminated];
	}
	if(qParser != nil){
		[qParser setShouldStop:YES]; // when this finishes it will signal this thread with kParserTerminated
	}
}

- (void)handlePortMessage:(NSPortMessage *)portMessage
{
	unsigned int messageID = [portMessage msgid];

	if(messageID == kParserTerminated){
		[[NSRunLoop currentRunLoop] removePort:[portMessage receivePort] forMode:NSDefaultRunLoopMode];
		[[NSFileManager defaultManager] removeFileAtPath:[qstatQueryResultingXMLFile path] handler:nil];
		[[serverList progressDelegate] finished];
		[serverList queryTerminated];
	}
}

- (void)reloadServerList:(MServerList *)sl
{
	serverList = [sl retain];
	
	[[serverList progressDelegate] started];
	
	/*** Start Qstat  ***/
	qstatTask = [[MQStatTask alloc] init];
	
	if([[NSUserDefaults standardUserDefaults] boolForKey:@"pipeQstatOutput"]){
		// TODO
	}else{
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(qstatTaskDidTerminate:) 
													 name:NSTaskDidTerminateNotification
												   object:[qstatTask qstat]];
		
		qstatQueryResultingXMLFile = [[qstatTask queryGameServer:[[sl game] masterServerAddress]
												  withServerType:[[sl game] masterServerFlag]] retain];
	}
	

	
//	qstatQueryResultingXMLFile = [[NSURL URLWithString:@"file://localhost/Users/cereal/Desktop/stuff/iFrag_stuff/qstat_small.xml"] retain];
//	[self qstatTaskDidTerminate:nil];
}

- (void)refreshGameServers:(NSArray *)servers inServerList:(MServerList *)sl
{	
	serverList = [sl retain];
	serverCount = [[NSNumber numberWithInt:[servers count]] retain];
	
	[[serverList progressDelegate] started];
	
	/*** Start Qstat  ***/
	qstatTask = [[MQStatTask alloc] init];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(qstatTaskDidTerminate:) 
												 name:NSTaskDidTerminateNotification
											   object:[qstatTask qstat]];
		
	qstatQueryResultingXMLFile = [[qstatTask queryGameServers:servers] retain];
}


- (void)qstatTaskDidTerminate:(NSNotification *)aNotification
{

	id qstat = [aNotification object];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:NSTaskDidTerminateNotification
												  object:qstat];
	[qstatTask release]; qstatTask = nil;

	if ([qstat terminationStatus] != 0){ 
		[[serverList progressDelegate] finished];
		//o qstat nunca se queixa de nada... por isso isto nunca deve acontecer
		//TODO mudar o codigo do qstat para retornar um teminationStatus??
		return;
	}else{
		/** Start the XML parser thread **/	
		NSPort *port = [NSMachPort port];
		[port setDelegate:self];
		[[NSRunLoop currentRunLoop] addPort:port forMode:NSDefaultRunLoopMode];
	
		qParser = [MQStatXMLParser new];
		[qParser setProgressDelegate:[serverList progressDelegate]];
		id w;
		if(serverCount == nil){
			w = [NSNull null];
		}else {
			w = serverCount;
		}
		NSArray *args = [NSArray arrayWithObjects:qstatQueryResultingXMLFile, serverList, w, port, nil];
		[NSThread detachNewThreadSelector:@selector(parseServers:) toTarget:qParser withObject:args];
	}
}

@end
