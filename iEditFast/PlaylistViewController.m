//
//  PlaylistViewController.m
//  iEditFast
//
//  Created by SUSHIL on 2/13/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import "PlaylistViewController.h"
#import "SharedStore.h"
#import "PlaylistCell.h"
#import "CustomIOS7AlertView.h"
#import "playlistItemSelectorViewController.h"
#import "Library.h"
#import "LibraryViewController.h"
#import "PlaylistItems.h"


@interface PlaylistViewController ()

@end

@implementation PlaylistViewController

@synthesize PlaylistTableView;
@synthesize ContainerView,TableViewContainer;
@synthesize recordingsArray,playlistName,dataModel;
@synthesize entityNameString,fetchedResultsController,fetchPredicate,sortDescriptorArray,selectedrecording;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        // Custom initialization
        dataModel=[[iEditDataModel alloc]init];

        dataModel.managedObjectContext=[DELEGATE managedObjectContext];

    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    [PlaylistTableView registerNib:[UINib nibWithNibName:@"PlaylistCell" bundle:nil] forCellReuseIdentifier:@"MyCustomCell"];

    [[SharedStore store] customizeNavigationBar];
    [self customizeView];

    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	NSLog(@"FRC %@", fetchedResultsController);
    [PlaylistTableView reloadData];
}


-(void)viewWillDisappear:(BOOL)animated
{
//    self.fetchedResultsController=nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark CUSTOM METHODS

-(void)customizeView
{
    
    CGRect frame;
    frame = ContainerView.frame;
    frame.size.height = ScreenSize.height-StatusbarFrame.size.height-NavigationbarFrame.size.height+IOS_Delta;
    
    [ContainerView setFrame:frame];
 
    CGRect tableViewFrame = self.PlaylistTableView.frame;
    tableViewFrame.size.height = ContainerView.frame.size.height-PlaylistTableView.frame.origin.y-TABBAR_Frame.size.height;
    self.PlaylistTableView.frame = tableViewFrame;
   
    // set custom back button
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *addBtnImage = [UIImage imageNamed:@"ICN_add"]  ;
    [addBtn setBackgroundImage:addBtnImage forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(addPlaylistButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    addBtn.frame = CGRectMake(0, 0, 30, 30);
    addBtn.imageEdgeInsets = UIEdgeInsetsMake(0,5, 0, -10);
    UIBarButtonItem *addPlaylistButton = [[UIBarButtonItem alloc] initWithCustomView:addBtn] ;
    
    self.navigationItem.leftBarButtonItem = addPlaylistButton;
    
    UIButton *deleteAllButton = [[UIButton alloc] init];
    deleteAllButton.frame=CGRectMake(0,0,30,30);
    [deleteAllButton setBackgroundImage:[UIImage imageNamed: @"NAV_delete.png"] forState:UIControlStateNormal];
    [deleteAllButton addTarget:self action:@selector(showPopUpbeforDeletion) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:deleteAllButton];
}

-(void)showPopUpbeforDeletion
{
    
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Delete all playlists"
                                                    otherButtonTitles:nil];
    
    
    [actionSheet showInView:DELEGATE.window];
}


#pragma mark actoinsheet delegates

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex==actionSheet.cancelButtonIndex)
    {
        NSLog(@"Cancelled button pressed %ld",(long)buttonIndex);
    }
    else
    {
        if (buttonIndex==0)
        {
            [self deleteAllPlaylists];
        }
        
        
        
    }
}


-(void)deleteAllPlaylists
{
    for (Playlists *bookmark in [self.fetchedResultsController fetchedObjects]) {
        [DELEGATE.managedObjectContext deleteObject:bookmark];
        NSError *error = nil;
            if (![DELEGATE.managedObjectContext save:&error])
              {
                   // handle error
                  UIAlertView *removeSuccessFulAlert=[[UIAlertView alloc]initWithTitle:@"iEditSmart" message:@"Can not delete playlists at the moment. Please try again later." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                  [removeSuccessFulAlert show];
              }
    }
    [PlaylistTableView reloadData];
//    for (UITableViewCell *cell in self.PlaylistTableView.visibleCells)
//    {
//        NSIndexPath  *selectedIndexPath = [self.PlaylistTableView indexPathForCell:cell];
//        
//        
//        [DELEGATE.managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:selectedIndexPath]];
//        
//        NSError *error = nil;
//        if (![DELEGATE.managedObjectContext save:&error])
//        {
//            // handle error
//        }
//    }
}

#pragma mark -

    
-(void)addPlaylistButtonClicked
{
    // Here we need to pass a full frame
    CustomIOS7AlertView *alertView = [[CustomIOS7AlertView alloc] init];
    
    // Add some custom content to the alert view
    [alertView setContainerView:[[SharedStore store] createDemoView:@""]];

    
    // Modify the parameters
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Cancel",@"Save", nil]];
    [alertView setDelegate:self];
    
    // You may use a Block, rather than a delegate.
    [alertView setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex)
     {

        [alertView close];
    }];
    
    [alertView setUseMotionEffects:true];
    
    // And launch the dialog
    [alertView show];
}
                                            
#pragma mark -

#pragma mark CUSTOM ALERTVIE METHODS



- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    NSLog(@"Delegate: Button at position %ld is clicked on alertView %ld.", (long)buttonIndex, (long)[alertView tag]);
    if (buttonIndex==1)
    {
        UITextField *nameField = (UITextField *)[alertView viewWithTag:111111];
        playlistName=nameField.text;
        if (playlistName.length==0)
        {
            playlistName=[@"PlayList " stringByAppendingString:[self dateString]];
            
            
        }
      
        playlistItemSelectorViewController *listController=[[playlistItemSelectorViewController alloc]initWithNibName:@"playlistItemSelectorViewController" bundle:nil];
        listController.hidesBottomBarWhenPushed = YES;
        listController.playlistTitle=playlistName;
        listController.delegate=self;
        
        UINavigationController *nav = [[UINavigationController alloc]
                                       initWithRootViewController:listController];
        [self presentViewController:nav animated:YES completion:NULL];
        
        [alertView close];
       
    }
}

#pragma mark -

- (NSString *) dateString
{
    // return a formatted string for a file name
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMddHHmm";
    return [formatter stringFromDate:[NSDate date]] ;
    
}
#pragma mark Playlist Delegate Methods


-(void) addplaylist:(NSString *)name withrecordings:(NSArray *) recordings
{
    NSLog(@"selected %@",recordings);
    
    Playlists *newPlaylist= [dataModel createPlaylist:playlistName withRecordings:recordings];
    [dataModel PlaylistDetails:newPlaylist withRecordings:recordings];

}

#pragma mark -


#pragma mark UITableView Datasource/Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id  sectionInfo =[[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellheight = 48;
    
    return cellheight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MyCustomCell";
    
    PlaylistCell *cell = [PlaylistTableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    PlaylistCell __weak *weakCell = cell;
    
    [cell setAppearanceWithBlock:^{
        weakCell.rightUtilityButtons = [self rightButtons];
        weakCell.delegate = self;
        weakCell.containingTableView = tableView;
    } force:NO];
    
    [cell setCellHeight:cell.frame.size.height];
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;


}


- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
  
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                 icon:[UIImage imageNamed: @"delete_white.png"]];
    return rightUtilityButtons;
}
-(void)configureCell:(PlaylistCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Playlists *playlist=[fetchedResultsController objectAtIndexPath:indexPath];
    NSString* theFileName = playlist.name;
    cell.playlistName.text=theFileName;
    PlaylistTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)tableView: (UITableView*)tableView willDisplayCell: (UITableViewCell*)cell forRowAtIndexPath: (NSIndexPath*)indexPath
{
    
    if(indexPath.row % 2 == 0)
        cell.backgroundColor = Color_Grey_06;
    else
        cell.backgroundColor = [UIColor whiteColor];
}

-(void)refreshCellAtIndexPath:(NSIndexPath *)indexPath {
    PlaylistCell *cell  = (PlaylistCell*)[PlaylistTableView cellForRowAtIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    NSMutableArray *filesInPlaylist=[[NSMutableArray alloc]init];

    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:indexPath.section];
    Playlists *selectedPL=[[sectionInfo objects ] objectAtIndex:indexPath.row];

    LibraryViewController *library=[[LibraryViewController alloc]initWithplaylist:selectedPL ];
    [self.navigationController pushViewController:library animated:YES];
    NSLog(@"playlist objexts %@",[selectedPL containsRecordings]);
//    filesInPlaylist=[dataModel getPlaylistItems:selectedPL];
//    NSSet *recs=selectedPL.
////    NSLog(@"conteined Recs %@",recs);
////    NSLog(@"zzz %@",[recs allObjects]);
//    NSArray *files=[recs allObjects];
////    NSLog(@"zzz %@",[files objectAtIndex:0]);
//    for (id recordings in files) {
//        Library *rec=recordings;
//        [filesInPlaylist addObject:rec.filename];
//
//    }
//    NSLog(@"rec %@",filesInPlaylist);
    


}

-(CGFloat)heightForLabelAtIndex:(NSInteger)rowIndex {
   
    
    return 30;
}

-(CGFloat)heightForCellAtIndex:(NSInteger)rowIndex {
  
    return 30;
}

#pragma mark -


#pragma mark NSFetchResultsController Methods
- (NSFetchedResultsController *)fetchedResultsController
{
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Playlists" inManagedObjectContext:DELEGATE.managedObjectContext ];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"createdDate" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:DELEGATE.managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:@"Root"];
    self.fetchedResultsController = theFetchedResultsController;
    fetchedResultsController.delegate = self;
    
    return fetchedResultsController;
}

#pragma mark ~
#pragma mark NSFetchResultsController Delegate Methods
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [PlaylistTableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = PlaylistTableView;
    [tableView beginUpdates];
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(PlaylistCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath ];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
            
    }
    [recordingsArray removeAllObjects];
//    [recordingNamesArray removeAllObjects];
    [tableView endUpdates];
    
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [PlaylistTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [PlaylistTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
    
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    
    [PlaylistTableView endUpdates];
    
}

#pragma mark - SWTableViewDelegate



- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    NSIndexPath *cellIndexPath = [PlaylistTableView indexPathForCell:cell];
    
    selectedrecording=[fetchedResultsController objectAtIndexPath:cellIndexPath];
    switch (index)
    {
        case 0:
        {
                      // Delete button was pressed
                   NSIndexPath *selectedIndexPath = [PlaylistTableView indexPathForCell:cell];
          
                  [DELEGATE.managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:selectedIndexPath]];
        
                    NSError *error = nil;
                    if (![DELEGATE.managedObjectContext save:&error])
                    {
                         // handle error
                   }
        
         
                                       break;
        }
        case 1:
        {
//
        }
        default:
            break;
    }
}


- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell {
    return YES;
}



@end
