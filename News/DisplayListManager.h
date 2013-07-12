//
//  DisplayListManager.h
//  News
//
//  Created by karta sutanto on 12/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//
//  This singleton class objective is to manage the displayList

#import <Foundation/Foundation.h>

static NSString *kNotificationDisplayListUpdated = @"NotificationDisplayListUpdated";

@interface DisplayListManager : NSObject <NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *channelsFetchedResultsController;
    NSFetchedResultsController *tagsFetchedResultsController;
}

@property (nonatomic, retain)NSManagedObjectContext *context;

- (void)startMonitor;
- (id)initWithContext:(NSManagedObjectContext *)ctx;

@end