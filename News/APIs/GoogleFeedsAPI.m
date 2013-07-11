//
//  GoogleFeedsAPI.m
//  News
//
//  Created by karta sutanto on 10/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import "GoogleFeedsAPI.h"
#import "NSString+URLEncoding.h"

@implementation GoogleFeedsQueryEntry
@synthesize link, title, url, contentSnippet;
@end

@implementation GoogleFeedsAPI
+ (id)sharedManager {
    static GoogleFeedsAPI *googleFeedsAPI;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        googleFeedsAPI = [[self alloc] init];
    });
    
    return  googleFeedsAPI;
}

- (void)queryWithString:(NSString *)string withCallback:(void (^)(BOOL, NSArray*))callback {
    static NSURLSessionDataTask *dataTask;
    if (dataTask) {
        [dataTask cancel];
    }
    
    NSString *urlEncodedQueryString = [string urlencode];
    NSString *urlString = [NSString stringWithFormat:@"https://ajax.googleapis.com/ajax/services/feed/find?v=1.0&q=%@", urlEncodedQueryString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [urlRequest setValue:@"http://unplug.io" forHTTPHeaderField:@"Referer"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    dataTask =
    [session dataTaskWithRequest:urlRequest
               completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                   BOOL bSuccess = true;
                   if (error) {
                       bSuccess = false;
                   }
                   NSError *jsonParserError = nil;
                   if (data == nil) {
                       bSuccess = false;
                   }
                   else {
                       NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData:data
                                                                                 options:NSJSONReadingMutableContainers
                                                                                   error:&jsonParserError];
                       NSArray *entryObjects = [self processResponseDictToArrayObjects:jsonArray];
                       if (jsonParserError) {
                           bSuccess = false;
                       }
                       
                       
                       if (bSuccess != false) {
                           callback(bSuccess, entryObjects);
                           return ;
                       }
                   }
                   
                   callback(bSuccess, nil);
               }];
    
    [dataTask resume];
}

- (NSArray *)processResponseDictToArrayObjects:(NSDictionary *)responseDict {
    NSDictionary *responseData = [responseDict objectForKey:@"responseData"];
    if (!responseData) {
        return nil;
    }
    NSArray *entries = [responseData objectForKey:@"entries"];
    NSMutableArray *entryObjects = [[NSMutableArray alloc] init];
    if (!entries) {
        return  nil;
    }
    
    for (NSDictionary *entry in entries) {
        GoogleFeedsQueryEntry *entryObj = [[GoogleFeedsQueryEntry alloc] init];
        entryObj.title = [entry objectForKey:@"title"];
        entryObj.link = [entry objectForKey:@"link"];
        entryObj.url  = [entry objectForKey:@"url"];
        entryObj.contentSnippet = [entry objectForKey:@"contentSnippet"];
        [entryObjects addObject:entryObj];
    }
    return entryObjects;
}
@end
