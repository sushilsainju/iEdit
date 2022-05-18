//
//  bookmarkDetailsViewController.m
//  iEditFast
//
//  Created by SUSHIL on 3/26/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import "bookmarkDetailsViewController.h"
#import "iEditAppDelegate.h"
#import "SharedStore.h"

@interface bookmarkDetailsViewController ()

#define filedetailFrameWidth  145
#define filedetailFrameHeight 145

@end



@implementation bookmarkDetailsViewController

@synthesize bookmarkText,bookmarkImage;
@synthesize containerView,imageContainer,textContainer;
@synthesize selectedBookmark;
@synthesize filedetailsView;
@synthesize filename,datetime;
@synthesize RecordingName;
@synthesize dataModel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        dataModel=[[iEditDataModel alloc]init];
        dataModel.managedObjectContext=[DELEGATE managedObjectContext];

        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self customizeView:[self getImagePath]];
    NSLog(@"selected bookmark %@",selectedBookmark);
    [self loadDetails];
    if ( !bookmarkImage.hidden)
    {
//        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnimage:)];
//        tapGesture.numberOfTapsRequired = 1;
//        tapGesture.delegate=self;
//        [imageContainer setUserInteractionEnabled:YES];
//        [self.view addGestureRecognizer:tapGesture];
    }
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - CUSTOM Methods

//-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//    UIView *touchedview = touch.view;
//    NSLog(@"Is of type dropdown; returning NO %@",[touchedview subviews]);
//
//    for (UIView *view in [self.view subviews])
//    {
//        // Check if superclass is of type dropdown
//        if ([view isKindOfClass:[UILabel class]])
//        { // dropDown is an ivar; replace with your own
//            NSLog(@"Is of type dropdown; returning NO");
//            return YES;
//        }
//        
//    }
//    
//    return NO;
//}

-(void)userTappedOnimage:(UIGestureRecognizer*)gestureRecognizer
{
    bookmarkImageViewController *bmImage=[[bookmarkImageViewController alloc]initWithNibName:@"bookmarkImageViewController" bundle:nil];
    bmImage.imagepath=[self getImagePath];
    bmImage.bmtitle=selectedBookmark.name;
  
    [self.navigationController pushViewController:bmImage animated:YES];
}


-(void )loadDetails
{
    self.title=selectedBookmark.name;
    bookmarkText.text=selectedBookmark.text;
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMM dd yyyy,HH:mm"];
    NSString *nsstr = [format stringFromDate:selectedBookmark.date];
    datetime.text=nsstr;
    datetime.numberOfLines=0;
    filename.text=RecordingName;
//    [datetime sizeToFit];
}
-(NSString *)getImagePath
{
    NSString *path;
    
    if (selectedBookmark.hasImage)
    {
        NSArray *images=[selectedBookmark.hasImage allObjects];
        if (images.count>0)
        {
           
            self.containedImage=[images objectAtIndex:0];
            path=self.containedImage.filepath;
            
            
        }
        else
        {
            path=@"";
        }
        
        RecordingName=selectedBookmark.forRecording.filename;
        
    }
    return path;
}

-(NSNumber *)getBookmarkedInstace
{
    NSNumber *time=selectedBookmark.timeInSeconds;
    return time;
    
}

-(void)customizeView :(NSString *)imagepath
{
    
//    bookmarkText.contentInset = UIEdgeInsetsMake(0,0,0,0);
    [UIView setRoundedBorder:bookmarkText.layer withWidth:0.4 borderColor:[UIColor grayColor] andRadius:4.0];

    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor darkGrayColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"FontNAme" size:12], NSFontAttributeName, nil]];
    CGRect fileDetFrame=filedetailsView.frame;
    
    CGRect frame;
    frame = containerView.frame;
    frame.size.height = ScreenSize.height;//-StatusbarFrame.size.height-NavigationbarFrame.size.height;
    
    [containerView setFrame:frame];
    
    CGRect imageframe = self.imageContainer.frame;
    imageframe.size.height=152;
    imageframe.origin.y = IOS_Delta;
    
    CGRect bookmarkFrame = self.textContainer.frame;
    CGRect textViewFrame = self.bookmarkText.frame;

    UIButton *cancelButton = [[UIButton alloc] init];
    cancelButton.frame=CGRectMake(0,0,30,30);
    [cancelButton setBackgroundImage:[UIImage imageNamed: @"NAV_back.png"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:cancelButton];
    UIButton *editButton = [[UIButton alloc] init];
    editButton.frame=CGRectMake(0,0,30,30);
    [editButton setBackgroundImage:[UIImage imageNamed: @"NAV_edit"] forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(editBookmarkDetails) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:editButton];


    CGRect filenameFrame= filename.frame;//.origin.y=4;
    CGRect dateFrame=datetime.frame;
    if (imagepath && ![imagepath isEqual:@""])
    {
        bookmarkImage.hidden=NO;
        UIImage* image = [UIImage imageWithContentsOfFile:self.containedImage.filepath];
        
//        NSData *data = UIImagePNGRepresentation(image);
        CGRect imageframe=CGRectMake(88, 10, 145, 145);

        image = [[SharedStore store] scaleAndRotateImaga:image];
        [bookmarkImage setContentMode:UIViewContentModeScaleToFill];
        [bookmarkImage setImage:image];
        bookmarkImage.layer.cornerRadius=5;
        bookmarkImage.layer.masksToBounds=YES;
//       fileDetFrame.size.width=filedetailFrameWidth;
      
//        imageframe.size.height=filedetailFrameHeight;
        bookmarkImage.frame=imageframe;
//        filenameFrame.origin.y=imageframe.origin.y+imageframe.size.height+4;
//        dateFrame.origin.y=filenameFrame.origin.y+filenameFrame.size.height;
        
        datetime.numberOfLines=0;
        
        [datetime setFrame:dateFrame];


    }
    else
    {
        
        bookmarkImage.hidden=YES;
//        fileDetFrame.size.width=filedetailFrameWidth+bookmarkImage.frame.size.width+8;
//        fileDetFrame.origin.x=10;
        imageframe=CGRectMake(88, 10, 0, 60);

        fileDetFrame.origin.y=IOS_Delta;
        [filedetailsView setFrame:fileDetFrame];
        
//        filenameFrame.origin.y=4;
//        [filename setFrame:filenameFrame];
//        dateFrame.origin.y=filenameFrame.origin.y+filenameFrame.size.height;
//        dateFrame.size.width=fileDetFrame.size.width-5;
//        dateFrame.size.height=23;
//
//        filenameFrame.size.width=fileDetFrame.size.width-5;
//
//        [datetime setFrame:dateFrame];
//        imageframe.size.height=50;
    }
    self.imageContainer.frame = imageframe;
    fileDetFrame.origin.y=imageframe.origin.y+imageframe.size.height+3;
    [filedetailsView setFrame:fileDetFrame];
    bookmarkFrame.origin.y = IOS_Delta+imageframe.size.height+dateFrame.size.height+filenameFrame.size.height;
    bookmarkFrame.origin.y=fileDetFrame.origin.y+fileDetFrame.size.height;
    bookmarkFrame.size.height = containerView.frame.size.height-IOS_Delta-imageContainer.frame.size.height;

    self.textContainer.frame = bookmarkFrame;
    
    textViewFrame.size.height=bookmarkFrame.size.height-20;
//    [bookmarkText setFrame:textViewFrame];
    NSLog(@"screen %f ,containerView %f ,imageFrame %f, textcontainer %f ",ScreenSize.height,containerView.frame.size.height,imageContainer.frame.size.height,textContainer.frame.size.height);
}


-(void)editBookmarkDetails
{
//    addBookmarksViewController *editBookmark=[[addBookmarksViewController alloc]initWithBookmark:selectedBookmark];
//    [self.navigationController pushViewController:editBookmark animated:YES];
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
    

    bookmarkText.editable=YES;
    [bookmarkText becomeFirstResponder];
}

- (void)saveAction
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
    [dataModel editBookmarkNotes:selectedBookmark withText:bookmarkText.text];
    
}

- (void)cancelAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

//-(void) AddBookmarkTextLibrary:(NSString *)bookmarkText withImage:(NSString *) imageDesc;
//{
//    NSString *bookmarkTitle;
//    
//    if(bookmarkText.length==0)
//    {
//        Library *selectedRecording=[allRecordingsInLibrary objectAtIndex:selectedFileIndex];
//        bookmarkTitle=[ NSString stringWithFormat:@"Bookmark-%@",selectedRecording.filename];
//    }
//    else
//        bookmarkTitle=[self getBookmarkName:bookmarkText];
//    dataModel.isMaster=YES;
//    [bookmarkcontentDictionary setObject:bookmarkTitle     forKey:Bookmark_param_title];
//    [bookmarkcontentDictionary setObject:bookmarkText forKey:Bookmark_param_text];
//    [bookmarkcontentDictionary setObject:[NSDate date ] forKey:Bookmark_param_date];
//    [bookmarkcontentDictionary setObject:[NSNumber numberWithInt:bookmarkedTime] forKey:Bookmark_param_time];
//    
//    if (imageDesc)
//    {
//        [bookmarkcontentDictionary setObject:imageDesc forKey:Bookmark_param_imagePath];
//    }
//    
//    
//    [bookmarksArray addObject:bookmarkcontentDictionary];
//    [dataModel insertRecordingsInLibrary:recordingDictionary andBookmarks:bookmarksArray];
//    
//    [bookmarksArray removeAllObjects];
//    
//    
//    
//}


-(void)backButtonClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)playbuttonClicked:(id)sender
{
    
    bookmarkImageViewController *bmImage=[[bookmarkImageViewController alloc]initWithNibName:@"bookmarkImageViewController" bundle:nil];
    bmImage.selectedRecording=selectedBookmark.forRecording;
    bmImage.imagepath=[self getImagePath];
    bmImage.timeInSeconds=[self getBookmarkedInstace];
    bmImage.bmtitle=selectedBookmark.name;
    
    [self.navigationController pushViewController:bmImage animated:YES];
}

#pragma mark ---------- UITEXTFIELD DELEGATE METHODS ----------

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self animateTextField: textView up: YES];
}


- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self animateTextField: textView up: NO];
}

- (void) animateTextField: (UITextView*) textField up: (BOOL) up
{
     int movementDistance = 40; // tweak as needed

    if (!bookmarkImage.hidden) {
        movementDistance=170;
    }
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}
@end
