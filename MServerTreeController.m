//
//  MServerTreeController.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/11/15.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import "MServerTreeController.h"
#import "MServerList.h"
#import "MSmartServerList.h"

@implementation MServerTreeController

- (MServerList *)selectedServerList
{
	id selectedObject = [[self selectedObjects] objectAtIndex:0];
	if([selectedObject isKindOfClass:[MServerList class]]){
		return selectedObject;
	}else{
		return [(MSmartServerList *)selectedObject parent];
	}
}

- (MSmartServerList *)selectedSmartServerList
{
	id selectedObject = [[self selectedObjects] objectAtIndex:0];
	if([selectedObject isKindOfClass:[MSmartServerList class]]){
		return selectedObject;
	}else{
		return nil;
	}
}

- (BOOL)isServerListSelected
{
	id selectedObject = [[self selectedObjects] objectAtIndex:0];
	if([selectedObject isKindOfClass:[MServerList class]]){
		return YES;
	}
	return NO;
}
@end
