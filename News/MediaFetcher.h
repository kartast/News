//
//  MediaFetcher.h
//  News
//
//  Created by karta sutanto on 11/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZSContextWatcher;
@interface MediaFetcher : NSObject {
    ZSContextWatcher *contextWatcher;
    NSManagedObjectContext *mainContext;
    NSManagedObjectContext *tempContext;
}

@property (nonatomic, retain) ZSContextWatcher *contextWatcher;

@end
