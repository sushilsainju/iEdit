//
//  BokmarksCell.h
//  iEditFast
//
//  Created by SUSHIL on 2/18/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@interface BokmarksCell : SWTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *bookmarkImage;
@property (weak, nonatomic) IBOutlet UILabel *bookmarkText;
@property (weak, nonatomic) IBOutlet UILabel *bookmarkTitle;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end
