//
//  ItemDetail.h
//  News
//
//  Created by karta sutanto on 5/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Media;
@class Item;

@interface ItemDetail : NSManagedObject

@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * html;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * resolvedURL;
@property (nonatomic, retain) Item *item;
@property (nonatomic, retain) NSSet *medias;
@property (nonatomic) BOOL isValid;

+ (id)itemDetailForURL:(NSString *)url
             inContext:(NSManagedObjectContext *)context
          shouldInsert:(NSNumber *)bShouldInsert;

+ (id)itemDetailFromResponseDict:(NSDictionary *)dict
                       inContext:(NSManagedObjectContext *)context
                    shouldInsert:(NSNumber *)bShouldInsert;

+ (id)itemDetailInvalidWithURL:(NSString *)url
                     inContext:(NSManagedObjectContext *)context
                  shouldInsert:(NSNumber *)bShouldInsert;
@end

@interface ItemDetail (CoreDataGeneratedAccessors)

- (void)addMediasObject:(Media *)value;
- (void)removeMediasObject:(Media *)value;
- (void)addMedias:(NSSet *)values;
- (void)removeMedias:(NSSet *)values;
@end