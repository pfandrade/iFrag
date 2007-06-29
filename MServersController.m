//
//  MServersController.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/04/05.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import "MServersController.h"
#import "MServer.h"
#import "MServerList.h"

extern NSString *iFragPBoardType;

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
	[serversTableView registerForDraggedTypes:[NSArray arrayWithObject:iFragPBoardType]];
	[serversTableView setVerticalMotionCanBeginDrag:NO];
}

#pragma mark Copy & Paste

- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes 
	 toPasteboard:(NSPasteboard*)pboard 
{ 
	NSArray *selectedServers = [self selectedObjects];
	NSMutableArray *copiedServers = [[NSMutableArray alloc] initWithCapacity:[selectedServers count]];
	
	NSEnumerator *selectedEnum = [selectedServers objectEnumerator];
	id server;
	int i = 0;
	while(server = [selectedEnum nextObject]){
		[copiedServers insertObject:[server dictionaryWithValuesForKeys:[NSArray arrayWithObjects:@"address", @"serverType",nil]]
							atIndex:i];
	}
	
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[[copiedServers copy] autorelease]];
	[copiedServers release];
	
	[pboard addTypes:[NSArray arrayWithObject:iFragPBoardType] 
			   owner:self];
	[pboard setData:data forType:iFragPBoardType];
	return YES; 
} 

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info 
			  row:(int)row dropOperation:(NSTableViewDropOperation)operation
{
	return NO;
}

- (NSDragOperation)tableView:(NSTableView *)aTableView 
				validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row 
	   proposedDropOperation:(NSTableViewDropOperation)operation
{
	return NSDragOperationNone;
}


- (BOOL)canCut
{
	return [self canCopy];
}

- (BOOL)canCopy
{
	return ([[self selectedObjects] count] != 0);
}


- (BOOL)canPasteFromPasteboard:(NSPasteboard *)pb
{
    NSArray *types = [NSArray arrayWithObject:iFragPBoardType];
    NSString *bestType = [pb availableTypeFromArray:types];
    if(bestType != nil){
		NSArray *copiedServers = [NSKeyedUnarchiver unarchiveObjectWithData:[pb dataForType:bestType]];
		//lets get a reference to the controller
		NSObjectController *controller = [[self infoForBinding:@"contentSet"] objectForKey:NSObservedObjectKey];
		NSString *gameServerType = [[[controller selectedObjects] objectAtIndex:0] gameServerType];

		if([gameServerType isEqualToString:@"FAV"])
			return YES;

		return [[copiedServers valueForKey:@"serverType"] containsObject:gameServerType];
	}
	return NO;
}

- (BOOL)canPaste
{
	return [self canPasteFromPasteboard:[NSPasteboard generalPasteboard]];
}



- (void)pasteFromPasteboard:(NSPasteboard *)pb
{
   NSArray *types = [NSArray arrayWithObject:iFragPBoardType];
    NSString *bestType = [pb availableTypeFromArray:types];
    if(bestType != nil){
		NSArray *copiedServers = [NSKeyedUnarchiver unarchiveObjectWithData:[pb dataForType:bestType]];
		//lets get a reference to the controller
		NSObjectController *controller = [[self infoForBinding:@"contentSet"] objectForKey:NSObservedObjectKey];
		id sl = [[controller selectedObjects] objectAtIndex:0];
		NSString *gameServerType = [sl gameServerType];
		
		NSEnumerator *e = [copiedServers objectEnumerator];
		id dict;
		NSManagedObjectContext *context = [[NSApp delegate] managedObjectContext];
		MServer *server;
		NSMutableArray *addedServers = [[NSMutableArray alloc] init];
		while(dict = [e nextObject]){
			if([gameServerType isEqualToString:@"FAV"] || [[dict valueForKey:@"serverType"] isEqualToString:gameServerType]){
				server = [MServer createServerWithAddress:[dict valueForKey:@"address"]
												inContext:context];
				[server setServerType:[dict valueForKey:@"serverType"]];
				[self addObject:server];
				[addedServers addObject:server];
			}
		}
		[sl refreshServers:addedServers];
		[addedServers release];
		[context save:nil];
	}
}

- (void)paste
{
	[self pasteFromPasteboard:[NSPasteboard generalPasteboard]];
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
