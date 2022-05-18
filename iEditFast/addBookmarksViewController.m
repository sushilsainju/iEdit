//
//  addBookmarksViewController.m
//  iEditFast
//
//  Created by SUSHIL on 3/19/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import "addBookmarksViewController.h"
#import "SharedStore.h"
//#import <OpenEars/LanguageModelGenerator.h>


@interface addBookmarksViewController ()
@property (strong, atomic) ALAssetsLibrary* library;

@end

const unsigned char SpeechKitApplicationKey[] = {0xd5, 0x6f, 0xde, 0xf9, 0x2c, 0x01, 0xe2, 0xd9, 0x22, 0x35, 0x93, 0x0a, 0x20, 0x65, 0x8d, 0x8b, 0x0a, 0xeb, 0x22, 0xcb, 0x3d, 0xd4, 0x0a, 0xb3, 0xdd, 0xaa, 0x5a, 0x54, 0xbd, 0x7c, 0x0f, 0x92, 0xeb, 0xee, 0x8b, 0x17, 0xef, 0x6d, 0xf1, 0x12, 0xa3, 0x84, 0x1c, 0xc3, 0xea, 0xa9, 0x4e, 0xf4, 0x95, 0x70, 0xbf, 0xd2, 0x44, 0xc9, 0x86, 0x21, 0x73, 0xe0, 0x75, 0x31, 0x5c, 0x85, 0xc3, 0x47
};
NSString *lmPath = nil;
NSString *dicPath = nil;




@implementation addBookmarksViewController



@synthesize containerView,buttonsContainer,bookmarkContainer;
@synthesize bookmarkTextView,bookmarkImage;
@synthesize delegate;
@synthesize imagePicker;
@synthesize imagePath;
@synthesize autoTimer;
@synthesize library;
//@synthesize pocketsphinxController;
//@synthesize openEarsEventsObserver;

CGImageRef UIGetScreenImage(void);


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        library = [[ALAssetsLibrary alloc] init];
    }
    return self;
}

//- (id)initWithBookmark:(Bookmarks *)bookmarkToEdit
//{
//    self = [super initWithNibName:@"addBookmarksViewController" bundle:nil];
//    if (self)
//    {
//        bookmarkText.text=bookmarkToEdit.text;
//        // Custom initialization
//        imagePicker = [[UIImagePickerController alloc] init];
//        imagePicker.delegate = self;
//        library = [[ALAssetsLibrary alloc] init];
//    }
//    return self;
//}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];
    if (autoTimer>0) {
        [self loadImagePickerForCamera];
        autoTimer=-1;
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
   [self customizeView];


    self.navigationController.navigationBar.hidden = NO;
    self.title = @"Add Bookmark";
    
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
    


    bookmarkTextView.contentInset = UIEdgeInsetsMake(-68,0,0,0);
   
}



-(void)customizeView
{
    autoImageClick=YES;

    switch (DELEGATE.autoImageTimer)
    {
        case autoimage_None:
            autoTimer=0;
            [bookmarkTextView becomeFirstResponder];
            autoImageClick=NO;
            break;
        case autoimage_2Sec:
            autoTimer=2;
            break;
        case autoimage_4Sec:
            autoTimer=4;
            break;
        case autoimage_6Sec:
            autoTimer=6;
            break;
        default:
            break;
    }

     CGRect bookmarkFrame = self.bookmarkContainer.frame;
//    bookmarkFrame.size.height=frame.size.height-buttonsFrame.size.height-216;
    bookmarkFrame.origin.y = IOS_Delta;
    self.bookmarkContainer.frame = bookmarkFrame;
    
//    [bookmarkImage setContentMode:UIViewContentModeScaleAspectFit];

    
   

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)saveAction
{
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Bookmark text %@",bookmarkTextView.text);
    if((![self.bookmarkTextView.text isEqualToString:@""])||imagePath )
    {
        
        if([self.delegate respondsToSelector:@selector(AddBookmarkText:withImage:)])
        {
            
            [self.delegate AddBookmarkText:self.bookmarkTextView.text withImage:imagePath];
        }
        else if([self.delegate respondsToSelector:@selector(AddBookmarkTextLibrary:withImage:)])
        {
            
            [self.delegate AddBookmarkTextLibrary:self.bookmarkTextView.text withImage:imagePath];
        }
    }
}



- (void)cancelAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)autoTextButtonClicked:(id)sender {

}



- (IBAction)cameraButtonClicked:(id)sender
{
    [self loadImagePickerForCamera];
    
}




#pragma mark - Camera Methods
-(void)loadImagePickerForCamera
//sagar
{   //UIImagePickerControllerSourceTypePhotoLibrary
    //UIImagePickerControllerSourceTypeCamera
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        //sourceType = UIImagePickerControllerSourceTypePhotoLibrary
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePicker animated:YES completion:nil];
        self.imagePicker = imagePicker;
        if (autoImageClick)
        {
            [imagePicker setShowsCameraControls:NO];
            [NSTimer scheduledTimerWithTimeInterval:autoTimer
                                             target:self
                                           selector: @selector(targetMethod)
                                           userInfo:nil
                                            repeats:NO];
        }
        
    }
   
}

- (void)targetMethod
{
    [self.imagePicker takePicture];
    // ...
}

-(void)createPhototAlbum
{
    
    
}

-(void)checkForAlbum
{
    __block ALAssetsGroup* groupToAddTo;
    [self.library enumerateGroupsWithTypes:ALAssetsGroupAlbum
                                usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                    if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:Key_PhotoAlbumName]) {
                                        NSLog(@"found album %@", Key_PhotoAlbumName);
                                        groupToAddTo = group;
                                    }
                                }
                              failureBlock:^(NSError* error) {
                                  NSLog(@"failed to enumerate albums:\nError: %@", [error localizedDescription]);
                              }];
}


#pragma mark ---------- IMAGEPICKER DELEGATE METHODS ----------

bool imageSelected,autoImageClick;

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    // GET THE PICKED IMAGE
    UIImage *pickedImage;
    if(picker.allowsEditing)
        pickedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    else
        pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    
    
    // DISMISS THE IMAGEPICKERVIEW
    imageSelected=YES;
    [self dismissViewControllerAnimated:NO completion:nil];
    
    // SET THE PICKED IMAGE
    if (pickedImage)
    {
        [bookmarkImage setImage:pickedImage];
        pickedImage=[[SharedStore store]scaleAndRotateImaga:pickedImage];
        NSData *pngData = UIImagePNGRepresentation(pickedImage);
        NSString *filePath = [self documentsPathForFileName]; //Add the file name
        [pngData writeToFile:filePath atomically:YES]; //Write the file
        imagePath=filePath;
        
//        CGImageRef img = [pickedImage CGImage];
        


        UIImageWriteToSavedPhotosAlbum(pickedImage,
                                       self,
                                       @selector(image:finishedSavingWithError:contextInfo:),
                                       nil);
        
    }
    else
        [bookmarkImage setImage:[UIImage imageNamed:Image_PlaceholderSmall]];
    if (autoTimer!=0)
    {
        [self saveAction];
    }
    
}


-(void)image:(UIImage *)image
finishedSavingWithError:(NSError *)error
 contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    // DISMISS THE IMAGEPICKERVIEW
    [self dismissViewControllerAnimated:NO completion:nil];
    imageSelected=NO;
    
   
}

- (NSString *)documentsPathForFileName
{
    
    
        // return a formatted string for a file name
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MMddHHmmss";
        //    return [formatter stringFromDate:[NSDate date]] ;
       NSString *filename=[[formatter stringFromDate:[NSDate date]] stringByAppendingString:@".png"];
   
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    return [documentsPath stringByAppendingPathComponent:filename];
}

#pragma mark -



@end
