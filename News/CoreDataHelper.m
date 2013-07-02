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

- (id)initWithNewContextInCurrentThread {
    if (self = [super init]) {
        AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        _PSC = appdelegate.persistentStoreCoordinator;
        
        // create new context
        self.managedObjectContext = [[NSManagedObjectContext alloc] init];
        self.managedObjectContext.persistentStoreCoordinator = _PSC;
    }
    return self;
}

- (id)initWithExistingContext:(NSManagedObjectContext *)context {
    if (self = [super init]) {
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
@end