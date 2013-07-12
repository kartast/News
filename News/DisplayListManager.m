//
//  DisplayListManager.m
//  News
//
//  Created by karta sutanto on 12/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import "DisplayListManager.h"
#import "DisplayList.h"
#import "Channel.h"
#import "Item.h"
#import "Tag.h"
#import "NSManagedObjectContext-EasyFetch.h"

@implementation DisplayListManager
@synthesize context;
- (id)initWithContext:(NSManagedObjectContext *)ctx {
    if (self = [super init]) {
        self.context = ctx;
    }
    return self;
}

- (void)startMonitor {
    // add any new channel or tag into displaylist
    // Channels with no tag
    NSPredicate *predicateChannelsTagNil = [NSPredicate predicateWithFormat:@"tags.@count == 0"];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Channel"
                                                         inManagedObjectContext:context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    fetchRequest.entity = entityDescription;
    fetchRequest.predicate = predicateChannelsTagNil;
    channelsFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                           managedObjectContext:context
                                                                             sectionNameKeyPath:nil
                                                                                      cacheName:nil];
    channelsFetchedResultsController.delegate = self;
    
    // Tags with at least one Channel
    NSPredicate *predicateTagChannelNotNil = [NSPredicate predicateWithFormat:@"channels.@count > 0"];
    entityDescription = [NSEntityDescription entityForName:@"Tag"
                                                         inManagedObjectContext:context];
    fetchRequest = [[NSFetchRequest alloc] init];
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    fetchRequest.entity = entityDescription;
    fetchRequest.predicate = predicateTagChannelNotNil;
    tagsFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                       managedObjectContext:context
                                                                         sectionNameKeyPath:nil
                                                                                  cacheName:nil];
    tagsFetchedResultsController.delegate = self;
    
    NSError *error;
    if ([tagsFetchedResultsController performFetch:&error]) {
        [self tagsFetchResultsChangedContent:tagsFetchedResultsController.fetchedObjects];
    }
    if (error) {
        ALog(@"error fetching tags");
    }
    if ([channelsFetchedResultsController performFetch:&error]) {
        [self channelsFetchResultsChangedContent:channelsFetchedResultsController.fetchedObjects];
    }
    if (error) {
        ALog(@"error fetching channels");
    }
}

- (void)channelsFetchResultsChangedContent:(NSArray*)fetchedChannels {
    // Remove any channel not in fetchedChannels
    NSArray *invalidChannels = [self.context fetchObjectsForEntityName:@"DisplayList"
                                                   predicateWithFormat:@"NOT (feed in %@)", fetchedChannels];
    for (DisplayList * displayList in invalidChannels) {
        [self.context deleteObject:displayList];
    }
    
    /*
        check if any channel not in displaylist
        add to displayList
     */
    for (Channel *channel in fetchedChannels) {
        if (![DisplayList hasFeedWithURL:channel.feedURL inContext:self.context]) {
            // Not exist, create new one with highest order
            DisplayList *newItem = [DisplayList newDisplayItemChannel:channel
                                                            inContext:self.context
                                                         shouldInsert:@YES];
            DLog(@"Added new channel to displayList %@", newItem.feed.feedURL);
        }
    }
    
    if ([self.context hasChanges]) {
        NSError *error;
        [self.context save:&error];
        if (error) {
            ALog(@"error saving context: %@", error);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDisplayListUpdated
                                                            object:nil
                                                          userInfo:nil];
    }
    
}

- (void)tagsFetchResultsChangedContent:(NSArray *)fetchedTags {
    // Remove any empty tags
    NSArray *invalidTags = [self.context fetchObjectsForEntityName:@"DisplayList"
                                               predicateWithFormat:@"NOT (tag in %@) AND feed == nil", fetchedTags];
    for (DisplayList * displayList in invalidTags) {
        [self.context deleteObject:displayList];
    }
    /*
        check if any tag not in displayList
        add to displayList
     */
    for (Tag *tag in fetchedTags) {
        if (![DisplayList hasTagWithName:tag.name inContext:self.context]) {
            DisplayList *newItem = [DisplayList newDisplayItemTag:tag
                                                        inContext:self.context
                                                     shouldInsert:@YES];
            DLog(@"Added new tag to displayList %@", newItem.tag.name);
        }
    }
    
    if ([self.context hasChanges]) {
        NSError *error;
        [self.context save:&error];
        if (error) {
            ALog(@"error saving context: %@", error);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDisplayListUpdated
                                                            object:nil
                                                          userInfo:nil];
    }
    
    
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (controller == tagsFetchedResultsController) {
        [self tagsFetchResultsChangedContent:controller.fetchedObjects];
    }else if (controller == channelsFetchedResultsController) {
        [self channelsFetchResultsChangedContent:controller.fetchedObjects];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    DLog(@"object changed");
}


@end
