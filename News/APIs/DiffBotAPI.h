//
//  FeedBinAPI.h
//  News
//
//  Created by karta sutanto on 1/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import <Foundation/Foundation.h>
//static NSString *kFetchSubscriptionsDone            = @"kFetchSubscriptionsDone";
//static NSString *kFetchEntriessDone                 = @"kFetchEntriessDone";
//static NSString *kFetchTagsDone                     = @"kFetchTagsDone";
//static NSString *kFetchResultBOOL                   = @"kFetchResultBOOL";
//static NSString *kParserManagedObjectContext        = @"kParserManagedObjectContext";

@interface DiffBotAPI : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate> {

}
@property (nonatomic, strong) NSString *apiToken;
@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic) NSOperationQueue *parseQueue;
@property (nonatomic, strong) NSManagedObjectContext *parserMOC;
@property (nonatomic, retain) NSArray *linksToQuery;

- (id)initWithToken:(NSString*)token;
// Start background session and fetch
@end
