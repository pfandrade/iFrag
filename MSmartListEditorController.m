#import "MSmartListEditorController.h"
#import "MSmartServerList.h"
#import "MServerList.h"

@implementation MSmartListEditorController

@synthesize smartServerList;
@synthesize predicate;
@synthesize serverList;

- (void)setup
{
	NSPredicate *p = [[self smartServerList] predicate];
	if(p == nil){
		p = [NSPredicate predicateWithFormat:@"ping < 100"];
	}
	NSString *n = [[self smartServerList] name];
	if(n == nil){
		n = @"New Smart List";
	}
	[self setSmartListName:n];
	[self setPredicate:p];
	
	//let's create the image
	NSImage *icon = [[[self serverList] icon] copy];
	[icon setScalesWhenResized:YES];
	[icon setSize:NSMakeSize(64,64)];
	
	NSImage *sslIcon =  [NSImage imageNamed:@"Smart Folder"];
	NSImage *composedImage = [[NSImage alloc] initWithSize:[icon size]];
	
	[composedImage lockFocus];
	[icon compositeToPoint:NSMakePoint(0,0) operation:NSCompositeSourceOver];
	[sslIcon compositeToPoint:NSMakePoint(32,0) operation:NSCompositeSourceOver];
	[composedImage unlockFocus];
	
	[imageView setImage:composedImage];
	[composedImage release];
	[icon release];
}

- (IBAction)cancel:(id)sender {
	[self  close];
}

- (IBAction)save:(id)sender {
	//hack to force commit of all textFields in NSPredicateEditor
	[[self window] makeFirstResponder:saveButton];
	
    NSPredicate *p = [self predicate];
	if(p == nil){
		// The shouldn't allow this to happen, but it is here anyway
		NSAlert *alert = [NSAlert alertWithMessageText:@"No rule specified"
										 defaultButton:@"OK" 
									   alternateButton:nil
										   otherButton:nil 
							 informativeTextWithFormat:@"Please specify at least one rule for this smart list, or press the Cancel button to dismiss this window."];
		
		[alert beginSheetModalForWindow:[self window]
						  modalDelegate:nil
						 didEndSelector:nil 
							contextInfo:nil];
		return;
	}
	NSString *n = [self smartListName];
	if(n == nil || [n length] == 0){
		NSAlert *alert = [NSAlert alertWithMessageText:@"Empty Smart List name"
										 defaultButton:@"OK" 
									   alternateButton:nil
										   otherButton:nil 
							 informativeTextWithFormat:@"Please specify a name for this smart list."];
		[alert beginSheetModalForWindow:[self window]
						  modalDelegate:nil
						 didEndSelector:nil 
							contextInfo:nil];
		return;
	}
	
	NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
	MSmartServerList *ssl = [self smartServerList];
	if(ssl == nil){
		ssl = [MSmartServerList createSmartServerListInContext:moc];
		[[self serverList] addSmartListsObject:ssl];
	}
	[ssl setName:n];
	[ssl setPredicate:p];

	NSError *error = nil;
	[moc save:&error];
	if(error != nil){
		NSLog(@"Save error: %@", error);
	}
#ifdef DEBUG
	NSLog(@"Predicate: %@", p);
#endif
	[self close];
}

- (void)setSmartListName:(NSString *)name
{
	[smartListNameTextFiled setStringValue:name];
}
- (NSString *)smartListName
{
	return [smartListNameTextFiled stringValue];
}


- (void)runModalSheetForWindow:(NSWindow *)window
{
	//force window to load
	if([self serverList] == nil){
		NSLog(@"Attempt to create smartList without specifing a ServerList");
		return;
	}
	
	[self window];
	[self setup];
	[NSApp beginSheet:[self window]
	   modalForWindow:window
		modalDelegate:nil 
	   didEndSelector:nil 
		  contextInfo:nil];
}


#pragma mark NSWindow Delegate methods 

- (void)windowWillClose:(NSNotification *)aNotification
{
	[NSApp endSheet:[self window]];
	[self setSmartListName:@""];
	[self setSmartServerList:nil];
	[self setServerList:nil];
}


@end
