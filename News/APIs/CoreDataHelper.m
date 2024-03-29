//
//  CoreDataHelper.m
//  News
//
//  Created by karta sutanto on 2/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import "CoreDataHelper.h"
#import "AppDelegate.h"

@implementation CoreDataHelper
@synthesize PSC = _PSC;
@synthesize managedObjectContext;

- (id)mainContext {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return [appDelegate managedObjectContext];
}

+ (id)defaultContext {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return [appDelegate managedObjectContext];
}

+ (NSManagedObjectContext *)newContextInCurrentThread {
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSPersistentStoreCoordinator *psc = appdelegate.persistentStoreCoordinator;
    
    // create new context
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    managedObjectContext.persistentStoreCoordinator = psc;
    return managedObjectContext;
}

- (id)initWithNewContextInCurrentThread {
    if (self = [super init]) {
        
        AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        _PSC = appdelegate.persistentStoreCoordinator;
        
        // create new context
        self.managedObjectContext = [[NSManagedObjectContext alloc] init];
        self.managedObjectContext.persistentStoreCoordinator = _PSC;
        DLog(@"Create new context:%@ in thread:%@", self.managedObjectContext, [NSThread currentThread]);
    }
    return self;
}

- (id)initWithExistingContext:(NSManagedObjectContext *)context {
    if (self = [super init]) {
         DLog(@"Using existing context:%@ ",context);
        AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        _PSC = appdelegate.persistentStoreCoordinator;
        
        // create new context
        self.managedObjectContext = context;
    }
    return self;
}

- (BOOL)isRecordExistForEntityName:(NSString *)entityName
                        byProperty:(NSString *)propertyName
                         withValue:(id)value {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *ent = [NSEntityDescription entityForName:entityName
                                           inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = ent;
    
    // narrow search result to id
    fetchRequest.propertiesToFetch = @[propertyName];
    
    NSError *error = nil;
    NSString *string = [NSString stringWithFormat:@"%@ = %@", propertyName, value];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:string];
    NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest
                                                                     error:&error];
    if (fetchedItems.count == 0) {
        return NO;
    }
    return YES;
}

- (NSManagedObject *)findRecordForEntityName:(NSString *)entityName
                                  byProperty:(NSString *)propertyName
                                   withValue:(id)value {
    
    /*
    Find a record
     */
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *ent = [NSEntityDescription entityForName:entityName
                                           inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = ent;
    
    // narrow search result to id
//    fetchRequest.propertiesToFetch = @[propertyName];
    
    NSError *error = nil;
    NSString *string = [NSString stringWithFormat:@"%@ = %@", propertyName, value];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:string];
//    [fetchRequest setIncludesPropertyValues:NO];
    NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest
                                                                     error:&error];
    if (fetchedItems.count == 0) {
        return nil;
    }
    return [fetchedItems objectAtIndex:0];
}

- (NSArray *)fetchFeedsGroupedByTags {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityChannel = [NSEntityDescription entityForName:@"Channel" inManagedObjectContext:self.managedObjectContext];

    [fetchRequest setEntity:entityChannel];
    
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        DLog(@"Error: %@", error);
        return nil;
    }
    return result;
}

#pragma mark -- Display List


@end
