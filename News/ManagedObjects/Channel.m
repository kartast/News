 //
//  Channel.m
//  News
//
//  Created by karta sutanto on 2/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import "Channel.h"
#import "Item.h"
#import "Tag.h"

@implementation Channel

@dynamic feedDescription;
@dynamic feedURL;
@dynamic imageURL;
@dynamic link;
@dynamic title;
@dynamic stringID;
@dynamic createdAt;
@dynamic guid;
@dynamic items;
@dynamic tags;
@dynamic channelCategory;
@dynamic author;
@dynamic iconURL;
@dynamic updatedAt;

+ (id)channelWithURL:(NSString *)feed_url
           inContext:(NSManagedObjectContext *)context
        shouldInsert:(NSNumber *)bShouldInsert {
    /*
     Create new channel if not already exist
     */
    NSArray *array = [context fetchObjectsForEntityName:@"Channel"
                                    predicateWithFormat:@"feedURL = %@", feed_url];
    Channel *channel;
    if ([array count] > 0) {
        channel = [array objectAtIndex:0];
    }else {
        // Create new
        NSEntityDescription *ent = [NSEntityDescription entityForName:@"Channel"
                                               inManagedObjectContext:context];
        channel = [[Channel alloc] initWithEntity:ent
                   insertIntoManagedObjectContext:([bShouldInsert boolValue] ? context : nil)];
        [channel setFeedURL:feed_url];
    }
    return  channel;
}

+ (id)channelWithURL:(NSString *)feed_url
               title:(NSString *)title
           createdAt:(NSDate *)created_at
                link:(NSString *)site_url
              syncID:(NSString *)syncID
           inContext:(NSManagedObjectContext *) context
        shouldInsert:(NSNumber *)bShouldInsert {
    /*
        Create new channel if not already exist
     */
    NSArray *array = [context fetchObjectsForEntityName:@"Channel"
                                    predicateWithFormat:@"feedURL = %@", feed_url];
    Channel *channel;
    if ([array count] > 0) {
        // Found & update
        channel = [array objectAtIndex:0];
        [channel setTitle:title];
        [channel setGuid:syncID];
    }else {
        // Create new
        NSEntityDescription *ent = [NSEntityDescription entityForName:@"Channel"
                                               inManagedObjectContext:context];
        channel = [[Channel alloc] initWithEntity:ent
                   insertIntoManagedObjectContext:([bShouldInsert boolValue] ? context : nil)];
        [channel setFeedURL:feed_url];
        [channel setTitle:title];
        [channel setCreatedAt:created_at];
        [channel setLink:site_url];
        NSString *guid = [NSString stringWithFormat:@"%@",(syncID ? syncID : @-1)];
        [channel setGuid:guid];
    }
    return  channel;
}

+ (NSArray *)importFromArray:(NSArray *)arrayOfDicts
                   inContext:(NSManagedObjectContext *)context
                shouldInsert:(NSNumber *)bShouldInsert {
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dict in arrayOfDicts) {
        NSString *feed_url = [dict objectForKey:@"feedURL"];
        NSString *title = [dict objectForKey:@"title"];
        NSDate *created_at = [dict objectForKey:@"createdAt"];
        NSString *site_url = [dict objectForKey:@"link"];
        NSNumber *syncID = [dict objectForKey:@"guid"];
        
        // validate
        if (!feed_url || !title || !created_at || !site_url) {
            DLog(@"Fail importing object: %@",dict);
            continue;
        }
        
        Channel *channel = [self channelWithURL:feed_url
                                          title:title
                                      createdAt:created_at
                                           link:site_url
                                         syncID:[NSString stringWithFormat:@"%@", syncID]
                                      inContext:context
                                   shouldInsert:bShouldInsert];
        [resultArray addObject:channel];
    }
    
    return resultArray;
}

+ (void)deleteChannelWithURL:(NSString *)url inContext:(NSManagedObjectContext *)context {
    NSArray *array = [context fetchObjectsForEntityName:@"Channel"
                                    predicateWithFormat:@"feedURL = %@", url];
    if ([array count] >0) {
        Channel *channel = [array objectAtIndex:0];
        [context deleteObject:channel];
    }
}

/*
 For syncing, delete the channels not returned by server
 */
+ (NSArray *)deleteChannelsExceptFor:(NSArray *)receivedFeedIDs
                           inContext:(NSManagedObjectContext *)context {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (guid IN %@)", receivedFeedIDs];
    NSArray *channelsToBeDeleted = [context fetchObjectsForEntityName:@"Channel" withPredicate:predicate];
    for (Channel *channel in channelsToBeDeleted) {
        [channel willBeDeleted];
        [context deleteObject:channel];
    }
    
    return [context fetchObjectsForEntityName:@"Channel"];
}

- (void)addCategory:(NSString *)categoryString
          inContext:(NSManagedObjectContext *)context {
    
    Tag *tag = [Tag TagForCategoryName:categoryString
                             inContext:context
                          shouldInsert:YES];
    
    [self addTagsObject:tag];
    
    NSError *error;
    [context save:&error];
    if (error) {
        ALog(@"save error");
    }
}

- (void)removeCategory:(NSString *)categoryString
             inContext:(NSManagedObjectContext *)context {
    [self.tags enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        Tag *tag = (Tag *)obj;
        if ([tag.name isEqualToString:categoryString]) {
            [self removeTagsObject:tag];
            *stop = YES;
        }
    }];
    
    if ([context hasChanges]) {
        NSError *error;
        [context save:&error];
        if (error) {
            ALog(@"save error");
        }
    }
}

- (void)willBeDeleted {
    //TODO: handle delettion, like clean up tags and entries
}

// TODO: isChannelReady?

@end
