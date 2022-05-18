//
//  editFilesManagementViewController.h
//  iEditFast
//
//  Created by SUSHIL on 4/8/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import <UIKit/UIKit.h>
# import "FMMoveTableView.h"
#import "FMMoveTableViewCell.h"
#import "JMWhenTapped.h"

@protocol iEditManageChunksDelegate <NSObject>

- (void)manageChunkFiles:(NSArray *)chunkFiles andSaveOption:(NSString *)option;
- (void)ignoreChunkFiles:(NSArray *)chunkFiles;
@end

@interface editFilesManagementViewController : UIViewController <FMMoveTableViewDataSource,FMMoveTableViewDelegate,UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *instructoinLaebl;
@property (nonatomic, strong) NSMutableArray *editFilesArray;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *bothContainerView;
@property (weak, nonatomic) IBOutlet UIView *compositeContainerView;
@property (weak, nonatomic) IBOutlet UIButton *buttonComposite;
@property (weak, nonatomic) IBOutlet UIButton *buttonIndividual;
@property (weak, nonatomic) IBOutlet UIButton *bothButton;
@property (weak, nonatomic) IBOutlet FMMoveTableView *compositeTableView;
@property (weak, nonatomic) IBOutlet FMMoveTableView *bothTableView;

@property (weak, nonatomic) id <iEditManageChunksDelegate> chunksDelegate;


- (IBAction)compositeButtonClicked:(id)sender;
- (IBAction)individualFilesButtonClicked:(id)sender;
- (IBAction)bothButtonClicked:(id)sender;
- (IBAction)savebuttonClicked:(id)sender;
- (IBAction)cancelButtonClicked:(id)sender;


@end
