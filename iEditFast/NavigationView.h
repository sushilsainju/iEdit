//
//  NavigationView.h
//  StraatJutter
//
//  Created by samesh on 22/11/13.
//
//

#import <UIKit/UIKit.h>

#define PAGE_TITLE_Republica        @"Republica"
#define PAGE_TITLE_Nagarik          @"नागरिक न्युज"
#define PAGE_TITLE_Settings         @"Settings"

@protocol NavigationViewDelegate <NSObject>
@optional
    -(void)homeButtonClicked;
    -(void)backButtonClicked;
    -(void)rightNavBarButtonClicked;
@end

@interface NavigationView : UIView {
}
// --- IBOutlet OBJECTS ---
@property(strong, nonatomic) IBOutlet UIView    *view;
@property(strong, nonatomic) IBOutlet UILabel   *titleLabel;
@property(strong, nonatomic) IBOutlet UIButton  *homeBUtton;
@property(strong, nonatomic) IBOutlet UIButton  *backButton;
@property(strong, nonatomic) IBOutlet UIButton  *rightNavBarButton;
@property(strong, nonatomic) IBOutlet UIImageView *titleImageView;
// --- DELEGATE OBJECTS ---
@property(nonatomic, assign) id <NavigationViewDelegate> delegate;


//---------  IBACTION METHODS ---------
-(IBAction)homeButtonClicked:(id)sender;
-(IBAction)backButtonClicked:(id)sender;
-(IBAction)rightNavBarButtonClicked:(id)sender;


@end
