//
//  OverlayView.m
//  SchoolCalendar
//
//  Created by Bala Bhadra Maharjan on 7/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "OverlayView.h"
#import "SharedStore.h"

@implementation OverlayView

@synthesize isActive;
@synthesize color, opacity, animDuration;
@synthesize headerText, footerText;

-(id)initWithFrame:(CGRect)frame{
	isActive = NO;
	return [self initWithFrame:frame opacity:1.0 color:[UIColor greenColor] animDuration:0.5];
}

-(id)initWithFrame:(CGRect)frame opacity:(CGFloat)anOpacity color:(UIColor *)aColor animDuration:(CGFloat)duration{
	if((self = [super initWithFrame:frame])){
		self.opaque = NO;
		self.color = aColor;
		self.backgroundColor = self.color;
//		self.backgroundColor = [UIColor clearColor];
		self.opacity = anOpacity;
		self.animDuration = duration;
		isActive = NO;
	}
	return self;
}

-(void)showInView:(UIView *)parentView withActivityIndicator:(BOOL)indicator{
	isActive = YES;
	[self retain];
	self.alpha = 0;
	[parentView addSubview:self];
    [self setBackgroundColor:[UIColor colorWithWhite:0.5 alpha:0.4]];

//    [parentView sendSubviewToBack:self];

    //ADD ROUNDED BLOCK BG
    UIView *blockView = [[[UIView alloc] initWithFrame:CGRectMake(40, (parentView.frame.size.height - 132)/2, 239, 132)] autorelease];
    [blockView setFrame:CGRectMake(40, (parentView.frame.size.height - 132)/2, 239, 132)];
//    [blockView setCenter:parentView.center];
    [blockView setCenter:self.center];
    [blockView setBackgroundColor:[UIColor colorWithWhite:0.96 alpha:1.0]];
    [[SharedStore store] setRoundedClearBorder:blockView.layer withRadius:5.0];

	if(indicator && [[self subviews] count] == 0){
		UIActivityIndicatorView *indicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
		indicator.center = CGPointMake(blockView.frame.origin.x + blockView.frame.size.width/2, blockView.frame.origin.y + blockView.frame.size.height/2);
		indicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
        [self addSubview:indicator];
        
		[indicator startAnimating];
	}

    UILabel *headerLabel = [[[UILabel alloc] init] autorelease];
    headerLabel.frame =  CGRectMake(blockView.frame.origin.x + 5, blockView.frame.origin.y + 16, 230, 20);
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor blackColor];
    headerLabel.font = [UIFont systemFontOfSize:15];
    headerLabel.adjustsFontSizeToFitWidth = YES;
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.text = headerText;
    [self addSubview:headerLabel];

    UILabel *footerLabel = [[[UILabel alloc] init] autorelease];
    footerLabel.frame =  CGRectMake(blockView.frame.origin.x + 5, blockView.frame.origin.y + 92, 230, 20);
    footerLabel.backgroundColor = [UIColor clearColor];
    footerLabel.textColor = [UIColor darkGrayColor];
    footerLabel.font = [UIFont systemFontOfSize:15];
    footerLabel.textAlignment = NSTextAlignmentCenter;
    footerLabel.text = footerText;
    [self addSubview:footerLabel];

    [self addSubview:blockView];
    [self sendSubviewToBack:blockView];

    
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animDuration];

	self.alpha = opacity;
	[UIView commitAnimations];
}

-(void)hide{
	isActive = NO;
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animDuration];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(finishedFadeOut:finished:context:)];
    self.alpha = 0.0;
    [UIView commitAnimations];
}

-(void)finishedFadeOut:(NSString*)animationID finished:(BOOL)finished context:(void*)context{
	[self removeFromSuperview];
	[self release];
}

-(void)setColor:(UIColor *)aColor{
	[aColor retain]; 
	[color release];
	color = aColor;
	self.backgroundColor = color;
}

-(void)setOpacity:(CGFloat)anOpacity{
	opacity = anOpacity;
	self.alpha = opacity;
}

-(void)dealloc{
	[color release];
	[super dealloc];
}

@end
