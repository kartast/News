//
//  Media.m
//  News
//
//  Created by karta sutanto on 10/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import "Media.h"
#import "NSManagedObjectContext-EasyFetch.h"

@implementation Media

@dynamic caption;
@dynamic link;
@dynamic primary;
@dynamic type;
@dynamic width;
@dynamic height;
@dynamic itemDetail;

+ (id)mediaForURL:(NSString *)url
      withCaption:(NSString *)caption
          andType:(NSString *)type
        isPrimary:(NSNumber *)isPrimary
        inContext:(NSManagedObjectContext *)context
     shouldInsert:(NSNumber *)bShouldInsert {
    
    NSArray *array = [context fetchObjectsForEntityName:@"Media" predicateWithFormat:@"link = %@ AND caption = %@", url, caption];
    
    Media *media;
    if ([array count] > 0) {
        media = [array objectAtIndex:0];
    }else {
        NSEntityDescription *ent = [NSEntityDescription entityForName:@"Media"
                                               inManagedObjectContext:context];
        media = [[Media alloc] initWithEntity:ent insertIntoManagedObjectContext:([bShouldInsert boolValue] ? context : nil)];
        media.link = url;
        media.caption = caption;
        media.type = type;
        media.primary = isPrimary;
    }
    return media;
}

+ (id)setMediaSizeForURL:(NSString *)url
                   width:(NSNumber *)width
               andHeight:(NSNumber *)height
               inContext:(NSManagedObjectContext *)context
              shouldSave:(BOOL)shouldSave {
    
    NSArray *array = [context fetchObjectsForEntityName:@"Media" predicateWithFormat:@"link = %@", url];
    
    Media *theMedia = nil;
    for (Media *media in array) {
        theMedia = media;
        [theMedia setHeight:height];
        [theMedia setWidth:width];
    }
    
    if (shouldSave) {
        if ([context hasChanges]) {
            NSError *error;
            [context save:&error];
            ALog(@"Error saving: %@", error);
        }
    }
    
    return theMedia;
}

@end
