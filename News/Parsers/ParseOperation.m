
//  ParseSubscriptionOperation.m
//  News
//
//  Created by karta sutanto on 1/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import "ParseOperation.h"
#import "Channel.h"
#import "AppDelegate.h"
#import "NSObject+JL_KeyPathIntrospection.h"
#import "ISO8601DateFormatter.h"

@interface ParseOperation() {
   
}

@end

@implementation ParseOperation

@synthesize fileURL = _fileURL;
@synthesize coreDataHelper;
@synthesize givenManagedObjectContext = _givenMOC;

- (id)initWithDownloadedFilePath:(NSURL *)url
                      andMapping:(NSDictionary*)mapping
         andManagedObjectContext:(NSManagedObjectContext *)moc {
    self = [super init];
    if (self) {
        _fileURL = url;
        apiMapping = mapping;
        if (moc) {
            _givenMOC = moc;
        }
    }
    return self;
}

- (void)mapJSONArray:(NSArray *)jsonArray
           toObjects:(NSMutableArray *)channelsArray
         withMapping:(NSDictionary *)mapping
       andEntityName:(NSString *)entityName {

    for (NSDictionary *entry in jsonArray) {
        NSManagedObject *channel = [self mapEntry:entry
                                      withMapping:mapping
                                        entityName:entityName];
        [channelsArray addObject:channel];
    }
}

- (NSManagedObject *)mapEntry:(NSDictionary *)entry
                  withMapping:(NSDictionary *)mapping
                   entityName:(NSString*)className {
    // setup entity
    NSEntityDescription *ent = [NSEntityDescription entityForName:className
                                           inManagedObjectContext:self.coreDataHelper.managedObjectContext];
    Class EntityClass = NSClassFromString(className);
    NSManagedObject *channel = [[EntityClass alloc] initWithEntity:ent insertIntoManagedObjectContext:nil];
    
    for (NSString *key in mapping) {
        NSString *propertyName = [mapping objectForKey:key];
        Class class = [EntityClass JL_classForPropertyAtKeyPath:propertyName];
        
        // Check if entry has they key
        if (![entry objectForKey:key] || [entry objectForKey:key] == [NSNull null]) {
            continue;
        }
        
        if (class == [NSDate class]) {
            // convert
            NSString *dateString = [entry objectForKey:key];
            ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
            NSDate *date = [formatter dateFromString:dateString];
            if (date) {
                [channel setValue:date forKey:propertyName];
            }
        }
        else if (class == [NSString class]) {
            // Handle String
            
            // KARTA: this allows conversion from number to string if needed
            id value = [entry objectForKey:key];
            NSString *string;
            if ([value isKindOfClass:[NSString class]]) {
                string = (NSString *)value;
            }else {
                string = [NSString stringWithFormat:@"%@",[entry objectForKey:key]];
            }
            if ([string length] > 0) {
                [channel setValue:string forKey:propertyName];
            }
        }
        else if (class == [NSNumber class]) {
            // Handle String
            NSNumber *number = [entry objectForKey:key];
            if (number != NULL) {
                [channel setValue:number forKey:propertyName];
            }
        }else if (class == [NSArray class]) {
        }
    }
    return channel;
}

- (void)cleanup {
    // remove downloaded file
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtURL:_fileURL error:nil];
}

@end
