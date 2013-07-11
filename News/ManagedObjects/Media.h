//
//  Media.h
//  News
//
//  Created by karta sutanto on 10/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ItemDetail.h"

@class ItemDetail;
static const NSString *kItemMediaTypeImage = @"image";
static const NSString *kItemMediaTypeVideo = @"video";

@interface Media : NSManagedObject

@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSNumber * primary;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) ItemDetail *itemDetail;

+ (id)mediaForURL:(NSString *)url
      withCaption:(NSString *)caption
          andType:(NSString *)type
        isPrimary:(NSNumber *)isPrimary
        inContext:(NSManagedObjectContext *)context
     shouldInsert:(NSNumber *)bShouldInsert;

+ (id)setMediaSizeForURL:(NSString *)url
                   width:(NSNumber *)width
               andHeight:(NSNumber *)height
               inContext:(NSManagedObjectContext *)context
              shouldSave:(BOOL)shouldSave;


@end
