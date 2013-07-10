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
#import "ParserFeedbin.h"

@implementation ParseSubscriptionOperation

// -------------------------------------------------------------------------------
//	main:
// -------------------------------------------------------------------------------
- (void)main {
    if (![self isCancelled] && self.fileURL != nil) {
        coreDataHelper = [[CoreDataHelper alloc] initWithNewContextInCurrentThread];
        
        NSData *jsonData = [NSData dataWithContentsOfFile:[self.fileURL path]];
        if (!jsonData) {
            [self sendNotificationSuccess:NO];
            return;
        }
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

- (void)parseAndSyncFromFeedBinSubscriptionsJSON:(NSString *)json
                                       inContext:(NSManagedObjectContext *)ctx {
    
    NSArray *parsedResults = [ParserFeedbin parseSubscriptionsJSON:json];
    NSArray *importedChannels = [Channel importFromArray:parsedResults
                                               inContext:ctx
                                            shouldInsert:@YES];
    
    DLog(@"imported %d channels", [importedChannels count]);
    
    // Remove the ones not in the server
    NSMutableArray *receivedFeedIDs = [[NSMutableArray alloc] init];
    for (NSDictionary *channelDict in parsedResults) {
        [receivedFeedIDs addObject:[channelDict objectForKey:@"guid"]];
    }
    
    NSArray *syncedChannels = [Channel deleteChannelsExceptFor:(NSArray *)receivedFeedIDs
                                                     inContext:ctx];
    
    DLog(@"Synced %d channels", [syncedChannels count]);
    
    if ([ctx hasChanges]) {
        NSError *saveError = nil;
        if (![ctx save:&saveError]) {
            ALog(@"save fail: %@", saveError);
            [self sendNotificationSuccess:NO];
            return;
        }
    }
    [self sendNotificationSuccess:YES];
    
    
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
            ALog(@"save fail");
            [self sendNotificationSuccess:NO];
            return;
        }
    }
    [self sendNotificationSuccess:YES];
    
    DLog(@"save ok");
}

- (void)sendNotificationSuccess:(BOOL)bYesNo {
    [[NSNotificationCenter defaultCenter] postNotificationName:kFetchSubscriptionsDone
                                                        object:nil
                                                      userInfo:@{kFetchResultBOOL: [NSNumber numberWithBool:bYesNo]}];
}
@end
