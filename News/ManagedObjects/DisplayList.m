//
//  DisplayList.m
//  News
//
//  Created by karta sutanto on 10/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import "DisplayList.h"
#import "Channel.h"
#import "Tag.h"
#import "NSManagedObjectContext-EasyFetch.h"

@implementation DisplayList

@dynamic displayOrder;
@dynamic displayingDate;
@dynamic feed;
@dynamic tag;

- (DisplayListType)displayListType {
    if (self.feed != nil) {
        return DisplayListFeed;
    }else {
        return DisplayListTag;
    }
}

+ (BOOL)hasTagWithName:(NSString *)name inContext:(NSManagedObjectContext *)context {
    NSArray *tagsWithName = [context fetchObjectsForEntityName:@"Tag" predicateWithFormat:@"name = %@", name];
    NSArray *array = [context fetchObjectsForEntityName:@"DisplayList" predicateWithFormat:@"tag in %@", tagsWithName];
    if ([array count]==0) {
        return NO;
    }
    return YES;
}

+ (BOOL)hasFeedWithURL:(NSString *)feedURL inContext:(NSManagedObjectContext *)context {
//    NSArray *tagsWithName = [context fetchObjectsForEntityName:@"Channel" predicateWithFormat:@"feedURL = %@", feedURL];
    NSArray *array = [context fetchObjectsForEntityName:@"DisplayList" predicateWithFormat:@"feed.feedURL = %@", feedURL];
    if ([array count]==0) {
        return NO;
    }
    return YES;
}

+ (id)newDisplayItemTag:(Tag *)tag
              inContext:(NSManagedObjectContext *)context
           shouldInsert:(NSNumber *)bShouldInsert {
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DisplayList" inManagedObjectContext:context];
    DisplayList *displayList = [[DisplayList alloc] initWithEntity:entity
                                    insertIntoManagedObjectContext:([bShouldInsert boolValue] ? context : nil)];
    displayList.tag = tag;
    displayList.displayingDate = nil;
    displayList.feed = nil;
    displayList.displayOrder = @([[self highestDisplayOrderInContext:context] intValue] + 1);
    return displayList;
}

+ (id)newDisplayItemChannel:(Channel *)channel
                  inContext:(NSManagedObjectContext *)context
               shouldInsert:(NSNumber *)bShouldInsert {
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DisplayList" inManagedObjectContext:context];
    DisplayList *displayList = [[DisplayList alloc] initWithEntity:entity
                                    insertIntoManagedObjectContext:([bShouldInsert boolValue] ? context : nil)];
    displayList.feed = channel;
    displayList.displayingDate = nil;
    displayList.tag = nil;
    displayList.displayOrder = @([[self highestDisplayOrderInContext:context] intValue] + 1);
    return displayList;
}

+ (NSNumber *)highestDisplayOrderInContext:(NSManagedObjectContext *)context {
    NSArray *array = [context fetchObjectsForEntityName:@"DisplayList" sortByKey:@"displayOrder" ascending:NO];
    int nMaxDisplayOrder = 0;
    if ([array count] > 0) {
        DisplayList *displayList = [array objectAtIndex:0];
        nMaxDisplayOrder = [displayList.displayOrder integerValue];
    }
    
    return [NSNumber numberWithInt:nMaxDisplayOrder];
}
@end
