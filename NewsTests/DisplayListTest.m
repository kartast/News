//
//  DisplayListTest.m
//  News
//
//  Created by karta sutanto on 12/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DisplayListManager.h"
#import "DisplayList.h"
#import "TestHelper.h"
#import "NSManagedObjectContext-EasyFetch.h"
#import "RSSFeedManager.h"
#import "Channel.h"

@interface DisplayListTest : XCTestCase {
    NSPersistentStoreCoordinator *coord;
    NSManagedObjectContext *ctx;
    NSManagedObjectModel *model;
    NSPersistentStore *store;
    NSManagedObjectContext *bgContext;
}

@end

@implementation DisplayListTest


- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [self tearDownCoreDataStack];
    [super tearDown];
}

#ifdef TESTASYNC
- (void)testDisplayListAddNewChannel {
    ASYNC_LOCK_INIT(100);
    
    [self setUpCoreDataStack:@"CoreData_2_Feed"];
    
    __block int nDisplayListCount = 0;
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationDisplayListUpdated
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      DLog(@"Display List Updated");
                                                      NSArray *anotherArray = [ctx fetchObjectsForEntityName:@"DisplayList" sortByKey:@"displayOrder" ascending:YES];
                                                      nDisplayListCount = [anotherArray count];
                                                  }];
    
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"FoxNewxFeed"
                                                                          ofType:@"xml"];
    DisplayListManager *displayListManager = [[DisplayListManager alloc] initWithContext:ctx];
    
    
    [[RSSFeedManager sharedManager]
        processFeedFromFile:filePath
                  inContext:ctx
               withCallback:^(BOOL bSuccess, RSSFeed *feed, NSError *error) {
                   XCTAssertNil(error, @"error adding feed: %@", error);
                   
                   NSArray *array = [ctx fetchObjectsForEntityName:@"Channel"
                                               predicateWithFormat:@"title = %@", @"FOXNews.com"];
                   
                   Channel *channel = [array objectAtIndex:0];
                   XCTAssertTrue([channel.title isEqualToString:@"FOXNews.com"],
                                @"Not fetched correctly");
                    ASYNC_LOCK_DONE();
                   
               }];
    [displayListManager startMonitor];
    
    // add new channel from rss xml
    ASYNC_LOCK_HERE();
    
    XCTAssertTrue(nDisplayListCount == 3, @"display list count got %d", nDisplayListCount);
}

- (void)testDisplayListChannelAddTag {
    ASYNC_LOCK_INIT(50);
    [self setUpCoreDataStack:@"CoreData_6_Feed"];
    
    __block int nDisplayListCount = 0;
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationDisplayListUpdated
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      DLog(@"Display List UPdated");
                                                      NSArray *anotherArray = [ctx fetchObjectsForEntityName:@"DisplayList" sortByKey:@"displayOrder" ascending:YES];
                                                      nDisplayListCount = [anotherArray count];
                                                      if (nDisplayListCount == 6) {
                                                          ASYNC_LOCK_DONE();
                                                      }
                                                  }];
    
    DisplayListManager *displayListManager = [[DisplayListManager alloc] initWithContext:ctx];
    [displayListManager startMonitor];
    
    NSArray *anyFeed = [ctx fetchObjectsForEntityName:@"Channel"];
    XCTAssertNotNil(anyFeed, @"no channel in core data after import!");
    
    Channel *channel = [anyFeed objectAtIndex:0];
    [channel addCategory:@"Apple" inContext:ctx];
    
    ASYNC_LOCK_HERE();
    
    // Expected final value
    NSArray *displayListArray = [ctx fetchObjectsForEntityName:@"DisplayList"];
    int nExpectedTagCount = 1;
    int nExpectedFeedCount = 4;
    int nActualTagCount =0;
    int nActualFeedCount =0;
    for (DisplayList *displayList in displayListArray) {
        if ([displayList displayListType] == DisplayListFeed) {
            nActualFeedCount++;
        }else {
            nActualTagCount++;
        }
    }
    
    XCTAssertTrue(nActualTagCount == nExpectedTagCount, @"Tag count dont match");
    XCTAssertTrue(nActualFeedCount == nExpectedFeedCount, @"Tag count dont match");
}

- (void)testdisplayListChannelRemoveTag {
    ASYNC_LOCK_INIT(100);
    [self setUpCoreDataStack:@"CoreData_6_Feed"];
    
    __block int nDisplayListCount = 0;
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationDisplayListUpdated
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      DLog(@"Display List UPdated");
                                                      NSArray *anotherArray = [ctx fetchObjectsForEntityName:@"DisplayList" sortByKey:@"displayOrder" ascending:YES];
                                                      nDisplayListCount = [anotherArray count];

                                                      if (nDisplayListCount == 6) {
                                                          ASYNC_LOCK_DONE();
                                                      }
                                                  }];
    
    DisplayListManager *displayListManager = [[DisplayListManager alloc] initWithContext:ctx];
    [displayListManager startMonitor];
    
    NSArray *anyFeed = [ctx fetchObjectsForEntityName:@"Channel"];
    XCTAssertNotNil(anyFeed, @"no channel in core data after import!");
    
    Channel *channel = [anyFeed objectAtIndex:0];
    [channel addCategory:@"Apple" inContext:ctx];
    
    NSArray *allFeeds = [ctx fetchObjectsForEntityName:@"Channel"];
    for (Channel *channel in allFeeds) {
        if ([channel.tags count] > 0) {
            [channel removeTags:channel.tags];
        }
    }
    [ctx save:nil];
    
    ASYNC_LOCK_HERE();
    
    // Expected final value
    NSArray *displayListArray = [ctx fetchObjectsForEntityName:@"DisplayList"];
    int nExpectedTagCount = 0;
    int nExpectedFeedCount = 6;
    int nActualTagCount =0;
    int nActualFeedCount =0;
    for (DisplayList *displayList in displayListArray) {
        if ([displayList displayListType] == DisplayListFeed) {
            nActualFeedCount++;
        }else {
            nActualTagCount++;
        }
    }
    
    XCTAssertTrue(nActualTagCount == nExpectedTagCount, @"Tag count dont match");
    XCTAssertTrue(nActualFeedCount == nExpectedFeedCount, @"Tag count dont match");
}

- (void)testDisplayListChannelChangeTag {
    ASYNC_LOCK_INIT(10);
    [self setUpCoreDataStack:@"CoreData_6_Feed"];
    
    __block int nDisplayListCount = 0;
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationDisplayListUpdated
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      DLog(@"Display List UPdated");
                                                      NSArray *anotherArray = [ctx fetchObjectsForEntityName:@"DisplayList" sortByKey:@"displayOrder" ascending:YES];
                                                      nDisplayListCount = [anotherArray count];
                                                      if (nDisplayListCount == 6) {
                                                          ASYNC_LOCK_DONE();
                                                      }
                                                  }];
    
    DisplayListManager *displayListManager = [[DisplayListManager alloc] initWithContext:ctx];
    [displayListManager startMonitor];
    
    NSArray *anyFeed = [ctx fetchObjectsForEntityName:@"Channel"];
    XCTAssertNotNil(anyFeed, @"no channel in core data after import!");
    Channel *channel = [anyFeed objectAtIndex:0];
    [channel addCategory:@"Apple" inContext:ctx];
    
    for (Channel *channel in anyFeed) {
        if ([channel.tags count]>0  ) {
            [channel removeTags:channel.tags];
            [channel addCategory:@"Tech News" inContext:ctx];
            break;
        }
    }
    
    ASYNC_LOCK_HERE();
    
    // Expected final value
    NSArray *displayListArray = [ctx fetchObjectsForEntityName:@"DisplayList"];
    int nExpectedTagCount = 2;
    int nExpectedFeedCount = 4;
    int nActualTagCount =0;
    int nActualFeedCount =0;
    for (DisplayList *displayList in displayListArray) {
        if ([displayList displayListType] == DisplayListFeed) {
            nActualFeedCount++;
        }else {
            nActualTagCount++;
        }
    }
    
    XCTAssertTrue(nActualTagCount == nExpectedTagCount, @"Tag count dont match");
    XCTAssertTrue(nActualFeedCount == nExpectedFeedCount, @"Tag count dont match");
}

- (void)testDisplayListOrdering
{
    /*
        User can set custom ordering for |display items|
     */
}
#endif

- (void)testImportCoreDataFromArchive {
    [self setUpCoreDataStack:@"CoreData_2_Feed"];
    NSArray *array = [ctx fetchObjectsForEntityName:@"Channel"];
    XCTAssertTrue([array count] == 2, @"Number of channel imported is not equal to 2");
    [self tearDownCoreDataStack];
    
    [self setUpCoreDataStack:@"CoreData_6_Feed"];
    NSArray *newArray = [ctx fetchObjectsForEntityName:@"Channel"];
    XCTAssertTrue([newArray count] == 6, @"Number of channel imported is not equal to 6");
}

#pragma mark -- setup core data
- (void)setUpCoreDataStack:(NSString *)archiveName {
    NSString *archivePath = [[NSBundle bundleForClass:[self class]] pathForResource:archiveName ofType:@"zip"];
    [TestHelper importCoreDataArchiveWithPath:archivePath];
    
    model = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    NSPersistentStoreCoordinator *coordinator =
    [[NSPersistentStoreCoordinator alloc]
     initWithManagedObjectModel: model];
    
    NSString *STORE_TYPE = NSSQLiteStoreType;

    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Test.sqlite"];
    NSError *error;
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:STORE_TYPE
                                                            configuration:nil
                                                                      URL:storeURL
                                                                  options:options
                                                                    error:&error];
    
    if (newStore == nil) {
        
        NSLog(@"Store Configuration Failure\n%@",
              ([error localizedDescription] != nil) ?
              [error localizedDescription] : @"Unknown Error");
    }
    
    
    ctx = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [ctx setPersistentStoreCoordinator:coordinator];
}

- (void)tearDownCoreDataStack {
    coord = nil;
    ctx = nil;
    model = nil;
    store = nil;
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
