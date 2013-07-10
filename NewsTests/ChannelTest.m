//
//  ChannelTest.m
//  News
//
//  Created by karta sutanto on 8/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Channel.h"
#import "ParserFeedbin.h"
#import "ParseSubscriptionOperation.h"

@interface ChannelTest : XCTestCase {
    NSPersistentStoreCoordinator *coord;
    NSManagedObjectContext *ctx;
    NSManagedObjectModel *model;
    NSPersistentStore *store;
}

@end

@implementation ChannelTest

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

- (void)testThatEnvironmentWorks {
    XCTAssertNotNil(store, @"no persistent store");
}

- (void)testImportNewChannel {
    Channel *channel = [Channel channelWithURL:@"http://daringfireball.net/index.xml"
                                         title:@"Daring Fireball"
                                     createdAt:nil
                                          link:@"http://daringfireball.net"
                                        syncID:@"50"
                                     inContext:ctx
                                  shouldInsert:@YES];
    
    XCTAssertNotNil(channel, @"Fail to import new channel");
    
    NSArray *channelFetched = [ctx fetchObjectsForEntityName:@"Channel"
                                         predicateWithFormat:@"feedURL = %@", @"http://daringfireball.net/index.xml"];
    XCTAssertTrue([channelFetched count] == 1, @"channel in context is not exactly 1");
}

- (void)testImportExistingChannel {
    /*
        Import two channels with the same feedURL
     */
    Channel *channel = [Channel channelWithURL:@"http://daringfireball.net/index.xml"
                                         title:@"Daring Fireball"
                                     createdAt:nil
                                          link:@"http://daringfireball.net"
                                        syncID:@"50"
                                     inContext:ctx
                                  shouldInsert:@YES];
    
    NSArray *channelFetched = [ctx fetchObjectsForEntityName:@"Channel"
                                         predicateWithFormat:@"guid = %@", @50];

    XCTAssertTrue([channelFetched count] == 1,
                  @"channel in context is not exactly 1 after first import");
    
    channel = [Channel channelWithURL:@"http://daringfireball.net/index.xml"
                               title:@"Daring Fireball 2"
                           createdAt:nil
                                link:@"http://daringfireball.net"
                              syncID:@"50"
                           inContext:ctx
                        shouldInsert:@YES];
    
    XCTAssertNotNil(channel, @"Fail to import existing channel");
    
    channelFetched = [ctx fetchObjectsForEntityName:@"Channel"
                                predicateWithFormat:@"guid = %@", @50];
    
    XCTAssertTrue([channelFetched count] == 1,
                  @"channel in context is not exactly 1 after import existing");
    
    channel = [channelFetched objectAtIndex:0];
    
    XCTAssertTrue([channel.title isEqualToString:@"Daring Fireball 2"],
                  @"title not updated");
}

- (void)testImportFromFeedBin {
    
    // Load sample response from file
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"feedbinSubscriptions72"
                                                         ofType:@"json"];
    NSError *error = nil;
    NSString *sampleSubscriptionsString = [NSString stringWithContentsOfFile:filePath
                                                                    encoding:NSUTF8StringEncoding
                                                                       error:&error];
    XCTAssertNil(error, @"load sample string from file fail");
    XCTAssertNotNil(sampleSubscriptionsString,
                    @"load sample string from file fail");
    
    ParseSubscriptionOperation *subscriptionParser = [[ParseSubscriptionOperation alloc] init];
    [subscriptionParser parseAndSyncFromFeedBinSubscriptionsJSON:sampleSubscriptionsString
                                                       inContext:ctx];
   
    NSArray *channelFetched = [ctx fetchObjectsForEntityName:@"Channel"];
    XCTAssertTrue([channelFetched count] == 72 , @"channels count in context not correct, expected 72");
    
    for (Channel *channel in channelFetched) {
        XCTAssertNotNil(channel.title,      @"title property not avaliable");
        XCTAssertNotNil(channel.feedURL,    @"feed URL property not set");
        XCTAssertNotNil(channel.link,       @"link property not set");
        XCTAssertNotNil(channel.createdAt,  @"date property not set");
    }
}

- (void)testSyncWithFeedBin {
    [self testImportFromFeedBin];
    
    // Load sample response from file
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"feedbinSubscriptions70"
                                                                          ofType:@"json"];
    NSError *error = nil;
    NSString *sampleSubscriptionsString = [NSString stringWithContentsOfFile:filePath
                                                                    encoding:NSUTF8StringEncoding
                                                                       error:&error];
    XCTAssertNil(error, @"load sample string from file fail");
    XCTAssertNotNil(sampleSubscriptionsString,
                    @"load sample string from file fail");
    
    ParseSubscriptionOperation *subscriptionParser = [[ParseSubscriptionOperation alloc] init];
    [subscriptionParser parseAndSyncFromFeedBinSubscriptionsJSON:sampleSubscriptionsString
                                                       inContext:ctx];
    
    NSArray *channelFetched = [ctx fetchObjectsForEntityName:@"Channel"];
    XCTAssertTrue([channelFetched count] == 70 , @"channels count in context not correct, expected 70");
    
    for (Channel *channel in channelFetched) {
        XCTAssertNotNil(channel.title,      @"title property not avaliable");
        XCTAssertNotNil(channel.feedURL,    @"feed URL property not set");
        XCTAssertNotNil(channel.link,       @"link property not set");
        XCTAssertNotNil(channel.createdAt,  @"date property not set");
    }
}

- (void)testSyncWithFeedBinUpstream {
    XCTFail(@"Not implementation");
}

@end
