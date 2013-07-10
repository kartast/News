//
//  ParserFeedbin.h
//  News
//
//  Created by karta sutanto on 8/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParserFeedbin : NSObject
+ (NSArray *)parseSubscriptionsJSON:(NSString *)jsonString;
+ (NSDictionary *)parseTagsJSON:(NSString *)jsonString;

+ (void)syncTagsJSONWithCoreDataForDict:(NSDictionary *)dict
                              inContext:(NSManagedObjectContext *)context;

+ (NSDictionary *)mappingForSubscriptions;
+ (NSDictionary *)mappingForEntries;
+ (NSDictionary *)mappingForTags;

@end
