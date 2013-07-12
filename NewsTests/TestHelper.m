//
//  TestHelper.m
//  News
//
//  Created by karta sutanto on 12/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import "TestHelper.h"
#import "SSZipArchive.h"

@implementation TestHelper
+ (void)importCoreDataArchiveWithPath:(NSString *)filePath {
    [SSZipArchive unzipFileAtPath:filePath toDestination:[self documentDirectory] overwrite:YES password:nil error:nil];
}

+ (NSString *)documentDirectory
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    NSLog(@"docDirectory IS  %@", documentDirectory);
    return documentDirectory;
}
@end
