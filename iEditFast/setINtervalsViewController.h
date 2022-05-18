//
//  setINtervalsViewController.h
//  iEditFast
//
//  Created by SUSHIL on 4/28/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAMultisectorControl.h"


@protocol setIntervalsDelegate <NSObject>
-(void) Setintervals:(NSString *)intervalString andTimeinSeconds:(NSInteger)seconds atButtonwithndex:(NSInteger)buttonIndex
;
@end

@interface setINtervalsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *ContainerView;
@property (weak, nonatomic) IBOutlet SAMultisectorControl *selectorView;
@property (weak, nonatomic) IBOutlet UILabel *labelSeconds;
@property (weak, nonatomic) IBOutlet UILabel *labelMins;
@property (unsafe_unretained) id <setIntervalsDelegate> delegate;
@property(nonatomic, assign) NSInteger selectedButtonIndex;
@property(nonatomic, assign) NSInteger intervalsInSeconds;

@property (weak, nonatomic) IBOutlet UIView *labelContainerView;
@property (weak, nonatomic) IBOutlet UILabel *labelHrs;

@property (strong, nonatomic) NSString *intervalString;


@end
