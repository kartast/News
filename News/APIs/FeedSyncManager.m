//
//  FeedSyncManager.m
//  News
//
//  Created by karta sutanto on 6/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import "FeedSyncManager.h"
#import "FeedBinAPI.h"
#import "CoreDataHelper.h"

@implementation FeedSyncManager

+ (id)sharedManager {
    static FeedSyncManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {

    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

#pragma mark -- Sync stuffs
- (void)startSync {
    // TODO: make sure dont double sync
    if (!feedBinAPIManager) {
        feedBinAPIManager = [[FeedBinAPI alloc] initWithUserName:@"kartasutanto@gmail.com"
                                                     andPassword:@"asd12345"];
    }
    [feedBinAPIManager startFetchFeeds];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(syncFeedsEntriesDone:)
     name:kFetchEntriessDone
     object:nil];
}

- (void)syncFeedsEntriesDone:(NSNotification*) note {
    
    /*
        Finish Syncing Feeds and Entries
        Start to process articles - Get summary and images
        ?How to decide which one first?
        ?By the order of displaying the feeds
     */
    
    CoreDataHelper *cdHelper = [[CoreDataHelper alloc] initWithNewContextInCurrentThread];
    NSArray *array = [cdHelper fetchFeedsGroupedByTags];
    NSLog(@"%@", array);
}

#pragma mark -- Display List (the main page)

- (void)validateDisplayListWithSyncedData {
    /*
        Remove any tags not in database,
        Remove any feeds not in database,
        Append new tags just added,
        Append new feeds just added,
        Update existing tags name,
        Update existing feeds name
     */
}

@end
