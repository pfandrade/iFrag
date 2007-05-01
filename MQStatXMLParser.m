//
//  MQStatXMLParser.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 06/11/11.
//  Copyright 2006 Maracuja Software. All rights reserved.
//

#import "MQStatXMLParser.h"
#import "MServerList.h"
#import "MServer.h"
#import "MPlayer.h"
#import "MRule.h"
#import "MProgressDelegate.h"

@interface NSObject (ServerListPrivateMethod)
	- (NSNumber *)refreshServerCount;
@end

@implementation MQStatXMLParser

-(id)init
{
	if ((self = [super init])) {
		inElement = NO;
    }
    return self;
}

-(void)dealloc
{
	[count release];
	[qstatParser release];
	[serverList release];
	[progressDelegate release];
	[currentServer release];
//	[currentRules release];
	[currentRuleName release];
//	[currentPlayers release];
	[currentPlayer release];
	[currentString release];	
	[super dealloc];
}

- (NSArray *)parseServersInURL:(NSURL *)file fromServerList:(id)sl withDelegate:(id)delegate count:(NSNumber *)n
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	serverList = (MServerList *)[sl retain];
	progressDelegate = [delegate retain];
	count = [n retain];

	if(qstatParser){
		[qstatParser release];
	}
	
	qstatParser = [[NSXMLParser alloc] initWithContentsOfURL:file];
	[qstatParser setDelegate:self];
	[qstatParser setShouldProcessNamespaces:YES];
	[qstatParser setShouldResolveExternalEntities:NO];
	[qstatParser parse];
	[pool release];
	
	return [parsedServers autorelease];
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	if(count != nil){
		parsedServers = [[NSMutableArray alloc] initWithCapacity:[count unsignedIntValue]];
		[progressDelegate startedProcessing:[count intValue]];
	}
	
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	//[serverList addServers:parsedServers];
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
			[parsedServers release];
			parsedServers = [[NSMutableArray alloc] initWithCapacity:[nServers intValue]];
			[progressDelegate startedProcessing:[nServers intValue]];
			currentServer = nil;
			return;
		}

		 //Isto nao devia acontecer
		[currentServer release];
		currentServer = [[MServer createServerWithAddress:[attributeDict objectForKey:@"address"]] retain];
		
		NSString *status = [attributeDict objectForKey:@"status"]; 
		if([status isEqualToString:@"DOWN"] || [status isEqualToString:@"TIMEOUT"]){
			[currentServer setPing:[NSNumber numberWithInt:9999]];
			[currentServer setName:[NSString stringWithFormat:@"unknown (%@)",[attributeDict objectForKey:@"address"]]];
//			[currentServer setPlayers:[[NSMutableArray new] autorelease]];
//			[currentServer setRules:[[NSMutableDictionary new] autorelease]];
			[currentServer setNumplayers:[NSNumber numberWithInt:-1]];
			[currentServer setMaxplayers:[NSNumber numberWithInt:-1]];
		}
		[currentServer setServerType:[attributeDict objectForKey:@"type"]];
		[currentServer setAddress:[attributeDict objectForKey:@"address"]];
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
		//if (currentRules){
//			 //Isto nao devia acontecer
//			[currentRules release];
//		}
//		currentRules = [[NSMutableDictionary alloc] init];
        return;
    }

	// --------- Element rule ---------
	if ([elementName isEqualToString:@"rule"]) {
		inElement = YES;
		if (currentRuleName){
			 //Isto nao devia acontecer
			[currentRuleName release];
		}
		currentRuleName = [[attributeDict objectForKey:@"name"] retain];
        return;
    }

	// --------- Element players ---------
	if ([elementName isEqualToString:@"players"]) {
		//if (currentPlayers){
//			 //Isto nao devia acontecer
//			[currentPlayers release];
//		}
//		currentPlayers = [[NSMutableArray alloc] init];
		inPlayers = YES;
        return;
	}
	
	//  --------- Element player ---------
	if ([elementName isEqualToString:@"player"]) {
		if (currentPlayer){
			 //Isto nao devia acontecer
			[currentPlayer release];
		}
		currentPlayer = [[MPlayer createPlayer] retain];
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
		[parsedServers addObject:currentServer];
		[currentServer release]; currentServer = nil;
		[progressDelegate incrementByOne];
		return;
    }
	
	// --------- Element name ---------	
	if ([elementName isEqualToString:@"name"]) {
		if(inPlayers){
			[currentPlayer setName:currentString];
			[currentString release]; currentString = nil;
			inElement = NO;
			return;
		}
		[currentServer setName:currentString];
		[currentString release]; currentString = nil;
		inElement = NO;
		return;
    }
	
	// --------- Element gametype ---------	
	if ([elementName isEqualToString:@"gametype"]) {
		[currentServer setGameType:currentString];
		[currentString release]; currentString = nil;
		inElement = NO;
        return;
    }
	
	// --------- Element map ---------	
	if ([elementName isEqualToString:@"map"]) {
		[currentServer setMap:currentString];
		[currentString release]; currentString = nil;
		inElement = NO;
        return;
    }
	
	// --------- Element numplayers ---------	
	if ([elementName isEqualToString:@"numplayers"]) {
		[currentServer setNumplayers:[NSNumber numberWithInt:[currentString intValue]]];
		[currentString release]; currentString = nil;
		inElement = NO;
        return;
    }

	// --------- Element maxplayers ---------	
	if ([elementName isEqualToString:@"maxplayers"]) {
		[currentServer setMaxplayers:[NSNumber numberWithInt:[currentString intValue]]];
		[currentString release]; currentString = nil;
		inElement = NO;
        return;
    }
	
	// --------- Element ping ---------	
	if ([elementName isEqualToString:@"ping"]) {
		if(inPlayers){
			[currentPlayer setPing:[NSNumber numberWithInt:[currentString intValue]]];
			[currentString release]; currentString = nil;
			inElement = NO;
			return;
		}		
		[currentServer setPing:[NSNumber numberWithInt:[currentString intValue]]];
		[currentString release]; currentString = nil;
		inElement = NO;
        return;
    }
	
	// --------- Element rules ---------
	if ([elementName isEqualToString:@"rules"]) {
		//[currentServer setRules:currentRules];
//		[currentRules release]; currentRules = nil;
        return;
    }
	
	// --------- Element rule ---------
	if ([elementName isEqualToString:@"rule"]) {
		//[currentRules setObject:currentString forKey:currentRuleName];
		MRule *rule = [MRule createRule];
		[rule setName:currentRuleName]; [rule setValue:currentString];
		[currentServer addRulesObject:rule];
		[currentString release]; currentString = nil;
		[currentRuleName release]; currentRuleName = nil;
		inElement = NO;
        return;
    }
	
	// --------- Element players ---------
	if ([elementName isEqualToString:@"players"]) {
	//	[currentServer setPlayers:currentPlayers];
//		[currentPlayers release]; currentPlayers = nil;
		inPlayers = NO;
		return;
	}
	
	//  --------- Element player ---------
	if ([elementName isEqualToString:@"player"]) {
		//[currentPlayers addObject:currentPlayer];
		[currentServer addPlayersObject:currentPlayer];
		[currentPlayer release]; currentPlayer = nil;
        return;
	}
	
	// --------- Element score ---------	
	if ([elementName isEqualToString:@"score"]) {
		[currentPlayer setScore:[NSNumber numberWithInt:[currentString intValue]]];
		[currentString release]; currentString = nil;
		inElement = NO;
        return;
    }
	
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	[currentServer release];
//	[currentRules release];
	[currentRuleName release];
//	[currentPlayers release];
	[currentPlayer release];
	[currentString release];
	[parsedServers release];
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
@end
