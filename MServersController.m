//
//  MServersController.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/04/05.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import "MServersController.h"

@implementation MServersController

+ (void)initialize{
	
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary
        dictionaryWithObject:[NSNumber numberWithBool:YES]  forKey:@"colorizeServers"];
	
    [defaults registerDefaults:appDefaults];
}

- (void)awakeFromNib
{
	[[NSNotificationCenter defaultCenter] addObserver:serversTableView 
											 selector:@selector(setNeedsDisplay) 
												 name:NSUserDefaultsDidChangeNotification
											   object:nil];
}

	
#pragma mark Actions

- (IBAction)serverInfo:(id)sender
{
	if([infoWindow isVisible])
		[infoWindow orderOut:self];
	else
		[infoWindow orderFront:self];
}

- (IBAction)togglePlayersDrawer:(id)sender
{
	[playersDrawer toggle:self];
}

#pragma mark Table View Delegate Methods

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	if([[aTableColumn identifier] isEqualToString:@"attributedName"]){
		if(![[NSUserDefaults standardUserDefaults] boolForKey:@"colorizeServers"]){
			NSAttributedString *attString = [aCell attributedStringValue];
			[aCell setStringValue:[attString string]];
		}
	}
}

@end
