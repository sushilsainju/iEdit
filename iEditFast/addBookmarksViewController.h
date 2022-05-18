//
//  addBookmarksViewController.h
//  iEditFast
//
//  Created by SUSHIL on 3/19/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bookmarks.h"
#import <AssetsLibrary/AssetsLibrary.h>
//#import <OpenEars/PocketsphinxController.h>
//#import <OpenEars/AcousticModel.h>
//#import <OpenEars/OpenEarsEventsObserver.h>

typedef void (^ALAssetsLibraryWriteImageCompletionBlock)(NSURL *assetURL, NSError *error);


@protocol iEditAddBookmarkDelegate <NSObject>
-(void) AddBookmarkText:(NSString *)bookmarkText withImage:(NSString *) imageDesc;
-(void) AddBookmarkTextLibrary:(NSString *)bookmarkText withImage:(NSString *) imageDesc;

@end


//PocketsphinxController *pocketsphinxController;
//OpenEarsEventsObserver *openEarsEventsObserver;

@interface addBookmarksViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *bookmarkContainer;
@property (weak, nonatomic) IBOutlet UIView *buttonsContainer;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITextView *bookmarkTextView;
@property (weak, nonatomic) IBOutlet UIImageView *bookmarkImage;
@property (unsafe_unretained) id <iEditAddBookmarkDelegate> delegate;

@property(nonatomic, retain) UIImagePickerController *imagePicker;

@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *autotextButton;
@property (strong, nonatomic) NSString *imagePath;
@property(nonatomic, assign) NSInteger autoTimer;
//@property (strong, nonatomic) SKRecognizer* voiceSearch;
//@property (strong, nonatomic) PocketsphinxController *pocketsphinxController;
//@property (strong, nonatomic) OpenEarsEventsObserver *openEarsEventsObserver;


- (void)saveAction;
- (void) cancelAction;

- (id)initWithBookmark:(Bookmarks *)bookmarkToEdit;

- (IBAction)cameraButtonClicked:(id)sender;
- (IBAction)autoTextButtonClicked:(id)sender;

@end
