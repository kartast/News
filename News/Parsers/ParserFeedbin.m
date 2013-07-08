//
//  ParserFeedbin.m
//  News
//
//  Created by karta sutanto on 8/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import "ParserFeedbin.h"
#import "Channel.h"
#import "NSObject+JL_KeyPathIntrospection.h"
#import "ISO8601DateFormatter.h"

@implementation ParserFeedbin

+ (NSArray *)parseSubscriptionsJSON:(NSString *)jsonString {
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        ALog(@"error parsing subscriptions json");
        return nil;
    }
    
    for (NSDictionary *json in jsonArray) {
        [resultArray addObject:[self mapToChannelProperties:json]];
    }
    return resultArray;
}

+ (NSDictionary *)mapToChannelProperties:(NSDictionary *)sourceDict{
    /*
        Iterate each key in mapping, copy from sourceDict to targetDict
        Property type derived from channel object
     */
    NSMutableDictionary *targetDict = [[NSMutableDictionary alloc] init];
    NSDictionary *mapping = [self mappingForSubscriptions];
    
    for (NSString *key in mapping) {
        NSString *propertyName = [mapping objectForKey:key];
        Class propertyClass = [Channel JL_classForPropertyAtKeyPath:propertyName];
        // Check if entry has they key
        if (![sourceDict objectForKey:key] || [sourceDict objectForKey:key] == [NSNull null]) {
            continue;
        }
        
        if (propertyClass == [NSDate class]) {
            // convert
            NSString *dateString = [sourceDict objectForKey:key];
            ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
            NSDate *date = [formatter dateFromString:dateString];
            if (date) {
                [targetDict setValue:date forKey:propertyName];
            }
        }
        else if (propertyClass == [NSString class]) {
            // Handle String
            
            NSString *string = [sourceDict objectForKey:key];
            if ([string length] > 0) {
                [targetDict setValue:string forKey:propertyName];
            }
        }
        else if (propertyClass == [NSNumber class]) {
            // Handle String
            NSNumber *number = [sourceDict objectForKey:key];
            if (number != NULL) {
                [targetDict setValue:number forKey:propertyName];
            }
        }else if (propertyClass == [NSArray class]) {
        }

    }
    return targetDict;
}

#pragma -- API Mapping
+ (NSDictionary *)mappingForSubscriptions {
    return @{@"feed_id": @"feedID",
             @"created_at": @"createdAt",
             @"title": @"title",
             @"id": @"guid",
             @"feed_url": @"feedURL",
             @"site_url": @"link"};
}

+ (NSDictionary *)mappingForEntries {
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

+ (NSDictionary *)mappingForTags {
    return @{@"id": @"tagID",
             @"feed_id": @"feedID",
             @"name": @"name"};
}
@end
