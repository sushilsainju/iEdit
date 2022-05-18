//
//  SearchViewController.m
//  iEditFast
//
//  Created by SUSHIL on 2/13/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import "SearchViewController.h"
#import "SharedStore.h"


#define Librarycellheight 45
#define Bookmarkscellheight 80



@interface SearchViewController ()
@property (assign, nonatomic) searchFor searchEntity;

@end



@implementation SearchViewController
@synthesize mySegmentedControl;
@synthesize containerView,SegmentContainer;
@synthesize searchEntity;
@synthesize fetchedResultsController,fetchPredicate,sortDescriptor,entityNameString;
@synthesize Searchbar,searchResultsTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    [[SharedStore store] customizeNavigationBar];
    [self customizeView];
    
    [searchResultsTableView registerNib:[UINib nibWithNibName:@"BookmarksCell" bundle:nil] forCellReuseIdentifier:@"BookmarkCell"];
    [searchResultsTableView registerNib:[UINib nibWithNibName:@"iEditLibraryCell" bundle:nil] forCellReuseIdentifier:@"LibraryCell"];

//    [searchTableView setAllowsSelection:YES];
//    [self.searchTableView setDelegate:self];
    
//    [self.searchTableView setDataSource:self];    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(IBAction)SegmentToggle:(UISegmentedControl*)sender {
//    if (sender.selectedSegmentIndex==0) {
//        NSLog(@"one");
//    }
//    else {
//        NSLog(@"two");
//    }
//}


#pragma mark CUSTOM METHODS

-(void)customizeView {
    
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    
    CGRect frame;
    frame = containerView.frame;
    frame.size.height = ScreenSize.height-StatusbarFrame.size.height-NavigationbarFrame.size.height+IOS_Delta;
    frame.origin.y=containerView.frame.origin.y;//+IOS_Delta;
    
    [containerView setFrame:frame];
    
    //    if(listingLibrary)
    //    {
    //
    //    }
    
    
    CGRect segmentFrame = SegmentContainer.frame;
    segmentFrame.origin.y=IOS_Delta;// containerView.frame.origin.y;
    segmentFrame.size.height=50;;

    SegmentContainer.frame=segmentFrame;
    
    CGRect searcBarFrame=Searchbar.frame;
    searcBarFrame.origin.y=IOS_Delta;
    Searchbar.frame=searcBarFrame;
    
    NSArray *buttonNames = [NSArray arrayWithObjects:
                            @"Recordings", @"Bookmarks", nil];
    UISegmentedControl* segmentedControl = [[UISegmentedControl alloc]
                                            initWithItems:buttonNames];
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
//    segmentedControl.momentary = YES;
    segmentedControl.backgroundColor=[UIColor whiteColor];
    segmentedControl.tintColor=[UIColor lightGrayColor];
//    segmentedControl
    segmentedControl.selectedSegmentIndex=0;
    [segmentedControl addTarget:self action:@selector(segmentAction:)
               forControlEvents:UIControlEventValueChanged];
    
    // Add it to the navigation bar
    self.navigationItem.titleView = segmentedControl;
    
    CGRect tableFrame=searchResultsTableView.frame;
    tableFrame.origin.y=searcBarFrame.origin.y+searcBarFrame.size.height;
    tableFrame.size.height=containerView.frame.size.height-searcBarFrame.size.height;
    searchResultsTableView.frame=tableFrame;
    entityNameString=@"Library";
    
}



#pragma mark IBACTION METHODS

- (IBAction)ControlChanged:(id)sender
{
    if(sender  ==0){
        NSLog(@"One");
    } else {
       
    }
}

-(void) segmentAction: (UISegmentedControl *) segmentedControl
{
    // Update the label with the segment number
    NSString *segmentNumber = [NSString stringWithFormat:@"%0ldd",
                               segmentedControl.selectedSegmentIndex + 1];
    if (segmentedControl.selectedSegmentIndex==0)
    {
        searchEntity=searchRecording;
        entityNameString=@"Library";
        fetchPredicate=nil;
        sortDescriptor=[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    }
    else
    {
        searchEntity=searchBookmarks;
        entityNameString=@"Bookmarks";
        fetchPredicate=nil;
        sortDescriptor=[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
        
    }
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:entityNameString inManagedObjectContext:DELEGATE.managedObjectContext ];
    [[fetchedResultsController fetchRequest]setEntity:entity];
    [[fetchedResultsController fetchRequest]setPredicate:fetchPredicate];
    [[fetchedResultsController fetchRequest]setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSLog(@"index %@",segmentNumber);
    
    [self performFetch];
}


#pragma mark ---------- UISEARCHBAR DELEGATE METHODS ----------

- (void)searchBarTextDidBeginEditing:(UISearchBar *)aSearchBar{
	[Searchbar setShowsCancelButton:YES animated:YES];
}

- (void)searchBar:(UISearchBar *)aSearchBar textDidChange:(NSString *)searchText{
	[self performFetch];
    
	
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSFetchRequest *aRequest = [[self fetchedResultsController] fetchRequest];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"album_name BEGINSWITH[cd] %@",searchText];
    
    [aRequest setPredicate:predicate];
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
}


-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [Searchbar resignFirstResponder];
	[Searchbar setShowsCancelButton:NO animated:YES];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self performFetch ];
    [Searchbar resignFirstResponder];

}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [Searchbar resignFirstResponder];

}

-(void)performFetch
{
    NSError *error;
    if (Searchbar.text.length==0) {
        fetchPredicate=nil;
    }
    else
    {
        if (searchEntity==searchBookmarks)
        {
            fetchPredicate = [NSPredicate predicateWithFormat:@" text CONTAINS[c]  %@ ", Searchbar.text];

        }
        else
        fetchPredicate = [NSPredicate predicateWithFormat:@"filename BEGINSWITH[c] %@ ", Searchbar.text];
    }
    [[fetchedResultsController fetchRequest]setPredicate:fetchPredicate];
	if (![[self fetchedResultsController] performFetch:&error])
    {
		NSLog(@"Error in search %@, %@", error, [error userInfo]);
	}
    else
    {
        [searchResultsTableView reloadData];
    }
   
}


#pragma mark UITableView Datasource/Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id  sectionInfo =[[fetchedResultsController sections] objectAtIndex:section];
    NSLog(@"rows %lu",(unsigned long)[sectionInfo numberOfObjects]);

    return [sectionInfo numberOfObjects];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (searchEntity==searchBookmarks) {
        return Bookmarkscellheight;
    }
    else
        return Librarycellheight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    if (searchEntity==searchBookmarks)
//    {
//    static NSString *cellMainNibID = @"BookmarkCell";
//    
//    BokmarksCell *cell = (BokmarksCell *)[searchResultsTableView dequeueReusableCellWithIdentifier:cellMainNibID];
//    if (cell == nil)
//    {
//		NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"BookmarksCell" owner:nil options:nil];
//		for (id currentObject in topLevelObjects) {
//			if([currentObject isKindOfClass:[UITableViewCell class]])
//            
//            {
//				cell = (BokmarksCell *) currentObject;
//                cell.detailTextLabel.text=@"sdsads";
//
//			}
//		}
//    }
//    
//        cell.detailTextLabel.text=@"sdsads";
//    [self configureBookmarkCell:cell atIndexPath:indexPath];
//    
//    return cell;
//
//
//    }
//    else
//    {
//        
//        static NSString *cellIdentifier = @"LibraryCell";
//        
//        iEditLibraryCell *cell = [self.searchResultsTableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
//        
//        iEditLibraryCell __weak *weakCell = cell;
//        
//        
//        [cell setCellHeight:cell.frame.size.height];
//        
//        [self configureLibraryCell:cell atIndexPath:indexPath];
//        return cell;
//        
//
//    }
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [searchResultsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    [self configureCell:cell atIndexPath:indexPath];
    cell.textLabel.frame = CGRectMake(10, 20, 100,22);
    return cell;
   
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:10];
    cell.textLabel.frame = CGRectMake(10, 20, 100,22);
    cell.detailTextLabel.frame = CGRectMake(10, 20, 200,22);
    cell.textLabel.textColor=[UIColor lightGrayColor];
    cell.detailTextLabel.textColor=[UIColor lightGrayColor];
    if(indexPath.row % 2 == 0)
        cell.backgroundColor = Color_Grey_06;
    else
        cell.backgroundColor = [UIColor whiteColor];
    
}

- (NSString *) dateString:(NSDate *)dates
{
    // return a formatted string for a file name
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"dd/MM/YYYY";
    return [formatter stringFromDate:dates] ;
    
}

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if(searchEntity==searchBookmarks)
    {
        Bookmarks *bookmark=[fetchedResultsController objectAtIndexPath:indexPath];
        cell.textLabel.text=bookmark.name;
        cell.detailTextLabel.text=[self dateString:bookmark.date];// bookmark.date;

    }
    else
    {
//        LibraryViewController *library;
        Library *recording=[fetchedResultsController objectAtIndexPath:indexPath];
//        NSString *duration= [ library getDuration:recording.filepath];
        NSString* theFileName = [recording.filepath lastPathComponent] ;
//        NSString *nametoShow=[library namewithoutExtensoin:recording.filename];
        cell.textLabel.text=theFileName;
        cell.detailTextLabel.text=[self dateString:recording.date];
        searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    //    [recordingsArray addObject:theFileName];
    //    [recordingNamesArray addObject:nametoShow];
    
}

-(void)configureLibraryCell:(iEditLibraryCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    LibraryViewController *library;
    Library *recording=[fetchedResultsController objectAtIndexPath:indexPath];
    NSString *duration= [ library getDuration:recording.filepath];
    NSString* theFileName = [recording.filepath lastPathComponent] ;
//    NSString *nametoShow=[library namewithoutExtensoin:recording.filename];
    cell.title.text =theFileName;
    cell.textLabel.text=theFileName;
    cell.duration.text=duration;
    searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    [recordingsArray addObject:theFileName];
//    [recordingNamesArray addObject:nametoShow];
    
}



-(void)configureBookmarkCell:(BokmarksCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    Bookmarks *bookmark=[fetchedResultsController objectAtIndexPath:indexPath];
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
            [cell.bookmarkImage setImage:image];
            
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
        cell.textLabel.text=bookmark.name;
        CGSize maximumLabelSize = CGSizeMake(304,60);
        //    CGSize minimumLabelSize=CGSizeMake(280, 40);
        
        // use font information from the UILabel to calculate the size
        CGSize expectedLabelSize = [bookmark.name sizeWithFont:cell.bookmarkTitle.font constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];
        
        // create a frame that is filled with the UILabel frame data
        
        TitleFrame.size.height = expectedLabelSize.height;
        if (TitleFrame.size.height<23) {
            TitleFrame.size.height=23;
        }
        
        TextFrame.size.height=Bookmarkscellheight-18-TitleFrame.size.height;
        TextFrame.size.width=TitleFrame.size.width;
        TextFrame.origin.y=TitleFrame.origin.y+TitleFrame.size.height;
        
        
        [cell.bookmarkImage setFrame:imageframe];
        [cell.bookmarkTitle setFrame:TitleFrame];
        [cell.bookmarkText setFrame:TextFrame];
        
        cell.bookmarkText.numberOfLines=2;
        [cell.bookmarkText sizeToFit];
        
    }
    
    
    searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    
}



-(void)refreshCellAtIndexPath:(NSIndexPath *)indexPath
{
    if (searchEntity==searchBookmarks)
    {
        BokmarksCell *cell  = (BokmarksCell*)[searchResultsTableView cellForRowAtIndexPath:indexPath];
        
        [self configureBookmarkCell:cell atIndexPath:indexPath];

    }
    else
    {
        iEditLibraryCell *cell  = (iEditLibraryCell*)[searchResultsTableView cellForRowAtIndexPath:indexPath];
        
        [self configureLibraryCell:cell atIndexPath:indexPath];
    }
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:indexPath.section];
    if (searchEntity==searchRecording) {
        PlayerViewController *player=[[PlayerViewController alloc]initWithNibName:@"playerViewController" bundle:nil];
        player.allRecordingsInLibrary=[sectionInfo objects ];
        //    player.recordingNamesInLibrary=recordingNamesArray;
        NSLog(@"selecte %ld",(long)indexPath.row);
        player.selectedFileIndex=(int)indexPath.row;
        [self.navigationController pushViewController:player animated:YES];

    }
    else
    {
        bookmarkDetailsViewController *details=[[bookmarkDetailsViewController alloc]initWithNibName:@"bookmarkDetailsViewController" bundle:nil];
        details.hidesBottomBarWhenPushed = YES;
        
        UINavigationController *nav = [[UINavigationController alloc]
                                       initWithRootViewController:details];
        NSLog(@"selected %ld",(long)indexPath.row);
        NSArray *allBookmarks=[sectionInfo objects];
        details.selectedBookmark=[allBookmarks objectAtIndex:indexPath.row ];
        [self presentViewController:nav animated:YES completion:NULL];

    }
    
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
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:entityNameString inManagedObjectContext:DELEGATE.managedObjectContext ];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:fetchPredicate];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"date" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:DELEGATE.managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:nil];
    self.fetchedResultsController = theFetchedResultsController;
    fetchedResultsController.delegate = self;
    
    return fetchedResultsController;}

#pragma mark ~
#pragma mark NSFetchResultsController Delegate Methods
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [searchResultsTableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    
    UITableView *tableView = searchResultsTableView;
    [tableView beginUpdates];
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
        {
            if (searchEntity==searchBookmarks)
            {
                BokmarksCell *cell  = (BokmarksCell*)[searchResultsTableView cellForRowAtIndexPath:indexPath];
                
//                [self configureBookmarkCell:cell atIndexPath:indexPath];
                [self configureCell:cell atIndexPath:indexPath];

            }
            else
            {
                iEditLibraryCell *cell  = (iEditLibraryCell*)[searchResultsTableView cellForRowAtIndexPath:indexPath];
                
//                [self configureLibraryCell:cell atIndexPath:indexPath];
                [self configureCell:cell atIndexPath:indexPath];
            }
        }
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
            
    }
//   [bookmarkArray removeAllObjects];
//   [bookmarkNamesArray removeAllObjects];
    [tableView endUpdates];
    
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [searchResultsTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [searchResultsTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
    
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    
    [searchResultsTableView endUpdates];
    
}

@end
