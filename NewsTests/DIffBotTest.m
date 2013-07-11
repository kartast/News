//
//  DIffBotTest.m
//  News
//
//  Created by karta sutanto on 9/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DiffBotAPIManager.h"

@interface DIffBotTest : XCTestCase

@end

@implementation DIffBotTest

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

#if TESTASYNC
- (void)testExample
{
    ASYNC_LOCK_INIT();
    NSArray *urls = @[@"http://df4.us/lj9", @"http://df4.us/lc"];
    [[DiffBotAPIManager sharedManager] addURLsToAnalyze:urls];
    ASYNC_LOCK_HERE();
}
#endif

@end