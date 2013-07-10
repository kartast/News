//
//  Tag.m
//  News
//
//  Created by karta sutanto on 2/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import "Tag.h"
#import "Channel.h"


@implementation Tag

@dynamic guid;
@dynamic name;
@dynamic channels;
@synthesize feedID;

+ (id)TagForCategoryName:(NSString *)name
               inContext:(NSManagedObjectContext *)ctx
            shouldInsert:(BOOL)bShouldInsert {
    NSArray *array = [ctx fetchObjectsForEntityName:@"Tag" predicateWithFormat:@"name = %@", name];
    if ([array count] > 0) {
        return [array objectAtIndex:0];
    }
    
    NSEntityDescription *ent = [NSEntityDescription entityForName:@"Tag"
                                           inManagedObjectContext:ctx];
    Tag *tag = [[Tag alloc] initWithEntity:ent
            insertIntoManagedObjectContext:(bShouldInsert? ctx : nil)];
    tag.name = name;
    return tag;
}

+ (void)deleteTagWithName:(NSString *)name
              inContext:(NSManagedObjectContext *)ctx {
    
    NSArray *array = [ctx fetchObjectsForEntityName:@"Tag" predicateWithFormat:@"name ==[c] %@", name];
    if ([array count] > 0) {
        Tag *tag = [array objectAtIndex:0];
        [ctx deleteObject:tag];
    }
    
    if ([ctx hasChanges]) {
        NSError *err;
        [ctx save:&err];
        if (err) {
            ALog(@"deleting tag error");
        }
    }
}

+ (void)importFromDictionary:(NSDictionary *)dict
         shouldRemoveTheRest:(BOOL)bShouldDelete
                   inContext:(NSManagedObjectContext *)context {

}

- (BOOL)hasFeedID:(NSNumber *)feed_id {
    BOOL bFound = false;
    for (Channel *channel in [self.channels allObjects]) {
        if ([channel.guid isEqualToString:[NSString stringWithFormat:@"%@",feed_id]]) {
            bFound = true;
            break;
        }
    }
    return bFound;
}

@end
