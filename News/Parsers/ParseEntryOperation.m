//
//  ParseSubscriptionOperation.m
//  News
//
//  Created by karta sutanto on 1/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import "ParseEntryOperation.h"
#import "Channel.h"
#import "Item.h"
#import "AppDelegate.h"
#import "NSObject+JL_KeyPathIntrospection.h"
#import "ISO8601DateFormatter.h"

@implementation ParseEntryOperation

// -------------------------------------------------------------------------------
//	main:
// -------------------------------------------------------------------------------
- (void)main {
    if (![self isCancelled] && self.fileURL != nil) {
        if (self.givenManagedObjectContext) {
            self.coreDataHelper = [[CoreDataHelper alloc] initWithExistingContext:self.givenManagedObjectContext];
        } else {
            self.coreDataHelper = [[CoreDataHelper alloc] initWithNewContextInCurrentThread];
        }
        
        NSData *jsonData = [NSData dataWithContentsOfFile:[self.fileURL path]];
        if (!jsonData) {
            [self sendNotificationSuccess:NO];
            return;
        }
        NSError *error;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&error];
        entries = [[NSMutableArray alloc] init];
        [self mapJSONArray:jsonArray
                 toObjects:entries
               withMapping:apiMapping
             andEntityName:@"Item"];
        
        [self addEntryToCoreData:entries];
        
        [self cleanup];
    }
}

- (void)addEntryToCoreData:(NSArray*)itemsArray{
    
    /*
     add channel to core data, check for duplicate
     */
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *ent = [NSEntityDescription entityForName:@"Item"
                                           inManagedObjectContext:self.coreDataHelper.managedObjectContext];
    fetchRequest.entity = ent;
    
    // narrow search result to id
    fetchRequest.propertiesToFetch = @[@"guid"];
    
    NSError *error = nil;
    Item *item = nil;
    for (item in itemsArray) {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"guid = %@", item.guid];
        NSArray *fetchedItems = [self.coreDataHelper.managedObjectContext executeFetchRequest:fetchRequest
                                                                         error:&error];
        if (fetchedItems.count == 0) {
            // Link to subscription
            Channel *channel = (Channel *)[self.coreDataHelper findRecordForEntityName:@"Channel"
                                                                 byProperty:@"feedID"
                                                                  withValue:item.feedID];
            if (channel == nil) {
                //sth wrong
                // cannot find the subscription that holds this item
                continue;
            }
            [self.coreDataHelper.managedObjectContext insertObject:item];
            item.channel = channel;
        }
    }
    
    if ([self.coreDataHelper.managedObjectContext hasChanges]) {
        if (![self.coreDataHelper.managedObjectContext save:&error]) {
            // save fail
            ALog(@"save Entries fail");
            [self sendNotificationSuccess:NO];
            return;
        }
    }
    
    DLog(@"save Entries ok");
    [self sendNotificationSuccess:YES];
    
}

- (void)sendNotificationSuccess:(BOOL)bYesNo {
    [[NSNotificationCenter defaultCenter] postNotificationName:kFetchEntriessDone
                                                        object:nil
                                                      userInfo:@{kFetchResultBOOL: [NSNumber numberWithBool:bYesNo],
                                                                 kParserManagedObjectContext: self.coreDataHelper.managedObjectContext}];
}
@end
