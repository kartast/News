//
//  Channel.h
//  News
//
//  Created by karta sutanto on 2/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item, Tag;

@interface Channel : NSManagedObject

@property (nonatomic, retain) NSString * feedDescription;
@property (nonatomic, retain) NSString * feedURL;
@property (nonatomic, retain) NSNumber * feedID;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * stringID;
@property (nonatomic, retain) NSString * channelCategory;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * guid;
@property (nonatomic, retain) NSOrderedSet *items;
@property (nonatomic, retain) NSSet *tags;
@end

@interface Channel (CoreDataGeneratedAccessors)

- (void)insertObject:(Item *)value inItemsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromItemsAtIndex:(NSUInteger)idx;
- (void)insertItems:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeItemsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInItemsAtIndex:(NSUInteger)idx withObject:(Item *)value;
- (void)replaceItemsAtIndexes:(NSIndexSet *)indexes withItems:(NSArray *)values;
- (void)addItemsObject:(Item *)value;
- (void)removeItemsObject:(Item *)value;
- (void)addItems:(NSOrderedSet *)values;
- (void)removeItems:(NSOrderedSet *)values;
- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
