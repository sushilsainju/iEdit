//
//  iEditAppDelegate.h
//  iEditFast
//
//  Created by SUSHIL on 2/10/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "DropboxViewController.h"
#import "SearchViewController.h"
#import "SettingsViewController.h"
#import "MainViewController.h"
#import "BookmarksViewController.h"
#import "LibraryViewController.h"
#import "PlaylistViewController.h"

@class MainViewController;

#define DELEGATE ((iEditAppDelegate*)[[UIApplication sharedApplication] delegate])



@interface iEditAppDelegate : UIResponder <UIApplicationDelegate,CRTabBarControllerDelegate>
{
    MainViewController *mainViewController;
}   

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MainViewController *viewController;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, assign) NSInteger RecordingSetting;
@property (nonatomic, assign) NSInteger autoImageTimer;
@property (weak, nonatomic)  UIProgressView *fileProgress;

-(void)setSampleRateArray;
-(void)setbitRateArray;
- (void)setupSpeechKitConnection;
@end
