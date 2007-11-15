//
//  CallOfDuty2.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/08/24.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import "MCallOfDuty2.h"
#import "MServer.h"

#define CALLOFDUTY2APPNAME @"Call of Duty 2 Multiplayer"

static NSString *const _gameName			= @"Call Of Duty 2";
static NSString *const _bundleIdentifier	= @"com.aspyr.callofduty2";
static NSString *const _serverTypeString	= @"cod2s";
static NSString *const _masterServerFlag	= @"cod2m";
static NSString *const _masterServerAddress = @"cod2master.activision.com";
static NSString *const _defaultGameType		= @"main";
static NSString *const _defaultServerPort	= @"28960";

@implementation MCallOfDuty2

+ (BOOL)isInstalled {
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	
	//	return ([ws absolutePathForAppBundleWithIdentifier:_bundleIdentifier] != nil);
	//we have to use fullPathForApplication: because Aspyr though it would be great to have 
	//the same bundle indentifier for "Quake 4" and "Quake 4 Dedicated Server"
	return ([ws fullPathForApplication:CALLOFDUTY2APPNAME] != nil);
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

- (NSError *)launchWithServer:(MServer *)server andPassword:(NSString *)pass{
	//TODO:
	return nil;
}

#pragma mark Overriden Instance Methods

- (id) init {
	//	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	
	//	NSString *bundleName = [[[ws fullPathForApplication:QUAKE4APPNAME] lastPathComponent] stringByDeletingPathExtension];
	
	self = [super initWithGameName:_gameName
					 andBundlePath:[[NSWorkspace sharedWorkspace] fullPathForApplication:CALLOFDUTY2APPNAME]];
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
	return ([[[server rulesDict] valueForKey:@"pswrd"] intValue] == 1);
}	

@end
