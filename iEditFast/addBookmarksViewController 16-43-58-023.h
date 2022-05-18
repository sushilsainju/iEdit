//
//  addBookmarksViewController.h
//  iEditFast
//
//  Created by SUSHIL on 3/19/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
typedef void (^ALAssetsLibraryWriteImageCompletionBlock)(NSURL *assetURL, NSError *error);


@protocol iEditAddBookmarkDelegate <NSObject>
-(void) AddBookmarkText:(NSString *)bookmarkText withImage:(NSString *) imageDesc;

@end



@interface addBookmarksViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *bookmarkContainer;
@property (weak, nonatomic) IBOutlet UIView *buttonsContainer;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITextView *bookmarkText;
@property (weak, nonatomic) IBOutlet UIImageView *bookmarkImage;
@property (unsafe_unretained) id <iEditAddBookmarkDelegate> delegate;
@property(nonatomic, retain) UIImagePickerController *imagePicker;

@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *autotextButton;
@property (strong, nonatomic) NSString *imagePath;


- (void)saveAction;
- (void) cancelAction;


- (IBAction)cameraButtonClicked:(id)sender;
- (IBAction)autoTextButtonClicked:(id)sender;

@end
