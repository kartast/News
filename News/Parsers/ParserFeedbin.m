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
#import "Tag.h"

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

// Feedbin one to one realtionship between Channel with tags
// We use One - Many Channel with tags
+ (NSDictionary *)parseTagsJSON:(NSString *)jsonString {
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:NSJSONReadingMutableContainers error:&error];
    
    for (NSDictionary *dict in jsonArray) {
        NSString *tagName = [dict objectForKey:@"name"];
        NSMutableArray *feedIDs = [resultDict valueForKey:tagName];
        if (feedIDs == nil) {
            feedIDs = [[NSMutableArray alloc] init];
            [resultDict setValue:feedIDs forKey:tagName];
        }
        [feedIDs addObject:[dict valueForKey:@"feed_id"]];
    }
    return resultDict;
}

+ (void)syncTagsJSONWithCoreDataForDict:(NSDictionary *)dict
                              inContext:(NSManagedObjectContext *)context {
    
    // Delete the tags not sent from server
    NSMutableArray *allTagNames = [[dict allKeys] mutableCopy];
    NSMutableArray *allInvalidTagsInCoreData = [[context fetchObjectsForEntityName:@"Tag"
                                                               predicateWithFormat:@"NOT (name in %@)", allTagNames]
                                                mutableCopy];
    
    for (Tag *tag in allInvalidTagsInCoreData) {
        [context deleteObject:tag];
    }
    
    NSMutableArray *allFeedIDsWithTags = [[NSMutableArray alloc] init];
    
    // Delete the feed not in the server's tags
    for (NSString *tagName in [dict allKeys]) {
        NSArray *feedIDsforTagFromServer = [dict objectForKey:tagName];
        [allFeedIDsWithTags  addObjectsFromArray:feedIDsforTagFromServer];
        
        // Get the channels not inside here from CORe data
        NSArray *allChannelsWithCategoryRemoved = [context fetchObjectsForEntityName:@"Channel"
                                                                 predicateWithFormat:@"ANY tags.name contains[cd] %@ AND NOT (feedID IN %@) ", tagName, feedIDsforTagFromServer];
        for (Channel *channel in allChannelsWithCategoryRemoved) {
            [channel removeCategory:tagName inContext:context];
        }
    }
    
    NSArray *allValidTagsInCoreData = [context fetchObjectsForEntityName:@"Tag"];
    NSArray *allChannelWithTags = [context fetchObjectsForEntityName:@"Channel"
                                                 predicateWithFormat:@"guid IN %@", allFeedIDsWithTags];
    // Add new categories
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        for (NSNumber *feedID in (NSArray *)obj) {
            NSString *tagName = (NSString *)key;
            Tag *theTag = nil;
            for (Tag* tag in allValidTagsInCoreData) {
                if ([tag.name isEqualToString:tagName]) {
                    theTag = tag;
                    break;
                }
            }
            
            // Create if needed
            if (theTag == nil) {
                theTag = [Tag TagForCategoryName:tagName inContext:context shouldInsert:YES];
            }
            
            if (![theTag hasFeedID:feedID]) {
                // Find the channel
                NSUInteger index = [allChannelWithTags indexOfObjectPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop) {
                    return [[(Channel *)obj guid] isEqualToString:[NSString stringWithFormat:@"%@",feedID]];
                }];
                if (index != NSNotFound) {
                    // Add category to the channel
                    Channel *channel = [allChannelWithTags objectAtIndex:index];
                    [channel addCategory:theTag.name inContext:context];
                }
            }
        }
    }];
}

#pragma -- API Mapping
+ (NSDictionary *)mappingForSubscriptions {
    return @{@"created_at": @"createdAt",
             @"title": @"title",
             @"feed_id": @"guid",
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
