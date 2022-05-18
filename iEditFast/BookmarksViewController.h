//
//  BookmarksViewController.h
//  iEditFast
//
//  Created by SUSHIL on 2/13/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"
#import "CustomIOS7AlertView.h"
#import "iEditDataModel.h"
#import "Bookmarks.h"
#import "BookmarkImages.h"


@interface BookmarksViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate,SWTableViewCellDelegate,CustomIOS7AlertViewDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>


@property (weak, nonatomic) IBOutlet UIView *ContainerView;
@property (weak, nonatomic) IBOutlet UIView *TableViewContainer;
@property (weak, nonatomic) IBOutlet UITableView *BookmarksTableView;

@property (nonatomic, strong) NSMutableArray *bookmarkArray;
@property (nonatomic, strong) NSMutableArray *bookmarkNamesArray;


@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSString      *entityNameString;
@property (nonatomic, strong) NSPredicate   *fetchPredicate;
@property (nonatomic, strong) NSArray       *sortDescriptorArray;
@property(nonatomic,strong ) Bookmarks         *selectedBookmark;
@property(nonatomic,strong ) BookmarkImages         *containedImage;



@end
