//
//  MainViewController.h
//  iEditFast
//
//  Created by SUSHIL on 2/10/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import <UIKit/UIKit.h>
#import "CRTabBarController.h"
#import <AVFoundation/AVFoundation.h>
#import "CustomIOS7AlertView.h"
#import "Library.h"
#import "iEditDataModel.h"
#import "addBookmarksViewController.h"
#import "editFilesManagementViewController.h"

@class iEditDataModel;


double currentMaxAccelX;
double currentMaxAccelY;
double currentMaxAccelZ;
double currentMaxRotX;
double currentMaxRotY;
double currentMaxRotZ;

@interface MainViewController : UIViewController<AVAudioRecorderDelegate,CustomIOS7AlertViewDelegate,iEditAddBookmarkDelegate,iEditManageChunksDelegate,UIActionSheetDelegate,UIAccelerometerDelegate>

{
    
    NSString *mediaPath;
    NSString *filename;
    NSString *filenamewithExtension;
	NSTimer *currentTimeUpdateTimer;
    UILabel *timerLabel;
    SystemSoundID soundID;
	AVAudioRecorder *recorder;
    NSMutableDictionary *recordSetting;
    NSManagedObjectContext *managedObjectContext;
    AVAudioSession *audioSession;


}




@property (strong, nonatomic) IBOutlet UILabel *accX;
@property (strong, nonatomic) IBOutlet UILabel *accY;
@property (strong, nonatomic) IBOutlet UILabel *accZ;

@property (strong, nonatomic) IBOutlet UILabel *maxAccX;
@property (strong, nonatomic) IBOutlet UILabel *maxAccY;
@property (strong, nonatomic) IBOutlet UILabel *maxAccZ;

@property (strong, nonatomic) IBOutlet UILabel *rotX;
@property (strong, nonatomic) IBOutlet UILabel *rotY;
@property (strong, nonatomic) IBOutlet UILabel *rotZ;

@property (strong, nonatomic) IBOutlet UILabel *maxRotX;
@property (strong, nonatomic) IBOutlet UILabel *maxRotY;
@property (strong, nonatomic) IBOutlet UILabel *maxRotZ;

@property (strong, nonatomic) CMMotionManager *motionManager;


//------Properties-------------
@property (weak, nonatomic) IBOutlet UIView *ContainerView;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;
@property (weak, nonatomic) IBOutlet UIView *StopContainer;
@property (weak, nonatomic) IBOutlet UIView *RecorderContainer;
@property (weak, nonatomic) IBOutlet UIButton *RecordButton;
@property (nonatomic, retain) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainingTimerlabel;
- (IBAction)editButtonClicked:(id)sender;

@property (nonatomic, retain)	UILabel			*duration;
@property (nonatomic, retain)	NSTimer			*updateTimer;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSDate *startDate; // Stores the date of the click on the start button
@property (strong, nonatomic) NSString *filename;
@property (strong, nonatomic) NSString *filenamewithExtension; 
@property  (strong,nonatomic) NSMutableDictionary *recordingDictionary;
@property  (strong,nonatomic) NSMutableDictionary *bookmarkcontentDictionary;
@property  (strong,retain) NSMutableArray *bookmarksArray;

@property  (strong,nonatomic) NSMutableDictionary *editFileContentDictionary;
@property  (strong,nonatomic) NSMutableArray *editFilesArray;

@property (nonatomic, retain) iEditDataModel* dataModel;

@property (nonatomic, strong) Library *libraryManager;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UIButton *bookmarkButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;


@property(nonatomic, retain) NSMutableArray *IntervalNameArray;
@property(nonatomic, retain) NSMutableArray *intervalinSecondsArray;

@property(nonatomic, retain) UIActionSheet *valuePickerActionSheet;
@property(nonatomic, assign) NSInteger selectedIntervalIndex;
@property(nonatomic, assign) NSInteger bookmarkedTime;



@property(nonatomic, retain) NSArray *editTimeIntervalArray;
@property(nonatomic, retain) NSArray *editIntervalSeconds;
@property(nonatomic, assign) NSInteger startChunkAtSecond;
@property(nonatomic, assign) NSInteger endChunkAtSecond;
@property(nonatomic, assign) NSInteger recorderCurrentTime;
@property(nonatomic, assign) NSInteger wavChunkSecond;

@property(nonatomic, assign) NSInteger ChunkDurationInSeconds;
@property(nonatomic, assign) NSString *chunkDurationString;




//---------  IBACTION METHODS ---------

- (IBAction)recordButtonClicked:(id)sender;
- (IBAction)stopButtonClicked:(id)sender;
- (IBAction)bookmarkButtonClicked:(id)sender;


//-(void)insertRecordingsInLibrary:(NSMutableDictionary *)recordingDictionary;
//-(void)updateDB;



@end
