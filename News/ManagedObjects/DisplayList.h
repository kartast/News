//
//  DisplayList.h
//  News
//
//  Created by karta sutanto on 10/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Channel, Tag;

@interface DisplayList : NSManagedObject

@property (nonatomic, retain) NSNumber * displayOrder;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSDate * displayingDate;
@property (nonatomic, retain) Channel *feed;
@property (nonatomic, retain) Tag *tag;

@end
