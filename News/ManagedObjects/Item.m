//
//  Item.m
//  News
//
//  Created by karta sutanto on 5/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import "Item.h"
#import "Channel.h"
#import "NSManagedObjectContext-EasyFetch.h"

@implementation Item

@dynamic author;
@dynamic comments;
@dynamic createdAt;
@dynamic enclosure;
@dynamic feedID;
@dynamic guid;
@dynamic content;
@dynamic link;
@dynamic pubDate;
@dynamic itemDescription;
@dynamic title;
@dynamic unread;
@dynamic channel;
@dynamic itemDetail;

+ (id)itemWithUID:(NSString *)uid
        inContext:(NSManagedObjectContext *)context
     shouldInsert:(NSNumber *)bShouldInsert {
    NSArray *array = [context fetchObjectsForEntityName:@"Item" predicateWithFormat:@"guid = %@", uid];
    
    Item *item;
    if ([array count] > 0) {
        item = [array objectAtIndex:0];
    }else {
        NSEntityDescription *ent = [NSEntityDescription entityForName:@"Item"
                                               inManagedObjectContext:context];
        item = [[Item alloc] initWithEntity:ent insertIntoManagedObjectContext:([bShouldInsert boolValue] ? context : nil)];
        item.createdAt = [NSDate date];
    }
    return item;
}

+ (id)findItemWithLink:(NSString *)url
             inContext:(NSManagedObjectContext *)context
          shouldInsert:(NSNumber *)bShouldInsert {
    NSArray *array = [context fetchObjectsForEntityName:@"Item" predicateWithFormat:@"link = %@", url];
    Item *item = nil;
    if ([array count] > 0) {
        item = [array objectAtIndex:0];
    }
    return item;
}

@end
