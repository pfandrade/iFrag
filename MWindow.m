//
//  MWindow.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 12/26/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "MWindow.h"


@implementation MWindow

- (void)flagsChanged:(NSEvent *)theEvent
{	
	if ([theEvent modifierFlags] & NSAlternateKeyMask){
		[addNewSmartListButton setHidden:NO];
		[addNewServerButton setHidden:YES];
	}
	else{
		[addNewServerButton setHidden:NO];
		[addNewSmartListButton setHidden:YES];
	}
	[super flagsChanged:theEvent];
}

- (void)toggleAlternateButtons
{
	if([addNewSmartListButton isHidden]){
		[addNewSmartListButton setHidden:NO];
		[addNewServerButton setHidden:YES];
	}else{
		[addNewServerButton setHidden:NO];
		[addNewSmartListButton setHidden:YES];
	}
}

@end
