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
- (BOOL)canCopy;
- (BOOL)canPaste;

- (void)copyItems;
- (void)pasteItems;
@end

@implementation MTableView

#pragma mark Cut, Copy & Paste

- (IBAction)delete:(id)sender
{
//	[[self nextResponder] tryToPerform:@selector(removeServers:) with:sender]; 
	//lets get a reference to the controller
	[[[self infoForBinding:@"content"] objectForKey:NSObservedObjectKey] remove:sender];
	
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
	[[self dataSource] copyItems];
}

- (IBAction)paste:(id)sender
{
	[[self dataSource] pasteItems];
}

- (BOOL)validateUserInterfaceItem:(id)item
{
	id ds = [self dataSource];
    if ([item action] == @selector(cut:)) {
        return [ds canCut];
    }
	
	if ([item action] == @selector(copy:)) {
        return [ds canCopy];
    }
	
	if ([item action] == @selector(paste:)) {
        return [ds canPaste];
    }

	if ([item action] == @selector(delete:)) {
        return [ds canCut];
    }
	
	return YES; 
}

@end
