//
//  PlaylistCell.h
//  iEditFast
//
//  Created by SUSHIL on 2/18/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import "SWTableViewCell.h"
#import <UIKit/UIKit.h>

@interface PlaylistCell : SWTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *playlistName;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@end
