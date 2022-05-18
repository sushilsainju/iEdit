//
//  LibraryViewController.m
//  iEditFast
//
//  Created by SUSHIL on 2/13/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//



#import "LibraryViewController.h"
#import "SharedStore.h"
#import "iEditDataModel.h"
#import "PlayerViewController.h"
#import "iEditLibraryCell.h"
#import "PlaylistItems.h"



@interface LibraryViewController ()



@end

@implementation LibraryViewController

//@synthesize dataModel;
@synthesize LibraryTable;
@synthesize recordingsArray,recordingNamesArray;
@synthesize ContainerView,TableViewContainer;
@synthesize fetchedResultsController=_fetchedResultsController;
@synthesize entityNameString,fetchPredicate,sortDescriptor;
@synthesize selectedrecording,selectedPlaylist;
@synthesize playlistFiles,dataModel;
@synthesize listingLibrary;
@synthesize buttonContainer,addItemsButton,DeleteAllButton;

@synthesize fileBookmarks;

//sagar
@synthesize bookmarks;



NSIndexPath *selectedIndexPath;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        dataModel=[[iEditDataModel alloc]init];
        
        dataModel.managedObjectContext=[DELEGATE managedObjectContext];
        
        fetchPredicate      = [[NSPredicate alloc]  init];
        //        sortDescriptorArray = [[NSArray alloc]      init];
       //sagar sort descriptor changed
        sortDescriptor=[[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
        //sortDescriptor=[[NSSortDescriptor alloc] initWithKey:@"filename" ascending:NO];
        entityNameString=@"Library";
        fetchPredicate=nil;
        listingLibrary=YES;
        self.navigationItem.rightBarButtonItem = nil;
        
        UIButton *deleteAllButton = [[UIButton alloc] init];
        deleteAllButton.frame=CGRectMake(0,0,30,30);
        [deleteAllButton setBackgroundImage:[UIImage imageNamed: @"NAV_delete.png"] forState:UIControlStateNormal];
        [deleteAllButton addTarget:self action:@selector(showPopUpbeforDeletion) forControlEvents:UIControlEventTouchUpInside];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:deleteAllButton];
        
    }
    return self;
}

-(id)initWithplaylist:(Playlists *)playlist
{
    self = [self initWithNibName:@"LibraryViewController" bundle:nil];
    if (self)
    {
        selectedPlaylist=playlist;
        dataModel=[[iEditDataModel alloc]init];
        
        dataModel.managedObjectContext=[DELEGATE managedObjectContext];
        //        entityNameString=@"Library";
        entityNameString=@"PlaylistItems";
        
        fetchPredicate = [NSPredicate predicateWithFormat:@"ANY playlist = %@ ", playlist];
        sortDescriptor=[[NSSortDescriptor alloc] initWithKey:@"itemOrder" ascending:YES];
        listingLibrary=NO;
        self.title=playlist.name;
        self.playlistDate=playlist.createdDate;
        NSManagedObjectID *ids=playlist.objectID;
        NSLog(@"object ID>>>>> %@",ids);
        
        //        UIButton *cancelButton = [[UIButton alloc] init];
        //        cancelButton.frame=CGRectMake(0,0,30,30);
        //        [cancelButton setBackgroundImage:[UIImage imageNamed: @"NAV_edit"] forState:UIControlStateNormal];
        //        [cancelButton addTarget:self action:@selector(editPlaylist) forControlEvents:UIControlEventTouchUpInside];
        //
        //        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:cancelButton];
        
        
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.tintColor=[UIColor grayColor];
    [self.LibraryTable registerNib:[UINib nibWithNibName:@"iEditLibraryCell" bundle:nil] forCellReuseIdentifier:@"MyCustomCell"];
    [[SharedStore store] customizeNavigationBar];
    [self customizeView];
    recordingsArray= [[NSMutableArray alloc]init];
    recordingNamesArray=[[NSMutableArray alloc]init];
    
    
    
    //    [_uploadView setHidden:NO];
    
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error])
    {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }
    NSLog(@"FRC %@", _fetchedResultsController.fetchedObjects);
    [self resetProgress];
    
    [LibraryTable reloadData];
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


#pragma mark UITableView Datasource/Delegate

- (IBAction)deleteAllClicked:(id)sender
{
    [dataModel clearplaylist:self.title anddate:self.playlistDate] ;
    buttonContainer.hidden=YES;
    
}

- (IBAction)addItemsClicked:(id)sender
{
    playlistItemSelectorViewController *listController=[[playlistItemSelectorViewController alloc]initWithNibName:@"playlistItemSelectorViewController" bundle:nil];
    listController.hidesBottomBarWhenPushed = YES;
    listController.playlistTitle=self.title;
    
    listController.delegate=self;
    
    UINavigationController *nav = [[UINavigationController alloc]
                                   initWithRootViewController:listController];
    [self presentViewController:nav animated:YES completion:NULL];
    buttonContainer.hidden=YES;
    
}



#pragma mark CUSTOM METHODS

- (NSArray *)rightButtons:(NSIndexPath *)indexPath
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    Library *recording=[_fetchedResultsController objectAtIndexPath:indexPath];
    
    if (listingLibrary)
    {
        //sagar check if file is master and does not have composite in its file name
        if (recording.isMaster==YES&&[recording.filename rangeOfString:@"composite"].location==NSNotFound)
            
            [rightUtilityButtons sw_addUtilityButtonWithColor:
             [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                         icon:[UIImage imageNamed: @"rename"]];
    }
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                 icon:[UIImage imageNamed: @"delete_white.png"]];
    return rightUtilityButtons;
}

-(NSArray *)leftButtons
{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    if (listingLibrary) {
        [leftUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                    icon:[UIImage imageNamed: @"upload"]];
    }
    
    
    return leftUtilityButtons;
}

-(void)customizeView {
    
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    
    CGRect frame;
    frame = ContainerView.frame;
    frame.size.height = ScreenSize.height-StatusbarFrame.size.height-NavigationbarFrame.size.height+IOS_Delta;
    frame.origin.y=ContainerView.frame.origin.y;
    
    [ContainerView setFrame:frame];
    
    //    if(listingLibrary)
    //    {
    //
    //    }
    
    
    CGRect tableViewFrame = self.LibraryTable.frame;
    tableViewFrame.size.height = ContainerView.frame.size.height-LibraryTable.frame.origin.y-TABBAR_Frame.size.height;
    self.LibraryTable.frame = tableViewFrame;
    
    CGRect uploadFrame;
    uploadFrame = _progress.frame;
    uploadFrame.origin.y = tableViewFrame.origin.y+StatusbarFrame.size.height+NavigationbarFrame.size.height;
    [_progress setFrame:uploadFrame];
    
}

-(void)showPopUpbeforDeletion
{
    
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Delete all Recordings"
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
            [self deleteAllRecordings];
        }
        
        
        
    }
}

-(void)deleteAllRecordings
{
    for (int i=0; i<[self.fetchedResultsController fetchedObjects].count; i++)
    {
        NSError *error = nil;
        
        selectedrecording=[[_fetchedResultsController fetchedObjects] objectAtIndex:i];
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:selectedrecording.filepath error:&error];
        if (success)
        {
            NSLog(@"selected recording %@ ",selectedrecording.filepath);
            
        }
        else
        {
            NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
        }
        
        
    }
    
    for (Library *message in [self.fetchedResultsController fetchedObjects])
    {
        [DELEGATE.managedObjectContext deleteObject:message];
        NSError *error = nil;
        if (![DELEGATE.managedObjectContext save:&error])
        {
            // handle error
            UIAlertView *removeSuccessFulAlert=[[UIAlertView alloc]initWithTitle:@"iEditSmart" message:@"Can not delete files at the moment. Please try again later." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [removeSuccessFulAlert show];
        }
    }
    
    
    [LibraryTable reloadData];
}

#pragma mark -

-(void)promptSaveRecording:(NSString *)name
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

-(void)editPlaylist
{
    
    //POSITOIN BUTTON CONTAINER AT THE BOTTOM OF VIEW
    
    // ****** NEED TO WORK ON THIS*****
    //    CGRect buttonsFrame = self.buttonContainer.frame;
    //    buttonsFrame.origin.y = ContainerView.frame.size.height-TABBAR_Frame.size.height- buttonsFrame.size.height;
    //    self.buttonContainer.frame = buttonsFrame;
    //    [buttonContainer setHidden:!buttonContainer.hidden];
    
}

-(void) editplaylist:(NSString *)name anddate:(NSDate *)date withrecordings:(NSArray *) recordings
{
    //      [dataModel editplaylist:name anddate:self.playlistDate withrecordings:recordings];
    //    [dataModel addItems:recordings toPlaylist:selectedPlaylist];
    [dataModel PlaylistDetails:selectedPlaylist withRecordings:recordings];
    
}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    NSString *filename;
    if(buttonIndex==0)
    {
        //        [self discardFile];
        [alertView close];
    }
    else if(buttonIndex==1)
    {
        NSString *oldFilename=[selectedrecording.filename stringByDeletingPathExtension];
        
        UITextField *nameField = (UITextField *)[alertView viewWithTag:111111];
        filename=nameField.text;
        if (filename.length>0)
        {
            filename=[filename stringByAppendingString:fileExtension];
            if (selectedrecording)
            {
                fileBookmarks=[dataModel getBookmarksForrecording:selectedrecording];
                NSArray *associatedfiles=[dataModel getAssociatedFilesForrecording:selectedrecording];
                NSError * err = NULL;
                NSFileManager * fm = [[NSFileManager alloc] init];
                NSString *oldpath=selectedrecording.filepath;
                filename=[@"/" stringByAppendingString:filename];
                NSString *newfilepath=[DOCUMENTS_FOLDER stringByAppendingString:filename];
                BOOL result = [fm moveItemAtPath:oldpath toPath:newfilepath error:&err];
                if(!result)
                {
                    UIAlertView *removeSuccessFulAlert=[[UIAlertView alloc]initWithTitle:@"iEditSmart" message:@"Can not rename file.(File with specified name already exists)" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [removeSuccessFulAlert show];
                }
                else
                {
                    NSString *oldFilePath=selectedrecording.filepath;
                    selectedrecording.filename=[filename substringFromIndex:1];
                    selectedrecording.filepath=newfilepath;
                    NSError *error = nil;
                    if (![DELEGATE.managedObjectContext save:&error])
                    {
                        // handle error
                        UIAlertView *removeSuccessFulAlert=[[UIAlertView alloc]initWithTitle:@"iEditSmart" message:@"Can not rename file at the moment. Please try again later." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                        [removeSuccessFulAlert show];
                    }
                    if (!selectedrecording.isMaster)
                    {
                        [dataModel renameChunkFile:selectedrecording withOldPath:oldFilePath];
                    }
                    
                    //renaming associated Bookmarks
                    if (fileBookmarks.count>0)
                    {
                        for (int i=0;i<fileBookmarks.count;i++)
                        {
                            Bookmarks *selectedBookmark=[fileBookmarks objectAtIndex:i];
                            if (selectedBookmark)
                            {
                                NSString *name=[[newfilepath lastPathComponent] stringByDeletingPathExtension];
                                selectedBookmark.name=[NSString stringWithFormat:@"%@ - %d",name,i+1];
                                NSError *error = nil;
                                if (![DELEGATE.managedObjectContext save:&error]) {
                                    // handle error
                                }
                            }
                            
                        }
                    }
                    //rename assocaited files(chunks/composite)
                    if (associatedfiles.count>0)
                    {
                        for (int i=1;i<associatedfiles.count;i++)
                        {
                            Library *selectedChunk=[associatedfiles objectAtIndex:i];
                            if (selectedChunk)
                            {
                                

                                NSString *name=[[newfilepath lastPathComponent] stringByDeletingPathExtension];
                                
                                //                               NSString *oldFileName=[selectedChunk.filename lastPathComponent];
                                
                                NSString *newfileName = [selectedChunk.filename stringByReplacingOccurrencesOfString:oldFilename withString:name];
                                
                                selectedChunk.filename=newfileName;
                                NSError * err = NULL;
                                NSFileManager * fm = [[NSFileManager alloc] init];
                                NSString *oldpath=selectedChunk.filepath;
                                filename=[@"/" stringByAppendingString:filename];
                                NSString *newfilepath=[NSString stringWithFormat:@"%@/%@",DOCUMENTS_FOLDER,newfileName ];
                                selectedChunk.filepath=newfilepath;
                                BOOL result = [fm moveItemAtPath:oldpath toPath:newfilepath error:&err];
                                
                                
                                if(!result)
                                {
                                    UIAlertView *removeSuccessFulAlert=[[UIAlertView alloc]initWithTitle:@"iEditSmart" message:@"Can not rename file.(File with specified name already exists)" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                    [removeSuccessFulAlert show];
                                }
                                NSError *error = nil;
                                if (![DELEGATE.managedObjectContext save:&error]) {
                                    // handle error
                                }
                            }
                            
                        }
                        NSString *name=[[newfilepath lastPathComponent] stringByDeletingPathExtension];
                        NSString *newtxtfilepath=[NSString stringWithFormat:@"%@/%@.txt",DOCUMENTS_FOLDER,name ];
                        NSString *oldtxtfilepath=[NSString stringWithFormat:@"%@/%@.txt",DOCUMENTS_FOLDER,oldFilename ];
                        [fm moveItemAtPath:oldtxtfilepath toPath:newtxtfilepath error:&err];
                        NSString* contentEdit = [NSString stringWithContentsOfFile:newtxtfilepath
                                                                          encoding:NSUTF8StringEncoding
                                                                             error:NULL];
                        contentEdit = [contentEdit stringByReplacingOccurrencesOfString:oldFilename
                                                                             withString:name];
                        [[NSFileManager defaultManager] removeItemAtPath:newtxtfilepath error:nil];
                        NSString *newtxtfilepathPart2=[NSString stringWithFormat:@"%@/%@.txt",DOCUMENTS_FOLDER,name ];
                        [contentEdit writeToFile:newtxtfilepathPart2 atomically:YES];
                    }
                    
                }
            }
            [alertView close];
            
            
        }
        else
        {
            UIAlertView *removeSuccessFulAlert=[[UIAlertView alloc]initWithTitle:@"iEditSmart" message:@"Please Enter Filename" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
            [removeSuccessFulAlert show];
        }
        
    }
    
}

-(NSString *)namewithoutExtensoin:(NSString *)filename
{
    NSString *filename_extension = [filename pathExtension];
    NSInteger filenameextensionlength = [filename_extension length];
    NSInteger filename_length = [filename length];
    filename_length = filename_length - (1 + filenameextensionlength);
    return [ filename substringWithRange:NSMakeRange(0, filename_length) ];
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
    CGFloat cellheight = 48;
    
    return cellheight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"MyCustomCell";
    
    iEditLibraryCell *cell = [self.LibraryTable dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    iEditLibraryCell __weak *weakCell = cell;
    
    
    Library *recording=[_fetchedResultsController objectAtIndexPath:indexPath];
    NSMutableArray *rightButtons=(NSMutableArray *)[self rightButtons:indexPath];
    
    [cell setAppearanceWithBlock:^{
        //        if (recording.isMaster==NO||[recording.filename rangeOfString:@"composite"].location!=NSNotFound)
        //        {
        //            if (indexPath>0)
        //            {
        //                [rightButtons removeObjectAtIndex:0];
        //
        //            }
        //        }
        weakCell.rightUtilityButtons = rightButtons;
        weakCell.leftUtilityButtons=[self leftButtons];
        weakCell.delegate = self;
        weakCell.containingTableView = tableView;
    } force:YES];
    
    [cell setCellHeight:cell.frame.size.height];
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
    
    
    
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger retValue=1;
    if (listingLibrary)
    {
        Library *recording=[_fetchedResultsController objectAtIndexPath:indexPath];
        if (recording.isMaster==NO||[recording.filename rangeOfString:@"composite"].location!=NSNotFound) {
            retValue=2;
        }
        else
        {
            retValue=0;
        }
        
    }
    return retValue;
}


-(void)configureCell:(iEditLibraryCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Library *recording;
    NSLog(@"fetched Objects %@",_fetchedResultsController.fetchedObjects);
    if (!listingLibrary)
    {
        PlaylistItems *newItem=[_fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
        NSLog(@"rec %@",newItem.recording);
        recording=newItem.recording;
    }
    else
    {
        recording=[_fetchedResultsController objectAtIndexPath:indexPath];
    }
    NSString *duration= [ [SharedStore store] getDuration:recording.filepath];
    NSString* theFileName = [recording.filename lastPathComponent] ;
    NSString *nametoShow=[self namewithoutExtensoin:theFileName];
    cell.title.text =nametoShow;
    cell.duration.text=duration;
    CGRect durationlabelFrame= cell.duration.frame;
    
    if (cell.indentationLevel>0 ) {
        durationlabelFrame.origin.x=245;
        cell.duration.frame=durationlabelFrame;
        cell.backgroundColor = Color_Whitish_0975;
        
        
    }
    self.LibraryTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [recordingsArray addObject:theFileName];
    [recordingNamesArray addObject:nametoShow];
    
    
}



- (void)tableView: (UITableView*)tableView willDisplayCell: (UITableViewCell*)cell forRowAtIndexPath: (NSIndexPath*)indexPath
{
    if (listingLibrary)
    {
        Library *recording=[_fetchedResultsController objectAtIndexPath:indexPath];
        if (recording.isMaster==YES) {
            
            if(indexPath.row % 2 == 0)
                cell.backgroundColor = Color_Grey_06;
            else
                cell.backgroundColor = [UIColor whiteColor];
        }
    }
    
}

-(void)refreshCellAtIndexPath:(NSIndexPath *)indexPath {
    iEditLibraryCell *cell  = (iEditLibraryCell*)[LibraryTable cellForRowAtIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    
}







- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:indexPath.section];
    
    PlayerViewController *player=[[PlayerViewController alloc]initWithNibName:@"playerViewController" bundle:nil];
    player.allRecordingsInLibrary=[sectionInfo objects ];
    //    player.recordingNamesInLibrary=recordingNamesArray;
    if (!listingLibrary) {
        player.playingPlaylistItems=TRUE;
        //        player.allRecordingsInLibrary=[[sectionInfo objects ]valueForKeyPath:@"recording"];
        
    }
    player.selectedFileIndex=(int)indexPath.row;
    [self.navigationController pushViewController:player animated:YES];
    
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

#pragma mark - SWTableViewDelegate



- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    NSIndexPath *cellIndexPath = [self.LibraryTable indexPathForCell:cell];
    
    
    if (listingLibrary)
    {
        selectedrecording=[_fetchedResultsController objectAtIndexPath:cellIndexPath];
        
        
        // delete the images in the document directory completed
        
        NSString *mediaPath=selectedrecording.filepath;
        switch (index)
        {
            case 0:
            {
                //sagar delete recording for composite and - contained file
                //if([selectedrecording.filename rangeOfString:@"composite"].location!=NSNotFound || [selectedrecording.filename rangeOfString:@"-"].location!=NSNotFound ){
                if(!selectedrecording.isMaster || [selectedrecording.filename rangeOfString:@"composite"].location!=NSNotFound){
                    selectedIndexPath = [self.LibraryTable indexPathForCell:cell];
                    Library *fileToDelete=[self.fetchedResultsController objectAtIndexPath:selectedIndexPath];
                    NSLog(@"selected recording %@ ",mediaPath);
                    if (fileToDelete.isMaster==YES)
                    {
                        [dataModel handleMasterFileDeletion:fileToDelete];
                        
                    }
                    [DELEGATE.managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:selectedIndexPath]];
                    
                    NSError *error = nil;
                    if (![DELEGATE.managedObjectContext save:&error])
                    {
                        // handle error
                    }
                    
                    
                    
                    
                    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:mediaPath error:&error];
                    
                    if (success)
                    {
                        NSLog(@"selected recording %@ ",selectedrecording.filepath);
                        
                    }
                    else
                    {
                        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
                    }
                    
                    break;
                }
                selectedrecording=[_fetchedResultsController objectAtIndexPath:cellIndexPath];
                NSString *nametoShow=[self namewithoutExtensoin:selectedrecording.filename];
                
                NSLog(@"path %@",selectedrecording.filepath);
                
                [self promptSaveRecording:nametoShow];
                [cell hideUtilityButtonsAnimated:YES];
                break;
            }
            case 1:
            {
                // Delete button was pressed
                
                //sagar delete the images in the document directory
                bookmarks= [dataModel getBookmarksForrecording:selectedrecording];
                NSString *pathImage;
                for(int i=0;i<bookmarks.count;i++)
                {
                    Bookmarks *currentBookmark=[bookmarks objectAtIndex:i];
                    if(currentBookmark.hasImage)
                    {
                        NSArray *images=[currentBookmark.hasImage allObjects];
                        if (images.count>0)
                        {
                            NSString *imagePathFromBookmark = [[images valueForKey:@"filepath"] componentsJoinedByString:@""];
                            NSArray *fileNameOfImageArray = [imagePathFromBookmark componentsSeparatedByString:@"/"];
                            NSString *fileNameOfImage = [fileNameOfImageArray lastObject];
                            
                            
                            self.containedImage=[images objectAtIndex:0];
                            pathImage=self.containedImage.filepath;
                            
                            if([pathImage isEqualToString:@""]){
                                
                            }
                            else{
                                [[NSFileManager defaultManager] removeItemAtPath:pathImage error:nil];
                            }
                        }
                        else
                        {
                            pathImage=@"";
                        }
                        
                    }
                }
                
                // selectedrecording=[_fetchedResultsController objectAtIndexPath:cellIndexPath];
                selectedIndexPath = [self.LibraryTable indexPathForCell:cell];
                Library *fileToDelete=[self.fetchedResultsController objectAtIndexPath:selectedIndexPath];
                NSLog(@"selected recording %@ ",mediaPath);
                if (fileToDelete.isMaster==YES)
                {
                    [dataModel handleMasterFileDeletion:fileToDelete];
                    
                }
                [DELEGATE.managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:selectedIndexPath]];
                
                NSError *error = nil;
                if (![DELEGATE.managedObjectContext save:&error])
                {
                    // handle error
                }
                
                
                
                
                BOOL success = [[NSFileManager defaultManager] removeItemAtPath:mediaPath error:&error];
                //sagar delete text file with same name
                NSString *textfilePath = [[mediaPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"txt"];
                
                if ( [[NSFileManager defaultManager] isReadableFileAtPath:textfilePath] ){
                    [[NSFileManager defaultManager] removeItemAtPath:textfilePath error:nil];
                }
                //delete complete
                if (success)
                {
                    NSLog(@"selected recording %@ ",selectedrecording.filepath);
                    //sagar after delating master file reload table so that edit files become master
                    [LibraryTable reloadData];
                    
                }
                else
                {
                    NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
                }
                
                break;
            }
            default:
                break;
        }
        
    }
    else
    {
        Playlists *currentPlaylist=selectedPlaylist;
        PlaylistItems *selectedItem=[_fetchedResultsController objectAtIndexPath:cellIndexPath];
        selectedrecording=selectedItem.recording;
        //        NSString *nametoShow=[self namewithoutExtensoin:selectedrecording.filename];
        [currentPlaylist removePlaylistitemsObject:selectedItem];
        //        NSLog(@"path %@",selectedrecording.filepath);
        //        [selectedItem removeRecordingObject:selectedrecording];
        //        [dataModel removeplaylistItem:self.title anddate:self.playlistDate andFilename:selectedrecording.filename];
        [cell hideUtilityButtonsAnimated:YES];
        
    }
    
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
    [_progress setHidden:NO];
    NSIndexPath *cellIndexPath = [self.LibraryTable indexPathForCell:cell];
    
    selectedrecording=[_fetchedResultsController objectAtIndexPath:cellIndexPath];
    NSString *mediaPath=selectedrecording.filepath;
    switch (index)
    {
        case 0:
        {
            NSError *error=nil;
            //sagar - check internet connection before uploading file to dropbox
            NSString *URLString = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.google.com"] encoding:NSASCIIStringEncoding error:&error];
            
            if(URLString != NULL)
            {
                //sagar disable pressing of upload twice
                for (int i = 0; i < [cell.leftUtilityButtons count]; i++){
                    [(UIButton *)[cell.leftUtilityButtons objectAtIndex:i] setEnabled:NO];
                }
                selectedrecording=[_fetchedResultsController objectAtIndexPath:cellIndexPath];
                //                NSString *nametoShow=nil;
                //                nametoShow=[self namewithoutExtensoin:selectedrecording.filename];
                
                NSLog(@"path %@",selectedrecording.filepath);
                NSString *destDir = @"/";
                
                
                BOOL isDir=NO;
                
                NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                
                NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/zipTest"];
                
                if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
                    [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
                
                //NSString *source1 = [NSString stringWithFormat:@"%@/%@", documentsDirectory, selectedrecording.filename];
                NSString *source1 = selectedrecording.filepath;
                NSString *dest = [NSString stringWithFormat:@"%@/zipTest/%@",
                                  documentsDirectory,selectedrecording.filename];
               
                //NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSString *editFileParamsTextFileName = [NSString stringWithFormat:@"%@.txt",[selectedrecording.filename stringByDeletingPathExtension]];
                
                NSString *editFileWithParamsFilePath = [NSString stringWithFormat:@"%@/%@",
                                                        documentsDirectory, editFileParamsTextFileName];
                NSString *destEditFileWithParmsFilePath = [NSString stringWithFormat:@"%@/zipTest/%@",
                                       documentsDirectory,editFileParamsTextFileName];
                
                if ( [[NSFileManager defaultManager] isReadableFileAtPath:editFileWithParamsFilePath] ){
                    [[NSFileManager defaultManager] copyItemAtPath:editFileWithParamsFilePath toPath:destEditFileWithParmsFilePath error:nil];
                    //remove the edittextfile from the document directory
                    //[[NSFileManager defaultManager] removeItemAtPath:editFileWithParamsFilePath error:nil];
                }
                
                
                
                NSString *compositeFileName = [NSString stringWithFormat:@"%@composite.m4a", [[source1 lastPathComponent]  stringByDeletingPathExtension]];
                NSString *sourceComposite = [NSString stringWithFormat:@"%@/%@", documentsDirectory,compositeFileName];
                
                NSString *editFile1Name = [NSString stringWithFormat:@"%@-1.m4a", [[source1 lastPathComponent]  stringByDeletingPathExtension]];
                NSString *sourceEdit1 = [NSString stringWithFormat:@"%@/%@", documentsDirectory,editFile1Name];
                
                NSString *editFile2Name = [NSString stringWithFormat:@"%@-2.m4a", [[source1 lastPathComponent]  stringByDeletingPathExtension]];
                NSString *sourceEdit2 = [NSString stringWithFormat:@"%@/%@", documentsDirectory,editFile2Name];
                
                NSString *editFile3Name = [NSString stringWithFormat:@"%@-3.m4a", [[source1 lastPathComponent]  stringByDeletingPathExtension]];
                NSString *sourceEdit3 = [NSString stringWithFormat:@"%@/%@", documentsDirectory,editFile3Name];
                
                NSString *editFile4Name = [NSString stringWithFormat:@"%@-4.m4a", [[source1 lastPathComponent]  stringByDeletingPathExtension]];
                NSString *sourceEdit4 = [NSString stringWithFormat:@"%@/%@", documentsDirectory,editFile4Name];
                
                
                //NSString *editFile5Name = [NSString stringWithFormat:@"%@-5.m4a", [[[source1 lastPathComponent] substringToIndex:8] stringByDeletingPathExtension]];
                NSString *editFile5Name = [NSString stringWithFormat:@"%@-5.m4a", [[source1 lastPathComponent]  stringByDeletingPathExtension]];
                NSString *sourceEdit5 = [NSString stringWithFormat:@"%@/%@", documentsDirectory,editFile5Name];
                
                NSString *editFile6Name = [NSString stringWithFormat:@"%@-6.m4a", [[source1 lastPathComponent]  stringByDeletingPathExtension]];
                NSString *sourceEdit6 = [NSString stringWithFormat:@"%@/%@", documentsDirectory,editFile6Name];
                
                NSString *editFile7Name = [NSString stringWithFormat:@"%@-7.m4a", [[source1 lastPathComponent]  stringByDeletingPathExtension]];
                NSString *sourceEdit7 = [NSString stringWithFormat:@"%@/%@", documentsDirectory,editFile7Name];
                
                NSString *editFile8Name = [NSString stringWithFormat:@"%@-8.m4a", [[source1 lastPathComponent]  stringByDeletingPathExtension]];
                NSString *sourceEdit8 = [NSString stringWithFormat:@"%@/%@", documentsDirectory,editFile8Name];
                NSString *editFile9Name = [NSString stringWithFormat:@"%@-9.m4a", [[source1 lastPathComponent]  stringByDeletingPathExtension]];
                NSString *sourceEdit9 = [NSString stringWithFormat:@"%@/%@", documentsDirectory,editFile9Name];
                NSString *editFile10Name = [NSString stringWithFormat:@"%@-10.m4a", [[source1 lastPathComponent]  stringByDeletingPathExtension]];
                NSString *sourceEdit10 = [NSString stringWithFormat:@"%@/%@", documentsDirectory,editFile10Name];
                
                
                
                NSString *destComposite = [NSString stringWithFormat:@"%@/zipTest/%@",
                                  documentsDirectory,compositeFileName];
                
                NSString *destEdit1 = [NSString stringWithFormat:@"%@/zipTest/%@",
                                           documentsDirectory,editFile1Name];
                NSString *destEdit2 = [NSString stringWithFormat:@"%@/zipTest/%@",
                                       documentsDirectory,editFile2Name];
                NSString *destEdit3 = [NSString stringWithFormat:@"%@/zipTest/%@",
                                       documentsDirectory,editFile3Name];
                NSString *destEdit4 = [NSString stringWithFormat:@"%@/zipTest/%@",
                                       documentsDirectory,editFile4Name];
                NSString *destEdit5 = [NSString stringWithFormat:@"%@/zipTest/%@",
                                       documentsDirectory,editFile5Name];
                NSString *destEdit6 = [NSString stringWithFormat:@"%@/zipTest/%@",
                                       documentsDirectory,editFile6Name];
                NSString *destEdit7 = [NSString stringWithFormat:@"%@/zipTest/%@",
                                       documentsDirectory,editFile7Name];
                NSString *destEdit8 = [NSString stringWithFormat:@"%@/zipTest/%@",
                                       documentsDirectory,editFile8Name];
                NSString *destEdit9 = [NSString stringWithFormat:@"%@/zipTest/%@",
                                       documentsDirectory,editFile9Name];
                NSString *destEdit10 = [NSString stringWithFormat:@"%@/zipTest/%@",
                                       documentsDirectory,editFile10Name];
                
                if ( [[NSFileManager defaultManager] isReadableFileAtPath:source1] ){
                    [[NSFileManager defaultManager] copyItemAtPath:source1 toPath:dest error:nil];
                    
                }
                
                if ( [[NSFileManager defaultManager] isReadableFileAtPath:sourceComposite] ){
                    [[NSFileManager defaultManager] copyItemAtPath:sourceComposite toPath:destComposite error:nil];
                }
                
                if ( [[NSFileManager defaultManager] isReadableFileAtPath:sourceEdit1] ){
                    [[NSFileManager defaultManager] copyItemAtPath:sourceEdit1 toPath:destEdit1 error:nil];
                }
                if ( [[NSFileManager defaultManager] isReadableFileAtPath:sourceEdit2] ){
                    [[NSFileManager defaultManager] copyItemAtPath:sourceEdit2 toPath:destEdit2 error:nil];
                }
                if ( [[NSFileManager defaultManager] isReadableFileAtPath:sourceEdit3] ){
                    [[NSFileManager defaultManager] copyItemAtPath:sourceEdit3 toPath:destEdit3 error:nil];
                }
                if ( [[NSFileManager defaultManager] isReadableFileAtPath:sourceEdit4] ){
                    [[NSFileManager defaultManager] copyItemAtPath:sourceEdit4 toPath:destEdit4 error:nil];
                }
                if ( [[NSFileManager defaultManager] isReadableFileAtPath:sourceEdit5] ){
                    [[NSFileManager defaultManager] copyItemAtPath:sourceEdit5 toPath:destEdit5 error:nil];
                }
                if ( [[NSFileManager defaultManager] isReadableFileAtPath:sourceEdit6] ){
                    [[NSFileManager defaultManager] copyItemAtPath:sourceEdit6 toPath:destEdit6 error:nil];
                }
                if ( [[NSFileManager defaultManager] isReadableFileAtPath:sourceEdit7] ){
                    [[NSFileManager defaultManager] copyItemAtPath:sourceEdit7 toPath:destEdit7 error:nil];
                }
                if ( [[NSFileManager defaultManager] isReadableFileAtPath:sourceEdit8] ){
                    [[NSFileManager defaultManager] copyItemAtPath:sourceEdit8 toPath:destEdit8 error:nil];
                }
                if ( [[NSFileManager defaultManager] isReadableFileAtPath:sourceEdit9] ){
                    [[NSFileManager defaultManager] copyItemAtPath:sourceEdit9 toPath:destEdit9 error:nil];
                }if ( [[NSFileManager defaultManager] isReadableFileAtPath:sourceEdit10] ){
                    [[NSFileManager defaultManager] copyItemAtPath:sourceEdit10 toPath:destEdit10 error:nil];
                }

                
                
                
                
                
                NSArray *subpaths;
                //name of the compressed file to be sent to zip folder i.e this is the file that will be in zip folder
                
                
                //make a file name to write the data to using the documents directory:
                NSString *fileName = [NSString stringWithFormat:@"%@/zipTest/textfile.txt",
                                      documentsDirectory];
                
                //create content - four lines of text
                bookmarks= [dataModel getBookmarksForrecording:selectedrecording];
                NSMutableArray *textToBeWrittenInFile = [[NSMutableArray alloc] init];
                
                NSArray *textArray = [bookmarks valueForKey:@"text"];
                NSArray *timeArray =[bookmarks valueForKey:@"timeInSeconds"];
                NSArray *imageArray = [bookmarks valueForKey:@"hasImage"];
                
                for(int i=0; i< textArray.count; i++){
                    Bookmarks *currentBookmark=[bookmarks objectAtIndex:i];
                    if(currentBookmark.hasImage){
                        NSArray *images=[currentBookmark.hasImage allObjects];
                        if (images.count>0)
                        {
                            self.containedImage=[images objectAtIndex:0];
                            NSString *imagePath =self.containedImage.filepath;
                            NSLog(@"testinggg %@", [imageArray objectAtIndex:i]);
                            NSDictionary *temp = @{@"title": [textArray objectAtIndex:i], @"time": [timeArray objectAtIndex:i], @"imagePath":imagePath};
                            
                            [textToBeWrittenInFile addObject:temp];
                        } else {
                            NSLog(@"testinggg %@", [imageArray objectAtIndex:i]);
                            NSDictionary *temp = @{@"title": [textArray objectAtIndex:i], @"time": [timeArray objectAtIndex:i], @"imagePath":@""};
                            
                            [textToBeWrittenInFile addObject:temp];
                        }
                        
                        
                    }
                }
                NSLog(@"dict %@", textToBeWrittenInFile);
                
                //NSString *textContent = [NSString stringWithFormat:@"[ %@ ]",[textToBeWrittenInFile componentsJoinedByString:@","]];
                
                
                /*NSString *textContent = [NSString stringWithFormat:@"[ %@ ]",[textToBeWrittenInFile componentsJoinedByString:@","]];
                 NSString *textContentAsJsonAfterRemovingSlash = [textContent stringByReplacingOccurrencesOfString:@"\\" withString:@""];
                 NSString *textContentAsJsonAfterRemovingEqualSign = [textContentAsJsonAfterRemovingSlash stringByReplacingOccurrencesOfString:@"=" withString:@":"];
                 NSString *textContentAsJsonAfterRemovingSemiColon = [textContentAsJsonAfterRemovingEqualSign stringByReplacingOccurrencesOfString:@";" withString:@","];*/
                //save content to the documents directory
                //                [textContent writeToFile:fileName
                //                              atomically:NO
                //                                encoding:NSStringEncodingConversionAllowLossy
                //                                   error:nil];
                
                [textToBeWrittenInFile writeToFile:fileName atomically:YES];
                
                //sagar image copy to zip
                
                NSString *pathImage;
                NSString *destImagePath;
                for(int i=0;i<bookmarks.count;i++)
                {
                    Bookmarks *currentBookmark=[bookmarks objectAtIndex:i];
                    if(currentBookmark.hasImage)
                    {
                        NSArray *images=[currentBookmark.hasImage allObjects];
                        if (images.count>0)
                        {
                            NSString *imagePathFromBookmark = [[images valueForKey:@"filepath"] componentsJoinedByString:@""];
                            NSArray *fileNameOfImageArray = [imagePathFromBookmark componentsSeparatedByString:@"/"];
                            NSString *fileNameOfImage = [fileNameOfImageArray lastObject];
                            
                            
                            self.containedImage=[images objectAtIndex:0];
                            pathImage=self.containedImage.filepath;
                            
                            destImagePath =  [NSString stringWithFormat:@"%@/zipTest/%@",
                                              documentsDirectory, fileNameOfImage];
                            
                            [[NSFileManager defaultManager] copyItemAtPath:pathImage toPath:destImagePath error:nil];
                            // [[NSFileManager defaultManager] removeItemAtPath:pathImage error:nil];
                            
                        }
                        else
                        {
                            pathImage=@"";
                        }
                        
                    }
                }
                
                
                
                NSString *toCompress = @"zipTest";
                
                
                
                
                NSString *pathToCompress = [documentsDirectory stringByAppendingPathComponent:toCompress];
                
                NSFileManager *fileManager = [NSFileManager defaultManager];
                if ([fileManager fileExistsAtPath:pathToCompress isDirectory:&isDir] && isDir){
                    subpaths = [fileManager subpathsAtPath:pathToCompress];
                } else if ([fileManager fileExistsAtPath:pathToCompress]) {
                    subpaths = [NSArray arrayWithObject:pathToCompress];
                }
                
                
                
                
                NSString *folderNameToBeZippedWithExtension = selectedrecording.filename;
                NSArray *folderNameWithoutExtensionArray = [folderNameToBeZippedWithExtension componentsSeparatedByString:@"."];
                NSString *folderNameToBeZippedWithoutExtension = [folderNameWithoutExtensionArray objectAtIndex:0];
                NSString *folderNametoBeZippedWithZipExtension = [NSString stringWithFormat:@"%@.zip", folderNameToBeZippedWithoutExtension];
                
                NSString *zipFilePath = [NSString stringWithFormat:@"%@/%@.zip", documentsDirectory, folderNameToBeZippedWithoutExtension];
                
                
                ZipArchive *za = [[ZipArchive alloc] init];
                [za CreateZipFile2:zipFilePath];
                if (isDir) {
                    for(NSString *path in subpaths){
                        NSString *fullPath = [pathToCompress stringByAppendingPathComponent:path];
                        if([fileManager fileExistsAtPath:fullPath isDirectory:&isDir] && !isDir){
                            [za addFileToZip:fullPath newname:path];
                        }
                    }
                } else {
                    [za addFileToZip:pathToCompress newname:toCompress];
                }
                
                [za CloseZipFile2];
                
                
                
                
                
                
                // Upload file to Dropbox
            
                
                if ([self isDropboxLinked])
                {
                    //[self.restClient uploadFile:selectedrecording.filename toPath:destDir withParentRev:nil fromPath:selectedrecording.filepath];
                    //[[DBSession sharedSession] unlinkAll];
                    if(bookmarks.count > 0)
                    {
                        [self.restClient uploadFile:folderNametoBeZippedWithZipExtension toPath:destDir  fromPath:zipFilePath];
                        
                        [[NSFileManager defaultManager] removeItemAtPath:pathToCompress error:nil];
                        
                    } else {
                        
                        if([folderNameToBeZippedWithExtension rangeOfString:@"-"].location == NSNotFound && [folderNameToBeZippedWithExtension rangeOfString:@"composite"].location == NSNotFound){
                            NSLog(@"string does not contain - and composite");
                            [self.restClient uploadFile:folderNametoBeZippedWithZipExtension toPath:destDir  fromPath:zipFilePath];
                            [[NSFileManager defaultManager] removeItemAtPath:pathToCompress error:nil];
                        } else {
                            NSLog(@"string contains - or composite!");
                            [self.restClient uploadFile:selectedrecording.filename toPath:destDir  fromPath:selectedrecording.filepath];
                           [[NSFileManager defaultManager] removeItemAtPath:pathToCompress error:nil];
                            [[NSFileManager defaultManager] removeItemAtPath:zipFilePath error:nil];
                        }
                    }
                    
                }
                else
                {
                    
                    [[DBSession sharedSession] linkFromController:self];
                    //                    if(bookmarks.count> 0){
                    //                    [self.restClient uploadFile:folderNametoBeZippedWithZipExtension toPath:destDir fromPath:zipFilePath];
                    //                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                    //                    [[NSFileManager defaultManager] removeItemAtPath:pathToCompress error:nil];
                    //                    } else {
                    //                        [self.restClient uploadFile:selectedrecording.filename toPath:destDir  fromPath:selectedrecording.filepath];
                    //                    }
                }
                
                
                [cell hideUtilityButtonsAnimated:YES];
                //cell.userInteractionEnabled = YES;
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iEditSmart" message:@"Please Check the internet Connection."  delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
            }
            break;
        }
        case 1:
        {
            // Delete button was pressed
            selectedIndexPath = [self.LibraryTable indexPathForCell:cell];
            NSLog(@"selected recording %@ ",mediaPath);
            
            [DELEGATE.managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:selectedIndexPath]];
            
            NSError *error = nil;
            if (![DELEGATE.managedObjectContext save:&error])
            {
                // handle error
            }
            
            
            BOOL success = [[NSFileManager defaultManager] removeItemAtPath:mediaPath error:&error];
            if (success)
            {
                NSLog(@"selected recording %@ ",selectedrecording.filepath);
                
            }
            else
            {
                NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
            }
            
            break;
        }
        default:
            break;
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell {
    return YES;
}


//------------------------------------------------------------------------------------------------------------//
//------- Dropbox Delegate -----------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - DBRestClientDelegate methods

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (BOOL)isDropboxLinked
{
    return [[DBSession sharedSession] isLinked];
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    NSMutableArray *dirList = [[NSMutableArray alloc] init];
    
    if (metadata.isDirectory) {
        for (DBMetadata *file in metadata.contents) {
            if ([file.filename hasSuffix:@".m4a"]) {
                // Add to list if not '.exe' and either the file is a directory, there are no allowed files set or the file ext is contained in the allowed types
                //                if ([file isDirectory] || allowedFileTypes.count == 0 || [allowedFileTypes containsObject:[file.filename pathExtension]] ) {
                [dirList addObject:file];
                //                }
            }
        }
    }
    
    //    fileList = dirList;
    //
    //    [self updateTableData];
    
}


- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath metadata:(DBMetadata *)metadata
{
    [self resetProgress];
    //sagar remove zip folder from ios document directory
    NSString *extensionOfFile = [srcPath pathExtension];
    if([extensionOfFile isEqualToString:@"zip"]){
        [[NSFileManager defaultManager] removeItemAtPath:srcPath error:nil];
    }
    NSLog(@"File uploaded successfully to path: %@ %@", metadata.path, srcPath);
    [ALToastView toastInView:self.view withText:@"File uploaded successfully."];
    //sagar - alert view after file uploaded in dropbox
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iEditSmart" message:@"File uploaded successfully."  delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    //    [alert show];
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    NSLog(@"File upload failed with error: %@", error);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iEditSmart" message:[NSString stringWithFormat:@"File could not be uploaded.\n Please try again later." ]  delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
    [self resetProgress];
    
}


- (void)restClient:(DBRestClient*)client uploadProgress:(CGFloat)progress forFile:(NSString *)destPath from:(NSString *)srcPath
{
    
    [_progress setProgress:progress];
}


-(void)resetProgress
{
    [_progress setHidden:YES];
    
    [_progress setProgress:0];
    
}
#pragma mark NSFetchResultsController Methods
- (NSFetchedResultsController *)fetchedResultsController
{
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:entityNameString inManagedObjectContext:DELEGATE.managedObjectContext ];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setPredicate:fetchPredicate];
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:DELEGATE.managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:nil];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

#pragma mark ~
#pragma mark NSFetchResultsController Delegate Methods
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.LibraryTable beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.LibraryTable;
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
    [recordingsArray removeAllObjects];
    [recordingNamesArray removeAllObjects];
    [tableView endUpdates];
    
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.LibraryTable insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.LibraryTable deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
    
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    
    [self.LibraryTable endUpdates];
    
}

-(NSString *)getDuration:(NSString *)mediapath
{
    NSURL *afUrl = [NSURL fileURLWithPath:mediapath];
    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:afUrl options:nil];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds =  CMTimeGetSeconds(audioDuration);
    
    NSUInteger durationInSeconds = floor(audioDurationSeconds);
    NSUInteger durationInMinutes = durationInSeconds / 60;
    NSUInteger durationInRemainder = durationInSeconds % 60;
    
    NSString *finalDurationString = [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long)durationInMinutes, (unsigned long)durationInRemainder];
    
    return finalDurationString;
}


#pragma mark -

@end
