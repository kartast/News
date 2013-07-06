//
//  ParseSubscriptionOperation.h
//  News
//
//  Created by karta sutanto on 1/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataHelper.h"
#import "FeedBinAPI.h"

@interface ParseOperation : NSOperation {
    NSURL *fileURL;
    NSString *jsonString;
    
    NSDictionary *apiMapping;
    CoreDataHelper *coreDataHelper;
    NSManagedObjectContext *givenManagedObjectContext;
}

@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, retain) CoreDataHelper *coreDataHelper;
@property (nonatomic, retain) NSManagedObjectContext *givenManagedObjectContext;

- (id)initWithDownloadedFilePath:(NSURL *)url
                      andMapping:(NSDictionary*)mapping
         andManagedObjectContext:(NSManagedObjectContext *)moc;
- (void)cleanup;
- (void)mapJSONArray:(NSArray *)jsonArray
           toObjects:(NSMutableArray *)channelsArray
         withMapping:(NSDictionary *)mapping
       andEntityName:(NSString *)entityName;
- (NSManagedObject *)mapEntry:(NSDictionary *)entry
                  withMapping:(NSDictionary *)mapping
                   entityName:(NSString*)className;
@end
