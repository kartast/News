//
//  GoogleFeedsAPI.h
//  News
//
//  Created by karta sutanto on 10/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoogleFeedsQueryEntry : NSObject
@property (nonatomic, retain) NSString *link;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *contentSnippet;
@end

@interface GoogleFeedsAPI : NSObject
+ (id)sharedManager;
- (void)queryWithString:(NSString *)string withCallback:(void (^)(BOOL, NSArray*))callback;
@end
