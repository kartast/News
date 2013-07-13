//
//  DebugCell.m
//  News
//
//  Created by karta sutanto on 13/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import "DebugCell.h"

@implementation DebugCell
@synthesize delegate;

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

- (IBAction)debugBtn1Pressed:(id)sender {
    if ([delegate respondsToSelector:@selector(debugBtn1Pressed)]) {
        [delegate performSelector:@selector(debugBtn1Pressed) withObject:nil];
    }
}

- (IBAction)debugBtn2Pressed:(id)sender {
    if ([delegate respondsToSelector:@selector(debugBtn2Pressed)]) {
        [delegate performSelector:@selector(debugBtn2Pressed) withObject:nil];
    }
}

@end
