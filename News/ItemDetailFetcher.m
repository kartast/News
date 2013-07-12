//
//  ItemDetailFetcher.m
//  News
//
//  Created by karta sutanto on 11/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import "ItemDetailFetcher.h"
#import "CoreDataHelper.h"
#import "ItemDetail.h"
#import "Item.h"
#import "Channel.h"
#import "DiffBotAPIManager.h"

@implementation ItemDetailFetcher

- (id)initWithContext:(NSManagedObjectContext *)context {
    if (self = [super init]) {
        mainContext = context;
    }
    return self;
}

- (id)init {
    if (self = [super init]) {
        mainContext = [CoreDataHelper defaultContext];
    }
    return self;
}

- (void)startFetching {
    // Setup context watcher
    // Watch for newly added items
    NSEntityDescription *itemEntityDesc = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:mainContext];
    NSPredicate *predicateNoItemDetail = [NSPredicate predicateWithFormat:@"itemDetail == nil"];
    
    NSFetchRequest *fetchItemWithNoDetail = [[NSFetchRequest alloc] initWithEntityName:@"Item"];
    [fetchItemWithNoDetail setEntity:itemEntityDesc];
    [fetchItemWithNoDetail setReturnsObjectsAsFaults:NO];
    NSSortDescriptor *sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
    NSSortDescriptor *sortByChannel = [NSSortDescriptor sortDescriptorWithKey:@"channel" ascending:YES];
    NSSortDescriptor *sortByPubDate = [NSSortDescriptor sortDescriptorWithKey:@"pubDate" ascending:NO];
    [fetchItemWithNoDetail setSortDescriptors:@[sortByDate, sortByChannel, sortByPubDate]];
    [fetchItemWithNoDetail setPredicate:predicateNoItemDetail];
    
    fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchItemWithNoDetail
                                                                   managedObjectContext:mainContext
                                                                     sectionNameKeyPath:nil
                                                                              cacheName:nil];
    [fetchedResultsController setDelegate:self];
    NSError *error;
    BOOL success = [fetchedResultsController performFetch:&error];
    if (!success || error) {
        ALog(@"error:%@", error);
    }
    NSArray *fetchedObjects = [fetchedResultsController fetchedObjects];
    [self addItemsToAnalyzeQueue:fetchedObjects];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    NSArray *fetchedObjects = [controller fetchedObjects];
    [self addItemsToAnalyzeQueue:fetchedObjects];
    DLog(@"%@", controller);
}

- (void)addItemsToAnalyzeQueue:(NSArray *)fetchedItems {
    NSMutableArray *urls = [[NSMutableArray alloc] init];
    for (Item *item in fetchedItems) {
        [urls addObject:item.link];
    }
    [[DiffBotAPIManager sharedManager] addURLsToAnalyze:urls];
}
@end
