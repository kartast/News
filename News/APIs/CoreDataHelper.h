//
//  CoreDataHelper.h
//  News
//
//  Created by karta sutanto on 2/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataHelper : NSObject {
    NSPersistentStoreCoordinator *PSC;
    NSManagedObjectContext *managedObjectContext;
}
@property (nonatomic, retain) NSPersistentStoreCoordinator *PSC;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (id)initWithNewContextInCurrentThread;
- (id)initWithExistingContext:(NSManagedObjectContext *)context;
- (BOOL)isRecordExistForEntityName:(NSString *)entityName
                        byProperty:(NSString *)propertyName
                         withValue:(id)value;
- (NSManagedObject *)findRecordForEntityName:(NSString *)entityName
                                  byProperty:(NSString *)propertyName
                                   withValue:(id)value;
@end
