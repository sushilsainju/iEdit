//
//  FMMoveTableViewCell.h
//  FMFramework
//
//  Created by Florian Mielke.
//  Copyright 2012 Florian Mielke. All rights reserved.
//  


@interface FMMoveTableViewCell : UITableViewCell

- (void)prepareForMove;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *duration;

@end
