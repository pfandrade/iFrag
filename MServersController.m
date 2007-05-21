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
	NSMenuItem *inspectorMenuItem = [[[[NSApp mainMenu] itemWithTitle:@"View"] submenu] itemWithTag:2];
	
	if([infoWindow isVisible]){
		[infoWindow orderOut:self];
		[inspectorMenuItem setTitle:@"Show Inspector"];
	}else{
		[infoWindow orderFront:self];
		[inspectorMenuItem setTitle:@"Hide Inspector"];
	}
}

#pragma mark Table View Delegate Methods

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	static NSDictionary *info = nil;
	
	if (nil == info) {
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setLineBreakMode:NSLineBreakByTruncatingTail];
        info = [[NSDictionary alloc] initWithObjectsAndKeys:style, NSParagraphStyleAttributeName, nil];
        [style release];
    }
	
	if([[aTableColumn identifier] isEqualToString:@"attributedName"]){
		if(![[NSUserDefaults standardUserDefaults] boolForKey:@"colorizeServers"]){
			NSAttributedString *attString = [aCell attributedStringValue];
			[aCell setStringValue:[attString string]];
		}else{
			NSMutableAttributedString *mutAttString = [[NSMutableAttributedString alloc] initWithAttributedString:[aCell attributedStringValue]];
			[mutAttString addAttributes:info range:NSMakeRange(0,[mutAttString length])];
			[mutAttString autorelease];
			[aCell setAttributedStringValue:mutAttString];
		}
	}
}

@end
