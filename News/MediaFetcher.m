//
//  MediaFetcher.m
//  News
//
//  Created by karta sutanto on 11/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import "MediaFetcher.h"
#import "CoreDataHelper.h"
#import "CoreDataHelper.h"
#import "ItemDetail.h"
#import "Item.h"
#import "Channel.h"
#import "DiffBotAPIManager.h"

@implementation MediaFetcher

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
}

@end
