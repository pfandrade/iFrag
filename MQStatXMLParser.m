//
//  MQStatXMLParser.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 06/11/11.
//  Copyright 2006 Maracuja Software. All rights reserved.
//

#import "MQStatXMLParser.h"
#import "MServer.h"
#import "MPlayer.h"
#import "MRules.h"
#import "MProgressDelegate.h"
#import "MServerList.h"
#import "MQuery.h"

@implementation MQStatXMLParser

+ (void)initialize{
	
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary
        dictionaryWithObject:[NSNumber numberWithInt:300]  forKey:@"serverSyncStep"];
	
    [defaults registerDefaults:appDefaults];
}

-(id)init
{
	if ((self = [super init])) {
		inElement = NO;
		shouldStop = NO;
    }
    return self;
}

-(void)dealloc
{
	[sl release];
	[count release];
	[progressDelegate release];
	[currentServers release];
	[currentServer release];
	[currentRules release];
	[currentRuleName release];
	[currentPlayers release];
	[currentPlayer release];
	[currentString release];
//	[objectsToSync release];
//	[context release];
	[port release];
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

- (BOOL)shouldStop {
    return shouldStop;
}

- (void)setShouldStop:(BOOL)value {
        shouldStop = value;
}

- (void)sendTerminateMessage
{
	NSPortMessage *message = [[NSPortMessage alloc] initWithSendPort:port receivePort:nil components:nil];
	[message setMsgid:kParserTerminated];
	[message sendBeforeDate:[NSDate date]];
	
	[message release];	
}

//- (void)parseServersInURL:(NSURL *)file toServerList:(MServerList *)slist count:(NSNumber *)n context:(NSManagedObjectContext *)moc
- (void)parseServers:(NSArray *)args
{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	
	// create new context for this thread
	//context = [[NSManagedObjectContext alloc] init];
	//[context setPersistentStoreCoordinator:[[NSApp delegate] persistentStoreCoordinator]];
	//[context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
	//[context setUndoManager:nil];
	
	NSURL *file = [args objectAtIndex:0];
	sl = [[args objectAtIndex:1] retain];
	count = [[args objectAtIndex:2] retain];
	port = [[args objectAtIndex:3] retain];
	
	currentServers = [NSMutableArray new];
	serverSyncStep = [[NSUserDefaults standardUserDefaults] integerForKey:@"serverSyncStep"];
	serverCount = 0;
	
	NSXMLParser *qstatParser = [[NSXMLParser alloc] initWithContentsOfURL:file];
	[qstatParser setDelegate:self];
	[qstatParser setShouldProcessNamespaces:NO];
	[qstatParser setShouldResolveExternalEntities:NO];
	
	innerPool = [[NSAutoreleasePool alloc] init];
	[qstatParser parse];
	[qstatParser release];
	
	[innerPool release];
	[pool release];
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	if((id)count != (id)[NSNull null]){
		[progressDelegate startedProcessing:[count intValue]];
	}
//	objectsToSync = [NSMutableArray new];
	
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	[self syncObjectsWithMainThread];
	[self sendTerminateMessage];
}

- (void)parser:(NSXMLParser *)parser 
didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qualifiedName 
	attributes:(NSDictionary *)attributeDict
{
	// --------- Element server ---------
	if ([elementName isEqualToString:@"server"]) {
		NSString *nServers;
		if((nServers = [attributeDict objectForKey:@"servers"]) != nil){
			[progressDelegate startedProcessing:[nServers intValue]];
			currentServer = nil;
			return;
		}

		 //Isto nao devia acontecer
		[currentServer release];
		currentServer = [NSMutableDictionary new];
		
		NSString *status = [attributeDict objectForKey:@"status"]; 
		if([status isEqualToString:@"DOWN"] || [status isEqualToString:@"TIMEOUT"]){
			[currentServer setValue:[NSNumber numberWithInt:9999] forKey:@"ping"];
//			if([currentServer valueForKey:@"name"] == nil)
//				[currentServer setName:[NSString stringWithFormat:@"unknown (%@)",[attributeDict objectForKey:@"address"]]];
//			[[currentServer mutableSetValueForKey:@"players"] removeAllObjects];
			[currentServer setValue:[NSNumber numberWithInt:-1] forKey:@"numplayers"];
			[currentServer setValue:[NSNumber numberWithInt:-1] forKey:@"maxplayers"];
		}
		[currentServer setValue:[attributeDict objectForKey:@"type"] forKey:@"serverType"];
		[currentServer setValue:[attributeDict objectForKey:@"address"] forKey:@"address"];
        return;
    }
	
	// --------- Element name ---------	
	if ([elementName isEqualToString:@"name"]) {
		inElement = YES;
    }
	
		// --------- Element gametype ---------	
	if ([elementName isEqualToString:@"gametype"]) {
		inElement = YES;
    }
	
	// --------- Element map ---------	
	if ([elementName isEqualToString:@"map"]) {
		inElement = YES;
    }
	
	// --------- Element numplayers ---------	
	if ([elementName isEqualToString:@"numplayers"]) {
		inElement = YES;
    }
	
	// --------- Element maxplayers ---------	
	if ([elementName isEqualToString:@"maxplayers"]) {
		inElement = YES;
    }
	
	// --------- Element ping ---------	
	if ([elementName isEqualToString:@"ping"]) {
		inElement = YES;
    }
	
			
	// --------- Element rules ---------
	if ([elementName isEqualToString:@"rules"]) {
		[currentRules release];
		currentRules = [NSMutableDictionary new];
        return;
    }

	// --------- Element rule ---------
	if ([elementName isEqualToString:@"rule"]) {
		inElement = YES;
		[currentRuleName release]; currentRuleName = nil;
		currentRuleName = [[attributeDict objectForKey:@"name"] retain];
        return;
    }

	// --------- Element players ---------
	if ([elementName isEqualToString:@"players"]) {
		[currentPlayers release];
		//currentPlayers = [[currentServer mutableSetValueForKey:@"players"] retain];
		//[currentPlayers removeAllObjects];
		currentPlayers = [NSMutableArray new];
		inPlayers = YES;
        return;
	}
	
	//  --------- Element player ---------
	if ([elementName isEqualToString:@"player"]) {
		[currentPlayer release]; currentPlayer = nil;
		currentPlayer = [NSMutableDictionary new];
        return;
	}
	
	// --------- Element score ---------	
	if ([elementName isEqualToString:@"score"]) {
		inElement = YES;
    }
}

- (void)parser:(NSXMLParser *)parser 
 didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName
{
	// --------- Element server ---------
	if ([elementName isEqualToString:@"server"]) {
		if(currentServer == nil){ //isto esta aqui para o caso especial do header
			return;
		}
		[currentServer setValue:[NSDate date] forKey:@"lastRefreshDate"];
		[currentServers addObject:currentServer];
//		[objectsToSync addObject:currentServer];
		[currentServer release]; currentServer = nil;
		[progressDelegate incrementByOne];

		if(++serverCount == serverSyncStep){
			[self syncObjectsWithMainThread];
			serverCount = 0;
		}
		
		//test to see if we should stop
		if(shouldStop){
			[parser abortParsing];
		}
		return;
    }
	
	// --------- Element name ---------	
	if ([elementName isEqualToString:@"name"]) {
		if(inPlayers){
			[currentPlayer setValue:currentString forKey:@"name"];
			[currentString release]; currentString = nil;
			inElement = NO;
			return;
		}
		[currentServer setValue:currentString forKey:@"name"];
		[currentString release]; currentString = nil;
		inElement = NO;
		return;
    }
	
	// --------- Element gametype ---------	
	if ([elementName isEqualToString:@"gametype"]) {
		[currentServer setValue:currentString forKey:@"gameType"];
		[currentString release]; currentString = nil;
		inElement = NO;
        return;
    }
	
	// --------- Element map ---------	
	if ([elementName isEqualToString:@"map"]) {
		[currentServer setValue:currentString forKey:@"map"];
		[currentString release]; currentString = nil;
		inElement = NO;
        return;
    }
	
	// --------- Element numplayers ---------	
	if ([elementName isEqualToString:@"numplayers"]) {
		[currentServer setValue:[NSNumber numberWithInt:[currentString intValue]] forKey:@"numplayers"];
		[currentString release]; currentString = nil;
		inElement = NO;
        return;
    }

	// --------- Element maxplayers ---------	
	if ([elementName isEqualToString:@"maxplayers"]) {
		[currentServer setValue:[NSNumber numberWithInt:[currentString intValue]] forKey:@"maxplayers"];
		[currentString release]; currentString = nil;
		inElement = NO;
        return;
    }
	
	// --------- Element ping ---------	
	if ([elementName isEqualToString:@"ping"]) {
		if(inPlayers){
			NSNumber *playerPing = [NSNumber numberWithInt:[currentString intValue]];
			if([playerPing intValue] > 999){
				playerPing = [NSNumber numberWithInt:999];
			}
			[currentPlayer setValue:playerPing forKey:@"ping"];
			[currentString release]; currentString = nil;
			inElement = NO;
			return;
		}		
		[currentServer setValue:[NSNumber numberWithInt:[currentString intValue]] forKey:@"ping"];
		[currentString release]; currentString = nil;
		inElement = NO;
        return;
    }
	
	// --------- Element rules ---------
	if ([elementName isEqualToString:@"rules"]) {
		[currentServer setValue:currentRules forKey:@"rules"];
		[currentRules release]; currentRules = nil;
        return;
    }
	
	// --------- Element rule ---------
	if ([elementName isEqualToString:@"rule"]) {
		//[currentRules setObject:currentString forKey:currentRuleName];
		//MRules *rule = [MRules createRuleInContext:context];
		//[rule setName:currentRuleName]; [rule setValue:currentString];
		[currentRules setValue:currentString forKey:currentRuleName];
		[currentString release]; currentString = nil;
		[currentRuleName release]; currentRuleName = nil;
		inElement = NO;
        return;
    }
	
	// --------- Element players ---------
	if ([elementName isEqualToString:@"players"]) {
		[currentServer setValue:currentPlayers forKey:@"players"];
		[currentPlayers release]; currentPlayers = nil;
		inPlayers = NO;
		return;
	}
	
	//  --------- Element player ---------
	if ([elementName isEqualToString:@"player"]) {
		[currentPlayers addObject:currentPlayer];
		[currentPlayer release]; currentPlayer = nil;
        return;
	}
	
	// --------- Element score ---------	
	if ([elementName isEqualToString:@"score"]) {
		[currentPlayer setValue:[NSNumber numberWithInt:[currentString intValue]] forKey:@"score"];
		[currentString release]; currentString = nil;
		inElement = NO;
        return;
    }
	
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	NSLog(@"PARSE ERROR OCCURRED:\n%@",parseError);
	[self syncObjectsWithMainThread];
	[self sendTerminateMessage];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if(!inElement)
		return;
	
	if(!currentString)
		currentString = [[NSMutableString alloc] init];
	[currentString appendString:
		[self replaceEscapedCharacters:
			[string stringByTrimmingCharactersInSet:
				[NSCharacterSet whitespaceAndNewlineCharacterSet]]]];
}

- (void)parser:(NSXMLParser *)parser parser:foundIgnorableWhitespace:(NSString *)string
{
	//Nunca e' chamado, penso que e' por n ter um DTD definido
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
	if(!inElement)
		return;
	
	if(!currentString)
		currentString = [[NSMutableString alloc] init];
	int dataLength = [CDATABlock length];
	char *buffer = (char *)malloc(dataLength);
	[CDATABlock getBytes:buffer];
	[currentString appendString:[self replaceEscapedCharacters:[NSString stringWithCString:buffer length:dataLength]]];
	free(buffer);
	[currentString autorelease];
	currentString = [[currentString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] retain];
}

- (void)parser:(NSXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model
{
	
}

- (NSString *)replaceEscapedCharacters:(NSString *)string
{
	NSMutableString *muts = [[NSMutableString alloc] initWithString:string];
	
	[muts replaceOccurrencesOfString:@"&amp;" withString:@"&" options:0 range:NSMakeRange(0,[muts length])];
	[muts replaceOccurrencesOfString:@"&lt;" withString:@"<" options:0 range:NSMakeRange(0,[muts length])];
	[muts replaceOccurrencesOfString:@"&gt;" withString:@">" options:0 range:NSMakeRange(0,[muts length])];
	
	return [muts autorelease];
}

- (void)syncObjectsWithMainThread
{	
//	NSMutableSet *objectIDsToSync = [[NSMutableSet alloc] initWithSet:[[context insertedObjects] valueForKey:@"objectID"]];
//	[objectIDsToSync unionSet:[[context updatedObjects] valueForKey:@"objectID"]];
	
	//flush changes to disk
//	NSError *error = nil;
//	[context save:&error];
//	if(error != nil)
//		NSLog(@"Save Error: %@", error);
//	NSArray *objectIDsToSync = [objectsToSync valueForKey:@"objectID"];
	// update mainthread
	[sl performSelectorOnMainThread:@selector(insertServers:)
						 withObject:currentServers
					  waitUntilDone:YES];

//	[objectsToSync release];
	[currentServers release];
//	NSManagedObjectID *tempOID = [sl objectID];
//	[sl release];
//	[currentServers release];
//	[context reset];
	//setup new autorelease pool
	[innerPool release];
	innerPool = [[NSAutoreleasePool alloc] init];
//	sl = [[context objectWithID:tempOID] retain];
	currentServers = [NSMutableArray new];
//	objectsToSync = [NSMutableArray new];
}

@end
