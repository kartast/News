//
//  FeedCell.h
//  News
//
//  Created by karta sutanto on 12/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel* titleLabel;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
- (void)setTitle:(NSString *)title andImageURL:(NSString *)imageURL;
@end
