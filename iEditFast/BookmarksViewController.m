//
//  BookmarksViewController.m
//  iEditFast
//
//  Created by SUSHIL on 2/13/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import "BookmarksViewController.h"
#import "SharedStore.h"
#import "BokmarksCell.h"
#import "SWTableViewCell.h"
#import "bookmarkDetailsViewController.h"
#import "UIImage+Resize.h"
#import "UIImage+Resize.h"


@interface BookmarksViewController ()

@end

@implementation BookmarksViewController

@synthesize BookmarksTableView;
@synthesize ContainerView,TableViewContainer;
@synthesize bookmarkArray,bookmarkNamesArray;
@synthesize fetchedResultsController=_fetchedResultsController;
@synthesize entityNameString,fetchPredicate,sortDescriptorArray;
@synthesize selectedBookmark;

#define cellheight 85

NSIndexPath *selectedIndexPath;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        fetchPredicate      = [[NSPredicate alloc]  init];
        sortDescriptorArray = [[NSArray alloc]      init];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
   [[SharedStore store] customizeNavigationBar];
    [self.BookmarksTableView registerNib:[UINib nibWithNibName:@"BookmarksCell" bundle:nil] forCellReuseIdentifier:@"MyCustomCell"];

    [self customizeView];
    
    bookmarkNamesArray= [[NSMutableArray alloc]init];
    bookmarkArray=[[NSMutableArray alloc]init];
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
	NSLog(@"FRC %@", _fetchedResultsController);
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:NO];
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
   
    CGRect tableViewFrame = self.BookmarksTableView.frame;
    tableViewFrame.size.height = ContainerView.frame.size.height-BookmarksTableView.frame.origin.y-TABBAR_Frame.size.height;
    self.BookmarksTableView.frame = tableViewFrame;
    [self customizeNavigationBar];
    
}

-(void)customizeNavigationBar
{
    UIButton *deleteAllButton = [[UIButton alloc] init];
    deleteAllButton.frame=CGRectMake(0,0,30,30);
    [deleteAllButton setBackgroundImage:[UIImage imageNamed: @"NAV_delete.png"] forState:UIControlStateNormal];
    [deleteAllButton addTarget:self action:@selector(deleteAllBookmarksClicked) forControlEvents:UIControlEventTouchUpInside];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:deleteAllButton];

}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
//    [rightUtilityButtons sw_addUtilityButtonWithColor:
//     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
//                                                 icon:[UIImage imageNamed: @"rename"]];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                 icon:[UIImage imageNamed: @"delete_white.png"]];
    return rightUtilityButtons;
}

-(void)promptRenameBookmark:(NSString *)name
{
    // Here we need to pass a full frame
    CustomIOS7AlertView *alertView = [[CustomIOS7AlertView alloc] init];
    
    // Add some custom content to the alert view
    [alertView setContainerView:[[SharedStore store] createDemoView:name]];
    
    
    // Modify the parameters
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Cancel",@"Save", nil]];
    [alertView setDelegate:self];
    
    
    [alertView setUseMotionEffects:true];
    
    // And launch the dialog
    [alertView show];
}

-(void )deleteAllBookmarksClicked
{
    
    [self showPopUpbeforDeletion];
}

-(void)deleteAllBookmarks
{
    
    for (Bookmarks *bookmark in [self.fetchedResultsController fetchedObjects]) {
        [DELEGATE.managedObjectContext deleteObject:bookmark];
        NSError *error = nil;
        if (![DELEGATE.managedObjectContext save:&error])
        {
            // handle error
            UIAlertView *removeSuccessFulAlert=[[UIAlertView alloc]initWithTitle:@"iEditSmart" message:@"Can not delete bookmarks at the moment. Please try again later." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [removeSuccessFulAlert show];
        }
    }
    [BookmarksTableView reloadData];
//    for (UITableViewCell *cell in self.BookmarksTableView.visibleCells)
//    {
//        NSIndexPath  *selectedIndexPath = [self.BookmarksTableView indexPathForCell:cell];
//    
//    
//    [DELEGATE.managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:selectedIndexPath]];
//    
//    NSError *error = nil;
//    if (![DELEGATE.managedObjectContext save:&error])
//    {
//        // handle error
//    }
//    }
}

-(void)showPopUpbeforDeletion
{
    
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Delete all Bookmarks"
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
            [self deleteAllBookmarks];
        }
        
        
        
    }
}


#pragma mark -



#pragma mark UITableView Datasource/Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id  sectionInfo =[[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    CGFloat cellheight = 80;
    
    return cellheight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    ///CUSTOM CELL TO ADD TWO UTILITY BUTTONS ON SWIPE RIGHT
    static NSString *cellIdentifier = @"MyCustomCell";
    
    BokmarksCell *cell = [self.BookmarksTableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    BokmarksCell __weak *weakCell = cell;
    
    [cell setAppearanceWithBlock:^{
        weakCell.rightUtilityButtons = [self rightButtons];
        weakCell.delegate = self;
        weakCell.containingTableView = tableView;
    } force:NO];
    
    [cell setCellHeight:cell.frame.size.height];
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

-(void)configureCell:(BokmarksCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    Bookmarks *bookmark=[_fetchedResultsController objectAtIndexPath:indexPath];
    CGRect imageframe;
    imageframe = cell.imageView.frame;
    CGRect TitleFrame = cell.bookmarkTitle.frame;
    CGRect TextFrame = cell.bookmarkText.frame;

    
    if(bookmark.hasImage)
    {
//        NSLog(@"bookmark Details %@",[bookmark.hasImage allObjects]);
        NSArray *images=[bookmark.hasImage allObjects];
        if (images.count>0)
        {
            cell.bookmarkImage.hidden=NO;
            self.containedImage=[images objectAtIndex:0];
            imageframe.size.height=65;
            imageframe.origin.x=246;
            imageframe.origin.y=6;
            imageframe.size.width = imageframe.size.height;
            TitleFrame.size.width=cell.containerView.frame.size.width-imageframe.size.width-16;
            UIImage* image = [UIImage imageWithContentsOfFile:self.containedImage.filepath];
            UIImage *orientedImage= [[SharedStore store]scaleAndRotateImaga:image];

            [cell.bookmarkImage setImage:orientedImage];
            
            cell.bookmarkImage.layer.cornerRadius=5;
            cell.bookmarkImage.layer.masksToBounds=YES;
        }
        else
        {
            imageframe.size.width=0;

            cell.bookmarkImage.hidden=YES;
            TitleFrame.size.width=cell.containerView.frame.size.width-imageframe.size.width-16;
            NSLog(@"continer width %f and %f",cell.containerView.frame.size.width,cell.bookmarkTitle.frame.size.width);


        }
        
        cell.bookmarkTitle.text =bookmark.name;
        cell.bookmarkText.text=bookmark.text;
        
        CGSize maximumLabelSize = CGSizeMake(304,60);
        //    CGSize minimumLabelSize=CGSizeMake(280, 40);
        
        // use font information from the UILabel to calculate the size
        CGSize expectedLabelSize = [bookmark.name sizeWithFont:cell.bookmarkTitle.font constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];
        
        // create a frame that is filled with the UILabel frame data
        
        TitleFrame.size.height = expectedLabelSize.height;
        if (TitleFrame.size.height<23) {
            TitleFrame.size.height=23;
        }
        
        TextFrame.size.height=cellheight-18-TitleFrame.size.height;
        TextFrame.size.width=TitleFrame.size.width;
        TextFrame.origin.y=TitleFrame.origin.y+TitleFrame.size.height;
        
    
        [cell.bookmarkImage setFrame:imageframe];
        [cell.bookmarkTitle setFrame:TitleFrame];
        [cell.bookmarkText setFrame:TextFrame];
        
        cell.bookmarkText.numberOfLines=2;
        [cell.bookmarkText sizeToFit];

    }

    
    self.BookmarksTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    

    
}

- (void)tableView: (UITableView*)tableView willDisplayCell: (UITableViewCell*)cell forRowAtIndexPath: (NSIndexPath*)indexPath
{
    
    if(indexPath.row % 2 == 0)
        cell.backgroundColor = Color_Grey_06;
    else
        cell.backgroundColor = [UIColor whiteColor];
}

-(void)refreshCellAtIndexPath:(NSIndexPath *)indexPath {
    BokmarksCell *cell  = (BokmarksCell*)[BookmarksTableView cellForRowAtIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
      id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:indexPath.section];
    bookmarkDetailsViewController *details=[[bookmarkDetailsViewController alloc]initWithNibName:@"bookmarkDetailsViewController" bundle:nil];
    details.hidesBottomBarWhenPushed = YES;
   
    UINavigationController *nav = [[UINavigationController alloc]
                                   initWithRootViewController:details];
    NSLog(@"selected %ld",(long)indexPath.row);
    NSArray *allBookmarks=[sectionInfo objects];
    details.selectedBookmark=[allBookmarks objectAtIndex:indexPath.row ];
    [self presentViewController:nav animated:YES completion:NULL];
}

-(CGFloat)heightForLabelAtIndex:(NSInteger)rowIndex {
    
    return 30;
}

-(CGFloat)heightForCellAtIndex:(NSInteger)rowIndex {
        return 30;
}

#pragma mark -

#pragma mark NSFetchResultsController Methods
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Bookmarks" inManagedObjectContext:DELEGATE.managedObjectContext ];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"date" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:DELEGATE.managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:nil];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;}

#pragma mark ~
#pragma mark NSFetchResultsController Delegate Methods
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.BookmarksTableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.BookmarksTableView;
    [tableView beginUpdates];
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(BokmarksCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath ];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
            
    }
    [bookmarkArray removeAllObjects];
    [bookmarkNamesArray removeAllObjects];
    [tableView endUpdates];
    
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.BookmarksTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.BookmarksTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
    
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    
    [self.BookmarksTableView endUpdates];
    
}

#pragma mark - SWTableViewDelegate



- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    NSIndexPath *cellIndexPath = [self.BookmarksTableView indexPathForCell:cell];
    
    selectedBookmark=[_fetchedResultsController objectAtIndexPath:cellIndexPath];
//    NSString *mediaPath=selectedBookmark.name
    switch (index)
    {
        case 0:
        {
            /*selectedBookmark=[_fetchedResultsController objectAtIndexPath:cellIndexPath];
            NSString *nametoShow=selectedBookmark.name;
          
            
            [self promptRenameBookmark:nametoShow];
            [cell hideUtilityButtonsAnimated:YES];
            break;*/
            selectedIndexPath = [self.BookmarksTableView indexPathForCell:cell];
            
            
            [DELEGATE.managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:selectedIndexPath]];
            //sagar remove image in the document directory when bookmark is removed
            
            [[NSFileManager defaultManager] removeItemAtPath:self.containedImage.filepath error:nil];
            
            NSError *error = nil;
            if (![DELEGATE.managedObjectContext save:&error])
            {
                // handle error
            }
        }
        case 1:
        {
            // Delete button was pressed
            
            
            

        }
        default:
            break;
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell {
    return YES;
}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    NSString *bookmarkTitle;
    if(buttonIndex==0)
    {
        //        [self discardFile];
        [alertView close];
    }
    else if(buttonIndex==1)
    {
        UITextField *nameField = (UITextField *)[alertView viewWithTag:111111];
        bookmarkTitle=nameField.text;
        if (bookmarkTitle.length>0)
        {
            //            [self saveFileToLibrary];
            if (selectedBookmark)
            {
                selectedBookmark.name=bookmarkTitle;
                NSError *error = nil;
                if (![DELEGATE.managedObjectContext save:&error])
                {
                }
            }
            [alertView close];
            
            
        }
        else
        {
            UIAlertView *removeSuccessFulAlert=[[UIAlertView alloc]initWithTitle:@"iEditSmart" message:@"Please Enter Title For Bookmark" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
            [removeSuccessFulAlert show];
        }
        
    }
    
}

@end
