//
//  NSDate+InternetDateTime.h
//  News
//
//  Created by karta sutanto on 9/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import <Foundation/Foundation.h>

// Date format hints for parsing date from internet string
typedef enum {DateFormatHintNone, DateFormatHintRFC822, DateFormatHintRFC3339} DateFormatHint;

@interface NSDate (InternetDateTime)
+ (NSDate *)dateFromInternetDateTimeString:(NSString *)dateString formatHint:(DateFormatHint)hint;
+ (NSDate *)dateFromRFC3339String:(NSString *)dateString;
+ (NSDate *)dateFromRFC822String:(NSString *)dateString;
@end