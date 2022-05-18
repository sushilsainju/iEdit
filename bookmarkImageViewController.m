//
//  bookmarkImageViewController.m
//  iEditFast
//
//  Created by SUSHIL on 7/17/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//
#import "SharedStore.h"
#import "bookmarkImageViewController.h"
#import "Bookmarks.h"


#define IDZTrace() NSLog(@"%s", __PRETTY_FUNCTION__)

@interface bookmarkImageViewController ()
@property (nonatomic, strong) AVAudioPlayer* player;
@property (nonatomic, strong) NSTimer* timer;
@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) NSMutableArray *timesArray;

@end


@implementation bookmarkImageViewController

@synthesize recordingDictionary;
@synthesize player = mPlayer;
@synthesize timer = mTimer;
@synthesize dataModel;
@synthesize bookmarks;
@synthesize timeInSeconds;
@synthesize imageArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        recordingDictionary=[[NSMutableDictionary alloc]init];
        dataModel=[[iEditDataModel alloc]init];
        bookmarks=[[NSArray alloc]init];
//        bookmarkedRecording=record;
        dataModel.managedObjectContext=[DELEGATE managedObjectContext];
        _timesArray=[[NSMutableArray alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customizeView];
    [self prepareToPlay];
    bookmarks=[dataModel getBookmarksForrecording:_selectedRecording];
    imageArray=[self getImagesAtInstance];
    for (int i=0; i<imageArray.count; i++)
    {
        Bookmarks *bkm=[imageArray objectAtIndex:i];

        [_timesArray addObject:[bkm valueForKey:@"TIME"]];

    }
    // Do any additional setup after loading the view from its nib.
}

-(NSMutableArray *)getImagesAtInstance
{
    NSMutableArray *imagesArray=[[NSMutableArray alloc] init];
    for (int i=0; i<bookmarks.count; i++)
    {
        
        Bookmarks *bkm=[bookmarks objectAtIndex:i];
        
        if ([bkm hasImage]  )
        {
            NSMutableDictionary *images=[[NSMutableDictionary alloc]init];

//            NSDictionary *image=(NSDictionary *)[bkm hasImage];
            NSArray *imagesss=[[bkm hasImage]allObjects];
            if (imagesss.count>0) {
                NSDictionary *myObj=[imagesss objectAtIndex:0];
                NSString *zzz=[myObj valueForKey:@"filepath"];
                NSLog(@"path %@",zzz);
                //            NSLog(@"imagessssss %@",[image obj:@"filepath"]);
//                NSString *temp = (NSString *)[image valueForKey:@"filepath"];
                
                
                NSNumber *time=[bkm timeInSeconds];
                [images setValue:time forKey:@"TIME"];
                [images setValue:zzz  forKey:@"FILEPATH"];
                [imagesArray addObject:images];

            }
            
        }

    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"TIME" ascending:YES];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSArray *sortedArray = [imagesArray sortedArrayUsingDescriptors:sortDescriptors];
    
    imagesArray =[NSMutableArray arrayWithArray:sortedArray];
    return imagesArray;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload
{
    [self setPausePlayBtn:nil];
    
    [self setCurrentTimeLabel:nil];
    [self setPositionSlider:nil];
    [self setDurationLabel:nil];
    [self setFilenameLabel:nil];
    [self setVolumeSlider:nil];
    [super viewDidUnload];
}



-(void)viewDidDisappear:(BOOL)animated
{
    [self.player stop];
       [self setPausePlayBtn:nil];
    //    [self setNextbtn:nil];
    //    [self setPreviousBtn:nil];
       [self setCurrentTimeLabel:nil];
      [self setPositionSlider:nil];
       [self setDurationLabel:nil];
       [self setFilenameLabel:nil];
        [self setVolumeSlider:nil];
//        [self setAllRecordingsInLibrary:nil];
    //    [self setSelectedFileIndex:nil];
    //    [self setTimer:nil];
    [super viewWillDisappear:animated];}


#pragma mark custom methods
-(void)customizeView
{


    [self loadImage:_imagepath];
    
    // RESIZE VIEW
    CGRect frame;
    frame = _containerView.frame;
    frame.size.height = ScreenSize.height-StatusbarFrame.size.height-NavigationbarFrame.size.height+IOS_Delta;
    [_containerView setFrame:frame];
    
    //POSITOIN volume CONTAINER AT THE BOTTOM OF VIEW
    CGRect volumeFrame = self.volumeContainer.frame;
    volumeFrame.origin.y = _containerView.frame.size.height- volumeFrame.size.height;
    self.volumeContainer.frame = volumeFrame;
    
    CGRect sliderFrame = self.sliderContainer.frame;
    sliderFrame.origin.y =IOS_Delta;//mStatusbarFrame.size.height+NavigationbarFrame.size.height;
    self.sliderContainer.frame = sliderFrame;
    
    [self.volumeSlider  setThumbImage:[UIImage imageNamed:@"thumb9"] forState:UIControlStateNormal];
    
    [self.positionSlider  setThumbImage:[UIImage imageNamed:@"thumb9"] forState:UIControlStateNormal];
    
    //POSITOIN RECORDINGCONTAINER AT THE CENTRE OF THE VIEW
    CGRect speakerrFrame = self.imageContainer.frame;
    speakerrFrame.size.height=frame.size.height-sliderFrame.size.height-volumeFrame.size.height-IOS_Delta;
    speakerrFrame.origin.y = sliderFrame.origin.y+sliderFrame.size.height;
    self.imageContainer.frame = speakerrFrame;
    
    CGRect speakerImageFrame=self.bookmarkImage.frame;
    speakerImageFrame.origin.y = speakerrFrame.size.height/2-speakerImageFrame.size.height/2;
//    speakerImageFrame.origin.x = 102;
    
    
//    [self.imageContainer setFrame:speakerImageFrame];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backBtnImage = [UIImage imageNamed:@"NAV_back"]  ;
    [backBtn setBackgroundImage:backBtnImage forState:UIControlStateNormal];
    //    [backBtn setTitle:@"Library" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame = CGRectMake(0, 0, 30, 30);
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backBtn] ;
    self.navigationItem.leftBarButtonItem = backButton;
    
   
    
    self.navigationController.toolbar.backgroundColor=[UIColor whiteColor];

}


-(void)prepareToPlay
{
    // Do any additional setup after loading the view, typically from a nib.
    Library *recording;
    //    NSInteger  startFrom,endAt;
    recording=_selectedRecording;
    NSLog(@"selected rec %@",recording);
   NSString *mediaPath =recording.filepath;
    recordingDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           recording.filename, @"Name",
                           recording.filepath, @"Path",
                           recording.date, @"date",
                           nil];
    NSString *name=recording.filename;
    
    NSURL *url = [NSURL fileURLWithPath:mediaPath];
    _filenameLabel.text=name;
    
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
    self.player.currentTime=[timeInSeconds  intValue];

    self.player.delegate = self;
    [self.player play];
    
    [NSTimer
     scheduledTimerWithTimeInterval:1.0f
     target:self
     selector:@selector(checkforImage)
     userInfo:nil
     repeats:YES
     ];
    

    _durationLabel.text =  [NSString stringWithFormat:@"%d:%02d", (int)self.player.duration / 60, (int)self.player.duration % 60, nil];
    self.positionSlider.minimumValue = 0.0f;
    self.positionSlider.maximumValue = self.player.duration;
    
    [self updateViewForPlayerState:self.player];

    [self updateDisplay];
}


-(void)backButtonClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)loadImage:(NSString *)imagePath
{
    UIImage* image = [UIImage imageWithContentsOfFile:imagePath];
    image = [[SharedStore store] scaleAndRotateImaga:image];
    [_bookmarkImage setContentMode:UIViewContentModeScaleToFill];
    if (!image)
    {
        [_bookmarkImage setImage:[UIImage imageNamed:Image_placeholder]];


    }
    else
    [_bookmarkImage setImage:image];
    [_bookmarkTitle setText:_bmtitle];
    CATransition *transition = [CATransition animation];
    transition.duration = 1.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    
    [_bookmarkImage.layer addAnimation:transition forKey:nil];

}

static NSString *const kValueKey = @"value";
static NSString *const kIndexKey = @"index";

+ (NSArray *) searchNearestValuesOf: (int) value inArray: (NSArray *) values
{
    // set up values for indexes array
    NSMutableArray *indexes = [NSMutableArray arrayWithCapacity: values.count];
    for (int i = 0; i < values.count; i++)
        if ([values objectAtIndex:i]<value)
        {
            [indexes addObject: [NSNumber numberWithInt: i]];

        }
    
    // sort indexes
    [indexes sortUsingComparator: ^NSComparisonResult(id obj1, id obj2)
     {
         int num1 = abs([[values objectAtIndex: [obj1 intValue]] intValue] - value);
         int num2 = abs([[values objectAtIndex: [obj2 intValue]] intValue] - value);
         
         return (num1 < num2) ? NSOrderedAscending :
         (num1 > num2) ? NSOrderedDescending :
         NSOrderedSame;
     }];
    
    return [indexes subarrayWithRange: NSMakeRange(0, 3)];
}


-(void)checkforImage
{
    
    if (_timesArray.count>0) {
        NSTimeInterval currentTime = self.player.currentTime;
        NSInteger playerTime=currentTime;
        
        
        
        //        NSUInteger index = [_timesArray indexOfObject:@(playerTime)
        //                                   inSortedRange:NSMakeRange(0, _timesArray.count-1)
        //                                         options:NSBinarySearchingFirstEqual | NSBinarySearchingInsertionIndex
        //                                 usingComparator:^(id a, id b) {
        //                                     return [a compare:b];
        //                                 }];
        
        NSUInteger index = [_timesArray indexOfObject:@(playerTime)
                                        inSortedRange:NSMakeRange(0, _timesArray.count-1)
                                              options:NSBinarySearchingInsertionIndex
                                      usingComparator:^(id object0, id object1)
                            {
                                NSTimeInterval time0 = [object0 doubleValue];
                                NSTimeInterval time1 = [object1 doubleValue];
                                if (time0 < time1) return NSOrderedAscending;
                                else if (time0 > time1) return  NSOrderedDescending;
                                else return NSOrderedSame;
                            }];
        
        //    NSLog(@"index %lu",(unsigned long)index);
        
        
        NSDictionary *imagedictionary=(NSDictionary *)[imageArray objectAtIndex: index];
        NSInteger bookmarktime=[[imagedictionary valueForKey:@"TIME"] integerValue] ;
        if (currentTime<bookmarktime)
        {
            if(index>0)
                imagedictionary=(NSDictionary *)[imageArray objectAtIndex: index-1];
        }
        //    NSLog(@"image %@ ,currentTime %f",[imageArray objectAtIndex: index],currentTime);
        
        
        NSString *path=[imagedictionary valueForKey:@"FILEPATH"];
        
        [self loadImage:path];

    }

    


}

#pragma mark - Display Update

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"%s successfully=%@", __PRETTY_FUNCTION__, flag ? @"YES"  : @"NO");
           [_pausePlayBtn setImage:((self.player.playing == YES) ? [UIImage imageNamed:Image_pauseBtnBG] : [UIImage imageNamed:Image_playBtnBG]) forState:UIControlStateNormal];
        [self stopTimer];
    [_bookmarkImage setContentMode:UIViewContentModeScaleAspectFit];
    [_bookmarkImage setImage:[UIImage imageNamed:Image_placeholder]];
    [self updateDisplay];
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
		[_pausePlayBtn setImage:((p.playing == YES) ? [UIImage imageNamed:Image_pauseBtnBG] : [UIImage imageNamed:Image_playBtnBG]) forState:UIControlStateNormal];
		
		mTimer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(updateCurrentTime) userInfo:p repeats:YES];
	}
	else
	{
		[_pausePlayBtn setImage:((p.playing == YES) ? [UIImage imageNamed:Image_pauseBtnBG] : [UIImage imageNamed:Image_playBtnBG]) forState:UIControlStateNormal];
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
    
	if ([p play])
	{
        
		[self updateViewForPlayerState:p];
	}
	else
		NSLog(@"Could not play %@\n", p.url);
}
- (void)updateDisplay
{
    NSTimeInterval currentTime = self.player.currentTime;
    NSString* currentTimeString =     [NSString stringWithFormat:@"%d:%02d", (int)self.player.currentTime / 60, (int)self.player.currentTime % 60, nil];
    ;
    
    self.positionSlider.value = currentTime;
//    [self updateSliderLabels];
    self.currentTimeLabel.text = currentTimeString;
    self.volumeSlider.value = self.player.volume;
    if ([self.player isPlaying])
    {
    }
}

- (void)updateSliderLabels
{
//    NSTimeInterval currentTime = self.positionSlider.value;
    NSString* currentTimeString =     [NSString stringWithFormat:@"%d:%02d", (int)self.player.currentTime / 60, (int)self.player.currentTime % 60, nil];
    
    self.currentTimeLabel.text =  currentTimeString;
//    self.durationLabel.text =  [NSString stringWithFormat:@"%d:%02d", (int)self.player.duration / 60, (int)self.player.duration % 60, nil];
}

#pragma mark -




- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
    [self updateDisplay];
}

- (IBAction)playpauseClicked:(id)sender
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

- (IBAction)sliderValueChanged:(id)sender {
    if(self.timer)
        [self stopTimer];
    [self updateSliderLabels];
}

- (IBAction)currentTimeSliderTouchUpInside:(id)sender {
    [self.player stop];
    self.player.currentTime = self.positionSlider.value;
    [self.player prepareToPlay];
    [self playpauseClicked:self];
//    NSTimeInterval currentTime = self.player.currentTime;
//    NSInteger playerTime=currentTime;
    
}

- (IBAction)volumesliderValueChanged:(UISlider *)sender
{
    self.player.volume = [sender value];

}
@end
