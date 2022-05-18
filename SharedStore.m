//
//  SharedStore.m
//  iEditFast
//
//  Created by SUSHIL on 2/14/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import "SharedStore.h"

@interface SharedStore ()

@end

@implementation SharedStore
@synthesize datamodel;

static SharedStore* _store = nil;


+(SharedStore*)store
{
	@synchronized([SharedStore class])
	{
		if (!_store)
			_store = [[self alloc] init];
        
	}
	
    return _store;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        datamodel                       = [[iEditDataModel alloc] init];
        datamodel.managedObjectContext  = DELEGATE.managedObjectContext;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)customizeNavigationBar
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
//        [[UINavigationBar appearance] setBarTintColor:Top_bar_color];
//        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:87.0/255.0f green:87.0/255.0f blue:87.0/255.0 alpha:1.0]];
    } else
    {
        
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:Image_topTitleBar] forBarMetrics:UIBarMetricsDefault];
//        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor redColor] forKey:UITextAttributeTextColor];
        [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              [UIColor blackColor],UITextAttributeTextColor,
                                                              [UIColor whiteColor], UITextAttributeTextShadowColor,
                                                              [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset, nil]];
        

    }
    
    
    
}


-(void)textFieldDone
{
    
}


-(NSString *)getDuration:(NSString *)mediapath
{
    NSURL *afUrl = [NSURL fileURLWithPath:mediapath];
    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:afUrl options:nil];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds =  CMTimeGetSeconds(audioDuration);
    
    NSUInteger durationInSeconds = floor(audioDurationSeconds);
    NSUInteger durationInMinutes = durationInSeconds / 60;
    NSUInteger durationInRemainder = durationInSeconds % 60;
    
    NSString *finalDurationString = [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long)durationInMinutes, (unsigned long)durationInRemainder];
    
    return finalDurationString;
}

-(UIImage *)scaleAndRotateImaga:(UIImage *)image
{
    int kMaxResolution = 2048; // Or whatever
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1)
        {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else
        {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient)
    {
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else
    {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

- (UIView *)createDemoView:(NSString *)source
{
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 80)];
    
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, 270, 40)];
    textField.returnKeyType = UIReturnKeyDone;
    textField.tag = 111111;
    textField.placeholder = @"Title";
    textField.text=source;
    textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    textField.adjustsFontSizeToFitWidth = TRUE;
    [textField addTarget:self  action:nil
        forControlEvents:UIControlEventEditingDidEndOnExit];
    //CGRectMake(10, 10, 270, 180)
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 , 290, 110)];
    containerView.backgroundColor=PopUpView_Contianer_color;
    containerView.layer.borderColor = PopUpView_Contianer_Bordercolor;
    containerView.layer.borderWidth = 1;
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, textField.bounds.size.height , 270, 1)];
    lineView.backgroundColor = Textfield_Line_color;
    [containerView addSubview:textField];
    [containerView addSubview:lineView];
    
    [demoView addSubview:containerView];
    
    
    
    return demoView;
}



- (UIView *)createPopViewForeditedFile
{
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 80)];
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 270, 40)];
    label.text=@" Save Edited Segment?";
       //CGRectMake(10, 10, 270, 180)
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 , 290, 70)];
    containerView.backgroundColor=PopUpView_Contianer_color;
    containerView.layer.borderColor = PopUpView_Contianer_Bordercolor;
    containerView.layer.borderWidth = 1;
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, 45 , 270, 1)];
    lineView.backgroundColor = Textfield_Line_color;
    [containerView addSubview:label];
    [containerView addSubview:lineView];
    
    [demoView addSubview:containerView];
    
    
    
    return demoView;
}

-(void)showToastMessage :(NSString *)MessageText
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = MessageText;
    hud.margin = 10.f;
    hud.yOffset = 150.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:3];
}




-(void)setRoundedClearBorder:(CALayer *)item withRadius:(CGFloat)cornerRadius {
	CALayer *layer = item;
	layer.masksToBounds = YES;
	layer.cornerRadius = cornerRadius;
	layer.borderWidth = 1.5;
	layer.borderColor = [[UIColor clearColor] CGColor];
}

@end
