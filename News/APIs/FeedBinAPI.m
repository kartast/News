//
//  FeedBinAPI.m
//  News
//
//  Created by karta sutanto on 1/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//
//  TODO: To test on fetch from background make sure call completion handler


#import "FeedBinAPI.h"
#import "AppDelegate.h"
#import "NSString+Base64.h"
#import "ParseSubscriptionOperation.h"
#import "ParseEntryOperation.h"
#import "ParseTagOperation.h"
#import "FeedSyncManager.h"

#define API_POINT_FEEDBIN   @"https://api.feedbin.me/v2"
#define API_SUBSCRIPTIONS   @"subscriptions.json"
#define API_ENTRIES         @"entries.json"
#define API_TAGS            @"taggings.json"

@implementation FeedBinAPI
@synthesize userName = _userName;
@synthesize password = _password;
@synthesize parserMOC;

- (id)initWithUserName:(NSString *)username andPassword:(NSString *)pwd {
    if (self = [super init]) {
        _userName = username;
        _password = pwd;
        self.parseQueue = [NSOperationQueue new];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        [self startFetchTags];
    }else {
        [self startFetchFeeds];
    }
}

- (void)startFetchTags {
    self.session = [self backgroundSession];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(fetchTagsDone:)
        name:kFetchTagsDone
        object:nil];
    [self getTags];
}

- (void)fetchTagsDone:(NSNotification *)note {
    NSDictionary *dict = [note userInfo];
    BOOL bSuccessFail = [[dict objectForKey:kFetchResultBOOL] boolValue];
    if (bSuccessFail) {
        [self startFetchEntries];
    } else {
        [self startFetchFeeds];
    }
}

- (void)startFetchEntries {
    self.session = [self backgroundSession];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(fetchEntriesDone:)
        name:kFetchEntriessDone
        object:nil];
    
    [self getFeeds];
}

- (void)fetchEntriesDone:(NSNotification *)note {
    NSDictionary *dict = [note userInfo];
    BOOL bSuccessFail = [[dict objectForKey:kFetchResultBOOL] boolValue];
    if (bSuccessFail) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSyncFeedsEntriesDone
                                                            object:nil
                                                          userInfo:nil];
    } else {
//        [self startFetchFeeds];
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

- (void)getFeeds {
    
    /*
     Create a download task to downloads entries json
     */
    NSURLRequest *request = [self requestForAPI:API_ENTRIES];
    self.downloadTask = [self.session downloadTaskWithRequest:request];
    [self.downloadTask setTaskDescription:API_ENTRIES];
}

- (void)getTags {
    NSURLRequest *request = [self requestForAPI:API_TAGS];
    self.downloadTask = [self.session downloadTaskWithRequest:request];
    [self.downloadTask setTaskDescription:API_TAGS];
}

- (NSURLRequest *)requestForAPI:(NSString *)api {
    
    /*
     Create API Request object from API End Point and Api path
     */
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", API_POINT_FEEDBIN, api];;
    NSURL *downloadURL = [NSURL URLWithString:urlString];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:downloadURL];
    
    NSString *loginString = [NSString stringWithFormat:@"%@:%@", _userName, _password];
    NSString *encodedLoginData = [NSString encodeBase64WithString:loginString];
    NSString *loginHeader = [NSString stringWithFormat:@"Basic %@", encodedLoginData];
    
    [request setValue:loginHeader forHTTPHeaderField:@"Authorization"];
    return request;
}

- (void)checkForAllDownloadsHavingCompleted
{
    /*
     Ask the session for its current tasks; if there are none, then the session is complete.
     */
	[self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
		NSUInteger count = [dataTasks count] + [uploadTasks count] + [downloadTasks count];
		if (count == 0)
        {
            /*
             If we were launched via the application:handleEventsForBackgroundURLSession:completionHandler delegate, invoke the completion handler now
             */
			NSLog(@"All tasks are finished");
			AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
			if (appDelegate.backgroundSessionCompletionHandler) {
				void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
				appDelegate.backgroundSessionCompletionHandler = nil;
				completionHandler();
			}
		}
	}];
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
        else if ([downloadTask.taskDescription isEqualToString:API_ENTRIES]){
            /*
             Process Downloaded Entries JSON
             */
            ParseEntryOperation *parseOperation = [[ParseEntryOperation alloc] initWithDownloadedFilePath:destinationURL
                                                                                               andMapping:[self mappingForEntries]
                                                                                  andManagedObjectContext:nil];
            [self.parseQueue addOperation:parseOperation];
        }else if ([downloadTask.taskDescription isEqualToString:API_TAGS] ) {
            /*
                Process downloaded tags json
             */
            ParseTagOperation *parseOperation = [[ParseTagOperation alloc] initWithDownloadedFilePath:destinationURL
                                                                                           andMapping:[self mappingForTags]
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
//	[self checkForAllDownloadsHavingCompleted];
}


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{

}

- (void)URLSession:(NSURLSession *)session
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    BLog();
    if (_userName && _password) {
        NSURLCredential *credential = [NSURLCredential credentialWithUser:_userName
                                                                 password:_password
                                                              persistence:NSURLCredentialPersistencePermanent];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    }else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
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

- (NSDictionary *)mappingForEntries {
    return @{@"id":         @"guid",
             @"feed_id":    @"feedID",
             @"title":      @"title",
             @"url":        @"link",
             @"author":     @"author",
             @"content":    @"itemDescription",
             @"summary":    @"summary",
             @"published":  @"pubDate",
             @"created_at": @"createdAt"};
}

- (NSDictionary *)mappingForTags {
    return @{@"id": @"tagID",
             @"feed_id": @"feedID",
             @"name": @"name"};
}
@end
