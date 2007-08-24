//
//  MQuake4.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/08/16.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import "MQuake4.h"
#import <stdlib.h>

#define QUAKE4APPNAME @"Quake 4"

// this game name is not used anymore, we now use the bundleName
static NSString *const _gameName			= @"Quake 4";
static NSString *const _bundleIdentifier	= @"com.aspyr.Quake4";
static NSString *const _serverTypeString	= @"q4s";
static NSString *const _masterServerFlag	= @"q4m";
static NSString *const _masterServerAddress = @"q4master.idsoftware.com";
static NSString *const _defaultGameType		= @"q4base";
static NSString *const _defaultServerPort	= @"28004";

@implementation MQuake4

+ (BOOL)isInstalled {
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	
	//	return ([ws absolutePathForAppBundleWithIdentifier:_bundleIdentifier] != nil);
	//we have to use fullPathForApplication: because Aspyr though it would be great to have 
	//the same bundle indentifier for "Quake 4" and "Quake 4 Dedicated Server"
	return ([ws fullPathForApplication:QUAKE4APPNAME] != nil);
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
	
	int colorCode, len;
	float red, green, blue;
	
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
		if((colorCode == ('c' - '0'))){
			if(len > 4){
				red = abs([currentString characterAtIndex:1] - '0') / 10.0;
				green = abs([currentString characterAtIndex:2] -'0') / 10.0;
				blue = abs([currentString characterAtIndex:3] - '0') / 10.0;
				color = [NSColor colorWithDeviceRed:red green:green blue:blue alpha:1.0];
				subString = [currentString substringFromIndex:4];
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


+ (NSError *)connectToServer:(MServer *)server {
	//TODO:
	return nil;
}

#pragma mark Overriden Instance Methods

- (id) init {
//	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	
//	NSString *bundleName = [[[ws fullPathForApplication:QUAKE4APPNAME] lastPathComponent] stringByDeletingPathExtension];
	
	self = [super initWithGameName:_gameName
					 andBundlePath:[[NSWorkspace sharedWorkspace] fullPathForApplication:QUAKE4APPNAME]];
	if (self != nil) {
		bundleIdentifier = _bundleIdentifier;
	}
	return self;
}

+ (NSString *)serverTypeString {
    return _serverTypeString;
}

+ (NSString *)masterServerFlag {
    return _masterServerFlag;
}

+ (NSString *)masterServerAddress {
    return _masterServerAddress;
}

+ (NSString *)defaultGameType
{
	return _defaultGameType;
}

+ (NSString *)defaultServerPort
{
	return _defaultServerPort;
}

@end

