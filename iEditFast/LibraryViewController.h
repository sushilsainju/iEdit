//
//  LibraryViewController.h
//  iEditFast
//
//  Created by SUSHIL on 2/13/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iEditDataModel.h"
#import "SWTableViewCell.h"
#import "CustomIOS7AlertView.h"
#import <DropboxSDK/DropboxSDK.h>
#import "Playlists.h"
#import "playlistItemSelectorViewController.h"
#import "addBookmarksViewController.h"
#import "TreeListTableViewCell.h"
#import "ZipArchive.h"



//@class iEditDataModel;

@class DBRestClient;
@class DBMetadata;
@protocol DropboxBrowserDelegate;

@interface LibraryViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate,SWTableViewCellDelegate,CustomIOS7AlertViewDelegate,DBRestClientDelegate,iEditAddBookmarkDelegate,UIActionSheetDelegate>
{
    DBMetadata *selectedFile;
    
    DBRestClient *restClient;
    UIBackgroundTaskIdentifier backgroundProcess;
    BOOL isLocalFileOverwritten;
    //    DropboxViewController *newSubdirectoryController;
}

@property (weak, nonatomic) IBOutlet UIView *ContainerView;
@property (weak, nonatomic) IBOutlet UIView *TableViewContainer;
@property (weak, nonatomic) IBOutlet UITableView *LibraryTable;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;

//@property (nonatomic, retain) iEditDataModel* dataModel;
@property (nonatomic, strong) NSMutableArray *recordingsArray;
@property (nonatomic, strong) NSMutableArray *recordingNamesArray;


@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSString      *entityNameString;
@property (nonatomic, strong) NSPredicate   *fetchPredicate;
@property (nonatomic, strong) NSSortDescriptor       *sortDescriptor;

@property (nonatomic, strong) NSDate      *playlistDate;


@property (nonatomic,assign) BOOL listingLibrary;
@property (nonatomic,strong ) Library         *selectedrecording;
@property (nonatomic,strong ) Playlists         *selectedPlaylist;
@property (nonatomic, retain) iEditDataModel* dataModel;

//sagar
@property (strong,nonatomic) NSArray *bookmarks;
@property(nonatomic,strong ) BookmarkImages         *containedImage;

@property (nonatomic, weak) NSArray       *playlistFiles;
@property (nonatomic, weak) NSArray       *fileBookmarks;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;
@property (weak, nonatomic) IBOutlet UIButton *addItemsButton;
@property (weak, nonatomic) IBOutlet UIButton *DeleteAllButton;
- (IBAction)deleteAllClicked:(id)sender;
- (IBAction)addItemsClicked:(id)sender;

-(id)initWithplaylist:(Playlists *)playlist;


-(NSString *)getDuration:(NSString *)mediapath;
-(NSString *)namewithoutExtensoin:(NSString *)filename;

@end
//sagar for progress bar height increase
@implementation UIProgressView (customView)
- (CGSize)sizeThatFits:(CGSize)size {
    CGSize newSize = CGSizeMake(self.frame.size.width, 6);
    return newSize;
}
@end


