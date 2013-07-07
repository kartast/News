//
//  ParseSubscriptionOperation.m
//  News
//
//  Created by karta sutanto on 1/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import "ParseTagOperation.h"
#import "Channel.h"
#import "Item.h"
#import "Tag.h"
#import "AppDelegate.h"
#import "NSObject+JL_KeyPathIntrospection.h"
#import "ISO8601DateFormatter.h"

@implementation ParseTagOperation

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
             andEntityName:@"Tag"];
        
        [self clearTags];
        [self addToCoreData:entries];
        [self saveChanges];
        [self cleanup];
    }
}

- (void)saveChanges {
    NSError *error = nil;
    if ([self.coreDataHelper.managedObjectContext hasChanges]) {
        if (![self.coreDataHelper.managedObjectContext save:&error]) {
            // save fail
            NSLog(@"save tags fail");
            [self sendNotificationSuccess:NO];
            return;
        }
    }
    NSLog(@"save tags ok");
    [self sendNotificationSuccess:YES];
}

- (void)clearTags {
    // TODO: New implementation, instead of clear all, only remove the one not inside
    NSFetchRequest *fetchAllTags = [[NSFetchRequest alloc] init];
    NSEntityDescription *ent = [NSEntityDescription entityForName:@"Tag"
                                           inManagedObjectContext:self.coreDataHelper.managedObjectContext];
    [fetchAllTags setEntity:ent];
    [fetchAllTags setIncludesPropertyValues:NO];
    
    NSError *error = nil;
    NSArray *tags = [self.coreDataHelper.managedObjectContext executeFetchRequest:fetchAllTags
                                                                            error:&error];
    
    for (Tag *tag in tags) {
        [self.coreDataHelper.managedObjectContext deleteObject:tag];
    }
}

- (void)addToCoreData:(NSArray*)array{
    
    /*
        Get |channel| name, 
        Put the |tag| name into |channel.channelCategory|
     */
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *ent = [NSEntityDescription entityForName:@"Tag"
                                           inManagedObjectContext:self.coreDataHelper.managedObjectContext];
    fetchRequest.entity = ent;
    
    // narrow search result to id
    fetchRequest.propertiesToFetch = @[@"name"];
    
    NSError *error = nil;
    Tag *tag = nil;
    for (tag in array) {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name = %@", tag.name];
        NSArray *fetchedTags = [self.coreDataHelper.managedObjectContext executeFetchRequest:fetchRequest
                                                                         error:&error];
        
        // Find the channel that this tags describe
        Channel *channel = (Channel *)[self.coreDataHelper findRecordForEntityName:@"Channel"
                                                                        byProperty:@"feedID"
                                                                         withValue:tag.feedID];
        if (channel == nil) {continue;}
        
        // Add to existing tag record
        Tag *theTag = nil;
        if (fetchedTags.count == 1) {
            theTag = [fetchedTags objectAtIndex:0];
        }
        else {
            // Create new
            theTag = [[Tag alloc] initWithEntity:ent
                        insertIntoManagedObjectContext:self.coreDataHelper.managedObjectContext];
            theTag.name = tag.name;
        }
        [theTag addChannelsObject:channel];
    }
}

- (void)sendNotificationSuccess:(BOOL)bYesNo {
    [[NSNotificationCenter defaultCenter] postNotificationName:kFetchTagsDone
                                                        object:nil
                                                      userInfo:@{kFetchResultBOOL: [NSNumber numberWithBool:bYesNo],
                                                                 kParserManagedObjectContext: self.coreDataHelper.managedObjectContext}];
}
@end
