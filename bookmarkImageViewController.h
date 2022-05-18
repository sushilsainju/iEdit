//
//  bookmarkImageViewController.h
//  iEditFast
//
//  Created by SUSHIL on 7/17/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "iEditDataModel.h"



@interface bookmarkImageViewController : UIViewController<AVAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *bookmarkImageView;
@property (weak, nonatomic) IBOutlet UILabel *bookmarkTitle;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong,nonatomic) NSString *imagepath;
@property (strong,nonatomic) NSNumber *timeInSeconds;

@property (strong,nonatomic) NSString *bmtitle;
@property (strong,nonatomic) NSArray *bookmarks;

@property (weak, nonatomic) IBOutlet UIImageView *bookmarkImage;
@property (weak, nonatomic) IBOutlet UIView *imageContainer;

@property (weak, nonatomic) IBOutlet UIView *sliderContainer;
@property (weak, nonatomic) IBOutlet UIView *volumeContainer;
@property (weak, nonatomic) IBOutlet UISlider *positionSlider;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *filenameLabel;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UIButton *pausePlayBtn;
@property (nonatomic, retain) Library* selectedRecording;
@property (nonatomic, retain) iEditDataModel* dataModel;


@property  (strong,nonatomic) NSMutableDictionary *recordingDictionary;
- (IBAction)playpauseClicked:(id)sender;
- (IBAction)sliderValueChanged:(id)sender;
- (IBAction)volumesliderValueChanged:(id)sender;
- (IBAction)currentTimeSliderTouchUpInside:(id)sender;

@end
