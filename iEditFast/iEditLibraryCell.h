//
//  iEditLibraryCell.h
//  iEditFast
//
//  Created by SUSHIL on 3/17/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"
#import "Library.h"
@interface iEditLibraryCell : SWTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *duration;


@property(nonatomic,strong ) Library         *selectedrecording;

@end
