//
//  ParseSubscriptionOperation.m
//  News
//
//  Created by karta sutanto on 1/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import "ParseSubscriptionOperation.h"
#import "Channel.h"
#import "AppDelegate.h"
#import "NSObject+JL_KeyPathIntrospection.h"
#import "ISO8601DateFormatter.h"

@implementation ParseSubscriptionOperation

// -------------------------------------------------------------------------------
//	main:
// -------------------------------------------------------------------------------
- (void)main {
    if (![self isCancelled] && self.fileURL != nil) {
//        self.managedObjectContext = [[NSManagedObjectContext alloc] init];
//        self.managedObjectContext.persistentStoreCoordinator = self.sharedPSC;
        coreDataHelper = [[CoreDataHelper alloc] initWithNewContextInCurrentThread];
        
        NSData *jsonData = [NSData dataWithContentsOfFile:[self.fileURL path]];
        NSError *error;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&error];
        channels = [[NSMutableArray alloc] init];
        [self mapJSONArray:jsonArray
                 toObjects:channels
               withMapping:apiMapping
             andEntityName:@"Channel"];
        
        [self addChannelToCoreData:channels];
        
        [self cleanup];
    }
}

- (void)addChannelToCoreData:(NSArray*)channelsArray{
    
    /*
     add channel to core data, check for duplicate
     */
    NSError *error = nil;
    Channel *channel = nil;
    for (channel in channelsArray) {
        BOOL bResult = [coreDataHelper isRecordExistForEntityName:@"Channel"
                                                       byProperty:@"guid"
                                                        withValue:channel.guid];
        if (!bResult) {
            [self.coreDataHelper.managedObjectContext insertObject:channel];
        }
    }
    
    if ([self.coreDataHelper.managedObjectContext hasChanges]) {
        if (![self.coreDataHelper.managedObjectContext save:&error]) {
            // save fail
            NSLog(@"save fail");
            [[NSNotificationCenter defaultCenter] postNotificationName:kFetchSubscriptionsDone
                                                                object:nil
                                                              userInfo:@{kFetchResultBOOL: @NO,
                                                                         kParserManagedObjectContext: self.coreDataHelper.managedObjectContext}];
            return;
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kFetchSubscriptionsDone
                                                        object:nil
                                                      userInfo:@{kFetchResultBOOL: @YES,
                                                                 kParserManagedObjectContext: self.coreDataHelper.managedObjectContext}];
    NSLog(@"save ok");
}
@end
