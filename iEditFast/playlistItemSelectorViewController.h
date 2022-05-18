//
//  playlistItemSelectorViewController.h
//  iEditFast
//
//  Created by SUSHIL on 4/30/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iEditDataModel.h"


@protocol iEditPlaylistDelegate <NSObject>
-(void) addplaylist:(NSString *)name withrecordings:(NSArray *) recordings;
-(void) editplaylist:(NSString *)name anddate:(NSDate *)date withrecordings:(NSArray *) recordings;
@end

@interface playlistItemSelectorViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate>
{
    id <iEditPlaylistDelegate> delegate;
}
@property (weak, nonatomic) IBOutlet UIView *ContainerView;
@property (weak, nonatomic) IBOutlet UIView *TableViewContainer;
@property (weak, nonatomic) IBOutlet UITableView *recordingTableView;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSString      *entityNameString;
@property (nonatomic, strong) NSPredicate   *fetchPredicate;
@property (nonatomic, strong) NSArray       *sortDescriptorArray;
@property(nonatomic,strong ) Library         *selectedrecording;
@property(nonatomic,strong ) Library         *selectedPLAYLIST;

@property (unsafe_unretained) id <iEditPlaylistDelegate> delegate;

@property(nonatomic, retain) NSMutableArray *recordingArray;
@property(nonatomic, retain) NSMutableArray *selectedCellsArray;


@property (nonatomic, strong) NSString      *playlistTitle;
@property (nonatomic, strong) NSManagedObjectID        *objId;


@end
