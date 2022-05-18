//
//  iEditLibraryCell.m
//  iEditFast
//
//  Created by SUSHIL on 3/17/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import "iEditLibraryCell.h"

@implementation iEditLibraryCell

@synthesize selectedrecording;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        Library *library=selectedrecording;
//        NSString *duration= [ library getDuration:recording.filepath];
        NSString* theFileName = [library.filepath lastPathComponent] ;
//        NSString *nametoShow=[library namewithoutExtensoin:theFileName];
        self.title.text =theFileName;
//        cell.duration.text=duration;

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    float indentPoints = self.indentationLevel * self.indentationWidth;
    
    self.contentView.frame = CGRectMake(
                                        indentPoints,
                                        self.contentView.frame.origin.y,
                                        self.contentView.frame.size.width - indentPoints,
                                        self.contentView.frame.size.height
                                        );
}

@end
