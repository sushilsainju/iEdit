//
//  playlistItemSelectorViewController.m
//  iEditFast
//
//  Created by SUSHIL on 4/30/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import "playlistItemSelectorViewController.h"
#import "iEditLibraryCell.h"


@interface playlistItemSelectorViewController ()

@end

@implementation playlistItemSelectorViewController

@synthesize TableViewContainer,ContainerView,recordingTableView;
@synthesize recordingArray,selectedCellsArray;
@synthesize fetchedResultsController=_fetchedResultsController;
@synthesize entityNameString,fetchPredicate,sortDescriptorArray,playlistTitle,selectedPLAYLIST;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        fetchPredicate      = [[NSPredicate alloc]  init];
        sortDescriptorArray = [[NSArray alloc]      init];
        selectedCellsArray=[[NSMutableArray alloc]init];
        recordingArray=[[NSMutableArray alloc]init];
        


    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [recordingTableView registerNib:[UINib nibWithNibName:@"iEditLibraryCell" bundle:nil] forCellReuseIdentifier:@"MyCustomCell"];
    [[SharedStore store] customizeNavigationBar];
    [self customizeView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [recordingTableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
//    self.fetchedResultsController=nil;
}

#pragma mark Custom Methods
-(void)customizeView {
    
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    
    CGRect frame;
    frame = ContainerView.frame;
    frame.size.height = ScreenSize.height-StatusbarFrame.size.height-NavigationbarFrame.size.height+IOS_Delta;
    frame.origin.y=ContainerView.frame.origin.y;
    
    [ContainerView setFrame:frame];
    
    
    CGRect tableViewFrame = recordingTableView.frame;
    tableViewFrame.size.height = ContainerView.frame.size.height-recordingTableView.frame.origin.y-TABBAR_Frame.size.height;
    recordingTableView.frame = tableViewFrame;
    
   
    self.navigationController.navigationBar.hidden = NO;
    self.title = @"Select items";
    //    self.navigationController.navigationBar.barTintColor = [UIColor grayColor];
    
    UIButton *saveButton = [[UIButton alloc] init];
    saveButton.frame=CGRectMake(0,0,30,30);
    [saveButton setBackgroundImage:[UIImage imageNamed: @"NAV_save.png"] forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:saveButton];
    
    UIButton *cancelButton = [[UIButton alloc] init];
    cancelButton.frame=CGRectMake(0,0,30,30);
    [cancelButton setBackgroundImage:[UIImage imageNamed: @"NAV_cancel.png"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:cancelButton];
    
    recordingTableView.allowsMultipleSelection=YES;

    
    
    
}

-(NSString *)getDuration:(NSString *)mediapath
{
    NSURL *afUrl = [NSURL fileURLWithPath:mediapath];
    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:afUrl options:nil];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds =  CMTimeGetSeconds(audioDuration);
    
    NSUInteger durationInSeconds = audioDurationSeconds;
    NSUInteger durationInMinutes = durationInSeconds / 60;
    NSUInteger durationInRemainder = durationInSeconds % 60;
    
    NSString *finalDurationString = [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long)durationInMinutes, (unsigned long)durationInRemainder];
    
    return finalDurationString;
}

-(BOOL)isRowSelectedOnTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
 NSLog(@"selectedcells>> %@  cellvalue >>%@",selectedCellsArray,[recordingArray objectAtIndex:indexPath.row]);
    if ([selectedCellsArray containsObject:[recordingArray objectAtIndex:indexPath.row]])
    {
        return YES;
    }
    else
    {
        return NO;
    }
   
    
}

- (void)saveAction {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    NSArray *selectedRecordings=[recordingTableView indexPathsForSelectedRows];
    for (int i=0;i<selectedRecordings.count;i++)
    {
        NSIndexPath *index=[selectedRecordings objectAtIndex:i];
//        NSLog(@"selected %d",[[selectedRecordings objectAtIndex:i] row]);
        Library *recording=[_fetchedResultsController objectAtIndexPath:index];
        [recordingArray addObject:recording];
       
    }

//    if (self.playlistTitle)
//    {
        if ([self.delegate respondsToSelector:@selector(editplaylist:anddate:withrecordings:)]) {
            [self.delegate editplaylist:playlistTitle anddate:[NSDate date] withrecordings:recordingArray];
        }
//    }
//   else
//   {
        if([self.delegate respondsToSelector:@selector(addplaylist:withrecordings:)])
        {
            
            [self.delegate addplaylist:playlistTitle withrecordings:recordingArray];
        }
//   }
}



- (void)cancelAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark UITableView Datasource/Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    id  sectionInfo =[[_fetchedResultsController sections] objectAtIndex:section];
//    NSLog(@"FRC non %lu",(unsigned long)[sectionInfo numberOfObjects]);
    return [sectionInfo numberOfObjects];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellheight = 48;
    
    return cellheight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

//    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
    
    
    
}

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    
    Library *recording=[_fetchedResultsController objectAtIndexPath:indexPath];

    NSString *nametoShow=recording.filename;
    cell.textLabel.text=nametoShow;
    cell.textLabel.textColor=[UIColor lightGrayColor];
    recordingTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    [recordingsArray addObject:theFileName];
//    [recordingNamesArray addObject:nametoShow];
    
    
}




- (void)tableView: (UITableView*)tableView willDisplayCell: (UITableViewCell*)cell forRowAtIndexPath: (NSIndexPath*)indexPath
{
    
    if(indexPath.row % 2 == 0)
        cell.backgroundColor = Color_Grey_06;
    else
        cell.backgroundColor = [UIColor whiteColor];
}

-(void)refreshCellAtIndexPath:(NSIndexPath *)indexPath {
    iEditLibraryCell *cell  = (iEditLibraryCell*)[recordingTableView cellForRowAtIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}
-(CGFloat)heightForLabelAtIndex:(NSInteger)rowIndex {
    
    
    return 30;
}

-(CGFloat)heightForCellAtIndex:(NSInteger)rowIndex {
    //to-do
    
    //
    return 30;
}


//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//}

#pragma mark -
#pragma mark NSFetchResultsController Methods
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Library" inManagedObjectContext:DELEGATE.managedObjectContext ];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"date" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:DELEGATE.managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:@"Root"];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;}

#pragma mark ~
#pragma mark NSFetchResultsController Delegate Methods
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [recordingTableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = recordingTableView;
    [tableView beginUpdates];
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(iEditLibraryCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath ];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
            
    }
//    [recordingsArray removeAllObjects];
//    [recordingNamesArray removeAllObjects];
    [tableView endUpdates];
    
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [recordingTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [recordingTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
    
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    
    [recordingTableView endUpdates];
    
}

@end
