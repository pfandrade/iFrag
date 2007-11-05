#import "MAddServerController.h"
#import "MMainController.h"
#import "MServer.h"
#import "MGenericGame.h"
#import "MServerList.h"

#include <netdb.h>
#include <netinet/in.h>
#include <arpa/inet.h>

@interface MAddServerController (Private)

- (NSString *)validateIPAddress:(NSString *)address;
- (NSString *)validatePort:(NSString *)port;

@end

@implementation MAddServerController

- (NSString *)validateIPAddress:(NSString *)inAddress
{
	
	//verificar que a string nao sao apenas inteiros
	// a funcao getHostByName funciona bem quando a string 
	//de entrada sao apenas inteiros, mas o que que quero 
	//e' q de um erro!
	int i, dots;
	for(i=0, dots=0; i<[inAddress length]; i++){
		if([inAddress characterAtIndex:i] == '.'){
			dots++;
			continue;
		}
		if(!isdigit([inAddress characterAtIndex:i])){
			break;
		}
	}
	//ser era tudo inteiro e não tinha 3 pontos, dar erro
	if(i == [inAddress length] && dots != 3){
		return nil;
	}
	
	struct hostent *h;
	char hostname[100];
	[inAddress getCString:hostname maxLength:100 encoding:NSASCIIStringEncoding];
	
	if ((h=gethostbyname(hostname)) == NULL) {
		return nil;
	}
	char *convertedAddress = inet_ntoa(*((struct in_addr *)h->h_addr));
	NSString *ret = [NSString stringWithUTF8String:convertedAddress];
	
	return ret;
}

- (NSString *)validatePort:(NSString *)port;
{
	int i;
	for(i=0; i<[port length]; i++){
		if(!isdigit([port characterAtIndex:i])){
			break;
		}
	}
	//ser era tudo inteiro, dar erro
	if(i != [port length]){
		return nil;
	}
	return port;
}

- (id)serverListsTreeController {
    return [[serverListsTreeController retain] autorelease];
}

- (void)setServerListsTreeController:(id)value {
    if (serverListsTreeController != value) {
        [serverListsTreeController release];
        serverListsTreeController = [value retain];
    }
}

- (NSArrayController *)serversController {
    return [[serversController retain] autorelease];
}

- (void)setServersController:(NSArrayController *)value {
    if (serversController != value) {
        [serversController release];
        serversController = [value retain];
    }
}


#pragma mark Actions

- (IBAction)add:(id)sender
{
	static NSAlert *alert = nil;
	if(alert == nil){
		alert = [NSAlert alertWithMessageText:@"The address you entered is not valid."
								defaultButton:@"OK" 
							  alternateButton:nil
								  otherButton:nil 
					informativeTextWithFormat:@"The address must be an ip address or a resolvable hostname, with an optional port number."];
		[alert retain];
		//TODO: por o showsHelp activo!!
	}
	
	NSArray *addressComponents = [[address stringValue] componentsSeparatedByString:@":"];

		
	NSString *serverKind = [[kind selectedItem] title];
	NSEnumerator *listEnum = [[serverListsTreeController content] objectEnumerator];
	
	//vamos procurar o jogo escolhido
	id list;
	while(list = [listEnum nextObject]){
		if([[list name] isEqualToString:serverKind])
			break;
	}
	//para retirarmos o server Type
	NSString *st = [[list game] serverTypeString];
	
	NSString *ipAddress;
	NSString *port;
	switch([addressComponents count]){
		//No port specified
		case 1:
			if((ipAddress = [self validateIPAddress:[addressComponents objectAtIndex:0]]) == nil){
				[alert beginSheetModalForWindow:[self window] 
								  modalDelegate:nil
								 didEndSelector:nil
									contextInfo:nil];
				return;
			}			
			port = [[list game] defaultServerPort];
			break;
		case 2:
			if((ipAddress = [self validateIPAddress:[addressComponents objectAtIndex:0]]) == nil){
				[alert beginSheetModalForWindow:[self window] 
								  modalDelegate:nil
								 didEndSelector:nil
									contextInfo:nil];
				return;
			}
			if((port = [self validatePort:[addressComponents objectAtIndex:1]]) == nil){
				[alert beginSheetModalForWindow:[self window] 
								  modalDelegate:nil
								 didEndSelector:nil
									contextInfo:nil];
				return;
			}
			break;
		default:
			[alert runModal];
			return;
	}
	
	//juntar o ip e o porto!
	NSString *serverAddress = [NSString stringWithFormat:@"%@:%@",ipAddress,port];
	
	NSManagedObjectContext *context = [[NSApp delegate] managedObjectContext];
	MServer *server = [MServer createServerWithAddress:serverAddress
											 inContext:context];
	
	// se o servidor já existir e nao for do mesmo jogo, dar erro
	if([server serverType] != nil && ![[server serverType] isEqualToString:st]){
		NSAlert *warning = [NSAlert alertWithMessageText:@"Warning" 
										   defaultButton:@"Overwrite"
										 alternateButton:@"Cancel"
											 otherButton:nil
							   informativeTextWithFormat:@"The server you are trying to add already exists and is of a different kind.\n\
	Do you wish to overwrite the existing server?"];
		switch([warning runModal]){
			case NSAlertDefaultReturn: 
				break;
			case NSAlertAlternateReturn:
				return;
			default:
				return;
		}
	}
	[server setServerType:st];
	
	[serversController addObject:server];
	[serverList performSelector:@selector(refreshServers:) withObject:[NSArray arrayWithObject:server]];
	NSError *error = nil;
	[context save:&error];
	if(error != nil)
		NSLog(@"%@", error);
	[self close];
	
}

- (IBAction)cancel:(id)sender
{
	[self  close];
}

- (void)runModalSheetForWindow:(NSWindow *)window
{
	//force window to load
	[self window];
	[self setupWindow];
	[NSApp beginSheet:[self window]
	   modalForWindow:window
		modalDelegate:nil 
	   didEndSelector:nil 
		  contextInfo:nil];
}

- (void)setupWindow
{
	serverList = [[serverListsTreeController selectedObjects] objectAtIndex:0];
	
	//title, subtitle and popup
	[kind removeAllItems];
	[address setStringValue:@""];
	
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
		[addButton setEnabled:NO];
	}else{
		[title setStringValue:@"Please enter the address of the server to add."];
		[kind addItemWithTitle:[serverList valueForKey:@"name"]];
		[kind selectItemWithTitle:[serverList valueForKey:@"name"]];
		[kind setEnabled:NO];
		[addButton setEnabled:YES];
	}
	
	[subTitle setStringValue:[NSString stringWithFormat:@"This will add the server to your %@ list.", listName]];
	
	//let's create the image
	NSImage *slIcon = [[serverList valueForKey:@"icon"] copy];
	[slIcon setScalesWhenResized:YES];
	[slIcon setSize:NSMakeSize(64,64)];
	NSString* imageName = [[NSBundle mainBundle] pathForResource:@"Add" ofType:@"tiff"]; 
	NSImage *addImg = [[NSImage alloc] initWithContentsOfFile:imageName];
	NSImage *composedImage = [[NSImage alloc] initWithSize:[slIcon size]];
	
	[composedImage lockFocus];
	[slIcon compositeToPoint:NSMakePoint(0,0) operation:NSCompositeSourceOver];
	[addImg compositeToPoint:NSMakePoint(32,0) operation:NSCompositeSourceOver];
	[composedImage unlockFocus];
	
	[image setImage:composedImage];
	[composedImage release];
	[slIcon release];
}

#pragma mark NSWindow Delegate methods 

- (void)windowWillClose:(NSNotification *)aNotification
{
	[NSApp endSheet:[self window]];
}

#pragma mark Actions
-(IBAction)popUpMenuSelectionDidChange:(id)sender
{
	if([[[kind selectedItem] title] isEqualToString:@"-"])
		[addButton setEnabled:NO];
	else
		[addButton setEnabled:YES];
}

@end
