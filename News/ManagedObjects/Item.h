//
//  Item.h
//  News
//
//  Created by karta sutanto on 5/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Channel;

@interface Item : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * comments;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * enclosure;
@property (nonatomic, retain) NSNumber * feedID;
@property (nonatomic, retain) NSNumber * guid;
@property (nonatomic, retain) NSString * itemDescription;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSDate * pubDate;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * unread;
@property (nonatomic, retain) Channel *channel;
@property (nonatomic, retain) NSManagedObject *itemDetail;

@end
