//
//  MQStatTask.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 06/11/05.
//  Copyright 2006 Maracuja Software. All rights reserved.
//

#import "MQStatTask.h"
#import "MServer.h"
#import <unistd.h>

#define DEFAULT_ARGS @"-nocfg", @"-u",@"-P",@"-R",@"-xml",@"-utf8"
#define NDEFAULT_ARGS 6

#define MAXSIM 20

@interface MQStatTask (Private)

- (NSURL *)lauchWithArgs:(NSArray *)args;

@end

@implementation MQStatTask (Private)

- (NSURL *)lauchWithArgs:(NSArray *)args
{
	//create temporary file
	NSProcessInfo * pInfo = [NSProcessInfo processInfo];
	NSMutableString *temporaryFileName = [NSMutableString stringWithString:[pInfo processName]];
	[temporaryFileName appendString:@".XXXXXX"];
	NSString *temporaryFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:temporaryFileName];
	
	char *template = strdup([temporaryFilePath cStringUsingEncoding:NSUTF8StringEncoding]);
	int fd = mkstemp(template);
	if(fd == -1){
		[[NSException exceptionWithName:MCantCreateFileException 
								 reason:[NSString stringWithFormat:@"Couldn't create file: %@",temporaryFilePath]
							   userInfo:nil] 
			raise];
	}
	temporaryFilePath = [NSString stringWithCString:template];
	free(template);
	//launch qstat
	[qstat setArguments:args];
	[qstat setStandardOutput:
		[[[NSFileHandle alloc] initWithFileDescriptor:fd] autorelease]]; 
    [qstat launch];
	
	return [NSURL fileURLWithPath:temporaryFilePath];

}

@end

@implementation MQStatTask

+ (void)initialize{
	
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary
        dictionaryWithObject:@"20" forKey:@"maxSimConn"];
	
    [defaults registerDefaults:appDefaults];
}

- (id) init {
	self = [super init];
	if (self != nil) {
		qstat = [NSTask new];
		NSString *qstatPath = [[NSBundle mainBundle] pathForAuxiliaryExecutable:@"qstat"];
		[qstat setCurrentDirectoryPath:[qstatPath stringByDeletingLastPathComponent]];
		[qstat setLaunchPath:qstatPath];	
	}
	return self;
}

- (void) dealloc {
	[qstat release];
	[super dealloc];
}

- (NSURL *)queryGameServer:(NSString *)serverAddress withServerType:(NSString *)serverType
{
	NSString *maxsim = [[NSUserDefaults standardUserDefaults] stringForKey:@"maxSimConn"];
	NSArray *args	= [NSArray arrayWithObjects:DEFAULT_ARGS, @"-maxsim", maxsim, [NSString stringWithFormat:@"-%@",serverType], serverAddress, nil];
	
	NSURL *filePathURL = [self lauchWithArgs:args];
	return filePathURL;
}

- (NSURL *)queryGameServers:(NSArray *)serverArray
{
	NSString *maxsim = [[NSUserDefaults standardUserDefaults] stringForKey:@"maxSimConn"];
	NSArray *args = [NSArray arrayWithObjects:DEFAULT_ARGS, @"-maxsim", maxsim, @"-f", @"-", nil];
	
	NSPipe *pipe = [NSPipe pipe];
	[qstat setStandardInput:pipe];
	NSFileHandle *writeHandle = [pipe fileHandleForWriting];
	NSURL *filePathURL = [self lauchWithArgs:args];
	
	NSEnumerator *enumerator = [serverArray objectEnumerator];
	MServer *server;
	while ((server = [enumerator nextObject])) {
		[writeHandle writeData:[[server serverType] dataUsingEncoding:NSUTF8StringEncoding]];
		[writeHandle writeData:[@" " dataUsingEncoding:NSUTF8StringEncoding]];
		[writeHandle writeData:[[server address] dataUsingEncoding:NSUTF8StringEncoding]];
		[writeHandle writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
	}
		
	[writeHandle closeFile];
	return filePathURL;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
	if ([qstat respondsToSelector:selector])
	{
		return [qstat methodSignatureForSelector:selector];
	} else {
		return [super methodSignatureForSelector: selector];
	}
}
- (void)forwardInvocation:(NSInvocation *)invocation
{
	[invocation invokeWithTarget:qstat];
}

@end
