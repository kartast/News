//
//  DiffBotAPIManager.h
//  News
//
//  Created by karta sutanto on 9/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiffBotAPIManager : NSObject <NSURLSessionDataDelegate, NSURLSessionTaskDelegate> {

}

+ (id)sharedManager;
- (void)addURLsToAnalyze:(NSArray *)URLs;
@end
