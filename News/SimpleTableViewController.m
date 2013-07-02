//
//  SimpleTableViewController.m
//  News
//
//  Created by karta sutanto on 1/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import "SimpleTableViewController.h"
#import "FeedBinAPI.h"
#import "Channel.h"
#import "AppDelegate.h"

@interface SimpleTableViewController ()

@end

@implementation SimpleTableViewController
@synthesize tableView = _tableView;

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
    NSEntityDescription *ent = [NSEntityDescription entityForName:@"Channel"
                                           inManagedObjectContext:context];
    fetchRequest.entity = ent;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    fetchResultsController = [[NSFetchedResultsController alloc]
                              initWithFetchRequest:fetchRequest
                              managedObjectContext:context
                              sectionNameKeyPath:nil
                              cacheName:@"channel_cache"];

    fetchResultsController.delegate=self;
    
    NSError *error;
    BOOL success = [fetchResultsController performFetch:&error];
    NSLog(@"error:%@", error);
}

- (void)startFetchFeeds {
    if (!apiManager) {
        apiManager = [[FeedBinAPI alloc] initWithUserName:@"kartasutanto@gmail.com"
                                              andPassword:@"asd12345"];
    }
    [apiManager startFetchFeeds];
}

#pragma mark - UITableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[fetchResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[fetchResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"uniqueID"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"uniqueID"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    Channel *channel = [fetchResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = channel.title;
    return  cell;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}

#pragma mark Memory warning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
