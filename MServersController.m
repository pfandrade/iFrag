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

static NSArray *keysToCopy = nil;

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
	//[serversTableView registerForDraggedTypes:[NSArray arrayWithObject:iFragPBoardType]];
	[serversTableView setVerticalMotionCanBeginDrag:NO];
	[serversTableView setDraggingSourceOperationMask:(NSDragOperationCopy | NSDragOperationMove) forLocal:YES];
	[serversTableView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
	if(keysToCopy == nil){
		keysToCopy = [[NSArray arrayWithObjects:@"serverType", @"address", @"attributedName", @"gameType", @"map", @"ping", @"fullness"] retain];
	}
}

#pragma mark Copy & Paste
- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes 
	 toPasteboard:(NSPasteboard*)pboard 
{ 	
	//release previously cached information
	[copiedItemsCache release];
	copiedItemsCache = [[NSMutableArray alloc] initWithCapacity:[rowIndexes count]];
	
	NSArray *servers = [self arrangedObjects];
	unsigned row, i;
	id value;
	NSMutableArray *rowObjectKeyValues;
	row = [rowIndexes firstIndex];
	
	do {
		rowObjectKeyValues = [[NSMutableArray alloc] initWithCapacity:[keysToCopy count]];
		for (i = 0; i < [keysToCopy count]; i++){
			value = [[servers objectAtIndex:row] valueForKey:[keysToCopy objectAtIndex:i]]; 
			[rowObjectKeyValues insertObject:[[value copy] autorelease] atIndex:i];
		}
		[copiedItemsCache addObject:rowObjectKeyValues];
		[rowObjectKeyValues release];
	} while((row = [rowIndexes indexGreaterThanIndex:row]) != NSNotFound);
	
	// declare the standard supported types
	//NSPasteboard *pb = [NSPasteboard generalPasteboard];
	NSArray *types;
	types = [NSArray arrayWithObjects:NSRTFPboardType, NSTabularTextPboardType, NSStringPboardType, nil];
	[pboard declareTypes:types owner:self];
	
	// now copy the selected servers to the iFragPBoard
	NSArray *selectedServers = [self selectedObjects];
	NSMutableArray *copiedServers = [[NSMutableArray alloc] initWithCapacity:[selectedServers count]];
	
	NSEnumerator *selectedEnum = [selectedServers objectEnumerator];
	id server;
	i = 0;
	while(server = [selectedEnum nextObject]){
		[copiedServers insertObject:[server dictionaryWithValuesForKeys:[NSArray arrayWithObjects:@"address", @"serverType",nil]]
							atIndex:i++];
	}
	
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[[copiedServers copy] autorelease]];
	[copiedServers release];
	
	// add the private pasteboard iFragPboard
	[pboard addTypes:[NSArray arrayWithObject:iFragPBoardType] 
			   owner:self];
	[pboard setData:data forType:iFragPBoardType];
	return YES; 
}

/* Provide data for standard pasterboards:
 * NSRTFPboardType, NSTabularTextPboardType, NSStringPboardType
 */
- (void)pasteboard:(NSPasteboard *)sender provideDataForType:(NSString *)type
{
	NSEnumerator *copyEnumerator = [copiedItemsCache objectEnumerator];
	NSMutableString *tsv = nil;
	NSMutableAttributedString *rtf = nil;
	static NSAttributedString *tabChar = nil;
	static NSAttributedString *newlineChar = nil;
	
	if(!tabChar){
		tabChar = [[NSAttributedString alloc] initWithString:@"\t"];
	}
	if(!newlineChar){
		newlineChar = [[NSAttributedString alloc] initWithString:@"\n"];
	}
	
	
    if ([type isEqualToString:NSStringPboardType] || [type isEqualToString:NSTabularTextPboardType]) {
		tsv = [[NSMutableString alloc] init];
    }
    else if ([type isEqualToString:NSRTFPboardType]) {
		rtf = [[NSMutableAttributedString alloc] init];
	}
	
	unsigned i;
	id objectKeyValues, keyValue;
	if(objectKeyValues = [copyEnumerator nextObject]){
		
		for(i=0;i<[objectKeyValues count]; i++){
			keyValue = [objectKeyValues objectAtIndex:i];
			if([keyValue isKindOfClass:[NSAttributedString class]]){
				[tsv appendFormat:((i==0) ? @"%@" : @"\t%@"), [keyValue string]];
				if(i!=0)
					[rtf appendAttributedString:tabChar];
				[rtf appendAttributedString:keyValue];
			}else{
				if(keyValue){
					[tsv appendFormat:(i==0) ? @"%@" : @"\t%@", keyValue];
					if(i!=0)
						[rtf appendAttributedString:tabChar];
					[rtf appendAttributedString:[[[NSAttributedString alloc] initWithString:[keyValue description]] autorelease]];
				}
			}
		}
		
	}
	while(objectKeyValues = [copyEnumerator nextObject]){
		[tsv appendString:@"\n"];
		[rtf appendAttributedString:newlineChar];
		
		for(i=0;i<[objectKeyValues count]; i++){
			keyValue = [objectKeyValues objectAtIndex:i];
			if([keyValue isKindOfClass:[NSAttributedString class]]){
				[tsv appendFormat:(i==0) ? @"%@" : @"\t%@", [keyValue string]];
				if(i!=0)
					[rtf appendAttributedString:tabChar];
				[rtf appendAttributedString:keyValue];
			}else{
				if(keyValue){
					[tsv appendFormat:(i==0) ? @"%@" : @"\t%@", keyValue];
					if(i!=0)
						[rtf appendAttributedString:tabChar];
					[rtf appendAttributedString:[[[NSAttributedString alloc] initWithString:[keyValue description]] autorelease]];
				}
			}
		}
	}
	
	if(tsv){
		[sender setString:[[tsv copy] autorelease] forType:type];
		[tsv release];
		return;
	}
	if(rtf){
		NSRange wholeStringRange = NSMakeRange(0, [rtf length]);
		NSData *rtfdData = [rtf RTFFromRange:wholeStringRange documentAttributes:nil];
		[sender setData:rtfdData forType:NSRTFPboardType];
		[rtf release];
		return;
	}
}

- (NSDragOperation)tableView:(NSTableView *)aTableView 
				validateDrop:(id <NSDraggingInfo>)info 
				 proposedRow:(int)row 
	   proposedDropOperation:(NSTableViewDropOperation)operation
{
	return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info 
			  row:(int)row dropOperation:(NSTableViewDropOperation)operation
{
	return NO;
}

- (BOOL)canCut
{
	return [self canCopy];
}

- (BOOL)canCopy
{
	return ([[self selectedObjects] count] != 0);
}


- (BOOL)canPasteIntoServerList:(id)sl fromPasteboard:(NSPasteboard *)pb
{
    NSArray *types = [NSArray arrayWithObject:iFragPBoardType];
    NSString *bestType = [pb availableTypeFromArray:types];
    if(bestType != nil){
		NSArray *copiedServers = [NSKeyedUnarchiver unarchiveObjectWithData:[pb dataForType:bestType]];
		NSString *gameServerType = [sl gameServerType];

		if([gameServerType isEqualToString:@"FAV"])
			return YES;

		return ([[copiedServers valueForKey:@"serverType"] indexOfObject:gameServerType] != NSNotFound);
	}
	return NO;
}

- (BOOL)canPaste
{
	NSObjectController *controller = [[self infoForBinding:@"contentSet"] objectForKey:NSObservedObjectKey];
	return [self canPasteIntoServerList:[[controller selectedObjects] objectAtIndex:0] fromPasteboard:[NSPasteboard generalPasteboard]];
}

- (void)pasteIntoServerList:(id)sl fromPasteboard:(NSPasteboard *)pb
{
	NSArray *types = [NSArray arrayWithObject:iFragPBoardType];
    NSString *bestType = [pb availableTypeFromArray:types];
    if(bestType != nil){
		NSArray *copiedServers = [NSKeyedUnarchiver unarchiveObjectWithData:[pb dataForType:bestType]];
		
		NSString *gameServerType = [sl gameServerType];
		
		NSEnumerator *e = [copiedServers objectEnumerator];
		id dict;
		NSManagedObjectContext *context = [[NSApp delegate] managedObjectContext];
		MServer *server;
		NSMutableArray *addedServers = [[NSMutableArray alloc] init];
		NSMutableSet *serversSet = [sl mutableSetValueForKey:@"servers"];
		while(dict = [e nextObject]){
			if([gameServerType isEqualToString:@"FAV"] || [[dict valueForKey:@"serverType"] isEqualToString:gameServerType]){
				server = [MServer createServerWithAddress:[dict valueForKey:@"address"]
												inContext:context];
				[server setServerType:[dict valueForKey:@"serverType"]];
				[serversSet addObject:server];
				[addedServers addObject:server];
			}
		}
		[sl refreshServers:addedServers];
		[addedServers release];
		[context save:nil];
	}
}

- (void)pasteItems
{
	NSObjectController *controller = [[self infoForBinding:@"contentSet"] objectForKey:NSObservedObjectKey];
	[self pasteIntoServerList:[[controller selectedObjects] objectAtIndex:0] fromPasteboard:[NSPasteboard generalPasteboard]];
}

- (void)copyItems
{
	[self tableView:serversTableView writeRowsWithIndexes:[self selectionIndexes] toPasteboard:[NSPasteboard generalPasteboard]];
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
