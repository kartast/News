//
//  MediaFetcher.h
//  News
//
//  Created by karta sutanto on 11/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MediaFetcher : NSObject <NSFetchedResultsControllerDelegate> {
    NSManagedObjectContext *mainContext;
    NSManagedObjectContext *tempContext;
    NSFetchedResultsController *fetchedResultsController;
}

@end
