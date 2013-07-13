//
//  RSSFeedManager.m
//  News
//
//  Created by karta sutanto on 9/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import "RSSFeedManager.h"
#import "RSSKit.h"
#import "Channel.h"
#import "Item.h"
#import "NSDate+InternetDateTime.h"
#import "ISO8601DateFormatter.h"
#import "CoreDataHelper.h"
#import "AppDelegate.h"
#import "NSManagedObjectContext-EasyFetch.h"

static const int kSecondsChannelUpdated = -3*60*60;
static const int kMaxChannelSimultaneousFetchCount = 3;

@implementation RSSFeedManager
@synthesize cdHelper;
@synthesize session, downloadTasks, givenContext;

+ (id)sharedManager {
    static RSSFeedManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    
        sharedMyManager.cdHelper = [[CoreDataHelper alloc] initWithNewContextInCurrentThread];
        sharedMyManager.downloadTasks = [[NSMutableArray alloc] init];
    });
    return sharedMyManager;
}

+ (id)testManager {
    static RSSFeedManager *testManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        testManager = [[self alloc] init];
        
        testManager.cdHelper = [[CoreDataHelper alloc] initWithNewContextInCurrentThread];
        testManager.downloadTasks = [[NSMutableArray alloc] init];
    });
    return testManager;
}

- (void)fetchLatestEntriesInContext:(NSManagedObjectContext *)context {
    /*
        Get all channels, fetch all channels with updatedAt older than 1 hour
     */
    self.givenContext = context;
    int nCurrentDownloadTasksCount = [self.downloadTasks count];
    if (nCurrentDownloadTasksCount <= kMaxChannelSimultaneousFetchCount) {
        [self getNextChannelToFetch:^(Channel *channel) {
            //Add channel to download
            if (channel != nil) {
                [self startDownloadTaskForFeedURL:channel.feedURL];
                [self fetchLatestEntriesInContext:context];
            }
        } inContext:context];
    }
}

- (void)addFeedByURL:(NSString *)url
        withCallback:(RSSFeedAddingCallback)callback
           inContext:(NSManagedObjectContext *)context {
    RSSParser *rssFeedParser = [[RSSParser alloc] initWithUrl:url];
    [rssFeedParser parseWithCompletionCallback:^(RSSParser *parser, RSSFeed *feed, NSError *error) {
        if (error) {
            if (callback) {
                callback(false, nil, error);
            }
            
            return;
        }
        
        [self importFeedToCoreData:feed inContext:context];
        if (callback) {
            callback(true, feed, nil);
        }
    }];
}

/*
    Background downloading returns filePath, use this to process file
 */
- (void)processFeedFromFile:(NSString *)filePath
                    withURL:(NSString *)feedURL
                  inContext:(NSManagedObjectContext *)context
               withCallback:(RSSFeedAddingCallback)callback {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        // This calls in background
        NSManagedObjectContext *bgContext = context;
        if (bgContext == nil) {
            // create new one
            CoreDataHelper *helper = [[CoreDataHelper alloc] initWithNewContextInCurrentThread];
            bgContext = helper.managedObjectContext;
        } else {
            
        }
        NSData *rssData = [NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]];
        RSSParser *parser = [[RSSParser alloc] init];
        [parser parseData:rssData withURL:feedURL withCallback:^(RSSParser *parser, RSSFeed *feed, NSError *error) {
            if (error) {
                // TODO: Remember fail how many times, if too many times,
                // then dont fetch too often
                callback(false, nil, error);
                return;
            }
            
            [self importFeedToCoreData:feed inContext:bgContext];
            callback(true, feed, nil);
        }];
        
    });
    
}

/*
    From RSS XML file to Core data, ignore duplicates
 */
- (NSError *)importFeedToCoreData:(RSSFeed *)feed
                        inContext:(NSManagedObjectContext *)context {
    // TODO: validate feed
    // Channel
    Channel *channel = [Channel channelWithURL:feed.urlSelf inContext:context shouldInsert:@YES];
    if (channel.title) {
        // just update necessary info
        [channel setTitle:feed.title];
        [channel setFeedDescription:feed.description];
        [channel setUpdatedAt:[NSDate date]];
    }else {
        [channel setTitle:feed.title];
        [channel setFeedDescription:feed.description];
        [channel setAuthor:feed.author];
        [channel setGuid:feed.uid];
        [channel setCreatedAt:[NSDate date]];
        [channel setUpdatedAt:[NSDate dateWithTimeIntervalSince1970:0]];
        [channel setIconURL:feed.iconUrl];
        if (feed.urlSelf) {
            [channel setFeedURL:feed.urlSelf];
        }
        [channel setLink:feed.url];
        for (NSString *category in feed.categories) {
            [channel addCategory:category inContext:context];
        }
    }
    
    // Entries
    for (RSSEntry *article in feed.articles) {
        NSString *uid = article.uid;
        if ([uid length] < 3) {
            uid = article.url;
        }
        Item *item = [Item itemWithUID:uid inContext:context shouldInsert:@YES];
        if (!item.title) {
            // NOt created before
            item.title = article.title;
            item.link = article.url;
            item.guid = uid;
            item.unread = @YES;
            item.itemDescription = article.summary;
            item.content = article.content;
            NSDate *date = [NSDate dateFromInternetDateTimeString:[article date] formatHint:DateFormatHintRFC822];
            if (!date) {
                ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
                date = [formatter dateFromString:[article date]];
            }
            item.pubDate = date;
            item.createdAt = [NSDate date];
            item.author = article.author;
            item.channel = channel;
        }
        
    }
    
    if ([context hasChanges]) {
        NSError *error = nil;
        [context save:&error];
        if (error) {
            ALog(@"Error saving %@", error);
            return  error;
        }
    }
    return  nil;
}

- (void)getDownloadTasksCount:(void(^)(int))callback {
    if (self.downloadTasks) {
        int count = [self.downloadTasks count];
        callback(count);
    }
    else {
        [[self backgroundSession] getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            callback([self.downloadTasks count]);
        }];
    }
}

- (void)getNextChannelToFetch:(void(^)(Channel *))callback
                    inContext:(NSManagedObjectContext *)context {
    
    NSDate *threeHoursAgo = [NSDate dateWithTimeIntervalSinceNow:kSecondsChannelUpdated];
    NSArray *channelsToUpdate = [context fetchObjectsForEntityName:@"Channel"
                                               predicateWithFormat:@"updatedAt <= %@", threeHoursAgo];
    DLog(@"");
    [self getDownloadTasksCount:^(int currentDownloadingCount) {
        if ([channelsToUpdate count] > currentDownloadingCount && [channelsToUpdate count] != 0 && kMaxChannelSimultaneousFetchCount > currentDownloadingCount) {
            Channel *channelToFetchNext = [channelsToUpdate objectAtIndex:currentDownloadingCount];
            callback(channelToFetchNext);
        }else {
            callback(nil);
        }
    }];
}

#pragma mark -- background downloading
- (void)downloadTaskFinishForID:(int)taskID {
    NSMutableArray *downloadTasksCopy = [[NSMutableArray alloc] initWithArray:downloadTasks];
    for (NSURLSessionDownloadTask *task in downloadTasksCopy) {
        if ([task taskIdentifier] == taskID) {
            [downloadTasks removeObject:task];
        }
    }
}

- (void)finishDownloadTask:(NSURLSessionTask *)task withError:(NSError *)error {
    [self downloadTaskFinishForID:task.taskIdentifier];
}

- (void)startDownloadTaskForFeedURL:(NSString *)feedURL {
    for (NSURLSessionDownloadTask *dlTask in self.downloadTasks) {
        if ([[dlTask taskDescription] isEqualToString:feedURL]) {
            return;
        }
    }
    NSURLRequest *request = [self requestForURL:feedURL];
    NSURLSessionDownloadTask *downloadTask = [[self backgroundSession] downloadTaskWithRequest:request];
    [downloadTask setTaskDescription:feedURL];
    [downloadTask resume];
    
    [self.downloadTasks addObject:downloadTask];
}

- (NSURLRequest *)requestForURL:(NSString *)feedURL {
    
    /*
     Create API Request object from API End Point and Api path
     */
    NSString *urlString = [NSString stringWithFormat:@"%@", feedURL];;
    NSURL *downloadURL = [NSURL URLWithString:urlString];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:downloadURL];
    
    return request;
}

- (NSURLSession *)backgroundSession
{
    /*
     Using disptach_once here ensures that multiple background sessions with the same identifier are not created in this instance of the application. If you want to support multiple background sessions within a single process, you should create each session with its own identifier.
     */
	static NSURLSession *newSession = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.unplug.Feeds.BackgroundSession"];
		newSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        //        session = [NSURLSession sharedSession];
        
	});
	return newSession;
}
#pragma mark NSURLSession Delegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    BLog();
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)downloadURL
{
    BLog();
    /*
     The download completed, you need to copy the file at targetPath before the end of this block.
     As an example, copy the file to the Documents directory of your app.
     */
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *URLs = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsDirectory = [URLs objectAtIndex:0];
    
    NSURL *originalURL = [[downloadTask originalRequest] URL];
    NSURL *destinationURL = [documentsDirectory URLByAppendingPathComponent:[originalURL lastPathComponent]];
    NSError *errorCopy;
    
    // For the purposes of testing, remove any esisting file at the destination.
    [fileManager removeItemAtURL:destinationURL error:NULL];
    BOOL success = [fileManager copyItemAtURL:downloadURL toURL:destinationURL error:&errorCopy];
    
    if (success)
    {
        // Need to pass in the rss url
        [self processFeedFromFile:[destinationURL absoluteString] withURL:[downloadTask taskDescription] inContext:nil withCallback:^(BOOL bSuccess, RSSFeed *feed, NSError *error) {
            DLog(@"parse status: %d", bSuccess);
        }];
        [self fetchLatestEntriesInContext:self.givenContext];
    }
    else
    {
        /*
         In the general case, what you might do in the event of failure depends on the error and the specifics of your application.
         */
        BLog(@"Error during the copy: %@", [errorCopy localizedDescription]);
    }
    [self finishDownloadTask:downloadTask withError:nil];
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    BLog();
    
    [self finishDownloadTask:task withError:error];
    if (error == nil)
    {
        DLog(@"Task: %@ completed successfully", task);
    }
    else
    {
        DLog(@"Task: %@ completed with error: %@", task, [error localizedDescription]);
    }
	
    //    double progress = (double)task.countOfBytesReceived / (double)task.countOfBytesExpectedToReceive;
    //	dispatch_async(dispatch_get_main_queue(), ^{
    //		self.progressView.progress = progress;
    //	});
    //	[self checkForAllDownloadsHavingCompleted];
}


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}

- (void)URLSession:(NSURLSession *)session
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    BLog();
    
}
@end
