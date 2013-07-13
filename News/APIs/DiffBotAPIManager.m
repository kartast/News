//
//  DiffBotAPIManager.m
//  News
//
//  Created by karta sutanto on 9/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import "DiffBotAPIManager.h"
#import "NSString+URLEncoding.h"
#import "ItemDetail.h"
#import "CoreDataHelper.h"

static const NSString *kTokenDiffBot = @"2532d012268a7d8c7ddad11c734710ee";
static const NSString *kDiffBotAPIURL = @"http://www.diffbot.com/api/batch";
static const int kMaxConnection = 5;

NSMutableArray *urlQueue;
NSMutableArray *urlAnalyzing;

NSMutableArray *downloadTasks;

@implementation DiffBotAPIManager

+ (id)sharedManager {
    static DiffBotAPIManager *staticManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticManager = [[self alloc] init];
        urlQueue = [[NSMutableArray alloc] init];
        urlAnalyzing = [[NSMutableArray alloc] init];
        downloadTasks = [[NSMutableArray alloc] init];
    });
    return staticManager;
}

- (void)addURLsToAnalyze:(NSArray *)URLs {
    [urlQueue addObjectsFromArray:URLs];
    [self checkNeedsDownload];
}

- (void)checkNeedsDownload {
    while ([downloadTasks count] < kMaxConnection &&
           [urlQueue count] > 0) {
        [self sendNextBatchOfURLsToAnalyze];
    }
}

- (void)sendNextBatchOfURLsToAnalyze {
    // If |urlQueue\ is empty, ignore
    // Get 50 urls
    // Send, wait for response
    
    NSMutableArray *urls = [[NSMutableArray alloc] init];
    while ([urls count] < 50 &&
           [urlQueue count]>0) {
        [urlAnalyzing addObject:[urlQueue lastObject]];
        [urls addObject:[urlQueue lastObject]];
        [urlQueue removeLastObject];
    }
    
    if ([urls count]>0) {
        [self sendAPIForURLs:urls];
        
    }
}

- (void)sendAPIForURLs:(NSArray*)urls {
    NSString *urlPostData = [self generatePostParamsFromUrls:urls];
    
    NSMutableURLRequest *urlRequest = [self articleRequestWithBatchPostData:urlPostData];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:self
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *dataTask =
    [session dataTaskWithRequest:urlRequest
               completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                   [self processResponse:data fromURLs:urls];
               }];
    
    [downloadTasks addObject:dataTask];
    [dataTask resume];
}

/*
 curl
 -d 'token=...'
 -d 'batch=[
 {"method": "GET", "relative_url": "/api/article?url=http%3A%2F%2Fblogs.wsj.com%2Fventurecapital%2F2012%2F05%2F31%2Finvestors-back-diffbots-visual-learning-robot-for-web-content%2F%3Fmod%3Dgoogle_news_blog%26token=..."},
 {"method": "GET", "relative_url": "/api/article?url=http%3A%2F%2Fgigaom.com%2Fcloud%2Fsilicon-valley-royalty-pony-up-2m-to-scale-diffbots-visual-learning-robot%2F%26token=..."}
 ]'
 http://www.diffbot.com/api/batch
 */
- (NSString *)generatePostParamsFromUrls:(NSArray *)URLs {
    NSMutableString *string = [[NSMutableString alloc] init];
    [string appendFormat:@"token=%@&batch=[", kTokenDiffBot];

    for (NSString *url in URLs) {
        NSString *urlEncodedString = [NSString stringWithFormat:@"/api/article?url=%@%%26token=%@%%26html=true%%26summary=true", [url urlencode], kTokenDiffBot];
        NSString *apiString = [NSString stringWithFormat:@"{\"method\": \"GET\", \"relative_url\": \"%@\"},", urlEncodedString];
        [string appendString:apiString];
    }
    
    // remove last comma
    [string deleteCharactersInRange:NSMakeRange([string length]-1, 1)];
    [string appendFormat:@"]"];
    return  string;
}

- (NSMutableURLRequest *)articleRequestWithBatchPostData:(NSString *)postString {
    
    /*
     Create API Request object from API End Point and Api path
     */
    NSString *urlString = [NSString stringWithFormat:@"%@", kDiffBotAPIURL];
    NSURL *downloadURL = [NSURL URLWithString:urlString];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:downloadURL];
    
    NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    return request;
}

#pragma -- Process DiffBot Data

- (void)processResponse:(NSData *)data fromURLs:(NSArray *)URLs {
    NSManagedObjectContext *context = [[CoreDataHelper alloc] initWithNewContextInCurrentThread].managedObjectContext;
    
    /*
        Separate results into each URL request
     */
    NSError *error = nil;
    if (data == nil) {
        [self sendAPIForURLs:URLs];// retry
        return;
    }
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data
                                                         options:NSJSONReadingMutableContainers
                                                           error:&error];
    NSMutableArray *urlsAnalyzedSuccess = [[NSMutableArray alloc] init];
    
    if (error) {
        // TODO: handle json error
    }
    
    NSLog(@"%@", jsonArray);
    for (NSDictionary *requestDict in jsonArray) {
        // body response is urlEncoded
        NSString *bodyEncoded = [requestDict valueForKey:@"body"];
        NSString *bodyDecoded = [bodyEncoded urlDecode];
        NSData *data = [bodyDecoded dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        if (data == nil ) {
            data = [bodyEncoded dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        }
        if (data == nil) {
            continue;
        }
        NSDictionary *bodyDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        // TODO: Check for errorCode
        // What to do if got errorCode?
        /*
            got error code means that the article fetching has failed, get the url
            !!just skip because the url returned is not the same
         */
        
        ItemDetail *itemDetail = [ItemDetail itemDetailFromResponseDict:bodyDict inContext:context shouldInsert:@YES];
        if (itemDetail != nil) {
            [urlsAnalyzedSuccess addObject:itemDetail.url];
        }
        DLog(@"%@", bodyDict);
    }
    
    // TODO: mark URL done or need to retry
    NSMutableArray *mutableURLs = [URLs mutableCopy];
    for (NSString *url in urlsAnalyzedSuccess) {
        NSString *theMatchingURL;
        for (NSString *urlSentToServer in mutableURLs) {
            if ([urlSentToServer isEqualToString:url]) {
                theMatchingURL = urlSentToServer;
                break;
            }
        }
        [mutableURLs removeObject:theMatchingURL];
    }
    
    // For those URL not marked, means probably got error, create a channelItem and request individually
    for (NSString *urlFailed in mutableURLs) {
        // Create invalid itemDetails
        [ItemDetail itemDetailInvalidWithURL:urlFailed inContext:context shouldInsert:@YES];
    }
    
    if ([context hasChanges]) {
        NSError *error;
        [context save:&error];
        if (error) {
            ALog(@"Error saving: %@", error);
        }
    }
}

@end
