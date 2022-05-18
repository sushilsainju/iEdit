//
//  PlaylistViewController.h
//  iEditFast
//
//  Created by SUSHIL on 2/13/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomIOS7AlertView.h"
#import "playlistItemSelectorViewController.h"
#import "editFilesManagementViewController.h"
#import "Playlists.h"
#import "SWTableViewCell.h"



@interface PlaylistViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,CustomIOS7AlertViewDelegate,iEditManageChunksDelegate,NSFetchedResultsControllerDelegate,SWTableViewCellDelegate,UIActionSheetDelegate>


@property (weak, nonatomic) IBOutlet UIView *ContainerView;
@property (weak, nonatomic) IBOutlet UIView *TableViewContainer;
@property (weak, nonatomic) IBOutlet UITableView *PlaylistTableView;

@property (strong,nonatomic) NSString *playlistName;
@property (nonatomic, strong) NSMutableArray *recordingsArray;

@property (nonatomic, retain) iEditDataModel* dataModel;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSString      *entityNameString;
@property (nonatomic, strong) NSPredicate   *fetchPredicate;
@property (nonatomic, strong) NSArray       *sortDescriptorArray;
@property(nonatomic,strong ) Library         *selectedrecording;



@end
