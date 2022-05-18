//
//  SharedStore.h
//  iEditFast
//
//  Created by SUSHIL on 2/14/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "QuartzCore/QuartzCore.h"
#import "iEditDataModel.h"
#import "MBProgressHUD.h"

@class iEditDataModel;

@interface SharedStore : UIViewController
{
    iEditDataModel *datamodel;
}

typedef enum {
    rec_recording = 0,
    rec_paused,
    rec_stopped,
} recorderState;

typedef enum {
    searchRecording = 0,
    searchBookmarks,
    
} searchFor;

typedef enum {
    editing = 0,
    idle,
} editorState;

typedef enum {
    alert_filename = 0,
    alert_bookmark,
    alert_editFile,
    
} customAlert;

typedef enum {
    save_compositeFile = 0,
    save_IndividualFiles,
    save_Both,
    notSelected,
    
} saveOptions;

typedef enum {
    recording_ALAC = 0,
    recording_AAC,
} recordingSettings;

typedef enum {
    autoimage_None = 0,
    autoimage_2Sec,
    autoimage_4Sec,
    autoimage_6Sec,
} autoimageSettings;

#define optioncompositeFile      @"composite"
#define optionIndividualFiles    @"individual"
#define optionBoth               @"both"
#define Key_savedRecorderSetting      @"savedSetting"
#define Key_savedAutoImageValue  @"autoImagesaved"

#define Key_PhotoAlbumName  @"iEditFast"

@property (nonatomic, strong) iEditDataModel *datamodel;


#define ALERT_TEXTFIELD NSINTEGER 132123
#define MINIMUM_DISKSPACE 10000


#define TAB_BAR_TOTALHEIGHT    = 132
#define TABBAR_Frame  CGRectMake(0, ScreenSize.height - 132, ScreenSize.width, 132)


#define ScreenSize      [[UIScreen mainScreen] bounds].size
#define StatusbarFrame  CGRectMake(0, 0, ScreenSize.width, 20)
#define NavigationbarFrame  CGRectMake(0, 0, ScreenSize.width, 44)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define IOS_Delta ((SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) ? 64 : 0)


// ######################################## COLORS ########################################
#define Top_bar_color    [UIColor colorWithRed:57.0/255 green:57.0/255 blue:57.0/255 alpha:1.0f]
#define PopUpView_Contianer_color      [UIColor colorWithRed:243.0/255.0 green:243.0/255.0 blue:243.0/255.0 alpha:1.0f]
//#define Color_Whitish_Grey  [UIColor colorWithRed:235.0/255 green:235.0/255 blue:235.0/255 alpha:1.0]
#define PopUpView_Contianer_Bordercolor      [[UIColor colorWithRed:146/255.0 green:146.0/255.0 blue:146.0/255.0 alpha:1.0f] CGColor]
#define Textfield_Line_color  [UIColor colorWithRed:187.0/255.0 green:187.0/255.0 blue:187.0/255.0 alpha:1.0f]
#define ViewBorder_color [[UIColor colorWithRed:146.0f/255.0f green:146.0f/255.0f blue:146.0f/255.0f alpha:1.0] CGColor];
#define Color_Whitish_0975  [UIColor colorWithWhite:0.975 alpha:1.0]
#define Color_Grey_04       [UIColor colorWithWhite:0.4 alpha:1.0]
#define Color_Grey_06       [UIColor colorWithWhite:0.6 alpha:0.1]//tablecellseparator

// ######################################## COLORS ########################################
#define Image_topTitleBar                   @"titlebarImage.png"
#define Image_sliderThumb                   @"titlebar_image.png"

#define Image_playBtnBG                     @"play.png"
#define Image_pauseBtnBG                    @"pause.png"
#define Image_placeholder                   @"splahscreen.png"
#define Image_PlaceholderSmall              @"NAV_bookmark.png"

//---------BOOKMARK Parameters----------------//
#define Bookmark_param_title            @"title"
#define Bookmark_param_text             @"text"
#define Bookmark_param_date             @"date"
#define Bookmark_param_imagePath        @"imagePath"
#define Bookmark_param_time         @"bookmarkedTime"



//---------EDITFILES Parameters----------------//
#define EDITFILES_param_chunkName            @"Name"
#define EDITFILES_param_chunkPath            @"Path"
#define EDITFILES_param_startTime            @"startChunk"
#define EDITFILES_param_endtime              @"endChunk"
#define EDITFILES_param_date                 @"date"
#define EDITFILES_param_duration             @"duration"
#define EDITFILES_param_filePath             @"filepath"

#define fileExtension     @".m4a"
#define compositefileExtension     @"composite.m4a"

//---------DROPBOX Parameters----------------//
//#define DROPBOX_AppKey            @"xfmkugws6ke7lo2"
//#define DROPBOX_AppSecret           @"pwek9omkw0494m4"

#define DROPBOX_AppKey            @"2pjg9c4fdvrnngr"
#define DROPBOX_AppSecret           @"omlryjpi5dts0l9"
//OLD
//#define DROPBOX_AppKey            @"p26mvzhfiycoqtp"
//#define DROPBOX_AppSecret           @"8nhvpndi39yh2gi"


#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]


// ######################################## USER DEFAULT VAlUES ########################################
#define DEFAULTS [NSUserDefaults standardUserDefaults]
#define editIntervalArray               @"editTimeIntervalArray"
#define editIntervalArrayinSeconds      @"editTimeIntervalArraySeconds"
#define sampleRateStringArray           @"sampleRateString"
#define sampleRateValueArray            @"sampleRateValue"
#define bitRateStringArray              @"bitRateString"
#define bitRateValueArray               @"bitRateValue"
#define cameraTimerStringArray          @"cameraTimerString"
#define cameraTimerArrayinSeconds       @"cameraTimerSeconds"


// ######################################## PREFERENCES DEFAULT VAlUES ########################################

#define recorderBitrate                     @"bitRate"
#define recorderSamplerate                  @"sampleRate"



-(void)customizeNavigationBar;
- (UIView *)createDemoView:(NSString *)source;
- (UIView *)createPopViewForeditedFile;
-(UIImage *)scaleAndRotateImaga:(UIImage *)image;


-(NSString *)getDuration:(NSString *)mediapath;

-(void)setRoundedClearBorder:(CALayer *)item withRadius:(CGFloat)cornerRadius;


// ------------ CLASS METHOD --------- //
+(SharedStore*)store;

-(void)showToastMessage :(NSString *)MessageText;


@end
