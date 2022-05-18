//
//  PlayerViewController.h
//  iEditFast
//
//  Created by SUSHIL on 3/13/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Library.h"
#import "iEditDataModel.h"
#import "PlaylistItems.h"
#import "addBookmarksViewController.h"

@interface PlayerViewController : UIViewController<AVAudioPlayerDelegate,iEditAddBookmarkDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *SpeakerImage;
@property (weak, nonatomic) IBOutlet UIView *spakerContainer;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *sliderContainer;
@property (weak, nonatomic) IBOutlet UIView *volumeContainer;
@property (weak, nonatomic) IBOutlet UISlider *positionSlider;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *filenameLabel;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UIButton *previousBtn;
@property (weak, nonatomic) IBOutlet UIButton *pausePlayBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextbtn;
@property  (strong,nonatomic) NSMutableDictionary *bookmarkcontentDictionary;
@property  (strong,nonatomic) NSMutableArray *bookmarksArray;
@property  (strong,nonatomic) NSMutableDictionary *recordingDictionary;
@property (strong, nonatomic) NSString *filenamewithExtension;
@property (nonatomic, retain) iEditDataModel* dataModel;
@property (strong, retain) Library* bookmarkedRecording;
@property (nonatomic, strong) NSString(*mediaPath);
@property(nonatomic, assign) NSInteger bookmarkedTime;



@property (nonatomic, assign)   NSArray             *allRecordingsInLibrary;
@property (nonatomic, assign)   NSArray             *recordingNamesInLibrary;

@property (nonatomic, assign)   NSInteger             selectedFileIndex;

@property (nonatomic, assign)   NSInteger             startPlayingFrom;
@property (nonatomic, assign)   NSInteger             stopPlayingAt;


@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSString      *entityNameString;
@property (nonatomic, strong) NSPredicate   *fetchPredicate;
@property (nonatomic, strong) NSSortDescriptor       *sortDescriptor;
@property   (nonatomic,assign) bool playingchunk;
@property   (nonatomic,assign) bool playingPlaylistItems;


- (IBAction)previusoBtnClicked:(id)sender;
- (IBAction)pauseplayClicked:(id)sender;
- (IBAction)nextBtnClicked:(id)sender;
- (IBAction)sliderValueChanged:(id)sender;
- (IBAction)volumeChanged:(UISlider *)sender;
- (IBAction)currentTimeSliderTouchUpInside:(id)sender;


-(id)initWithRecording:(Library *)record;

@end
