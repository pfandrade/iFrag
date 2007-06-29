//
//  MTableView.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/06/22.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import "MTableView.h"

@interface NSObject (MTableViewDelegateMethods)

- (BOOL)canCut;
- (BOOL)canPaste;

- (void)paste;
@end

@implementation MTableView

#pragma mark Cut, Copy & Paste

- (IBAction)delete:(id)sender
{
	[[self nextResponder] tryToPerform:@selector(removeServers:) with:sender]; 
	//lets get a reference to the controller
	//	[[[self infoForBinding:@"content"] objectForKey:NSObservedObjectKey] remove:sender];
	
}

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent
{
	BOOL weHandleIt;
	unichar keyChar;
	
	keyChar = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
	weHandleIt = NO;
	
	if ([[self window] firstResponder] != self)
	{
		// The focus is not on our list, ignore this key event.
	} else
	{
		// It's for us. We work with it.
		
		switch(keyChar)
		{
			case NSDeleteCharacter:
			case NSDeleteFunctionKey:
			case NSDeleteCharFunctionKey:
				// {
				//-- NSLog(@"Delete in performKeyEquivalent.");
				// Bitwise '&' comparison for command-key.
				if (NSCommandKeyMask & [theEvent modifierFlags])
				{
					// Skip the warning and just do it.
					[self delete: self];
				} else
				{
					// Be nice and show a warning.
					int button = [[NSAlert alertWithMessageText:@"Are you sure you want to delete the selected servers?" 
												  defaultButton:@"Yes" 
												alternateButton:@"No" 
													otherButton:nil
									  informativeTextWithFormat:@"The selected servers will be removed from the list."] runModal];
					if(button ==  NSAlertDefaultReturn)
						[self delete: self];
				}
				weHandleIt = YES;
				break;
			default:
				// Let nature take its course, so to speak.
				break;
		}
		
	}
	
	return weHandleIt;
}


- (IBAction)cut:(id)sender
{
	[self copy: sender];
	[self delete: sender];
}

- (IBAction)copy:(id)sender
{
	//lets get a reference to the controller
	NSArrayController *arrayController = [[self infoForBinding:@"content"] objectForKey:NSObservedObjectKey];
	
	//iterate over the selected objects and cache information
	NSIndexSet *selectedRowIndexes = [self selectedRowIndexes];
	NSArray *tableColumns = [self tableColumns];
	
	[copiedItemsCache release];
	copiedItemsCache = [[NSMutableArray alloc] initWithCapacity:[selectedRowIndexes count]];
	
	unsigned row, i;
	
	id value;
	NSMutableArray *rowObjectKeyValues;
	row = [selectedRowIndexes firstIndex];
	do {
		rowObjectKeyValues = [[NSMutableArray alloc] initWithCapacity:[tableColumns count]];
		for (i = 0; i < [tableColumns count]; i++){
			NSString *keyPath = [[[tableColumns objectAtIndex:i] infoForBinding:@"value"] objectForKey:NSObservedKeyPathKey];
			value = [[arrayController valueForKeyPath:keyPath] objectAtIndex:row];
			[rowObjectKeyValues insertObject:[[value copy] autorelease] atIndex:i];
		}
		[copiedItemsCache addObject:rowObjectKeyValues];
		[rowObjectKeyValues release];
	} while((row = [selectedRowIndexes indexGreaterThanIndex:row]) != NSNotFound);
	
	// declare supported types
	NSPasteboard *pb = [NSPasteboard generalPasteboard];
	NSArray *types;
	types = [NSArray arrayWithObjects:NSRTFPboardType, NSTabularTextPboardType, NSStringPboardType, nil];
	[pb declareTypes:types owner:self];
	
	// give the controller a chance to copy some data
	[arrayController tableView:self writeRowsWithIndexes:selectedRowIndexes toPasteboard:pb];
}

- (IBAction)paste:(id)sender
{
	[[[self infoForBinding:@"content"] objectForKey:NSObservedObjectKey] paste];
}

- (BOOL)validateUserInterfaceItem:(id)item
{
	NSArrayController *arrayController = [[self infoForBinding:@"content"] objectForKey:NSObservedObjectKey];
    if ([item action] == @selector(cut:)) {
        return [arrayController canCut];
    }
	
	if ([item action] == @selector(copy:)) {
        return [[self selectedRowIndexes] count] > 0;
    }
	
	if ([item action] == @selector(paste:)) {
        return [arrayController canPaste];
    }

	if ([item action] == @selector(delete:)) {
        return [arrayController canCut];
    }
	
	return YES; 
}


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


@end
