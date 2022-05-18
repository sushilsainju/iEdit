//
//  PlayerViewController.m
//  iEditFast
//
//  Created by SUSHIL on 3/13/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import "PlayerViewController.h"
#import "SharedStore.h"
#import "addBookmarksViewController.h"
#import "editFilesManagementViewController.h"
#import "iEditDataModel.h"



#define IDZTrace() NSLog(@"%s", __PRETTY_FUNCTION__)

@interface PlayerViewController ()

@property (nonatomic, strong) AVAudioPlayer* player;
@property (nonatomic, strong) NSTimer* timer;



- (void)updateDisplay;
- (void)updateSliderLabels;

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player
                       successfully:(BOOL)flag;
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player
                                 error:(NSError *)error;
@end

@implementation PlayerViewController

@synthesize currentTimeLabel = mCurrentTimeLabel;
@synthesize durationLabel = mDurationLabel;
@synthesize filenameLabel = mfilenameLabel;
@synthesize containerView,volumeContainer,sliderContainer;
@synthesize positionSlider,volumeSlider;
@synthesize previousBtn,pausePlayBtn,nextbtn;
@synthesize player = mPlayer;
@synthesize timer = mTimer;
@synthesize allRecordingsInLibrary,recordingNamesInLibrary;
@synthesize selectedFileIndex;
@synthesize bookmarkcontentDictionary,bookmarksArray,bookmarkedRecording;
@synthesize recordingDictionary;
@synthesize filenamewithExtension;
@synthesize dataModel;
@synthesize mediaPath;
@synthesize entityNameString,fetchPredicate,sortDescriptor;
@synthesize startPlayingFrom,stopPlayingAt;
@synthesize playingPlaylistItems;
@synthesize playingchunk;
@synthesize  bookmarkedTime;




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        recordingDictionary=[[NSMutableDictionary alloc]init];
        // Custom initialization
//        allRecordingsInLibrary=[[NSArray alloc]init];
        bookmarkcontentDictionary=[[NSMutableDictionary alloc] init];
        bookmarksArray=[[NSMutableArray alloc]init];
        dataModel=[[iEditDataModel alloc]init];
        dataModel.managedObjectContext=[DELEGATE managedObjectContext];
        playingPlaylistItems=FALSE;

    }
    return self;
}

-(id)initWithplaylist:(Playlists *)playlist
{
    self = [self initWithNibName:@"LibraryViewController" bundle:nil];
    if (self)
    {
        dataModel=[[iEditDataModel alloc]init];
        
        dataModel.managedObjectContext=[DELEGATE managedObjectContext];
       
        
        fetchPredicate = [NSPredicate predicateWithFormat:@"ANY containedIn = %@ ", playlist];
        sortDescriptor=[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
        self.title=playlist.name;
//        self.playlistDate=playlist.createdDate;
        NSManagedObjectID *ids=playlist.objectID;
        NSLog(@"object ID>>>>> %@",ids);
        
        playingPlaylistItems=TRUE;

        
        
        // Custom initialization
        
    }
    return self;
}


-(id)initWithRecording:(Library *)record;
{
    self = [self initWithNibName:@"playerViewController" bundle:nil];
    if (self)
    {
        dataModel=[[iEditDataModel alloc]init];
        bookmarkedRecording=record;
        dataModel.managedObjectContext=[DELEGATE managedObjectContext];
        
        fetchPredicate = [NSPredicate predicateWithFormat:@"filename = %@ ", record.filename];
        sortDescriptor=[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
        self.title=record.filename;
        //        self.playlistDate=playlist.createdDate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    NSLog(@"array %@",allRecordingsInLibrary);
    [self customizeView];
    NSString *className = NSStringFromClass([allRecordingsInLibrary class]);
    NSLog(@"all array %@",className);
    // Allow playback even if Ring/Silent switch is on mute
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty (kAudioSessionProperty_AudioCategory,
                             sizeof(sessionCategory),&sessionCategory);

    [self prepareToPlay];

}

- (void)viewDidUnload
{
    [self setPausePlayBtn:nil];
    [self setNextbtn:nil];
    [self setPreviousBtn:nil];
    [self setCurrentTimeLabel:nil];
    [self setPositionSlider:nil];
    [self setDurationLabel:nil];
    [self setFilenameLabel:nil];
    [self setVolumeSlider:nil];
//    [self setAllRecordingsInLibrary:nil];
//    [self setSelectedFileIndex:nil];
//    [self setTimer:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.player stop];
//    [self setPausePlayBtn:nil];
//    [self setNextbtn:nil];
//    [self setPreviousBtn:nil];
//    [self setCurrentTimeLabel:nil];
//    [self setPositionSlider:nil];
//    [self setDurationLabel:nil];
//    [self setFilenameLabel:nil];
//    [self setVolumeSlider:nil];
//    [self setAllRecordingsInLibrary:nil];
    //    [self setSelectedFileIndex:nil];
    //    [self setTimer:nil];
[super viewWillDisappear:animated];}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Custom Methods

-(void)customizeView
{
 
    
    // RESIZE VIEW
    CGRect frame;
    frame = containerView.frame;
    frame.size.height = ScreenSize.height-StatusbarFrame.size.height-NavigationbarFrame.size.height+IOS_Delta;
    [containerView setFrame:frame];
    
    //POSITOIN volume CONTAINER AT THE BOTTOM OF VIEW
    CGRect volumeFrame = self.volumeContainer.frame;
    volumeFrame.origin.y = containerView.frame.size.height-TABBAR_Frame.size.height- volumeFrame.size.height;
    self.volumeContainer.frame = volumeFrame;
    
    CGRect sliderFrame = self.sliderContainer.frame;
    sliderFrame.origin.y =IOS_Delta;//mStatusbarFrame.size.height+NavigationbarFrame.size.height;
    self.sliderContainer.frame = sliderFrame;
    
    [self.volumeSlider  setThumbImage:[UIImage imageNamed:@"thumb9"] forState:UIControlStateNormal];
   
    [self.positionSlider  setThumbImage:[UIImage imageNamed:@"thumb9"] forState:UIControlStateNormal];
    
    //POSITOIN RECORDINGCONTAINER AT THE CENTRE OF THE VIEW
    CGRect speakerrFrame = self.spakerContainer.frame;
    speakerrFrame.size.height=containerView.frame.size.height-TABBAR_Frame.size.height-sliderFrame.size.height-volumeFrame.size.height-IOS_Delta;
    speakerrFrame.origin.y = volumeFrame.origin.y-speakerrFrame.size.height;
    self.spakerContainer.frame = speakerrFrame;
    
    CGRect speakerImageFrame=self.SpeakerImage.frame;
    speakerImageFrame.origin.y = speakerrFrame.size.height/2-speakerImageFrame.size.height/2;
    speakerImageFrame.origin.x = 102;

    
    [self.SpeakerImage setFrame:speakerImageFrame];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backBtnImage = [UIImage imageNamed:@"NAV_back"]  ;
    [backBtn setBackgroundImage:backBtnImage forState:UIControlStateNormal];
//    [backBtn setTitle:@"Library" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(goback) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame = CGRectMake(0, 0, 30, 30);
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backBtn] ;
    self.navigationItem.leftBarButtonItem = backButton;
    
    UIButton *bmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *bmImage = [UIImage imageNamed:@"NAV_bookmark"]  ;
    [bmButton setBackgroundImage:bmImage forState:UIControlStateNormal];
    //    [backBtn setTitle:@"Library" forState:UIControlStateNormal];
    [bmButton addTarget:self action:@selector(bookmarkButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    bmButton.frame = CGRectMake(0, 0, 30, 30);
    UIBarButtonItem *bookmarkButton = [[UIBarButtonItem alloc] initWithCustomView:bmButton] ;
    self.navigationItem.rightBarButtonItem = bookmarkButton;
    
    self.navigationController.toolbar.backgroundColor=[UIColor whiteColor];

}


- (void)goback
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)bookmarkButtonClicked{
    bookmarkedTime=self.player.currentTime;
    addBookmarksViewController *bkController=[[addBookmarksViewController alloc]initWithNibName:@"addBookmarksViewController" bundle:nil];
    bkController.hidesBottomBarWhenPushed = YES;
    bkController.delegate=self;
    //if (Editor_State==editing) {
     //   NSLog(@"BookmarkforChunk");
    //}
    UINavigationController *nav = [[UINavigationController alloc]
                                   initWithRootViewController:bkController];
    [self presentViewController:nav animated:YES completion:NULL];

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

-(void) AddBookmarkTextLibrary:(NSString *)bookmarkText withImage:(NSString *) imageDesc;
{
    NSString *bookmarkTitle;
    NSLog(@"bookmarksArray file BEFORE -:%@ ",bookmarksArray);
    
    if(bookmarkText.length==0)
    {
        Library *selectedRecording=[allRecordingsInLibrary objectAtIndex:selectedFileIndex];
        bookmarkTitle=[ NSString stringWithFormat:@"Bookmark-%@",selectedRecording.filename];
    }
    else
        bookmarkTitle=[self getBookmarkName:bookmarkText];
    dataModel.isMaster=YES;
    [bookmarkcontentDictionary setObject:bookmarkTitle     forKey:Bookmark_param_title];
    [bookmarkcontentDictionary setObject:bookmarkText forKey:Bookmark_param_text];
    [bookmarkcontentDictionary setObject:[NSDate date ] forKey:Bookmark_param_date];
    [bookmarkcontentDictionary setObject:[NSNumber numberWithInt:bookmarkedTime] forKey:Bookmark_param_time];

    if (imageDesc)
    {
        [bookmarkcontentDictionary setObject:imageDesc forKey:Bookmark_param_imagePath];
    }
    
    
    [bookmarksArray addObject:bookmarkcontentDictionary];
    [dataModel insertRecordingsInLibrary:recordingDictionary andBookmarks:bookmarksArray];
    
    [bookmarksArray removeAllObjects];
    
    
    
}

-(void)prepareToPlay
{
    // Do any additional setup after loading the view, typically from a nib.
    self.timer = nil;
    Library *recording;
    
    //    NSInteger  startFrom,endAt;
    if (allRecordingsInLibrary.count>0)
    {
        
        if(playingPlaylistItems)
        {
            PlaylistItems *plItem=[allRecordingsInLibrary objectAtIndex:selectedFileIndex];
            recording=[plItem  valueForKey:@"recording" ];

        }
        else
        {
            recording=[allRecordingsInLibrary objectAtIndex:selectedFileIndex];

        }
    }
    else
    {
        recording=bookmarkedRecording;
    }
    NSLog(@"ismaster %d",recording.isMaster);
    if(!playingPlaylistItems)
    {
    if (!recording.isMaster)
    {
        NSDictionary *master=[dataModel getMasterRecording:recording];
        recording=[master valueForKey:@"master"];
        startPlayingFrom= [[master valueForKey:EDITFILES_param_startTime] integerValue];
        stopPlayingAt= [[master valueForKey:EDITFILES_param_endtime] integerValue];;
        playingchunk=TRUE;
    }
    else
    {
        playingchunk=FALSE;
    }
    }
    NSLog(@"selected rec %@",recording);
    mediaPath =recording.filepath;
    recordingDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           recording.filename, @"Name",
                           recording.filepath, @"Path",
                           recording.date, @"date",
                           nil];
    NSString *name=recording.filename;
 
    NSURL *url = [NSURL fileURLWithPath:mediaPath];
       mfilenameLabel.text=name;

    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
   
    [[AVAudioSession sharedInstance] setActive:YES error:nil];

    NSAssert(url, @"URL is valid.");
    NSError* error = nil;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if(!self.player)
    {
        NSLog(@"Error creating player: %@", error);
    }
    self.player.delegate = self;
    [self.player prepareToPlay];
    
    if (playingchunk)
    {
        self.player.currentTime=startPlayingFrom;
        
            [NSTimer
             scheduledTimerWithTimeInterval:stopPlayingAt-startPlayingFrom+1
             target:self
             selector:@selector(stopPlaying)
             userInfo:nil
             repeats:NO];
        


    }
//    if (playingPlaylistItems) {
//        [self.player play];
//        [self updateDisplay];
//
//    }
    // Fill in the labels that do not change
    self.durationLabel.text =  [NSString stringWithFormat:@"%d:%02d", (int)self.player.duration / 60, (int)self.player.duration % 60, nil];
    self.positionSlider.minimumValue = 0.0f;
    self.positionSlider.maximumValue = self.player.duration;
    

    [self updateDisplay];
}



- (void)stopPlaying
{
    if (playingchunk) {
        [self.player stop];
        playingchunk=FALSE;
    }
//    if (playingPlaylistItems) {
//        if (selectedFileIndex<allRecordingsInLibrary.count-1) {
//            selectedFileIndex++;
//            [self prepareToPlay];
//        }
//    }
}

#pragma mark - Display Update
- (void)updateDisplay
{
    NSTimeInterval currentTime = self.player.currentTime;
    NSString* currentTimeString =     [NSString stringWithFormat:@"%d:%02d", (int)self.player.currentTime / 60, (int)self.player.currentTime % 60, nil];
;
    
    self.positionSlider.value = currentTime;
    [self updateSliderLabels];
    self.currentTimeLabel.text = currentTimeString;
    self.volumeSlider.value = self.player.volume;
    if ([self.player isPlaying])
    {
           }
}

- (void)updateSliderLabels
{
    NSTimeInterval currentTime = self.positionSlider.value;
    NSString* currentTimeString = [NSString stringWithFormat:@"%.02f", currentTime];
    
    self.currentTimeLabel.text =  currentTimeString;
//    self.remainingTimeLabel.text = [NSString stringWithFormat:@"%.02f", self.player.duration - currentTime];
}

#pragma mark - Timer
- (void)timerFired:(NSTimer*)timer
{
    [self updateDisplay];
}

- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
    [self updateDisplay];
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{

    NSLog(@"%s successfully=%@", __PRETTY_FUNCTION__, flag ? @"YES"  : @"NO");
    if(playingPlaylistItems)
    {
        
        
        if (selectedFileIndex<allRecordingsInLibrary.count-1)
        {
            selectedFileIndex++;
            [self prepareToPlay];
            [self.player play];
        }
        
    }
    else
    {
    [pausePlayBtn setImage:((self.player.playing == YES) ? [UIImage imageNamed:Image_pauseBtnBG] : [UIImage imageNamed:Image_playBtnBG]) forState:UIControlStateNormal];
    [self stopTimer];
    }[self updateDisplay];
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    NSLog(@"stopperd");

}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"%s error=%@", __PRETTY_FUNCTION__, error);
    [self stopTimer];
    [self updateDisplay];
}

- (void)updateCurrentTime
{
	[self updateDisplay];
}

- (void)updateViewForPlayerState:(AVAudioPlayer *)p
{
	[self updateDisplay];
    
	if (mTimer)
		[mTimer invalidate];
    
	if (p.playing)
	{
		[pausePlayBtn setImage:((p.playing == YES) ? [UIImage imageNamed:Image_pauseBtnBG] : [UIImage imageNamed:Image_playBtnBG]) forState:UIControlStateNormal];
		
		mTimer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(updateCurrentTime) userInfo:p repeats:YES];
	}
	else
	{
		[pausePlayBtn setImage:((p.playing == YES) ? [UIImage imageNamed:Image_pauseBtnBG] : [UIImage imageNamed:Image_playBtnBG]) forState:UIControlStateNormal];
		mTimer = nil;
	}
	
}

-(void)pausePlaybackForPlayer:(AVAudioPlayer*)p
{
	[p pause];
	[self updateViewForPlayerState:p];
}

-(void)startPlaybackForPlayer:(AVAudioPlayer*)p
{
    // Allow playback even if Ring/Silent switch is on mute
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty (kAudioSessionProperty_AudioCategory,
                             sizeof(sessionCategory),&sessionCategory);

	if ([p play])
	{
        
		[self updateViewForPlayerState:p];
	}
	else
		NSLog(@"Could not play %@\n", p.url);
}

- (IBAction)previusoBtnClicked:(id)sender
{

    if(selectedFileIndex!=0)
    {
        [self.player stop];

        selectedFileIndex--;
        [self prepareToPlay];
        if (self.player)
        {
            [self.player play];
            [self startPlaybackForPlayer :self.player];
            [self updateDisplay];
        }
    }
}

- (IBAction)pauseplayClicked:(id)sender
{
    IDZTrace();
    if (self.player.playing == YES)
		[self pausePlaybackForPlayer: self.player];
	else
    {
//        CMTime timer = CMTimeMake(15, 1);
//        positionSlider.value=5;
//        [self.player setCurrentTime:positionSlider.value];
		[self startPlaybackForPlayer: self.player];
    }
}

- (IBAction)nextBtnClicked:(id)sender
{
    if(selectedFileIndex< allRecordingsInLibrary.count-1)
    {
        [self.player stop];
        selectedFileIndex++;
        [self prepareToPlay];
        if (self.player)
        {
            [self.player play];
            [self startPlaybackForPlayer :self.player];
            [self updateDisplay];
        }
    }

}

- (IBAction)sliderValueChanged:(id)sender
{
    if(self.timer)
        [self stopTimer];
    [self updateSliderLabels];
}



- (IBAction)volumeChanged:(UISlider *)sender
{
    self.player.volume = [sender value];
}

- (IBAction)currentTimeSliderTouchUpInside:(id)sender {
    [self.player stop];
    self.player.currentTime = self.positionSlider.value;
    [self.player prepareToPlay];
    [self pauseplayClicked:self];
}



@end
