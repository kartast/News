//
//  MediaFetcher.m
//  News
//
//  Created by karta sutanto on 11/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import "MediaFetcher.h"
#import "ZSContextWatcher.h"
#import "CoreDataHelper.h"

@implementation MediaFetcher
@synthesize contextWatcher;

- (id)init {
    if (self = [super init]) {
        mainContext = [CoreDataHelper defaultContext];
        
        // Monitor changes on the main context
        self.contextWatcher = [[ZSContextWatcher alloc] initWithManagedObjectContext:mainContext];
    }
    return self;
}

- (void)startFetching {
    // Setup context watcher
}

@end
