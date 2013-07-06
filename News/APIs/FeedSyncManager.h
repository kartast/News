//
//  FeedSyncManager.h
//  News
//
//  Created by karta sutanto on 6/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *kSyncFeedsEntriesDone         = @"SyncFeedsEntriesDone";

@class FeedBinAPI;
@interface FeedSyncManager : NSObject {
    FeedBinAPI *feedBinAPIManager;
}

+ (id)sharedManager;
- (void)startSync;
@end
