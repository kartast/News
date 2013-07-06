//
//  FeedBinAPI.m
//  News
//
//  Created by karta sutanto on 1/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//
//  TODO:
//  To test on fetch from background make sure call completion handler


#import "DiffBotAPI.h"
#import "AppDelegate.h"
#import "NSString+Base64.h"
#import "ParseSubscriptionOperation.h"
#import "ParseEntryOperation.h"
#import "ParseTagOperation.h"

#define API_POINT_FEEDBIN   @"https://api.feedbin.me/v2"
#define API_SUBSCRIPTIONS   @"subscriptions.json"
#define API_ENTRIES         @"entries.json"
#define API_TAGS            @"taggings.json"

@implementation DiffBotAPI
@synthesize apiToken    =  _apiToken;
@synthesize parserMOC;
@synthesize linksToQuery;

- (id)initWithToken:(NSString *)token {
    if (self = [super init]) {
        _apiToken = token;
        self.parseQueue = [NSOperationQueue new];
    }
    return self;
}

- (void)startAnalyzeAPIForLinks:(NSArray*)links {
    self.linksToQuery = [NSArray arrayWithArray:links];
}

- (void)startFetchFeeds {
    self.session = [self backgroundSession];
    
    [[NSNotificationCenter defaultCenter]
            addObserver:self
            selector:@selector(fetchFeedsDone:)
                name:kFetchSubscriptionsDone
                object:nil];
    
    [self getSubscriptions];
    
}

- (void)fetchFeedsDone:(NSNotification *)note {
    /*
     If success, fetch entries
     */
    NSDictionary *dict = [note userInfo];
    self.parserMOC = [dict objectForKey:kParserManagedObjectContext];
    BOOL bSuccessFail = [[dict objectForKey:kFetchResultBOOL] boolValue];
    if (bSuccessFail) {

    }else {

    }
}

- (void)getSubscriptions {
    
    /*
     Create a download task to download subscriptions json
     */
    NSURLRequest *request = [self requestForAPI:API_SUBSCRIPTIONS];
    self.downloadTask = [self.session downloadTaskWithRequest:request];
    [self.downloadTask setTaskDescription:API_SUBSCRIPTIONS];
}

- (NSURLRequest *)requestForAPI:(NSString *)api {
    
    /*
     Create API Request object from API End Point and Api path
     */
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", API_POINT_FEEDBIN, api];;
    NSURL *downloadURL = [NSURL URLWithString:urlString];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:downloadURL];

    return request;
}

- (NSURLSession *)backgroundSession
{
    /*
     Using disptach_once here ensures that multiple background sessions with the same identifier are not created in this instance of the application. If you want to support multiple background sessions within a single process, you should create each session with its own identifier.
     */
	static NSURLSession *session = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.unplug.Feeds.BackgroundSession"];
		session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
//        session = [NSURLSession sharedSession];
	});
	return session;
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
        if ([downloadTask.taskDescription isEqualToString:API_SUBSCRIPTIONS]) {
            /*
                Process Downloaded Subscriptions JSON
             */
            ParseSubscriptionOperation *parseOperation = [[ParseSubscriptionOperation alloc]
                                                          initWithDownloadedFilePath:destinationURL
                                                          andMapping:[self mappingForSubscriptions]
                                                          andManagedObjectContext:nil];
            [self.parseQueue addOperation:parseOperation];
        }
    }
    else
    {
        /*
         In the general case, what you might do in the event of failure depends on the error and the specifics of your application.
         */
        BLog(@"Error during the copy: %@", [errorCopy localizedDescription]);
    }
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    BLog();
    
    if (error == nil)
    {
        NSLog(@"Task: %@ completed successfully", task);
    }
    else
    {
        NSLog(@"Task: %@ completed with error: %@", task, [error localizedDescription]);
    }
	
//    double progress = (double)task.countOfBytesReceived / (double)task.countOfBytesExpectedToReceive;
//	dispatch_async(dispatch_get_main_queue(), ^{
//		self.progressView.progress = progress;
//	});
    
    self.downloadTask = nil;
}


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{

}

#pragma API MAPPING
- (NSDictionary *)mappingForSubscriptions {
    return @{@"feed_id": @"feedID",
             @"created_at": @"createdAt",
             @"title": @"title",
             @"id": @"guid",
             @"feed_url": @"feedURL",
             @"site_url": @"link"};
}

#pragma mark dealloc
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
