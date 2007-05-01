//
//  iFrag_AppDelegate.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/04/21.
//  Copyright Maracuja Software 2007 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface iFrag_AppDelegate : NSObject 
{
    IBOutlet NSWindow *window;
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;

- (IBAction)saveAction:sender;

- (NSWindow *)mainWindow;

@end
