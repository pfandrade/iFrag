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

- (id)currentSelection
{
	id selectedObjects = [self selectedObjects];
	if(selectedObjects != nil && [selectedObjects count] > 0){
		return [selectedObjects objectAtIndex:0];
	}
	return nil;
}

- (MServerList *)selectedServerList
{
	id selectedObject = [self currentSelection];
	
	if([selectedObject isKindOfClass:[MServerList class]]){
		return selectedObject;
	}else{
		return [(MSmartServerList *)selectedObject parent];
	}
}

- (MSmartServerList *)selectedSmartServerList
{
	id selectedObject = [self currentSelection];
	if([selectedObject isKindOfClass:[MSmartServerList class]]){
		return selectedObject;
	}else{
		return nil;
	}
}

- (BOOL)isServerListSelected
{
	id selectedObject = [self currentSelection];
	if([selectedObject isKindOfClass:[MServerList class]]){
		return YES;
	}
	return NO;
}
@end
