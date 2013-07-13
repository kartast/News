//
//  SimpleTableViewController.m
//  News
//
//  Created by karta sutanto on 1/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import "SimpleTableViewController.h"
#import "FeedSyncManager.h"
#import "Channel.h"
#import "AppDelegate.h"
#import "SimpleEntriesListViewController.h"
#import "RSSFeedManager.h"
#import "CoreDataHelper.h"
#import "DiffBotAPIManager.h"
#import "SimpleFeedsQueryPickerViewController.h"
#import "DisplayList.h"
#import "DisplayListManager.h"
#import "Tag.h"
#import "UIImageView+WebCache.h"
#import "FeedCell.h"
#import "DebugCell.h"

@interface SimpleTableViewController ()

@end

@implementation SimpleTableViewController
@synthesize tableView = _tableView;
@synthesize customCell;

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupFetchResultsController];
    
//    nav.barTintColor = [UIColor ]
    
    // Do any additional setup after loading the view from its nib.
    [self startFetchFeeds];
}

- (void)setupFetchResultsController {
    /*
     Create fetch request
     */
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appdelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *ent = [NSEntityDescription entityForName:@"DisplayList"
                                           inManagedObjectContext:context];
    fetchRequest.entity = ent;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    fetchResultsController = [[NSFetchedResultsController alloc]
                              initWithFetchRequest:fetchRequest
                              managedObjectContext:context
                              sectionNameKeyPath:nil
                              cacheName:nil];

    fetchResultsController.delegate=self;
    
    NSError *error;
    BOOL success = [fetchResultsController performFetch:&error];
    if (!success || error) {
        ALog(@"error:%@", error);
    }
}

- (void)startFetchFeeds {
    [[FeedSyncManager sharedManager] startSync];
}

#pragma mark - UITableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 85;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[fetchResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[fetchResultsController sections] objectAtIndex:section] numberOfObjects]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedCell *cell = (FeedCell *)[self.tableView dequeueReusableCellWithIdentifier:@"feedCell"];
    
    if (cell == nil) {
        [self.tableView registerNib:[UINib nibWithNibName:@"feedCell" bundle:nil] forCellReuseIdentifier:@"feedCell"];
        cell = (FeedCell*)[self.tableView dequeueReusableCellWithIdentifier:@"feedCell"];
    }
    
    // Debug cell
    int nTotalFetchedObjectsPlusDebugCell = [[fetchResultsController fetchedObjects] count]+1;
    if ([indexPath row] == (nTotalFetchedObjectsPlusDebugCell-1) ) {
        // last row
        DebugCell *debugCell = (DebugCell *)[self.tableView dequeueReusableCellWithIdentifier:@"debugCell"];
        if (debugCell == nil) {
            [self.tableView registerNib:[UINib nibWithNibName:@"DebugCell" bundle:nil] forCellReuseIdentifier:@"debugCell"];
            debugCell = (DebugCell*)[self.tableView dequeueReusableCellWithIdentifier:@"debugCell"];
            [debugCell setDelegate:self];
        }
        
        return debugCell;
    }
    DisplayList *displayItem = [fetchResultsController objectAtIndexPath:indexPath];
    NSString* imageURL = [displayItem displayImage];
    if ([displayItem displayListType] == DisplayListFeed) {
        Channel *channel = displayItem.feed;
        [cell setTitle:channel.title andImageURL:imageURL];
    }else {
        Tag *tag = displayItem.tag;
        Channel *channel = [tag.channels anyObject];
        UILabel* titleLabel = (UILabel*)[cell viewWithTag:100];
        titleLabel.text = channel.title;
    }
    return  cell;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    Channel *channel = [fetchResultsController objectAtIndexPath:indexPath];
//    SimpleEntriesListViewController *entryListVC = [[SimpleEntriesListViewController alloc] initWithNibName:@"SimpleEntriesListViewController" bundle:nil];
//    entryListVC.channel = channel;
//    [self.navigationController pushViewController:entryListVC animated:YES];
}

#pragma buttons
- (void)debugBtn1Pressed {
    DLog(@"debug button 1 pressed");
    SimpleFeedsQueryPickerViewController *feedsQueryVC = [[SimpleFeedsQueryPickerViewController alloc] init];
    [self presentViewController:feedsQueryVC animated:YES completion:nil];
}

- (void)debugBtn2Pressed {
    DLog(@"debug button 2 pressed");
}

- (IBAction)addTestFeed:(id)sender {
    
//    [[RSSFeedManager sharedManager] addFeedByURL:@"http://daringfireball.net/index.xml"
//                                    withCallback:^(BOOL bSuccess, RSSFeed *feed, NSError *error) {
//
//                                    } inContext:[CoreDataHelper newContextInCurrentThread]];
//    NSArray *urls = @[@"http://appleinsider.com/articles/13/07/10/yahoo-updates-mail-app-with-multi-login-support-tumblr-with-refined-search",
//                      @"http://appleinsider.com/articles/13/07/09/apple-files-for-stay-on-itc-ban-for-legacy-iphones-and-ipads",
//                      @"http://www.dailymail.co.uk/news/article-2359306/British-mother-Nicole-Reyes-held-squalid-Caribbean-jail-YEAR-charge.html",
//                      @"http://darigiasdfas.co/asdf",
//                      @"http://darigasiasdfas.co/asdf",];
//    [[DiffBotAPIManager sharedManager] addURLsToAnalyze:urls];
    
    SimpleFeedsQueryPickerViewController *feedsQueryVC = [[SimpleFeedsQueryPickerViewController alloc] init];
    [self presentViewController:feedsQueryVC animated:YES completion:nil];
}

#pragma mark Memory warning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
