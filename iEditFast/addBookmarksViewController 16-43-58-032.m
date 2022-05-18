//
//  addBookmarksViewController.m
//  iEditFast
//
//  Created by SUSHIL on 3/19/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import "addBookmarksViewController.h"
#import "SharedStore.h"

@interface addBookmarksViewController ()

@end

@implementation addBookmarksViewController

@synthesize containerView,buttonsContainer,bookmarkContainer;
@synthesize bookmarkText,bookmarkImage;
@synthesize delegate;
@synthesize imagePicker;
@synthesize imagePath;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customizeView];
    self.navigationController.navigationBar.hidden = NO;
    self.title = @"Add Bookmark";
//    self.navigationController.navigationBar.barTintColor = [UIColor grayColor];
    
    UIButton *saveButton = [[UIButton alloc] init];
    saveButton.frame=CGRectMake(0,0,30,30);
    [saveButton setBackgroundImage:[UIImage imageNamed: @"NAV_save.png"] forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:saveButton];
    
    UIButton *cancelButton = [[UIButton alloc] init];
    cancelButton.frame=CGRectMake(0,0,30,30);
    [cancelButton setBackgroundImage:[UIImage imageNamed: @"NAV_cancel.png"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:cancelButton];
    

//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction)];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAction)];
    [bookmarkText becomeFirstResponder];
    
    // Do any additional setup after loading the view from its nib.
}

-(void)customizeView
{
    
    bookmarkText.contentInset = UIEdgeInsetsMake(-68,0,0,0);


    CGRect frame;
    frame = containerView.frame;
    frame.size.height = ScreenSize.height-216-NavigationbarFrame.size.height-StatusbarFrame.size.height+IOS_Delta;
    [containerView setFrame:frame];
    
    //POSITOIN BUTTON CONTAINER AT THE BOTTOM OF VIEW
    CGRect buttonsFrame = self.buttonsContainer.frame;
    //216=keyboard height
    NSLog(@"screen %f container %f iosDel %d",ScreenSize.height,containerView.frame.size.height,IOS_Delta);
    buttonsFrame.origin.y = containerView.frame.size.height- buttonsFrame.size.height;//-IOS_Delta;
    self.buttonsContainer.frame = buttonsFrame;
    NSLog(@"buttons %f ",buttonsFrame.origin.y);

    //POSITOIN BOOKMARKS CONTAINER AT THE TOP OF VIEW
    CGRect bookmarkFrame = self.bookmarkContainer.frame;
   // bookmarkFrame.size.height=frame.size.height-buttonsFrame.size.height-216;
    bookmarkFrame.origin.y = IOS_Delta;
    self.bookmarkContainer.frame = bookmarkFrame;
    
   

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)saveAction {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if((![self.bookmarkText.text isEqualToString:@""]) )
    {
        if([self.delegate respondsToSelector:@selector(AddBookmarkText:withImage:)])
        {
            
            [self.delegate AddBookmarkText:self.bookmarkText.text withImage:imagePath];
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
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    else
    {
        //        [[SharedStore store] showNilDelegateAlertWithMessage:NSLocalizedString(@"Message_NoCamera", nil)];
    }
}

#pragma mark ---------- IMAGEPICKER DELEGATE METHODS ----------

bool imageSelected;

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
        NSData *pngData = UIImagePNGRepresentation(pickedImage);
        NSString *filePath = [self documentsPathForFileName]; //Add the file name
        [pngData writeToFile:filePath atomically:YES]; //Write the file
        imagePath=filePath;
    }
    else
        [bookmarkImage setImage:[UIImage imageNamed:Image_PlaceholderSmall]];
    
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
