// Auto Bookmark Settings/Camera Timer still stuck in “off’ position.
//  SettingsViewController.m
//  iEditFast
//
//  Created by SUSHIL on 2/13/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import "SettingsViewController.h"
#import "SharedStore.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize containerView,mainScrollView,RecorderSettingsView,EditorSettingView,bookmarkSettingsView;
@synthesize intervalSecondsArray,intervalStringArray,autocameraTimerSecondsArray,autocameraTimerStringArray;
@synthesize valuePickerActionSheet;
@synthesize selectedIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        intervalStringArray=[[NSMutableArray alloc]init];
        intervalSecondsArray=[[NSMutableArray   alloc]init];
        autocameraTimerStringArray=[[NSMutableArray alloc]init];
        autocameraTimerSecondsArray=[[NSMutableArray alloc]init];
        valuePickerActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:nil
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
        
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[SharedStore store] customizeNavigationBar];
    self.navigationController.navigationBar.hidden = NO;
    [self customizeView];
    [self getStoredIntervalArray];
    [self setsamplerates];
    // Do any additional setup after loading the view from its nib.
}

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
    frame.size.height = ScreenSize.height-StatusbarFrame.size.height-NavigationbarFrame.size.height+IOS_Delta-TABBAR_Frame.size.height;
    
    
    
    // CUSTOMIZE SCROLLVIEW
    frame  = self.mainScrollView.frame;
    frame.size.height  = self.containerView.frame.size.height;
    [self.mainScrollView setFrame:frame];
    
    CGRect settingsFrame=EditorSettingView.frame;
    settingsFrame.size.height=mainScrollView.frame.size.height+200;
    //    EditorSettingView.frame=settingsFrame;
    
    
    NSMutableArray *mutableTFs = [[NSMutableArray alloc] init];
    for (UIView *view in [mainScrollView subviews]) {
        if ([view isKindOfClass:[UIView class]])
        {
            
            [mutableTFs addObject:view];
            view.layer.masksToBounds=YES;
            view.layer.borderColor=ViewBorder_color;//[[UIColor colorWithRed:146.0f/255.0f green:146.0f/255.0f blue:146.0f/255.0f alpha:1.0] CGColor];
            view.layer.borderWidth= 0.5f;
            view.layer.sublayerTransform=CATransform3DMakeTranslation(0, 0, 0);
            
            
            
        }
    }
    float scrollviewHeight=RecorderSettingsView.frame.size.height+EditorSettingView.frame.size.height+bookmarkSettingsView.frame.size.height+30;
    [mainScrollView setContentSize:CGSizeMake(310, scrollviewHeight)];//+NavigationbarFrame.size.height )];
    
    
    RadioButton *rb1 = [[RadioButton alloc] initWithGroupId:@"first group" index:0];
    RadioButton *rb2 = [[RadioButton alloc] initWithGroupId:@"first group" index:1];
    
    rb1.frame = CGRectMake(10,30,22,22);
    rb2.frame = CGRectMake(10,60,22,22);
    
    [RecorderSettingsView addSubview:rb1];
    [RecorderSettingsView addSubview:rb2];
    
    
    
    UILabel *label1 =[[UILabel alloc] initWithFrame:CGRectMake(40, 30, 200, 20)];
    
    label1.backgroundColor = [UIColor clearColor];
    label1.text = @"Apple Lossless";
    label1.textColor=[UIColor darkGrayColor];
    [RecorderSettingsView addSubview:label1];
    
    UILabel *label2 =[[UILabel alloc] initWithFrame:CGRectMake(40, 60, 200, 20)];
    label2.backgroundColor = [UIColor clearColor];
    label2.text = @"AAC (64kbps)";
    label2.textColor=[UIColor darkGrayColor];
    
    [RecorderSettingsView addSubview:label2];
    
    
    [RadioButton addObserverForGroupId:@"first group" observer:self];
    
}
#pragma mark CUSTOM  METHODS

-(void)getStoredIntervalArray
{
    if ([DEFAULTS valueForKey:editIntervalArray])
    {
        NSMutableArray *buttons = [[NSMutableArray alloc] init];
        for (UIView *view in [EditorSettingView subviews]) {
            if ([view isKindOfClass:[UIButton class]])
            {
                
                [buttons addObject:view];
                
                
                
            }
        }
        
        //        intervalStringArray=[DEFAULTS valueForKey:editIntervalArray];
        intervalStringArray = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:editIntervalArray]];
        for (int i=1;i<intervalStringArray.count;i++)
        {
            
            UIButton *button = (UIButton *)[EditorSettingView viewWithTag:i];
            [button setTitle:[[ intervalStringArray objectAtIndex:i] capitalizedString] forState:UIControlStateNormal];
            
        }
    }
    if([DEFAULTS valueForKey:editIntervalArrayinSeconds])
    {
        intervalSecondsArray = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:editIntervalArrayinSeconds]];
        //        intervalSecondsArray=[DEFAULTS valueForKey:editIntervalArrayinSeconds];
    }
    if([DEFAULTS valueForKey:cameraTimerArrayinSeconds])
    {
        autocameraTimerStringArray=[[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:cameraTimerStringArray]];
        if ([DEFAULTS valueForKey:Key_savedAutoImageValue])
        {
            NSInteger timer=[DEFAULTS integerForKey:Key_savedAutoImageValue];
            switch (timer) {
                case autoimage_None:
                    DELEGATE.autoImageTimer=autoimage_None;
                    break;
                case autoimage_2Sec:
                    DELEGATE.autoImageTimer=autoimage_2Sec;
                    
                    break;
                case autoimage_4Sec:
                    DELEGATE.autoImageTimer=autoimage_4Sec;
                    
                    break;
                case autoimage_6Sec:
                    DELEGATE.autoImageTimer=autoimage_6Sec;
                    
                    break;
                default:
                    break;
            }
            [DEFAULTS setInteger:DELEGATE.autoImageTimer forKey:Key_savedAutoImageValue];
            [DEFAULTS synchronize];
            
            [_timerButton setTitle:[autocameraTimerStringArray objectAtIndex:DELEGATE.autoImageTimer] forState:UIControlStateNormal];
        }
    }
}

-(void)setsamplerates
{
    NSArray *samplerateStrings=[DEFAULTS valueForKey:sampleRateStringArray];
    NSArray *bitrateStrings=[DEFAULTS valueForKey:bitRateStringArray];
    if ([DEFAULTS valueForKey:recorderBitrate])
    {
        NSInteger bitrateoptin=[[DEFAULTS valueForKey:recorderBitrate]integerValue];
        [self.bitRateButton setTitle:[bitrateStrings objectAtIndex:bitrateoptin] forState:UIControlStateNormal];
    }
    else
    {
        
        [self.bitRateButton setTitle:[bitrateStrings objectAtIndex:0] forState:UIControlStateNormal];
        [DEFAULTS setObject:0 forKey:recorderBitrate];
        [DEFAULTS synchronize];
        
        
    }
    
    if ([DEFAULTS valueForKey:recorderSamplerate])
    {
        NSInteger samplerateoptin=[[DEFAULTS valueForKey:recorderSamplerate]integerValue];
        [self.sampleRateButton setTitle:[samplerateStrings objectAtIndex:samplerateoptin] forState:UIControlStateNormal];
    }
    else
    {
        
        [self.sampleRateButton setTitle:[samplerateStrings objectAtIndex:0] forState:UIControlStateNormal];
        [DEFAULTS setObject:0 forKey:recorderSamplerate];
        [DEFAULTS synchronize];
        
        
    }
    
    
}

#pragma mark IBACTION METHODS

- (IBAction)bitRateButtonclicked:(id)sender
{
    //    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
    //                                                             delegate:self
    //                                                    cancelButtonTitle:nil
    //                                               destructiveButtonTitle:nil
    //                                                    otherButtonTitles:nil];
    //
    //    // ObjC Fast Enumeration
    //    NSMutableArray *intervalsToShow=[[NSMutableArray alloc]init];
    //    for (int i=0;i<editIntervalSeconds.count;i++)
    //    {
    //        if ([[editIntervalSeconds objectAtIndex:i]integerValue]<startChunkAtSecond) {
    //            //            [actionSheet addButtonWithTitle:[editTimeIntervalArray objectAtIndex:i]];
    //            [intervalsToShow addObject:[editTimeIntervalArray objectAtIndex:i]];
    //
    //        }
    //    }
    //    for(NSString* title in intervalsToShow)
    //    {
    //        [actionSheet addButtonWithTitle:title];
    //
    //    }
    //    [actionSheet addButtonWithTitle:@"Cancel" ];
    //    actionSheet.cancelButtonIndex = [intervalsToShow count];
    //    [actionSheet showInView:DELEGATE.window];
}

- (IBAction)SampleRateButtonClicked:(id)sender
{
    
    
}

- (IBAction)IntervalButtonClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    int bTag = button.tag;
    NSLog(@"button clicked %d",bTag);
    setINtervalsViewController *intervalsController=[[setINtervalsViewController alloc]initWithNibName:@"setINtervalsViewController" bundle:nil];
    intervalsController.hidesBottomBarWhenPushed = YES;
    intervalsController.delegate=self;
    intervalsController.selectedButtonIndex=bTag;
    
    UINavigationController *nav = [[UINavigationController alloc]
                                   initWithRootViewController:intervalsController];
    [self presentViewController:nav animated:YES completion:NULL];
    
}

- (IBAction)timerButtonClicked:(id)sender
{
    
    // REMOVE PREVIOUS PICKER VIEWs
    for (UIView *SubView in valuePickerActionSheet.subviews)
    {
        [SubView removeFromSuperview];
    }
    UIToolbar *pickerToolbar;
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)]) {
        pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(-8, 0, 320, 44)];
    } else {
        pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    }
    pickerToolbar.barStyle = UIBarStyleBlackOpaque;
    [pickerToolbar sizeToFit];
    
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexSpace];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone  target:self action:@selector(doneButtonClicked:)];
    //    [doneBtn setTag:myTextField.tag];
    [barItems addObject:doneBtn];
    
    //UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    //[barItems addObject:cancelBtn];
    
    UIPickerView *pickerView = nil;
    pickerView = [[[UIPickerView alloc] initWithFrame:CGRectMake(-8, 0, 320, 450)]init] ;
    pickerView.delegate = self;
    [pickerView setShowsSelectionIndicator:YES];
    NSInteger selectedrowIndex = 0;
    
    [pickerView selectRow:selectedrowIndex inComponent:0 animated:NO];
    [pickerToolbar setItems:barItems animated:YES];
    [pickerView setFrame:CGRectMake(-8, 0, 320, 450)];
    [pickerView setBackgroundColor:[UIColor whiteColor]];
    
    
    
    
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)]) {
        // conditionally check for any version >= iOS 8 using 'isOperatingSystemAtLeastVersion'
        alertController = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:alertAction];
        [alertController addAction:alertAction];
        [alertController addAction:alertAction];
        //[alertController addAction:alertAction];
        [alertController.view addSubview:pickerView];
        [alertController.view addSubview:pickerToolbar];
        
        
        
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        // we're on iOS 7 or below
        [valuePickerActionSheet addSubview:pickerView];
        
        [valuePickerActionSheet addSubview:pickerToolbar];
        
        [valuePickerActionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
        
    }
    
    
    [valuePickerActionSheet setBackgroundColor:[UIColor whiteColor]];
    [valuePickerActionSheet setBounds:CGRectMake(0, 0, 320, 450)];
    
}

#pragma mark PICKERVIEW Delegate METHODS

-(void)doneButtonClicked:(UIButton *)sender
{
    if([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)]){
        [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
        [self showSelectedValues];
    } else {
        [valuePickerActionSheet dismissWithClickedButtonIndex:0 animated:YES];
        
        
        [self showSelectedValues];
        
    }
    
    
    
    
    
    
    
}

-(void)cancelButtonPressed:(id)sender{
    
    if([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)]){
        [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
        //[self showSelectedValues];
    } else {
        [valuePickerActionSheet dismissWithClickedButtonIndex:1 animated:YES];
        
        
        [self showSelectedValues];
        
    }
}

-(void)showSelectedValues
{
    
    [_timerButton setTitle:[[ self.autocameraTimerStringArray objectAtIndex:selectedIndex] capitalizedString] forState:UIControlStateNormal];
    DELEGATE.autoImageTimer=selectedIndex;
    [DEFAULTS setInteger:selectedIndex forKey:Key_savedAutoImageValue];
    [DEFAULTS synchronize];
    NSString *Timer=[autocameraTimerStringArray objectAtIndex:selectedIndex];
    NSLog(@"timer Id %@",Timer);
    
    
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    NSInteger numberOfComponents = 1;
    
    return numberOfComponents;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    NSInteger widthOfComponent = 320;
    
    return widthOfComponent;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSInteger numOfRows =0;
    if (pickerView.tag==0)
    {
        numOfRows = [self.autocameraTimerStringArray count];
        
    }
    
    return numOfRows;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    // Row n is same as row (n modulo numberItems).
    NSString *title = @"";
    title=[autocameraTimerStringArray objectAtIndex:row];
    return title;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedIndex = row;
    [self showSelectedValues];
}



#pragma mark Delegate METHODS

-(void) Setintervals:(NSString *)intervalString andTimeinSeconds:(NSInteger)seconds atButtonwithndex:(NSInteger)buttonIndex
{
    
    UIButton *button = (UIButton *)[EditorSettingView viewWithTag:buttonIndex];
    [button setTitle:intervalString forState:UIControlStateNormal];
    [intervalSecondsArray replaceObjectAtIndex:buttonIndex withObject: [NSNumber numberWithInteger:seconds] ];
    [intervalStringArray replaceObjectAtIndex:buttonIndex withObject: intervalString];
    [DEFAULTS setObject:intervalSecondsArray forKey:editIntervalArrayinSeconds];
    
    [DEFAULTS setObject:intervalStringArray forKey:editIntervalArray];
    [DEFAULTS synchronize];
    
    
    
}
@end
