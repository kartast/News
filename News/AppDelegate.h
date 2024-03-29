//
//  AppDelegate.h
//  News
//
//  Created by karta sutanto on 1/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (copy) void (^backgroundSessionCompletionHandler)();

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
