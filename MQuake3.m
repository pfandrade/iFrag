//
//  MQuake3.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/01/28.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import "MQuake3.h"
#import "MServer.h"

#include <stdlib.h> //para o abs
// this game name is not used anymore, we now use the bundleName
static NSString *const _gameName			= @"Quake 3";
static NSString *const _bundleIdentifier	= @"org.ioquake.ioquake3";
static NSString *const _serverTypeString	= @"q3s";
static NSString *const _masterServerFlag	= @"q3m";
static NSString *const _masterServerAddress = @"master.ioquake3.org";
static NSString *const _defaultGameType		= @"baseq3";
static NSString *const _defaultServerPort	= @"27960";


@implementation MQuake3

#pragma mark Overriden Abstract Class Methods

+ (BOOL)isInstalled {
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	
	return ([ws absolutePathForAppBundleWithIdentifier:_bundleIdentifier] != nil);
}

+ (NSAttributedString *)processName:(NSString *)name {
	static NSArray *colors;
	
	if(colors == nil){
		colors = [[NSArray arrayWithObjects:[NSColor blackColor],[NSColor redColor],[NSColor greenColor],[NSColor yellowColor],
											[NSColor blueColor],[NSColor colorWithCalibratedRed:0.18 green:1.0 blue:1.0 alpha:1.0],
											[NSColor purpleColor],[NSColor lightGrayColor],nil] retain];
	}
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSArray *slices = [name componentsSeparatedByString:@"^"];
	NSMutableAttributedString *attribString = [[NSMutableAttributedString alloc] init];
	NSEnumerator *str_enum = [slices objectEnumerator];

	NSString *currentString, *subString;
	NSColor *color = [NSColor blackColor]; //default color
	NSScanner *scanner1, *scanner2, *scanner3;
	int colorCode, len;
	unsigned red, green, blue;
	
	currentString = [str_enum nextObject];	//skip the first string
	if([currentString length] > 0) [attribString appendAttributedString:[[[NSAttributedString alloc] initWithString:currentString] autorelease]];

	while((currentString = [str_enum nextObject])){
		if ((len = [currentString length]) < 2){
			[attribString appendAttributedString:
				[[[NSAttributedString alloc] initWithString:@"^"
												 attributes:[NSDictionary dictionaryWithObject:color
																						forKey:NSForegroundColorAttributeName]] autorelease]];
			continue;
		}
		colorCode = [currentString characterAtIndex:0] - '0';
		if((colorCode == ('x' - '0'))){
			if(len > 7){
				scanner1 = [NSScanner scannerWithString:[currentString substringWithRange:NSMakeRange(1,2)]];
				scanner2 = [NSScanner scannerWithString:[currentString substringWithRange:NSMakeRange(3,2)]];
				scanner3 = [NSScanner scannerWithString:[currentString substringWithRange:NSMakeRange(5,2)]];
				if(![scanner1 scanHexInt:&red] || ![scanner2 scanHexInt:&green] || ![scanner3 scanHexInt:&blue]){
					color = [colors objectAtIndex:7];
					subString = [currentString substringFromIndex:1];
				}
				color = [NSColor colorWithDeviceRed:(red/255.0) green:(green/255.0) blue:(blue/255.0) alpha:1.0];
				subString = [currentString substringFromIndex:7];
			} else {
				color = [colors objectAtIndex:7];
				subString = [currentString substringFromIndex:1];
			}
		} else {
//			colorCode = (colorCode > 9 || colorCode < 0) ? 7 : colorCode; //Reset to white
			color = [colors objectAtIndex:abs((colorCode % 8))];
			subString = [currentString substringFromIndex:1];
		}
		[attribString appendAttributedString:
				[[[NSAttributedString alloc] initWithString:subString
												attributes:[NSDictionary dictionaryWithObject:color
																					   forKey:NSForegroundColorAttributeName]] autorelease]];
	}
	[pool release];
	return [attribString autorelease];
}

- (NSError *)launchWithServer:(MServer *)server andPassword:(NSString *)pass {
	NSString *path = [self executableGamePath];
	NSMutableArray *args = [[NSMutableArray alloc] init];
	
	// set game_type
	[args addObject:@"+set"]; [args addObject:@"fs_game"]; [args addObject:[server gameType]];
	// set punkbuster
	if([[server isPunkbusterEnabled] boolValue]){
		[args addObject:@"+set"]; [args addObject:@"cl_punkbuster"]; [args addObject:@"1"];
	}
	// set password
	if([[server isPrivate] boolValue]){
		[args addObject:@"+password"]; [args addObject:pass];
	}
	// set address
	[args addObject:@"+connect"]; [args addObject:[server address]];
#ifdef DEBUG
	NSLog(@"Lauching Quake3 with command line:\n%@ %@",path, [args componentsJoinedByString:@" "]);
#endif
	[NSTask launchedTaskWithLaunchPath:path arguments:[[args copy] autorelease]];
	[args release];
	return nil;
}

#pragma mark Overriden Instance Methods

- (id) init {	
	self = [super initWithGameName:_gameName 
					 andBundlePath:[[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:_bundleIdentifier]];
	
	if (self != nil) {
		bundleIdentifier = _bundleIdentifier;
	}
	return self;
}

- (NSString *)serverTypeString {
    return _serverTypeString;
}

- (NSString *)masterServerFlag {
    return _masterServerFlag;
}

- (NSString *)masterServerAddress {
    return _masterServerAddress;
}

- (NSString *)defaultGameType
{
	return _defaultGameType;
}

- (NSString *)defaultServerPort
{
	return _defaultServerPort;
}

- (BOOL)isPunkbusterEnabled:(MServer *)server
{
	return ([[[server rulesDict] valueForKey:@"sv_punkbuster"] intValue] == 1);
}

- (BOOL)isPrivate:(MServer *)server
{
	return ([[[server rulesDict] valueForKey:@"g_needpass"] intValue] == 1);
}	

@end
