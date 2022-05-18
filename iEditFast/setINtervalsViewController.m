//
//  setINtervalsViewController.m
//  iEditFast
//
//  Created by SUSHIL on 4/28/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import "setINtervalsViewController.h"
#import "SharedStore.h"

@interface setINtervalsViewController ()

@end

@implementation setINtervalsViewController

@synthesize selectorView,labelContainerView,selectedButtonIndex;
@synthesize labelHrs,labelMins,labelSeconds,intervalsInSeconds,intervalString;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        intervalString=[[NSString alloc]init];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupDesign];
    [self setupMultisectorControl];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupDesign{
    
    CGRect frame;
    frame = _ContainerView.frame;
    frame.size.height = ScreenSize.height-StatusbarFrame.size.height-NavigationbarFrame.size.height+IOS_Delta;
    
    [_ContainerView setFrame:frame];
    
    CGRect selectorFrame=selectorView.frame;
    selectorFrame.size.height=frame.size.height-labelContainerView.frame.size.height+StatusbarFrame.size.height;
    CGRect labelContainerFrame=labelContainerView.frame;
    labelContainerFrame.origin.y=IOS_Delta;
    labelContainerView.frame=labelContainerFrame;
    
    selectorFrame.origin.y=labelContainerFrame.origin.y+labelContainerFrame.size.height+10;
    selectorView.frame=selectorFrame;
    UIButton *saveButton = [[UIButton alloc] init];
    saveButton.frame=CGRectMake(0,0,30,30);
    [saveButton setBackgroundImage:[UIImage imageNamed: @"NAV_save.png"] forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:saveButton];
    
    UIButton *cancelButton = [[UIButton alloc] init];
    cancelButton.frame=CGRectMake(0,0,30,30);
    [cancelButton setBackgroundImage:[UIImage imageNamed: @"NAV_cancel.png"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:cancelButton];
}

- (void)setupMultisectorControl{
    [self.selectorView addTarget:self action:@selector(multisectorValueChanged:) forControlEvents:UIControlEventValueChanged];
    
//    UIColor *redColor = ViewBorder_color;
//    UIColor *greyColor = [UIColor colorWithRed:187.0/255.0 green:187.0/255.0 blue:187.0/255.0 alpha:1.0];
    UIColor *orangeColor = [UIColor colorWithRed:245.0/255.0 green:92.0/255.0 blue:58.0/255.0 alpha:0.9];
//    UIColor *darkgreyColor = [UIColor colorWithRed:57.0/255.0 green:57.0/255.0 blue:57.0/255.0 alpha:1.0];

    
    SAMultisectorSector *sector1 = [SAMultisectorSector sectorWithColor:orangeColor maxValue:4.0];
    SAMultisectorSector *sector2 = [SAMultisectorSector sectorWithColor:orangeColor maxValue:59.0];
    SAMultisectorSector *sector3 = [SAMultisectorSector sectorWithColor:orangeColor maxValue:59.0];
    
    sector1.tag = 0;
    sector2.tag = 1;
    sector3.tag = 2;
    
    sector1.endValue = 1.0;
    sector2.endValue = 1.0;
    sector3.startValue = 0.0;
    sector3.endValue = 1.0;
    
    [self.selectorView addSector:sector1];
    [self.selectorView addSector:sector2];
    [self.selectorView addSector:sector3];
    
    [self updateDataView];
}

- (void)multisectorValueChanged:(id)sender{
    [self updateDataView];
}

- (void)updateDataView
{
    for(SAMultisectorSector *sector in self.selectorView.sectors){
//        NSString *startValue = [NSString stringWithFormat:@"%.0f", sector.startValue];
        NSString *endValue = [NSString stringWithFormat:@"%.0f", sector.endValue];
//        NSString *hours,*mins,*secs;
//        mins=@"";
//        secs=@"";
//        hours=@"";
        if(sector.tag == 0){
            self.labelHrs.text = endValue;
//            if ([labelHrs.text integerValue]>0) {
//                hours=[labelHrs.text stringByAppendingString:@"Hrs "];
//            }
//            else
//            {
//                hours=@"";
//            }
        }
        if(sector.tag == 1){
            self.labelMins.text = endValue;
//            if ([labelMins.text integerValue]>0) {
//                mins=[labelMins.text stringByAppendingString:@"Mins "];
//            }
//            else
//            {
//                mins=@"";
//            }

        }
        if(sector.tag == 2){
            self.labelSeconds.text = endValue;
//            if ([labelSeconds.text integerValue]>0) {
//                secs=[labelSeconds.text stringByAppendingString:@"Secs "];
//            }
//            else
//            {
//                secs=@"";
//            }
        }
        intervalsInSeconds=[labelSeconds.text integerValue]+[labelMins.text integerValue]*60+[labelHrs.text integerValue]*3600;
        intervalString=@"";
        
        NSUInteger minutes = intervalsInSeconds/60;
        NSUInteger hours = minutes/60;
        if (hours==0)
        {
            if (intervalsInSeconds<60)
            {
                intervalString = [NSString stringWithFormat:@"%ld Seconds",(long)intervalsInSeconds];

            }
            else if(minutes%60==0 && intervalsInSeconds%60==0)
            {
                intervalString = [NSString stringWithFormat:@"%lu Minutes",(unsigned long)minutes];

            }
            else
            intervalString = [NSString stringWithFormat:@"%02luMins %02ldSecs",minutes%60, intervalsInSeconds%60];


        }
        else
        {
        intervalString = [NSString stringWithFormat:@"%02luHrs %02luMins %02ldSecs", (unsigned long)hours, minutes%60, intervalsInSeconds%60];
        }
    }
}


- (void)saveAction {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
        if([self.delegate respondsToSelector:@selector(Setintervals:andTimeinSeconds:atButtonwithndex:)])
        {
            
            [self.delegate Setintervals:intervalString andTimeinSeconds:intervalsInSeconds atButtonwithndex:selectedButtonIndex];
        }
    
}



- (void)cancelAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
