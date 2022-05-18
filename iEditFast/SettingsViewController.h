//
//  SettingsViewController.h
//  iEditFast
//
//  Created by SUSHIL on 2/13/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "setINtervalsViewController.h"
#import "RadioButton.h"

@interface SettingsViewController : UIViewController <setIntervalsDelegate,UIActionSheetDelegate,RadioButtonDelegate,UIPickerViewDataSource,UIPickerViewDelegate>{
    UIAlertController *alertController;
}
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIView *EditorSettingView;
@property (weak, nonatomic) IBOutlet UIView *RecorderSettingsView;
@property (weak, nonatomic) IBOutlet UIView *bookmarkSettingsView;
@property(nonatomic, retain) UIActionSheet *valuePickerActionSheet;
@property(nonatomic, assign) NSInteger selectedIndex;



@property (weak, nonatomic) IBOutlet UIButton *sampleRateButton;
@property (weak, nonatomic) IBOutlet UIButton *bitRateButton;

- (IBAction)bitRateButtonclicked:(id)sender;

- (IBAction)SampleRateButtonClicked:(id)sender;

- (IBAction)IntervalButtonClicked:(id)sender;
- (IBAction)timerButtonClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *timerButton;

@property (weak, nonatomic) IBOutlet UIButton *Intervalbutton2;
@property (weak, nonatomic) IBOutlet UIButton *Intervalbutton3;
@property (weak, nonatomic) IBOutlet UIButton *Intervalbutton4;
@property (weak, nonatomic) IBOutlet UIButton *Intervalbutton5;
@property (weak, nonatomic) IBOutlet UIButton *Intervalbutton6;


@property  (strong,nonatomic) NSMutableArray *intervalSecondsArray;
@property  (strong,nonatomic) NSMutableArray *intervalStringArray;

@property  (strong,nonatomic) NSMutableArray *autocameraTimerSecondsArray;
@property  (strong,nonatomic) NSMutableArray *autocameraTimerStringArray;

@property (weak, nonatomic) IBOutlet UIButton *Interval1;
@end
