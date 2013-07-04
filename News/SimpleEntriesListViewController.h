//
//  SimpleEntriesListViewController.h
//  News
//
//  Created by karta sutanto on 4/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Channel;
@interface SimpleEntriesListViewController : UITableViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate> {
    NSFetchedResultsController *fetchResultsController;
    id delegate;
    Channel *channel;
}
@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) Channel *channel;
@end
