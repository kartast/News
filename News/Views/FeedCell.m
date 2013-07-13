//
//  FeedCell.m
//  News
//
//  Created by karta sutanto on 12/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

@import UIKit;
#import "FeedCell.h"
#import "UIImageView+WebCache.h"

@implementation FeedCell
@synthesize imageView, titleLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setTitle:(NSString *)title andImageURL:(NSString *)imageURL {
    if (imageURL) {
        __block UIImageView *imgView = self.imageView;
        float cellHeight = self.frame.size.height;
        [self.imageView setImageWithURL:[NSURL URLWithString:imageURL]
                       placeholderImage:[UIImage imageNamed:nil]
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                  float fWidth = image.size.width;
                                  float fHeight = image.size.height;
                                  
                                  float fNewWidth = fWidth;
                                  float fNewHeight = fHeight;
                                  fNewWidth = 320.0;
                                  
                                  float fRatio = 320.0/fWidth;
                                  fNewHeight = fHeight * fRatio;
                                  
                                  CGRect frame = imgView.frame;
                                  frame.size.width = fNewWidth;
                                  frame.size.height = fNewHeight;
                                  frame.origin.x = 0.0;
                                  frame.origin.y =  -(frame.size.height/2.0)+(cellHeight/2.0);
                                  imgView.frame = frame;
                                  
                                  UIInterpolatingMotionEffect *mx = [[UIInterpolatingMotionEffect alloc]
                                                                     initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
                                  mx.maximumRelativeValue = @-39.0;
                                  mx.minimumRelativeValue = @39.0;
                                  
                                  UIInterpolatingMotionEffect *mx2 = [[UIInterpolatingMotionEffect alloc]
                                                                      initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
                                  mx2.maximumRelativeValue = @-10;
                                  mx2.minimumRelativeValue = @10;
                                  
                                  //Make sure yourView's bounds are beyond the canvas viewport - because it's being moved by values.
                                  
                                  [imgView addMotionEffect:mx2];
//                                  [yourView addMotionEffect:mx2];

                              }];
    }
    self.titleLabel.text = title;
}

@end
