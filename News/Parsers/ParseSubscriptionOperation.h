//
//  ParseSubscriptionOperation.h
//  News
//
//  Created by karta sutanto on 1/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParseOperation.h"

@interface ParseSubscriptionOperation : ParseOperation {
    NSMutableArray *channels;
}

- (void)parseAndImportFromFeedBinSubscriptionsJSON:(NSString *)json
                                         inContext:(NSManagedObjectContext *)ctx;
@end
