//
//  RSSFeedManager.h
//  News
//
//  Created by karta sutanto on 9/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RSSFeed;
@class CoreDataHelper;

typedef void (^RSSFeedAddingCallback)(BOOL, RSSFeed *, NSError *);

@interface RSSFeedManager : NSObject <NSURLSessionDataDelegate> {
    CoreDataHelper *cdHelper;
}
@property (nonatomic, retain) CoreDataHelper *cdHelper;
@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSMutableArray *downloadTasks; //NSURLSessionDownloadTask

+ (id)sharedManager;
- (void)fetchLatestEntries;
- (void)addFeedByURL:(NSString *)url
        withCallback:(RSSFeedAddingCallback)callback
           inContext:(NSManagedObjectContext *)context;
- (void)processFeedFromFile:(NSString *)filePath
                  inContext:(NSManagedObjectContext *)context
               withCallback:(RSSFeedAddingCallback)callback;
@end
