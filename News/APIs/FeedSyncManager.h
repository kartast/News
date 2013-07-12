//
//  FeedSyncManager.h
//  News
//
//  Created by karta sutanto on 6/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *kSyncFeedsEntriesDone         = @"SyncFeedsEntriesDone";

enum FeedSyncType {
    FeedSyncTypeRSS = 0,
    FeedSyncTypeFeedbin
};
typedef enum FeedSyncType FeedSyncType;

@class FeedBinAPI, ItemDetailFetcher, DisplayListManager;
@interface FeedSyncManager : NSObject {
    FeedBinAPI *feedBinAPIManager;
    FeedSyncType syncType;
    ItemDetailFetcher *itemDetailFetcher;
    DisplayListManager *displayListManager;
}

@property (nonatomic, readwrite) FeedSyncType syncType;

+ (id)sharedManager;
- (void)startSync;
@end
