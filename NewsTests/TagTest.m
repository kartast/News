//
//  TagTest.m
//  News
//
//  Created by karta sutanto on 8/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ParserFeedbin.h"
#import "Tag.h"
#import "Channel.h"
#import "ParseSubscriptionOperation.h"

@interface TagTest : XCTestCase {
    NSPersistentStoreCoordinator *coord;
    NSManagedObjectContext *ctx;
    NSManagedObjectModel *model;
    NSPersistentStore *store;
}

@end

@implementation TagTest

- (void)setUp {
    
    [super setUp];
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
    ctx = nil;
    NSError *error = nil;
    XCTAssertTrue([coord removePersistentStore:store error:&error],
                  @"couldn't remove persistent store: %@", error);
    store = nil;
    coord = nil;
    model = nil;
    
    [super tearDown];
}


- (void)importMockSubscriptions72FromFeedBin {
    /*
        Load Saved Feedbin subscriptions response to core data 
        total 72 entries
     */
    NSString *filePath = [[NSBundle bundleForClass:[self class]]
                          pathForResource:@"feedbinSubscriptions72"
                          ofType:@"json"];
    NSError *error = nil;
    NSString *sampleSubscriptionsString = [NSString stringWithContentsOfFile:filePath
                                                                    encoding:NSUTF8StringEncoding
                                                                       error:&error];
    XCTAssertNil(error, @"load sample string from file fail");
    XCTAssertNotNil(sampleSubscriptionsString,
                    @"load sample string from file fail");
    
    NSArray *parsedResults = [ParserFeedbin parseSubscriptionsJSON:sampleSubscriptionsString];
    XCTAssertTrue([parsedResults count] == 72,
                  @"parsed results count is not 72");
    ParseSubscriptionOperation *subscriptionParser = [[ParseSubscriptionOperation alloc] init];
    [subscriptionParser parseAndSyncFromFeedBinSubscriptionsJSON:sampleSubscriptionsString
                                                       inContext:ctx];
}

- (void)testFeedAddCategory {
    // setup
    [self importMockSubscriptions72FromFeedBin];
    
    // Actually Test adding category
    // Get the first feed and add a category
    Channel *channel = [[ctx fetchObjectsForEntityName:@"Channel" sortByKey:@"title" ascending:YES] objectAtIndex:0];
    NSString* category = @"Apple";
    [channel addCategory:category inContext:ctx];
    
    Tag *tag = [[ctx fetchObjectsForEntityName:@"Tag"
                           predicateWithFormat:@"name ==[c] %@", category] objectAtIndex:0];
    XCTAssertNotNil(tag.channels, @"tag object not created");
    XCTAssertTrue([tag.name isEqualToString:category], @"Category added is wrong");
    
    Channel *channelTagged = [tag.channels allObjects][0];
    DLog(@"%@", channelTagged.guid);
}

- (void)testFeedAddTwoCategories {
    [self importMockSubscriptions72FromFeedBin];
    
    // Actually Test adding category
    // Get the first feed and add a category
    Channel *channel = [[ctx fetchObjectsForEntityName:@"Channel" sortByKey:@"title" ascending:YES] objectAtIndex:0];
    NSString* category = @"Apple";
    NSString* anotherCategory = @"News";
    [channel addCategory:category inContext:ctx];
    [channel addCategory:anotherCategory inContext:ctx];
    
    Tag *tag = [[ctx fetchObjectsForEntityName:@"Tag"
                           predicateWithFormat:@"name ==[c] %@", category] objectAtIndex:0];
    XCTAssertNotNil(tag.channels, @"tag object not created");
    XCTAssertTrue([tag.name isEqualToString:category], @"Category added is wrong");
    XCTAssertTrue([channel.tags count] == 2, @"tags not equal to 2");
}

- (void)testFeedRemoveCategory {
    [self importMockSubscriptions72FromFeedBin];
    
    // Actually Test adding category
    // Get the first feed and add a category
    Channel *channel = [[ctx fetchObjectsForEntityName:@"Channel" sortByKey:@"title" ascending:YES] objectAtIndex:0];
    NSString* category = @"Apple";
    NSString* anotherCategory = @"News";
    [channel addCategory:category inContext:ctx];
    [channel addCategory:anotherCategory inContext:ctx];
    
    Tag *tag = [[ctx fetchObjectsForEntityName:@"Tag"
                           predicateWithFormat:@"name ==[c] %@", category] objectAtIndex:0];
    
    XCTAssertNotNil(tag.channels, @"tag object not created");
    XCTAssertTrue([tag.name isEqualToString:category], @"Category added is wrong");
    XCTAssertTrue([channel.tags count] == 2, @"tags not equal to 2");
    
    [channel removeCategory:@"Apple" inContext:ctx];
    XCTAssertTrue([channel.tags count] == 1, @"Deleting failed, tags still got 2");
}

- (void)testDeleteCategory {
    [self testFeedRemoveCategory];

    NSString *category = @"News";
    NSArray *channelsWithTag = [ctx fetchObjectsForEntityName:@"Channel"
                                          predicateWithFormat:@"ANY tags.name contains[cd] %@",category];
    
    Channel *channel = [channelsWithTag objectAtIndex:0];
    
    BOOL bChannelWithTheTagFound = false;
    for (Tag *tag  in [channel.tags allObjects]) {
        if ([tag.name isEqualToString:category]) {
            bChannelWithTheTagFound = true;
        }
    }
    
    XCTAssertTrue(bChannelWithTheTagFound, @"Tag not found how to delete!!!");
    
    [Tag deleteTagWithName:category inContext:ctx];   
    channelsWithTag = [ctx fetchObjectsForEntityName:@"Channel"
                                 predicateWithFormat:@"ANY tags.name contains[cd] %@",category];
    XCTAssertTrue([channelsWithTag count]==0, @"how come delete already still here!!");
}

- (void)testImportCategoriesFromFeedbin {
    [self importMockSubscriptions72FromFeedBin];
    
    // Read json response from file
    NSString *category = @"News";
    NSString *filePath = [[NSBundle bundleForClass:[self class]]
                          pathForResource:@"feedbinTaggingsNews"
                          ofType:@"json"];
    NSError *error = nil;
    NSString *sampleFeedbinTagsJSON = [NSString stringWithContentsOfFile:filePath
                                                                encoding:NSUTF8StringEncoding
                                                                   error:&error];
    XCTAssertNil(error, @"load sample string from file fail");
    XCTAssertNotNil(sampleFeedbinTagsJSON,
                    @"load sample string from file fail");
    
    NSDictionary *feedbinJSONDict = [ParserFeedbin parseTagsJSON:sampleFeedbinTagsJSON];
    XCTAssertNotNil(feedbinJSONDict, @"Parse JSON fail!");
    
    [ParserFeedbin syncTagsJSONWithCoreDataForDict:feedbinJSONDict
                                         inContext:ctx];
    
    NSArray *channelsWithTag = [ctx fetchObjectsForEntityName:@"Channel"
                                          predicateWithFormat:@"ANY tags.name contains[cd] %@",category];
    XCTAssertTrue([channelsWithTag count]==2, @"expect 2, get %d", [channelsWithTag count]);
}

- (void)testSyncCategoriesFromFeedbin {
    // Read json response from file
    NSString *filePath = [[NSBundle bundleForClass:[self class]]
                          pathForResource:@"feedbinTaggingsNews"
                          ofType:@"json"];
    NSError *error = nil;
    NSString *sampleFeedbinTagsJSON = [NSString stringWithContentsOfFile:filePath
                                                                encoding:NSUTF8StringEncoding
                                                                   error:&error];
    XCTAssertNil(error, @"load sample string from file fail");
    XCTAssertNotNil(sampleFeedbinTagsJSON,
                    @"load sample string from file fail");
    
    NSDictionary *feedbinJSONDict = [ParserFeedbin parseTagsJSON:sampleFeedbinTagsJSON];
    XCTAssertNotNil(feedbinJSONDict, @"Parse JSON fail!");
    
    [Tag importFromDictionary:feedbinJSONDict
          shouldRemoveTheRest:YES
                    inContext:ctx];
}

- (void)testSyncTagToFeedbinUpstream {
    XCTFail(@"Need Implementation");
}

@end
