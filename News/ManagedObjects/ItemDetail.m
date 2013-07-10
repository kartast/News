//
//  ItemDetail.m
//  News
//
//  Created by karta sutanto on 5/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import "ItemDetail.h"
#import "Item.h"
#import "Media.h"

@implementation ItemDetail

@dynamic icon;
@dynamic author;
@dynamic text;
@dynamic title;
@dynamic date;
@dynamic html;
@dynamic type;
@dynamic url;
@dynamic resolvedURL;
@dynamic item;
@dynamic summary;
@dynamic isValid;

+ (id)itemDetailForURL:(NSString *)url
             inContext:(NSManagedObjectContext *)context
          shouldInsert:(NSNumber *)bShouldInsert {
    NSArray *array = [context fetchObjectsForEntityName:@"ItemDetail" predicateWithFormat:@"url = %@", url];
    
    ItemDetail *itemDetail;
    if ([array count] > 0) {
        itemDetail = [array objectAtIndex:0];
    }else {
        NSEntityDescription *ent = [NSEntityDescription entityForName:@"ItemDetail"
                                               inManagedObjectContext:context];
        itemDetail = [[ItemDetail alloc] initWithEntity:ent
                         insertIntoManagedObjectContext:([bShouldInsert boolValue] ? context : nil)];
        itemDetail.url = url;
    }
    return itemDetail;
}

+ (id)itemDetailFromResponseDict:(NSDictionary *)dict
                       inContext:(NSManagedObjectContext *)context
                    shouldInsert:(NSNumber *)bShouldInsert {
    // Check got body or not
    NSString *text = [dict valueForKey:@"text"];
    if ([text length] < 1) {
        // Not valid
        return nil;
    }
    
    ItemDetail *itemDetail = [self itemDetailForURL:[dict valueForKey:@"url"]
                              inContext:context
                           shouldInsert:bShouldInsert];
    
    if ([dict valueForKey:@"icon"]) {
        [itemDetail setValue:[dict valueForKey:@"icon"] forKey:@"icon"];
    }
    if ([dict valueForKey:@"author"]) {
        [itemDetail setValue:[dict valueForKey:@"author"] forKey:@"author"];
    }
    if ([dict valueForKey:@"text"]) {
        [itemDetail setValue:[dict valueForKey:@"text"] forKey:@"text"];
    }
    if ([dict valueForKey:@"date"]) {
        // Handle date
    }
    if ([dict valueForKey:@"type"]) {
        [itemDetail setValue:[dict valueForKey:@"type"] forKey:@"type"];
    }
    if ([dict valueForKey:@"media"]) {
        // Handle media
        NSArray *mediaDicts = [dict valueForKey:@"media"];
        for (NSDictionary *mediaDict in mediaDicts) {
            // caption, link, primary, type
            if ([mediaDict valueForKey:@"caption"]) {
                
            }
        }
    }
    if ([dict valueForKey:@"url"]) {
        [itemDetail setValue:[dict valueForKey:@"url"] forKey:@"url"];
    }
    if ([dict valueForKey:@"resolvedURL"]) {
        [itemDetail setValue:[dict valueForKey:@"resolvedURL"] forKey:@"resolvedURL"];
    }
    if ([dict valueForKey:@"summary"]) {
        [itemDetail setValue:[dict valueForKey:@"summary"] forKey:@"summary"];
    }
    // Link with proper item
    return itemDetail;
}

@end
