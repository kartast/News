//
//  MiscTest.m
//  News
//
//  Created by karta sutanto on 10/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+URLEncoding.h"

@interface MiscTest : XCTestCase

@end

@implementation MiscTest

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

- (void)testURLEncoding
{
    NSDictionary *testCases = @{@"abcABC123":@"abcABC123",
                                @"-._~":@"-._~",
                                @"%":@"%25",
                                @"+":@"%2B",
                                @"&=*":@"%26%3D%2A"};

    [testCases enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        NSString *normalString = (NSString *)key;
        NSString *stringEncodedExpected = (NSString *)obj;
        NSString *stringEncoded = [key urlencode];
        XCTAssertTrue([stringEncoded isEqualToString:stringEncodedExpected], @"Expected: %@\nGot:%@", stringEncodedExpected, stringEncoded);
    }];
}

- (void)testURLDecoding
{
    NSDictionary *testCases = @{@"abcABC123":@"abcABC123",
                                @"-._~":@"-._~",
                                @"%":@"%25",
                                @"+":@"%2B",
                                @"&=*":@"%26%3D%2A"};
    
    [testCases enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        NSString *normalStringExpected = (NSString *)key;
        NSString *stringEncoded = (NSString *)obj;
        NSString *normalString = [stringEncoded urlDecode];
        XCTAssertTrue([normalString isEqualToString:normalStringExpected], @"Expected: %@\nGot:%@", normalStringExpected, normalString);
    }];
}

- (void)testDictionaryNoKey
{
    NSDictionary *testDict = @{@"someKey": @"someValue"};
    XCTAssertNoThrow([testDict valueForKey:@"noKey"], @"throws error!");
}

@end
