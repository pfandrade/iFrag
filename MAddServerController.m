#import "MAddServerController.h"
#import "MMainController.h"
#import "MServer.h"

@implementation MAddServerController

- (void)init
{
	[super initWithWindowNibName:@"AddServerDialog"];
}

#pragma mark Actions

- (IBAction)add:(id)sender
{
//	NSString *serverAddress = [address stringValue];
//	//TODO: VALIDAR O ENDEREÇO
//	
//	NSString *serverKind = [[kind selectedItem] title];
//	if([serverKind isEqualToString:@"-"]){
//		//TODO:Alert com erro?
//		return;
//	}
//	
//	MServer *server = [MServer createServerWithAddress:serverAddress];
//	NSEnumerator *listEnum = [[mainController installedServerLists] objectEnumerator];
//	id list;
//	while(list = [listEnum nextObject]){
//		if([[list name] isEqualToString:serverKind])
//			break;
//	}
//	
//	NSString *st = [[list game] serverTypeString];
//	[server setServerType:st];
//	[serverList addServersObject:server];
//	[serverList refreshServers:[NSArray arrayWithObject:server] withProgressDelegate:nil];
//	[self close];
	
}

- (IBAction)cancel:(id)sender
{
	[self  close];
}

- (NSWindow *)window
{
	NSWindow *w = [super window];
	[self setupWindow];
	return w;
}

- (void)setupWindow
{
//	serverList = [mainController currentServerList];
//	
//	//title, subtitle and popup
//	[kind removeAllItems];
//	NSString *listName = [serverList name];
//	if([listName isEqualToString:@"Favorites"]){
//		[title setStringValue:@"Please enter the address and kind of the server to add."];
//		NSEnumerator *listEnum = [[mainController installedServerLists] objectEnumerator];
//		id currentList;
//		while(currentList = [listEnum nextObject]){
//			if(currentList == serverList)//don't add the Favorites List
//				continue;
//			
//			[kind addItemWithTitle:[currentList name]];
//		}
//		[kind addItemWithTitle:@"-"];
//		[kind selectItemWithTitle:@"-"];
//		[kind setEnabled:YES];
//	}else{
//		[title setStringValue:@"Please enter the address of the server to add."];
//		[kind addItemWithTitle:[serverList name]];
//		[kind selectItemWithTitle:[serverList name]];
//		[kind setEnabled:NO];
//	}
//	
//	[subTitle setStringValue:[NSString stringWithFormat:@"This will add the server to your %@ list.", listName]];
}
#pragma mark NSWindow Delegate methods 

- (void)windowWillClose:(NSNotification *)aNotification
{
//	[NSApp endSheet:[self window]];
}

- (void)windowDidBecomeKey:(NSNotification *)aNotification
{
//	//let's create the image
//	NSImage *slIcon = [[serverList icon] copy];
//	[slIcon setSize:NSMakeSize(64,64)];
//	NSString* imageName = [[NSBundle mainBundle] pathForResource:@"Add" ofType:@"tiff"]; 
//	NSImage *addImg = [[NSImage alloc] initWithContentsOfFile:imageName];
//	
//	[image lockFocus];
//	[slIcon compositeToPoint:NSMakePoint(0,0) operation:NSCompositeSourceOver];
//	[addImg compositeToPoint:NSMakePoint(32,0) operation:NSCompositeSourceOver];
//	[image unlockFocus];
//	[slIcon autorelease];
}
@end
