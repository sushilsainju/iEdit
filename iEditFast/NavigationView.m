//
//  NavigationView.m
//  StraatJutter
//
//  Created by samesh on 22/11/13.
//
//

#import "NavigationView.h"

@implementation NavigationView

@synthesize view;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [[NSBundle mainBundle] loadNibNamed:@"NavigationView" owner:self options:nil];
    [self addSubview:self.view];
}


#pragma mark -
#pragma mark ---------- IBACTION METHODS ----------

-(IBAction)homeButtonClicked:(id)sender {
    [delegate homeButtonClicked];
}

-(IBAction)backButtonClicked:(id)sender {
    [delegate backButtonClicked];
}

-(IBAction)rightNavBarButtonClicked:(id)sender {
    [delegate rightNavBarButtonClicked];
}


@end
