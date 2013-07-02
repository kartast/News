//
//  FeedBinAPI.h
//  News
//
//  Created by karta sutanto on 1/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import <Foundation/Foundation.h>
static NSString *kFetchSubscriptionsDone          = @"kFetchSubscriptionsDone";
static NSString *kFetchEntriessDone               = @"kFetchEntriessDone";
static NSString *kFetchResultBOOL                 = @"kFetchResultBOOL";
static NSString *kParserManagedObjectContext      = @"kParserManagedObjectContext";

@interface FeedBinAPI : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate>
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *password;
@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic) NSOperationQueue *parseQueue;
@property (nonatomic, strong) NSManagedObjectContext *parserMOC;

- (id)initWithUserName:(NSString *)username andPassword:(NSString *)pwd;

// Start background session and fetch
- (void)startFetchFeeds;
- (void)startFetchEntries;
@end
