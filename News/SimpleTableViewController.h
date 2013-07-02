//
//  SimpleTableViewController.h
//  News
//
//  Created by karta sutanto on 1/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FeedBinAPI;
@interface SimpleTableViewController : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>{
    FeedBinAPI *apiManager;
    NSFetchedResultsController *fetchResultsController;
}
@property (nonatomic, retain) IBOutlet UITableView* tableView;
@end
