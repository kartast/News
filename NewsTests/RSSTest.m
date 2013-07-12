//
//  RSSKitTest.m
//  News
//
//  Created by karta sutanto on 9/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RSSKit.h"
#import "Channel.h"
#import "RSSFeedManager.h"

@interface RSSTest : XCTestCase {
    NSPersistentStoreCoordinator *coord;
    NSManagedObjectContext *ctx;
    NSManagedObjectModel *model;
    NSPersistentStore *store;
}

@end

@implementation RSSTest

- (void)setUp {
    
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    model = [NSManagedObjectModel mergedModelFromBundles:nil];
    coord = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    store = [coord addPersistentStoreWithType:NSInMemoryStoreType
                                configuration:nil
                                          URL:nil
                                      options:nil
                                        error:NULL];
    ctx = [[NSManagedObjectContext alloc] init];
    [ctx setPersistentStoreCoordinator:coord];
}

- (void)tearDown {
    
    // Put teardown code here; it will be run once, after the last test case.
    ctx = nil;
    NSError *error = nil;
    XCTAssertTrue([coord removePersistentStore:store error:&error],
                  @"couldn't remove persistent store: %@", error);
    store = nil;
    coord = nil;
    model = nil;
    
    [super tearDown];
}


#if TESTASYNC
- (void)testRSSParsing {
    ASYNC_LOCK_INIT(5);
    
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"SampleRSS_2.0"
                                                                          ofType:@"xml"];
    NSData *rssSampleData = [NSData dataWithContentsOfFile:filePath];
    
    RSSParser *parser = [[RSSParser alloc] init];
    [parser parseData:rssSampleData withCallback:^(RSSParser *rssParser, RSSFeed *rssFeed, NSError *error ) {
        XCTAssertNil(error, @"Error parsing :%@", error);
        XCTAssertNotNil(rssFeed, @"Feed returned empty");
        
        ASYNC_LOCK_DONE();
    }];
    
    ASYNC_LOCK_HERE();
}


- (void)testAddChannelByURL {
    [[RSSFeedManager sharedManager] addFeedByURL:@"http://daringfireball.net/index.xml"
                                    withCallback:^(BOOL bSuccess, RSSFeed *feed, NSError *error) {
                                        XCTAssertNil(error, @"error adding feed: %@", error);


                                        NSArray *array = [ctx fetchObjectsForEntityName:@"Channel"];
                                        Channel *channel = [array objectAtIndex:0];
                                        XCTAssertTrue([channel.title isEqualToString:@"Daring Fireball"], @"Not fetched correctly");
                                    } inContext:ctx];
}

- (void)testAddChannelWrongURL {
    [[RSSFeedManager sharedManager] addFeedByURL:@"http://bodoh/noob.xml"
                                    withCallback:^(BOOL bSuccess, RSSFeed *feed, NSError *error) {
                                        XCTAssertNotNil(error, @"error adding feed: %@", error);
                                        
                                        // TODO: CHeck insider core data
                                    } inContext:ctx];
}

- (void)testAddChannelFromFilePath {
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"DaringFireballFeed" ofType:@"xml"];
    [[RSSFeedManager sharedManager] processFeedFromFile:filePath
                                              inContext:ctx
                                           withCallback:^(BOOL bSuccess, RSSFeed *feed, NSError *error) {
                                                XCTAssertNil(error, @"error adding feed: %@", error);
    
                                               NSArray *array = [ctx fetchObjectsForEntityName:@"Channel"];
                                               Channel *channel = [array objectAtIndex:0];
                                               XCTAssertTrue([channel.title isEqualToString:@"Daring Fireball"], @"Not fetched correctly");
                                           }];
}

#endif

- (void)testRemoveChannelByURL {
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"DaringFireballFeed" ofType:@"xml"];
    [[RSSFeedManager sharedManager] processFeedFromFile:filePath
                                              inContext:ctx
                                           withCallback:^(BOOL bSuccess, RSSFeed *feed, NSError *error) {
                                               XCTAssertNil(error, @"error adding feed: %@", error);
                                               
                                               NSArray *array = [ctx fetchObjectsForEntityName:@"Channel"];
                                               Channel *channel = [array objectAtIndex:0];
                                               XCTAssertTrue([channel.title isEqualToString:@"Daring Fireball"], @"Not fetched correctly");
                                           }];

    NSArray *array = [ctx fetchObjectsForEntityName:@"Channel"];
    XCTAssertTrue([array count] > 0, @"expected > 0, got %d", [array count]);
    
    // remvoe now
    [Channel deleteChannelWithURL:@"http://daringfireball.net/index.xml" inContext:ctx];
    
    array = [ctx fetchObjectsForEntityName:@"Channel"];
    XCTAssertTrue([array count] == 0, @"expected 0, got %d", [array count]);
}

@end
