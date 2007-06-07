#import "MAddServerController.h"
#import "MMainController.h"
#import "MServer.h"
#import "MGenericGame.h"

@implementation MAddServerController

- (id)serverListsTreeController {
    return [[serverListsTreeController retain] autorelease];
}

- (void)setServerListsTreeController:(id)value {
    if (serverListsTreeController != value) {
        [serverListsTreeController release];
        serverListsTreeController = [value retain];
    }
}


#pragma mark Actions

- (IBAction)add:(id)sender
{
	NSString *serverAddress = [address stringValue];
	//TODO: VALIDAR O ENDEREÇO
	//Usar um NSFormatter?
	
	NSString *serverKind = [[kind selectedItem] title];
	if([serverKind isEqualToString:@"-"]){
		//TODO:Alert com erro?
		return;
	}
	NSEnumerator *listEnum = [[serverListsTreeController content] objectEnumerator];
	
	//vamos procurar o jogo escolhido
	id list;
	while(list = [listEnum nextObject]){
		if([[list name] isEqualToString:serverKind])
			break;
	}
	//para retirarmos o server Type
	NSString *st = [[list game] serverTypeString];
	
	NSManagedObjectContext *context = [[NSApp delegate] managedObjectContext];
	MServer *server = [MServer createServerWithAddress:serverAddress
											 inContext:context];
	
	// se o servidor já existir e nao tiver for do mesmo jogo, dar erro
	if([server serverType] != nil && ![[server serverType] isEqualToString:st]){
		//TODO: That server already exists and is of a different kind (dizer qual é o tipo)
		//choose another server or delete the existing one before continuing
		return;
	}
	[server setServerType:st];
	
	//TODO: Mudar isto!
	/* Por uma vi para o serversController
	 * usar esse para fazer um add do servidor
	 * PENSAR EM COMO CHEGAR A SERVERLIST REAL
	 * tirar a vi para treeController e usar a outra para 
	 * serverListsController
	*/
	[serverList performSelector:@selector(addServersObject:) withObject:server];
	[context save:nil];
	
	[serverList performSelector:@selector(refreshServers:) withObject:[NSArray arrayWithObject:server]];
	[self close];
	
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
	serverList = [serverListsTreeController selection];
	
	//title, subtitle and popup
	[kind removeAllItems];
	NSString *listName = [serverList valueForKey:@"name"];
	if([listName isEqualToString:@"Favorites"]){
		[title setStringValue:@"Please enter the address and kind of the server to add."];
		NSEnumerator *listEnum = [[serverListsTreeController content] objectEnumerator];
		id currentList;
		while(currentList = [listEnum nextObject]){
			if([[currentList valueForKey:@"name"] isEqualToString:@"Favorites"])//don't add the Favorites List
				continue;
			
			[kind addItemWithTitle:[currentList name]];
		}
		[kind addItemWithTitle:@"-"];
		[kind selectItemWithTitle:@"-"];
		[kind setEnabled:YES];
	}else{
		[title setStringValue:@"Please enter the address of the server to add."];
		[kind addItemWithTitle:[serverList valueForKey:@"name"]];
		[kind selectItemWithTitle:[serverList valueForKey:@"name"]];
		[kind setEnabled:NO];
	}
	
	[subTitle setStringValue:[NSString stringWithFormat:@"This will add the server to your %@ list.", listName]];
}
#pragma mark NSWindow Delegate methods 

- (void)windowWillClose:(NSNotification *)aNotification
{
	[NSApp endSheet:[self window]];
}

- (void)windowDidBecomeKey:(NSNotification *)aNotification
{
	//let's create the image
	NSImage *slIcon = [[serverList valueForKey:@"icon"] copy];
	[slIcon setScalesWhenResized:YES];
	[slIcon setSize:NSMakeSize(64,64)];
	NSString* imageName = [[NSBundle mainBundle] pathForResource:@"Add" ofType:@"tiff"]; 
	NSImage *addImg = [[NSImage alloc] initWithContentsOfFile:imageName];
	
	[image lockFocus];
	[slIcon compositeToPoint:NSMakePoint(0,0) operation:NSCompositeSourceOver];
	[addImg compositeToPoint:NSMakePoint(32,0) operation:NSCompositeSourceOver];
	[image unlockFocus];
	[slIcon autorelease];
}
@end
