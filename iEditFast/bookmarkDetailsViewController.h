//
//  bookmarkDetailsViewController.h
//  iEditFast
//
//  Created by SUSHIL on 3/26/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bookmarks.h"
#import "BookmarksViewController.h"
#import "bookmarkImageViewController.h"
#import "addBookmarksViewController.h"
#import "UIView+Rounded.h"

@interface bookmarkDetailsViewController : UIViewController<UINavigationControllerDelegate,UIGestureRecognizerDelegate,iEditAddBookmarkDelegate,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *imageContainer;
@property (weak, nonatomic) IBOutlet UIView *textContainer;
@property (weak, nonatomic) IBOutlet UIImageView *bookmarkImage;
@property (weak, nonatomic) IBOutlet UITextView *bookmarkText;
@property (weak, nonatomic) IBOutlet UIView *filedetailsView;
@property (weak, nonatomic) IBOutlet UILabel *filename;
@property (weak, nonatomic) IBOutlet UILabel *datetime;

@property (weak, nonatomic) NSString *RecordingName;

@property (weak, nonatomic) Bookmarks *selectedBookmark;
@property(nonatomic,strong ) BookmarkImages         *containedImage;
@property (nonatomic, retain) iEditDataModel* dataModel;

@property (weak, nonatomic) IBOutlet UIButton *playButton;
- (IBAction)playbuttonClicked:(id)sender;


@end
