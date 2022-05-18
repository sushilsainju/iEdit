//
//  SearchViewController.h
//  iEditFast
//
//  Created by SUSHIL on 2/13/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Library.h"
#import "SharedStore.h"
#import "BokmarksCell.h"
#import "iEditLibraryCell.h"
#import "BookmarkImages.h"
#import "Bookmarks.h"
#import "bookmarkDetailsViewController.h"
#import "PlayerViewController.h"



@interface SearchViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *searchResultsTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *Searchbar;


//@property (weak, nonatomic) IBOutlet UISearchBar *searchControl;
//@property (weak, nonatomic) IBOutlet UITableView *searchTableView;
@property (weak, nonatomic) IBOutlet UIView *containerView;



@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic,retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSString      *entityNameString;
@property (nonatomic, strong) NSPredicate   *fetchPredicate;
@property (nonatomic, strong) NSSortDescriptor       *sortDescriptor;

@property(nonatomic,strong ) Bookmarks         *selectedBookmark;
@property(nonatomic,strong ) BookmarkImages         *containedImage;

@property (weak, nonatomic) IBOutlet UIView *SegmentContainer;
@property (retain, nonatomic) IBOutlet UISegmentedControl *mySegmentedControl;
@end
