//
//  MainViewController.m
//  iEditFast
//
//  Created by SUSHIL on 2/10/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import "MainViewController.h"
#import "SharedStore.h"
#import "iEditAppDelegate.h"
#import "CustomIOS7AlertView.h"
#import "Library.h"
#import "addBookmarksViewController.h"
#import "editFilesManagementViewController.h"



double recordableiTime;
@interface MainViewController ()
{

}

@property (nonatomic, strong) editFilesManagementViewController *editManagementObject;

@property (assign, nonatomic) recorderState Recorder_State;
@property (assign, nonatomic) editorState Editor_State;

@property (assign,nonatomic) customAlert Alert_For;
@property (assign) BOOL isEditing;
@property (assign) BOOL runnigOutOfDiskSpace;

@property(nonatomic, retain) NSMutableArray *fileArrayToMerge;


@end


@implementation MainViewController

@synthesize editManagementObject;
@synthesize libraryManager;
@synthesize ContainerView;
@synthesize RecordButton;
@synthesize RecorderContainer,buttonContainer,StopContainer;
@synthesize timerLabel,remainingTimerlabel,Recorder_State,Editor_State,Alert_For;
@synthesize filename,filenamewithExtension;
@synthesize managedObjectContext;
@synthesize dataModel;
@synthesize editButton,bookmarkButton,stopButton;
@synthesize recordingDictionary,bookmarkcontentDictionary,bookmarksArray;
@synthesize editFilesArray,editFileContentDictionary,fileArrayToMerge;
@synthesize editIntervalSeconds,editTimeIntervalArray;
@synthesize startChunkAtSecond,endChunkAtSecond,ChunkDurationInSeconds,chunkDurationString,recorderCurrentTime,wavChunkSecond,bookmarkedTime;
@synthesize isEditing = isEditing_;  // creates an ivar isEditing_ to back the property myBool.

int isAudioRecord = 0;
NSError *error = nil;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        dataModel=[[iEditDataModel alloc]init];
        recordingDictionary=[[NSMutableDictionary alloc]init];
        bookmarksArray=[[NSMutableArray alloc]init];
        editFilesArray=[[NSMutableArray alloc]init];
        fileArrayToMerge=[[NSMutableArray alloc]init];
        editFileContentDictionary=[[NSMutableDictionary alloc]init];
        
        dataModel.managedObjectContext=[DELEGATE managedObjectContext];
        if (![DEFAULTS valueForKey:editIntervalArray]||![DEFAULTS valueForKey:editIntervalArrayinSeconds])
        {
        NSArray *array = [[NSArray alloc] initWithObjects:
                          @"Current",
                          @"5 seconds",
                          @"10 seconds",
                          @"1 minute",
                          @"2 minutes",
                          @"5 minutes",
                          @"10 minutes",
                          nil];
        
        NSArray *secondsarray = [[NSArray alloc] initWithObjects:
                                 [NSNumber numberWithInteger:0],
                                 [NSNumber numberWithInteger:5],
                                 [NSNumber numberWithInteger:10],
                                 [NSNumber numberWithInteger:60],
                                 [NSNumber numberWithInteger:120],
                                 [NSNumber numberWithInteger:300],
                                 [NSNumber numberWithInteger:600],
                                 nil];
        [DEFAULTS setObject:secondsarray forKey:editIntervalArrayinSeconds];
        
        [DEFAULTS setObject:array forKey:editIntervalArray];
        [DEFAULTS synchronize];
        }
        if ([DEFAULTS valueForKey:editIntervalArray])
        {
            NSLog(@"stored Value %@",[DEFAULTS valueForKey:editIntervalArray]);
            editTimeIntervalArray = [[NSArray alloc] initWithArray:[DEFAULTS valueForKey:editIntervalArray]];
            
        }
        if ([DEFAULTS valueForKey:editIntervalArrayinSeconds])
        {
            editIntervalSeconds = [[NSArray alloc] initWithArray:[DEFAULTS valueForKey:editIntervalArrayinSeconds]];
            
        }
        [DELEGATE setSampleRateArray];
        [DELEGATE setbitRateArray];
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    Recorder_State=rec_stopped;
    Editor_State=idle;
    self.navigationController.navigationBar.hidden = NO;
    [self customizeView];
    [[SharedStore store] customizeNavigationBar];
    currentTimeUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                              target:self selector:@selector(updateAudioDisplay)
                                                            userInfo:NULL repeats:YES];
    self.managedObjectContext = [DELEGATE managedObjectContext];
    editButton.enabled=FALSE;
    bookmarkButton.enabled=FALSE;
    stopButton.enabled=FALSE;
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([DEFAULTS valueForKey:editIntervalArray])
    {
        editTimeIntervalArray = [[NSArray alloc] initWithArray:[DEFAULTS valueForKey:editIntervalArray]];
        
    }
    if ([DEFAULTS valueForKey:editIntervalArrayinSeconds])
    {
        editIntervalSeconds = [[NSArray alloc] initWithArray:[DEFAULTS valueForKey:editIntervalArrayinSeconds]];
        
    }
    error=[[NSError alloc]init];
	audioSession = [AVAudioSession sharedInstance];
	[audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:nil];
    
	if(error) {
        
        NSLog(@"audioSession: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);
        return;
	}
    
	[audioSession setActive:YES error:nil];
	
    

    
    }

-(void)viewWillDisappear:(BOOL)animated
{
//    self.fetchedResultsController=nil;
}
#pragma mark ---------- CUSTOM METHODS ----------




-(void)customizeView
{
    self.timerLabel.text = @" timeString";

   
    // RESIZE VIEW
    CGRect frame;
    frame = ContainerView.frame;
    frame.size.height = ScreenSize.height-StatusbarFrame.size.height-NavigationbarFrame.size.height+IOS_Delta;

    [ContainerView setFrame:frame];

    //POSITOIN BUTTON CONTAINER AT THE BOTTOM OF VIEW
    CGRect buttonsFrame = self.buttonContainer.frame;
    buttonsFrame.origin.y = ContainerView.frame.size.height-TABBAR_Frame.size.height- buttonsFrame.size.height;
    self.buttonContainer.frame = buttonsFrame;
    
    //POSITOIN STOPCONTAINER ABOVE BUTTONS
    CGRect stopFrame = self.StopContainer.frame;
    stopFrame.origin.y =buttonsFrame.origin.y- stopFrame.size.height;
    self.StopContainer.frame = stopFrame;
    
    NSLog(@"stop %f",stopFrame.origin.y);

    //POSITOIN RECORDINGCONTAINER AT THE CENTRE OF THE VIEW
    CGRect recorderFrame = self.RecorderContainer.frame;
    recorderFrame.size.height=ContainerView.frame.size.height-TABBAR_Frame.size.height-stopFrame.size.height-buttonsFrame.size.height-IOS_Delta;
    recorderFrame.origin.y = stopFrame.origin.y-recorderFrame.size.height;
    self.RecorderContainer.frame = recorderFrame;
    
    
   
    
    CGRect recordButtonFrame;
    CGRect remainingTimeFrame=self.remainingTimerlabel.frame;
    CGRect timerFrame = self.timerLabel.frame;
    recordButtonFrame = RecordButton.frame;
    recordButtonFrame.origin.y = recorderFrame.size.height/2-recordButtonFrame.size.height/2;

    
    [RecordButton setFrame:recordButtonFrame];
    remainingTimeFrame.origin.y=10;
    remainingTimerlabel.frame=remainingTimeFrame;
    float recBtnFrameEnd=recordButtonFrame.origin.y+recordButtonFrame.size.height;
    float recViewFrameEnd=recorderFrame.origin.y+recorderFrame.size.height;
    NSLog(@"stop %f and recorder %f",recBtnFrameEnd,recViewFrameEnd);

    NSLog(@"timer %f ",timerFrame.origin.y);
    
    self.timerLabel.frame=timerFrame;


   


}

-(void)promptSaveRecording:(NSInteger)buttonTag
{
    CustomIOS7AlertView *alertView = [[CustomIOS7AlertView alloc] init];

    switch (buttonTag)
    {
        case 1:
        {
            
            if(editFilesArray.count==0)
            {
                Alert_For=alert_filename;
                [alertView setContainerView:[[SharedStore store] createDemoView:filename]];
            }
            else
            {
                
            }
        }
            
            break;
        case 2:
        {
            Alert_For=alert_editFile;
            [alertView setContainerView:[[SharedStore store] createPopViewForeditedFile]];

        }
            
            break;
            
        default:
            break;
    }
    
    
    
    // Modify the parameters
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Cancel",@"Save", nil]];
    [alertView setDelegate:self];
    

    
    [alertView setUseMotionEffects:true];
    
    // And launch the dialog
    [alertView show];
}

-(void)showEditIntervals
{

    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Time Interval"
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    // ObjC Fast Enumeration
    NSMutableArray *intervalsToShow=[[NSMutableArray alloc]init];
    for (int i=0;i<editIntervalSeconds.count;i++)
    {
        if ([[editIntervalSeconds objectAtIndex:i]integerValue]<startChunkAtSecond) {
//            [actionSheet addButtonWithTitle:[editTimeIntervalArray objectAtIndex:i]];
            [intervalsToShow addObject:[editTimeIntervalArray objectAtIndex:i]];

        }
    }
    for(NSString* title in intervalsToShow)
    {
        [actionSheet addButtonWithTitle:title];

    }
    [actionSheet addButtonWithTitle:@"Cancel" ];
    actionSheet.cancelButtonIndex = [intervalsToShow count];
    [actionSheet showInView:DELEGATE.window];
}



#pragma mark actoinsheet delegates

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex==actionSheet.cancelButtonIndex)
    {
        NSLog(@"Cancelled button pressed %ld",(long)buttonIndex);
        Editor_State=idle;
        [editButton setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal ];
    }
    else
    {
        if (buttonIndex>0)
        {
            NSInteger seconds=[[editIntervalSeconds objectAtIndex:buttonIndex] integerValue];
            [self makeChunk:seconds];
            startChunkAtSecond-=seconds;
        }
        
        [editButton setImage:[UIImage imageNamed:@"endedit"] forState:UIControlStateNormal ];


    }
}

-(void)makeChunk :(NSInteger)secondsPrior
{
//    NSLog(@"start from %d TO %d",secondsPrior,startChunkAtSecond);

}


-(float )getDuration:(NSString *)mediapath
{
    NSURL *afUrl = [NSURL fileURLWithPath:mediapath];
    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:afUrl options:nil];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds =  CMTimeGetSeconds(audioDuration);
    
    NSUInteger durationInSeconds = audioDurationSeconds;
//    NSUInteger durationInMinutes = durationInSeconds / 60;
//    NSUInteger durationInRemainder = durationInSeconds % 60;
    float duration=durationInSeconds;
//    NSString *finalDurationString = [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long)durationInMinutes, (unsigned long)durationInRemainder];
    
    return duration;
}

- (BOOL) mergeFiles:( NSArray* )filesarray
{
    
    NSError *error = nil;
    BOOL ok = NO;
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,    NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    
    CMTime nextClipStartTime = kCMTimeZero;
    //Create AVMutableComposition Object.This object will hold our multiple AVMutableCompositionTrack.
    AVMutableComposition *composition = [[AVMutableComposition alloc] init];
    
    AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    for (int i = 0; i< [filesarray count]; i++)
    {
//        int key = [[filesarray objectAtIndex:i] intValue];
        NSString *audioFileName = [filesarray objectAtIndex:i];
        
        //Build the filename with path
        NSString *soundOne = [documentsDirectory stringByAppendingPathComponent:audioFileName];
        //NSLog(@"voice file - %@",soundOne);
        
        NSURL *url = [NSURL fileURLWithPath:soundOne];
        
        AVAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
        NSLog(@"Asset: %@",avAsset);
//        NSArray *tracks;
//        while (tracks.count<1) {
//            tracks = [avAsset tracksWithMediaType:AVMediaTypeAudio];
//        }
        NSArray *tracks = [avAsset tracksWithMediaType:AVMediaTypeAudio];
        if ([tracks count] == 0)
            return NO;
        CMTimeRange timeRangeInAsset = CMTimeRangeMake(kCMTimeZero, [avAsset duration]);
        AVAssetTrack *clipAudioTrack = [[avAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        ok = [compositionAudioTrack insertTimeRange:timeRangeInAsset  ofTrack:clipAudioTrack atTime:nextClipStartTime error:&error];
        if (!ok) {
            NSLog(@"Current Video Track Error: %@",error);
        }
        nextClipStartTime = CMTimeAdd(nextClipStartTime, timeRangeInAsset.duration);
    }
    
    // create the export session
    // no need for a retain here, the session will be retained by the
    // completion handler since it is referenced there
    AVAssetExportSession *exportSession = [AVAssetExportSession
                                           exportSessionWithAsset:composition
                                           presetName:AVAssetExportPresetAppleM4A];
    if (nil == exportSession) return NO;
    NSString *outputFileName=[filesarray objectAtIndex:0];
    outputFileName=[outputFileName substringToIndex:8];
    NSString *output=[NSString stringWithFormat:@"%@/%@%@%@", DOCUMENTS_FOLDER,outputFileName,@"composite",fileExtension];

    
    // configure export session  output with all our parameters
    exportSession.outputURL = [NSURL fileURLWithPath:output]; // output path
    exportSession.outputFileType = AVFileTypeAppleM4A; // output file type
    
    // perform the export
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        if (AVAssetExportSessionStatusCompleted == exportSession.status) {
            NSLog(@"AVAssetExportSessionStatusCompleted");
        } else if (AVAssetExportSessionStatusFailed == exportSession.status) {
            // a failure may happen because of an event out of your control
            // for example, an interruption like a phone call comming in
            // make sure and handle this case appropriately
            NSLog(@"AVAssetExportSessionStatusFailed");
        } else {
            NSLog(@"Export Session Status: %ld", (long)exportSession.status);
        }
    }];
    
    return YES;
}

- (BOOL)trimAudio :(NSDictionary *)chunkFileDetails
{
    NSString *start=[chunkFileDetails valueForKey:@"startChunk"];
    NSString *end=[chunkFileDetails valueForKey:@"endChunk"];
    NSString *chunkName=[chunkFileDetails valueForKey:EDITFILES_param_chunkName];

    float vocalStartMarker = [start floatValue];
    float vocalEndMarker = [end floatValue];//[self getDuration:mediaPath];
    NSString *output=[NSString stringWithFormat:@"%@/%@", DOCUMENTS_FOLDER,chunkName];
//    NSString *fileoutput=[NSString stringWithFormat:@"%@%@", chunkName,fileExtension];

    NSURL *audioFileInput = [NSURL fileURLWithPath:mediaPath];;
    NSURL *audioFileOutput = [NSURL fileURLWithPath:output];;
    
    if (!audioFileInput || !audioFileOutput)
    {
        return NO;
    }
    
    [[NSFileManager defaultManager] removeItemAtURL:audioFileOutput error:NULL];
    AVAsset *asset = [AVAsset assetWithURL:audioFileInput];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetAppleM4A];
    
    if (exportSession == nil)
    {
        return NO;
    }
    
    CMTime startTime = CMTimeMake((int)(floor(vocalStartMarker * 100)), 100);
    CMTime stopTime = CMTimeMake((int)(ceil(vocalEndMarker * 100)), 100);
    CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime);
    
    exportSession.outputURL = audioFileOutput;
    exportSession.outputFileType = AVFileTypeAppleM4A;
    exportSession.timeRange = exportTimeRange;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^
     {
         if (AVAssetExportSessionStatusCompleted == exportSession.status)
         {
             // It worked!
//             [fileArrayToMerge addObject:fileoutput];

         }
         else if (AVAssetExportSessionStatusFailed == exportSession.status)
         {
             // It failed...
         }
     }];
    
    return YES;
    
}

#pragma mark -

-(void)toggleEditView
{
    editButton.enabled=!editButton.enabled;
    bookmarkButton.enabled=!bookmarkButton.enabled;
    stopButton.enabled=!stopButton.enabled;
}





- (void) updateAudioDisplay {
    
    double currentTime = recorder.currentTime;
    double rem=recordableiTime-currentTime;
    NSUInteger minutes = rem/60;
    NSUInteger hours = minutes/60;
	
    if (recorder == nil) {
        
        timerLabel.text = @"";
        
    } else if (!recorder.isRecording) {
        
        timerLabel.text = [NSString stringWithFormat: @"Recording  %02d:%02d",
								 (int) currentTime/60,
								 (int) currentTime%60];
        remainingTimerlabel.text=[NSString stringWithFormat:@"%02d:%02d:%02d" ,(int) hours,(int) minutes%60,
                                  (int) rem%60];
    }
    else
    {
//        uint64_t sizeperSec=[self getApproxFileSize:recorder.settings];

		timerLabel.text = [NSString stringWithFormat: @"Recording %02d:%02d",
								 (int) currentTime/60,
								 (int) currentTime%60];
        remainingTimerlabel.text=[NSString stringWithFormat:@"%02d:%02d:%02d" ,(int) hours,(int) minutes%60,
                                  (int) rem%60];
        uint64_t remainingDiskSpace = 35840120;
        if ((int)currentTime%60==0)
        {
           remainingDiskSpace = [self getFreeDiskspaceinKB];

        }
        if (remainingDiskSpace < MINIMUM_DISKSPACE)
        {
            _runnigOutOfDiskSpace=YES;
            if (Recorder_State==rec_recording ||Recorder_State==rec_paused)
            {
                
                [self stopRecording];
                [self toggleEditView];
                [RecordButton setImage:[UIImage imageNamed:@"ICN_RedRec"] forState:UIControlStateNormal ];
            }

            [self stopRecording];
        }
		[recorder updateMeters];
        
	}
    
}



- (NSString *) dateString
{
    // return a formatted string for a file name
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMddHHmm";
    return [formatter stringFromDate:[NSDate date]] ;

}

- (NSString *) dateStringwithSeconds
{
    // return a formatted string for a file name
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMddHHmmss";
//    return [formatter stringFromDate:[NSDate date]] ;
   return [[formatter stringFromDate:[NSDate date]] stringByAppendingString:fileExtension];
}

//RETURNS FREE DISK SPACE ON DEVICE
-(uint64_t)getFreeDiskspaceinKB
{
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary)
    {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    }
    else
    {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    
    totalFreeSpace/=1024;
    return totalFreeSpace;
}




//SAVE FILE TO LIBRARY
-(void)saveFileToLibrary
{
    //sagar need use this function to put lists in bookmark
    NSURL *afUrl = [NSURL fileURLWithPath:mediaPath];
    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:afUrl options:nil];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds =  CMTimeGetSeconds(audioDuration);
    audioDurationSeconds=audioDurationSeconds*2;
    filename=[self filename];
    filenamewithExtension=[filename stringByAppendingString:fileExtension];
    
    
    // replace file name with 10 characters with 8 character file name
    
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *mediaFileName = [NSString stringWithFormat:@"%@.m4a",[filenamewithExtension stringByDeletingPathExtension]];
    NSString *mediaFilePath = [NSString stringWithFormat:@"%@/%@",
                                            documentsDirectory, mediaFileName];
    
    if ( [[NSFileManager defaultManager] isReadableFileAtPath:mediaPath] ){
        [[NSFileManager defaultManager] copyItemAtPath:mediaPath toPath:mediaFilePath error:nil];
        //remove the 10 character file from the document directory
        [[NSFileManager defaultManager] removeItemAtPath:mediaPath error:nil];
    }
    //replace finished
    
    NSDate *date=[[NSDate date] dateByAddingTimeInterval:audioDurationSeconds];
    recordingDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                 filenamewithExtension, @"Name",
                mediaFilePath, @"Path",
                 date, @"date",
                  nil];
    //sagar create a text file to add edit file information and write to text file
    //NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *editFileParamsTextFileName = [NSString stringWithFormat:@"%@.txt",[filenamewithExtension stringByDeletingPathExtension]];
    
    NSString *editFileWithParamsFilePath = [NSString stringWithFormat:@"%@/%@",
                          documentsDirectory, editFileParamsTextFileName];
    
    [editFilesArray writeToFile:editFileWithParamsFilePath atomically:YES];
    //edit file writing finished
    if (editFilesArray.count>0)
    {
        dataModel.chunksArray=editFilesArray;
    }
    dataModel.isMaster=YES;
    [dataModel insertRecordingsInLibrary:recordingDictionary andBookmarks:bookmarksArray];
    [bookmarksArray removeAllObjects];
}

-(void)saveChunksToLibrary:(NSArray *)chunkArray
{
    NSLog(@"Files %@",chunkArray);

  for(id chunkFileDictionary in chunkArray)
  {
      NSMutableDictionary *chunkDictionary = [[NSMutableDictionary alloc]init];
      NSString *chunkfilename=[chunkFileDictionary valueForKey:EDITFILES_param_chunkName] ;
      NSString *Path = [NSString stringWithFormat:@"%@/%@", DOCUMENTS_FOLDER,[chunkFileDictionary valueForKey:EDITFILES_param_chunkName] ];

      [chunkDictionary setObject:chunkfilename forKey:EDITFILES_param_chunkName];
      [chunkDictionary setObject:Path forKey:EDITFILES_param_chunkPath];
      [chunkDictionary setObject:[NSDate date ] forKey:EDITFILES_param_date];

      
      dataModel.isMaster=NO;
      //sagar independent
      [dataModel insertRecordingsInLibrary:chunkDictionary andBookmarks:bookmarksArray];
      [bookmarksArray removeAllObjects];
  }
    
}

-(void)saveCompositeToLibrary:(NSArray *)chunkArray
{
    NSLog(@"Files %@",chunkArray);
    dataModel.isMaster=YES;
   
        NSMutableDictionary *chunkDictionary = [chunkArray objectAtIndex:0];
        NSString *compositefilename=[chunkDictionary valueForKey:EDITFILES_param_chunkName];
        compositefilename=[compositefilename substringToIndex:8];
        compositefilename=[compositefilename stringByAppendingString:compositefileExtension];
        NSString *Path = [NSString stringWithFormat:@"%@/%@", DOCUMENTS_FOLDER,compositefilename] ;
        
        [chunkDictionary setObject:compositefilename forKey:EDITFILES_param_chunkName];
        [chunkDictionary setObject:Path forKey:EDITFILES_param_chunkPath];
        [chunkDictionary setObject:[NSDate date ] forKey:EDITFILES_param_date];
        
        
        
        [dataModel insertRecordingsInLibrary:chunkDictionary andBookmarks:nil];
        [bookmarksArray removeAllObjects];
    
    
}


-(void)discardFile
{
    NSError *error;
 
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:mediaPath error:&error];
    if (success) {
        NSLog(@"file deleted  ");

    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
    [bookmarksArray removeAllObjects];

}

-(void)addEditFileContents:(NSInteger )startTime andEndTime:(NSInteger)endTime
{
    editFileContentDictionary=[[NSMutableDictionary alloc]init];
    
    ChunkDurationInSeconds=endTime-startTime;
    NSUInteger durationInSeconds = ChunkDurationInSeconds;
    NSUInteger durationInMinutes = durationInSeconds / 60;
    NSUInteger durationInRemainder = durationInSeconds % 60;
    NSString *chunkName=[NSString stringWithFormat:@"%@-%lu%@",filename ,editFilesArray.count+1,fileExtension];
    NSString *Path = [NSString stringWithFormat:@"%@/%@", DOCUMENTS_FOLDER,chunkName] ;

    chunkDurationString = [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long)durationInMinutes, (unsigned long)durationInRemainder];
    [editFileContentDictionary setObject:chunkName forKey:EDITFILES_param_chunkName];
    [editFileContentDictionary setObject:[NSNumber numberWithInteger:startTime]     forKey:EDITFILES_param_startTime];
    [editFileContentDictionary setObject:[NSNumber numberWithInteger:endTime]     forKey:EDITFILES_param_endtime];
    [editFileContentDictionary setObject:[NSDate date ]     forKey:EDITFILES_param_date];
    [editFileContentDictionary setObject:chunkDurationString     forKey:EDITFILES_param_duration];
    [editFileContentDictionary setObject:Path     forKey:EDITFILES_param_filePath];
    
    
    //sagar
    /*
     [editFileContentDictionary setObject:[NSNumber numberWithInt:bookmarkedTime] forKey:@"bookmarkTime"];
    [editFileContentDictionary setObject:[bookmarksArray valueForKey:@"text"]     forKey:@"bookmarkText"];
    */
    
    [editFilesArray addObject:editFileContentDictionary];
   

}





-(NSString *)getBookmarkName:(NSString *)text
{
    NSString *result=text;
    

        NSRange wordRange = NSMakeRange(0, 5);
        NSCharacterSet *delimiterCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSArray *firstWords = [text componentsSeparatedByCharactersInSet:delimiterCharacterSet];
    if (firstWords.count>5)
    {
        firstWords = [[text componentsSeparatedByString:@" "] subarrayWithRange:wordRange];

    }
        
        result = [firstWords componentsJoinedByString:@" "];
    

   
    return result;
}

-(void)toggleEdit:(id)sender
{
    if ([sender isSelected])
    {
        [sender setImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
        [sender setSelected:NO];
    } else
    {
        [sender setImage:[UIImage imageNamed:@"record.png"]forState:UIControlStateSelected ];
        [sender setSelected:YES];
    }

}
#pragma mark -



#pragma mark DELEGATE METHODS

- (void)manageChunkFiles:(NSArray *)chunkFiles andSaveOption:(NSString *)option
{
    //save master recording first
    [self saveFileToLibrary];
    
    [fileArrayToMerge removeAllObjects];

    for (id chunks in chunkFiles )
    {
        NSString *sfilename=[chunks valueForKey:EDITFILES_param_chunkName];
//        filename=[filename substringToIndex:];
//        sfilename=[sfilename stringByAppendingString:fileExtension];
        [fileArrayToMerge addObject:sfilename];
    }
    NSLog(@"Array %@ ",fileArrayToMerge);

    if ([option isEqualToString:optionIndividualFiles])
    {
        [self saveChunksToLibrary:chunkFiles];
    }
    else if([option isEqualToString:optionBoth])
    {
        [self saveChunksToLibrary:chunkFiles];

        [self mergeFiles:fileArrayToMerge];
        [self saveCompositeToLibrary:chunkFiles];

    }
    else
    {
        [self mergeFiles:fileArrayToMerge];
        [self saveCompositeToLibrary:chunkFiles];
    }
    [editFilesArray removeAllObjects];
}

- (void)ignoreChunkFiles:(NSArray *)chunkFiles
{
//    need to delete files
    NSLog(@"files %@",editFilesArray);
    NSError *error;
    for (int i=0; i<editFilesArray.count; i++)
    {
        NSDictionary *filedetails=[editFilesArray objectAtIndex:i];
        NSString *filenametoDelete=[[filedetails valueForKey:@"Name"] stringByAppendingString:fileExtension];
        NSString  *mediaPathtoDelte = [NSString stringWithFormat:@"%@/%@", DOCUMENTS_FOLDER,filenametoDelete] ;

        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:mediaPathtoDelte error:&error];
        if (success) {
            NSLog(@"file deleted  ");
            
        }
        else
        {
            NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
        }
    }
    

    [editFilesArray removeAllObjects ];
    [bookmarksArray removeAllObjects];
}
//sagar
-(void) AddBookmarkText:(NSString *)bookmarkText withImage:(NSString *) imageDesc;
{
    NSString *bookmarkTitle;
    NSLog(@"bookmarksArray file BEFORE -:%@ ",bookmarksArray);

//    if(bookmarkText.length==0)
//    {
        bookmarkTitle=[ NSString stringWithFormat:@"Bookmark-%@",filename];
//    }
//    else
//    bookmarkTitle=[self getBookmarkName:bookmarkText];
    bookmarkcontentDictionary=[[NSMutableDictionary alloc]init];
    [bookmarkcontentDictionary setObject:[NSNumber numberWithInt:bookmarkedTime] forKey:Bookmark_param_time];
    [bookmarkcontentDictionary setObject:bookmarkTitle     forKey:Bookmark_param_title];
    [bookmarkcontentDictionary setObject:bookmarkText forKey:Bookmark_param_text];
    [bookmarkcontentDictionary setObject:[NSDate date ] forKey:Bookmark_param_date];
    if (imageDesc) {
        [bookmarkcontentDictionary setObject:imageDesc forKey:Bookmark_param_imagePath];
    }
    

    [bookmarksArray addObject:bookmarkcontentDictionary];
    NSLog(@"bookmarksArray file  AFTER -:%@ ",bookmarksArray);

}

#pragma mark -
#define kAccelerometerFrequency        50.0 //Hz


-(void)configureAccelerometer
{
    CMMotionManager*  theAccelerometer = [[CMMotionManager alloc]init];
    theAccelerometer.accelerometerUpdateInterval = 1 / kAccelerometerFrequency;
    theAccelerometer.gyroUpdateInterval = .2;
    // Delegate events begin immediately.
}

//- (void)timerTick:(NSTimer *)timer1
//{
//    [timer1 invalidate];
//    addValueFlag = false;
//    int count = 0;
//    
//    for(int i = 0; i < self.accArray.count; i++)
//    {
//        if(([[self.accArray objectAtIndex:i] floatValue] >= [senstivity floatValue]) || ([[self.accArray objectAtIndex:i] floatValue] <= -[senstivity floatValue]))
//        {
//            count++;
//        }
//        
//        if(count >= 3)
//        {
//            
//            timerFlag = true;
//            [self.accArray removeAllObjects];
//            return;
//        }
//    }
//    [self.accArray removeAllObjects];
//    timerFlag = true;
//}

#pragma mark CUSTOM ALERTVIE METHODS



- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    switch (Alert_For)
    {
        case alert_editFile:
        {
            if(buttonIndex==0)
            {
                [alertView close];
            }
            else if(buttonIndex==1)
            {
                [self addEditFileContents:startChunkAtSecond  andEndTime:endChunkAtSecond];
                [alertView close];

                
            }
            break;
        }

            break;
        case alert_filename:
        {
            if(buttonIndex==0)
            {
                [self discardFile];
                [alertView close];
            }
            else if(buttonIndex==1)
            {
                UITextField *nameField = (UITextField *)[alertView viewWithTag:111111];
//                NSString *oldFilename=filename;
                NSString *oldFilepath=mediaPath;
                filename=nameField.text;
                filenamewithExtension=[filename stringByAppendingString:fileExtension];
                mediaPath = [NSString stringWithFormat:@"%@/%@", DOCUMENTS_FOLDER,filenamewithExtension] ;

                if (filename.length>0)
                {
                    [self saveFileToLibrary];
                    NSError * err = NULL;
                    NSFileManager * fm = [[NSFileManager alloc] init];
                    filenamewithExtension=[@"/" stringByAppendingString:filenamewithExtension];
                    NSString *newfilepath=[DOCUMENTS_FOLDER stringByAppendingString:filenamewithExtension];
                    BOOL result = [fm moveItemAtPath:oldFilepath toPath:newfilepath error:&err];
                    if(!result)
                        NSLog(@"Error: %@", err);
//                    else
//                    {
////                        selectedrecording.filename=[filename substringFromIndex:1];
////                        selectedrecording.filepath=newfilepath;
//                        NSError *error = nil;
//                        if (![DELEGATE.managedObjectContext save:&error])
//                        {
//                            // handle error
//                            UIAlertView *removeSuccessFulAlert=[[UIAlertView alloc]initWithTitle:@"iEditSmart" message:@"Can not rename file at the moment. Please try again later." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//                            [removeSuccessFulAlert show];
//                        }
//
                    [alertView close];
//
//                   
                }
                else
                {
                    UIAlertView *removeSuccessFulAlert=[[UIAlertView alloc]initWithTitle:@"iEditSmart" message:@"Please Enter Filename" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
                    [removeSuccessFulAlert show];
                }
                
            }
            break;
        }
        default:
            break;
    }
    
   
}

#pragma mark -

#pragma mark ---------- AVFRAMEWORK METHODS ----------




#pragma mark -


#pragma mark ---------- TIMER METHODS ----------





#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark ---------- IBACTION METHODS ----------





- (IBAction)recordButtonClicked:(id)sender
{
    if(Recorder_State==rec_stopped)
    {
        [self startRecording];
        if (recorder.recording) {
            [sender setImage:[UIImage imageNamed:@"ICN_RedPause"] forState:UIControlStateNormal ];
            [self toggleEditView];

        }
        timerLabel.hidden = FALSE;
        remainingTimerlabel.hidden=FALSE;

    }
    else if(Recorder_State==rec_paused)
    {
        [self resumeRecording];
        [sender setImage:[UIImage imageNamed:@"ICN_RedPause"] forState:UIControlStateNormal ];

    }
    else if(Recorder_State==rec_recording)
    {
        [self pauseRecording];
        [sender setImage:[UIImage imageNamed:@"ICN_RedRec"] forState:UIControlStateNormal ];

    }
}

- (IBAction)stopButtonClicked:(id)sender
{
//    [self getFreeDiskspace];
    if (Recorder_State==rec_recording ||Recorder_State==rec_paused)
    {
        
        [self stopRecording];
        [self toggleEditView];
        [RecordButton setImage:[UIImage imageNamed:@"ICN_RedRec"] forState:UIControlStateNormal ];
    }
   
//    [self trimAudio];
}


- (IBAction)editButtonClicked:(id)sender
{
    


    if (Editor_State==editing)
    {
        endChunkAtSecond=recorder.currentTime;
        NSLog(@"%ld",(long)endChunkAtSecond);
       

        [self promptSaveRecording:[sender tag]];

        
//        startChunkAtSecond=recorder.currentTime;
        [sender setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal ];

        Editor_State=idle;
        
    }
    else
    {
        startChunkAtSecond=recorder.currentTime;
        [sender setImage:[UIImage imageNamed:@"endedit"] forState:UIControlStateNormal ];
        if (Editor_State==idle)
        {
            [self   showEditIntervals];

        }
        Editor_State=editing;

    }
}

//-(NSString *)getDuration
//{
//    NSURL *afUrl = [NSURL fileURLWithPath:mediapath];
//    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:afUrl options:nil];
//    CMTime audioDuration = audioAsset.duration;
//    float audioDurationSeconds =  CMTimeGetSeconds(audioDuration);
//    
//    NSUInteger durationInSeconds = audioDurationSeconds;
//    NSUInteger durationInMinutes = durationInSeconds / 60;
//    NSUInteger durationInRemainder = durationInSeconds % 60;
//    
//    NSString *finalDurationString = [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long)durationInMinutes, (unsigned long)durationInRemainder];
//    
//    return finalDurationString;
//}

- (IBAction)bookmarkButtonClicked:(id)sender
{
//    [self promptBookmarkView];
    bookmarkedTime=recorder.currentTime;
    addBookmarksViewController *bkController=[[addBookmarksViewController alloc]initWithNibName:@"addBookmarksViewController" bundle:nil];
    bkController.hidesBottomBarWhenPushed = YES;
    bkController.delegate=self;
    //sagar editing state
    if (Editor_State==editing) {
        NSLog(@"BookmarkforChunk");
    }
    UINavigationController *nav = [[UINavigationController alloc]
                                   initWithRootViewController:bkController];
    [self presentViewController:nav animated:YES completion:NULL];
    wavChunkSecond=recorder.currentTime;
    [self createWav];

    
}


-(BOOL)createWav
{
//    
//    NSString *start=[chunkFileDetails valueForKey:@"startChunk"];
//    NSString *end=[chunkFileDetails valueForKey:@"endChunk"];
//    NSString *chunkName=[chunkFileDetails valueForKey:EDITFILES_param_chunkName];
    float vocalEndMarker = (float)wavChunkSecond;//[self getDuration:mediaPath];

    float vocalStartMarker=vocalEndMarker-5;
    NSString *output=[NSString stringWithFormat:@"%@/test.m4a", DOCUMENTS_FOLDER];
    //    NSString *fileoutput=[NSString stringWithFormat:@"%@%@", chunkName,fileExtension];
    
    NSURL *audioFileInput = [NSURL fileURLWithPath:mediaPath];;
    NSURL *audioFileOutput = [NSURL fileURLWithPath:output];;
    
    if (!audioFileInput || !audioFileOutput)
    {
        return NO;
    }
    
    [[NSFileManager defaultManager] removeItemAtURL:audioFileOutput error:NULL];
    AVAsset *asset = [AVAsset assetWithURL:audioFileInput];
    
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:asset
                                                                            presetName:AVAssetExportPresetAppleM4A];
    
    if (exportSession == nil)
    {
        return NO;
    }
    
    CMTime startTime = CMTimeMake((int)(floor(vocalStartMarker * 100)), 100);
    CMTime stopTime = CMTimeMake((int)(ceil(vocalEndMarker * 100)), 100);
    CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime);
    
    exportSession.outputURL = audioFileOutput;
    exportSession.outputFileType = AVFileTypeAppleM4A;
    exportSession.timeRange = exportTimeRange;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^
     {
         if (AVAssetExportSessionStatusCompleted == exportSession.status)
         {
             // It worked!
             //             [fileArrayToMerge addObject:fileoutput];
             
         }
         else if (AVAssetExportSessionStatusFailed == exportSession.status)
         {
             // It failed...
         }
     }];
    
    return YES;

}
//To stop the voice recording.
- (void) stopRecording
{
    if (_runnigOutOfDiskSpace) {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
								   message: @"Your Device is running out of free space. The Recording will stop now."
								  delegate: nil cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [alert show];
    }
    endChunkAtSecond=recorder.currentTime;

	[recorder stop];
    remainingTimerlabel.hidden=TRUE;
    timerLabel.hidden = TRUE;
    if (Editor_State==editing)
    {
        [self addEditFileContents:startChunkAtSecond  andEndTime:endChunkAtSecond];
        [editButton setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal ];
        Editor_State=idle;
    }
    
    if(editFilesArray.count==0)
    {
        
        [self promptSaveRecording:stopButton.tag];

    }
    else
    {
        for (int i=0; i<editFilesArray.count; i++)
        {
            NSMutableDictionary *editFileDetailsDictionary=[editFilesArray objectAtIndex:i];
            [self trimAudio:editFileDetailsDictionary];
        }
      
        editFilesManagementViewController *editController=[[editFilesManagementViewController alloc]initWithNibName:@"editFilesManagementViewController" bundle:nil];
        UINavigationController *nav = [[UINavigationController alloc]
                                       initWithRootViewController:editController];
        editController.editFilesArray=[[NSMutableArray alloc]initWithArray:editFilesArray];
        editController.chunksDelegate=self;
        [self presentViewController:nav animated:YES completion:NULL];
        
    }
    Recorder_State=rec_stopped;

}

// To pause the voice recording.
- (void) pauseRecording {
	
    [recorder pause];
    [self updateAudioDisplay];
    Recorder_State=rec_paused;
    //    btnPauseRecord.hidden = TRUE;
    
}

// To resume the audio from pause
- (void) resumeRecording {
	
    [recorder record];
    Recorder_State=rec_recording;
   
//    btnResumeRecord.hidden = TRUE;
    
}

-(uint64_t)getFileSize:(NSString *)filepath
{
    
    
    unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filepath error:nil] fileSize];
    NSLog(@"size %llu",fileSize);
    
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary)
    {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    }
    else
    {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    
    totalFreeSpace/=1024;
    return totalFreeSpace;
}


#pragma mark -

- (void) startRecording
{
    isAudioRecord = 1;
    
	
    //AAC SETTINGS
    NSDictionary *AACSettings = @{AVEncoderAudioQualityKey: @(AVAudioQualityMedium),
                                     AVFormatIDKey: @(kAudioFormatMPEG4AAC),
                                     AVEncoderBitRateKey: @(64000),
                                     AVNumberOfChannelsKey: @(1),
                                     AVSampleRateKey: @(44100)};
    
    
    //APPLE LOSSLESS SETTINGS
    NSDictionary *ALACSettings =    [[NSDictionary alloc] initWithObjectsAndKeys:
     [NSNumber numberWithFloat: 44100.0], AVSampleRateKey,
     [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
     [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
     [NSNumber numberWithInt: AVAudioQualityMax],
     AVEncoderAudioQualityKey,
     nil];
    
    NSDictionary *Settings;// =[[NSDictionary alloc]init];
    switch (DELEGATE.RecordingSetting) {
        case recording_AAC:
            Settings=[NSDictionary dictionaryWithDictionary:AACSettings ];
            break;
        case recording_ALAC:
            Settings=[NSDictionary dictionaryWithDictionary:ALACSettings ];
            break;
        default:
            break;
    }
    NSError *error;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:mediaPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:mediaPath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    filename=[self dateString ];
    filenamewithExtension=[self dateStringwithSeconds];
    mediaPath = [NSString stringWithFormat:@"%@/%@", DOCUMENTS_FOLDER,filenamewithExtension] ;
    NSURL *url = [NSURL fileURLWithPath:mediaPath];
    error = nil;
    NSData *audioData = [NSData dataWithContentsOfFile:[url path] options: 0 error:nil];
    
    if(audioData) {
        
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:[url path] error:nil];
        
    }
	
    error = nil;
    recorder = [[ AVAudioRecorder alloc] initWithURL:url settings:Settings error:nil];
	
    if(!recorder)
    {
        
        NSLog(@"recorder: %@ %ld %@", error, (long)[error code], [error description]);
//        NSLog(@"recorder: %@ %ld %@", [err description], (long)[err code], [[err userInfo] description]);

        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
								   message: [error localizedDescription]
								  delegate: nil cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    //prepare to record
    [recorder setDelegate:self];
    [recorder prepareToRecord];
    recorder.meteringEnabled = YES;
    
    BOOL audioHWAvailable = audioSession.inputAvailable;
    
    if (! audioHWAvailable) {
        
        UIAlertView *cantRecordAlert = [[UIAlertView alloc] initWithTitle: @"Warning"
                                                                  message: @"Audio input hardware not available"
                                                                 delegate: nil cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
        [cantRecordAlert show];
        return;
    }
    
	// start recording
    uint64_t remainigMemory=[self getFreeDiskspaceinKB];
    uint64_t sizeperSec=[self getApproxFileSize:recorder.settings];
    uint64_t remainingTime;
    
         remainingTime=remainigMemory/sizeperSec;
        NSLog(@"prem Sec%llu",remainingTime);

    
    recordableiTime=remainingTime;
	[recorder record];
    Recorder_State=rec_recording;

    
    
}

-(uint64_t)getApproxFileSize:(NSDictionary *)recorderSetting
{
    
//    NSInteger sampleRate=[[recorderSetting valueForKey:@"AVSampleRateKey"]integerValue];
    NSInteger channels=[[recorderSetting valueForKey:@"AVNumberOfChannelsKey"]integerValue];
    NSInteger bitrate=[[recorderSetting valueForKey:@"AVEncoderBitRateKey"]integerValue];
if (bitrate==0)
    bitrate=929000;
    uint64_t sizePerSec=(bitrate* channels)/(8*1024);
    recorderCurrentTime=recorder.currentTime;
//    if(recorderCurrentTime==1)
//    {
//        NSLog(@"one sec sec %ld Kb",(long)recorderCurrentTime);
//
//    }
//    else
//    {
//        NSLog(@"per sec %ld Kb",(long)recorderCurrentTime);
//
//    }
    
//    NSLog(@"per sec %llu Kb",sizePerSec);


    return sizePerSec;
}

//Formula = Sample rate x sample bit x # of channels x time in seconds / 8x1024
//recorder setting {
//    AVFormatIDKey = 1819304813;
//    AVLinearPCMBitDepthKey = 16;
//    AVLinearPCMIsBigEndianKey = 1;
//    AVLinearPCMIsFloatKey = 0;
//    AVLinearPCMIsNonInterleaved = 0;
//    AVNumberOfChannelsKey = 1;
//    AVSampleRateKey = 41000;
//}


@end
