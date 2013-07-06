//
//  Tag.h
//  News
//
//  Created by karta sutanto on 2/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Channel;

@interface Tag : NSManagedObject

@property (nonatomic, retain) NSNumber * tagID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *channels;

@property (nonatomic, retain) NSNumber *feedID;
@end

@interface Tag (CoreDataGeneratedAccessors)

- (void)addChannelsObject:(Channel *)value;
- (void)removeChannelsObject:(Channel *)value;
- (void)addChannels:(NSSet *)values;
- (void)removeChannels:(NSSet *)values;

@end
