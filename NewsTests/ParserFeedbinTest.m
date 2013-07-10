//
//  ParserFeedbinTest.m
//  News
//
//  Created by karta sutanto on 8/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ParserFeedbin.h"

@interface ParserFeedbinTest : XCTestCase

@end

@implementation ParserFeedbinTest

- (void)setUp {
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown {
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)parseImportSubscriptionsFromFile {
    
}

- (void)testParseSubscriptionsJSON {
    // Load sample response from file
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
    
    // test first object has created at
    NSManagedObject *managedObject = [parsedResults objectAtIndex:0];
    id createdAt = [managedObject valueForKey:@"createdAt"];
    XCTAssertTrue([createdAt isKindOfClass:[NSDate class]], @"created at property is not of type date");
}

- (void)testParseTagsJSON {
    NSString *filePath = [[NSBundle bundleForClass:[self class]]
                          pathForResource:@"feedbinTaggings"
                          ofType:@"json"];
    NSError *error = nil;
    NSString *sampleTaggingsJSON = [NSString stringWithContentsOfFile:filePath
                                                             encoding:NSUTF8StringEncoding
                                                                error:&error];
    XCTAssertNil(error, @"load sample string from file fail");
    XCTAssertNotNil(sampleTaggingsJSON, @"load sample string from file fail");
    
    NSDictionary *tagsDict = [ParserFeedbin parseTagsJSON:sampleTaggingsJSON];
    XCTAssertTrue([tagsDict count] > 0, @"parsingJSON fail");
}

@end
