//
//  DisplayList.h
//  News
//
//  Created by karta sutanto on 10/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

enum DisplayListType {
    DisplayListTag,
    DisplayListFeed
};
typedef enum DisplayListType DisplayListType;

@class Channel, Tag;

@interface DisplayList : NSManagedObject

@property (nonatomic, retain) NSNumber * displayOrder;
@property (nonatomic, retain) NSDate * displayingDate;
@property (nonatomic, retain) Channel *feed;
@property (nonatomic, retain) Tag *tag;

- (DisplayListType)displayListType;
+ (BOOL)hasTagWithName:(NSString *)name inContext:(NSManagedObjectContext *)context;
+ (BOOL)hasFeedWithURL:(NSString *)feedURL inContext:(NSManagedObjectContext *)context;
+ (id)newDisplayItemTag:(Tag *)tag
              inContext:(NSManagedObjectContext *)context
           shouldInsert:(NSNumber *)bShouldInsert;
+ (id)newDisplayItemChannel:(Channel *)channel
                  inContext:(NSManagedObjectContext *)context
               shouldInsert:(NSNumber *)bShouldInsert;
+ (NSNumber *)highestDisplayOrderInContext:(NSManagedObjectContext *)context;
- (NSString *)displayImage;
@end
