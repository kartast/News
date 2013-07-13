//
//  DebugCell.h
//  News
//
//  Created by karta sutanto on 13/7/13.
//  Copyright (c) 2013 karta sutanto. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DebugCellDelegate <NSObject>
@optional
- (void)debugBtn1Pressed;
- (void)debugBtn2Pressed;
@end

@interface DebugCell : UITableViewCell
@property (nonatomic, retain) id delegate;

- (IBAction)debugBtn1Pressed:(id)sender;
- (IBAction)debugBtn2Pressed:(id)sender;
@end
