//
//  MPlayersController.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/03/07.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import "MPlayersController.h"
#import "MPlayer.h"

@implementation MPlayersController

+ (void)initialize{
	
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary
        dictionaryWithObject:[NSNumber numberWithBool:YES]  forKey:@"colorizePlayers"];
	
    [defaults registerDefaults:appDefaults];
}

- (void)awakeFromNib
{
	[[NSNotificationCenter defaultCenter] addObserver:playersTableView
											 selector:@selector(setNeedsDisplay) 
												 name:NSUserDefaultsDidChangeNotification
											   object:nil];
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
		if(![[NSUserDefaults standardUserDefaults] boolForKey:@"colorizePlayers"]){
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
