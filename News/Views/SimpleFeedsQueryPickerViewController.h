//
//  SimpleFeedsQueryPickerViewController.h
//  News
//
//  Created by karta sutanto on 10/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimpleFeedsQueryPickerViewController : UITableViewController <UISearchBarDelegate> {
    UISearchBar *searchBar;
    UISearchDisplayController *searchController;
    NSArray *entriesArray;
}

@end
