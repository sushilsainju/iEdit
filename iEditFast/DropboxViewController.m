//
//  DropboxViewController.m
//  iEditFast
//
//  Created by SUSHIL on 2/13/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import "DropboxViewController.h"
#import "SharedStore.h"
#import "iEditLibraryCell.h"
#import "iEditAppDelegate.h"

// View tags to differeniate alert views
static NSUInteger const kDBSignInAlertViewTag = 1;
static NSUInteger const kFileExistsAlertViewTag = 2;
static NSUInteger const kDBSignOutAlertViewTag = 3;

@interface DropboxViewController ()

@end

@implementation DropboxViewController

@synthesize dropBoxTableView;
@synthesize ContainerView,TableViewContainer;
@synthesize currentPath;
@synthesize fileList,tableCellID;
@synthesize dataModel,libraryManager;
@synthesize overlayView;
@synthesize bookmarksArray;

static NSString *currentFileName = nil;
//BOOL downloadSuccess=NO;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        isLocalFileOverwritten = NO;
        restClient.delegate=self;
        // Custom initialization
        
        dataModel=[[iEditDataModel alloc]init];
        dataModel.managedObjectContext=[DELEGATE managedObjectContext];
        
        overlayView = [[OverlayView alloc] initWithFrame:DELEGATE.window.frame opacity:1.0 color:[UIColor colorWithWhite:0.2 alpha:0.5] animDuration:0.5];
        overlayView.headerText = @"iEditSmart";
        overlayView.footerText = @"Loading";
        
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    [self customizeView];
    
    self.navigationController.navigationBar.hidden = NO;
    if (self.currentPath == nil || [self.currentPath isEqualToString:@""]) self.currentPath = @"/";
    
    // Add a refresh control, pull down to refresh
    if ([UIRefreshControl class]) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.tintColor = [UIColor colorWithRed:0.0/255.0f green:122.0/255.0f blue:255.0/255.0f alpha:1.0f];
        [refreshControl addTarget:self action:@selector(updateContent) forControlEvents:UIControlEventValueChanged];
        //        self.refreshControl = refreshControl;
    }
    [[SharedStore store] customizeNavigationBar];
    //    if (![[DBSession sharedSession] isLinked]) {
    //        [[DBSession sharedSession] linkFromController:self];
    //    }
    //    // Initialize Directory Content
    //    if ([self.currentPath isEqualToString:@"/"]) {
    //        [self listDirectoryAtPath:@"/"];
    //    }
    //[overlayView showInView:DELEGATE.window withActivityIndicator:YES];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self resetProgress];
    NSLog(@"rest delegate= %@",restClient.delegate);
    NSError *error;
    //sagar - check internet connection before connecting to dropbox for listing the files
    NSString *URLString = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.google.com"] encoding:NSASCIIStringEncoding error:&error];
    
    if(URLString != NULL)
    {
        if (![self isDropboxLinked])
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login to Dropbox" message:[NSString stringWithFormat:@"%@ is not linked to your Dropbox. Would you like to login now and allow access?", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login", nil];
            alertView.tag = kDBSignInAlertViewTag;
            [alertView show];
        }
        if (![[DBSession sharedSession] isLinked])
        {
            [[DBSession sharedSession] linkFromController:self];
        }
        // Initialize Directory Content
        if ([self.currentPath isEqualToString:@"/"]) {
            [self listDirectoryAtPath:@"/"];
        }
        //        [overlayView showInView:DELEGATE.window withActivityIndicator:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iEditSmart" message:@"Please Check the internet Connection."  delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
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

+ (NSString *)fileName {
    return currentFileName;
}


-(void)customizeView
{
    
    CGRect frame;
    frame = ContainerView.frame;
    frame.size.height = ScreenSize.height-StatusbarFrame.size.height-NavigationbarFrame.size.height+IOS_Delta;
    
    [ContainerView setFrame:frame];
    
    CGRect tableViewFrame = self.dropBoxTableView.frame;
    tableViewFrame.size.height = ContainerView.frame.size.height-dropBoxTableView.frame.origin.y-TABBAR_Frame.size.height;
    self.dropBoxTableView.frame = tableViewFrame;
    
    CGRect uploadFrame;
    uploadFrame = _progress.frame;
    uploadFrame.origin.y = tableViewFrame.origin.y+StatusbarFrame.size.height+NavigationbarFrame.size.height;
    [_progress setFrame:uploadFrame];
}


-(void)resetProgress
{
    [_progress setHidden:YES];
    
    [_progress setProgress:0];
    
}
#pragma mark -



#pragma mark UITableView Datasource/Delegate

//------------------------------------------------------------------------------------------------------------//
//------- Table View -----------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([fileList count] == 0) {
        return 2; // Return cell to show the folder is empty
    } else {
        return [fileList count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([fileList count] == 0)
    {
        // There are no files in the directory - let the user know
        
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        return cell;
        
    } else
    {            UITableViewCell *cell = [[UITableViewCell alloc] init];
        
        //        // Check if the table cell ID has been set, otherwise create one
        //        if (!tableCellID || [tableCellID isEqualToString:@""]) {
        //            tableCellID = @"iEditLibraryCell";
        //        }
        //
        //        // Create the table view cell
        //        iEditLibraryCell *cell = (iEditLibraryCell *)[dropBoxTableView dequeueReusableCellWithIdentifier:tableCellID];
        //        if (cell == nil) {
        //            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"iEditLibraryCell" owner:nil options:nil];
        //            for (id currentObject in topLevelObjects) {
        //                if([currentObject isKindOfClass:[UITableViewCell class]]){
        //                    cell = (iEditLibraryCell *) currentObject;
        //                }
        //            }
        //        }
        
        // Configure the Dropbox Data for the cell
        DBMetadata *file = (DBMetadata *)[fileList objectAtIndex:indexPath.row];
        
        NSString* fname = [[file.filename lastPathComponent] stringByDeletingPathExtension];
        // Setup the cell file name
        NSLog(@"filename %@",fname);
        cell.textLabel.text = fname;
        cell.textLabel.textColor=[UIColor lightGrayColor];
        [cell.textLabel setNeedsDisplay];
        [dropBoxTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        // Display icon
        //        cell.imageView.image = [UIImage imageNamed:file.icon];
        
        // Setup Last Modified Date
        NSLocale *locale = [NSLocale currentLocale];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"E MMM d yyyy" options:0 locale:locale];
        [formatter setDateFormat:dateFormat];
        [formatter setLocale:locale];
        
        // Get File Details and Display
        if ([file isDirectory]) {
            // Folder
            cell.detailTextLabel.text = @"";
            [cell.detailTextLabel setNeedsDisplay];
        } else {
            // File
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, modified %@", file.humanReadableSize, [formatter stringFromDate:file.lastModifiedDate]];
            [cell.detailTextLabel setNeedsDisplay];
        }
        
        return cell;
    }
}


- (void)tableView: (UITableView*)tableView willDisplayCell: (UITableViewCell*)cell forRowAtIndexPath: (NSIndexPath*)indexPath
{
    
    if(indexPath.row % 2 == 0)
        cell.backgroundColor = Color_Grey_06;
    else
        cell.backgroundColor = [UIColor whiteColor];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath == nil)
        return;
    if ([fileList count] == 0)
    {
        // Do nothing, there are no items in the list. We don't want to download a file that doesn't exist (that'd cause a crash)
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else
    {
        
        selectedFile = (DBMetadata *)[fileList objectAtIndex:indexPath.row];
        if ([selectedFile isDirectory])
        {
            // Create new UITableViewController
            newSubdirectoryController = [[DropboxViewController alloc] init];
            newSubdirectoryController.rootViewDelegate = self.rootViewDelegate;
            NSString *subpath = [currentPath stringByAppendingPathComponent:selectedFile.filename];
            newSubdirectoryController.currentPath = subpath;
            newSubdirectoryController.title = [subpath lastPathComponent];
            //            newSubdirectoryController.shouldDisplaySearchBar = self.shouldDisplaySearchBar;
            //            newSubdirectoryController.deliverDownloadNotifications = self.deliverDownloadNotifications;
            //            newSubdirectoryController.allowedFileTypes = self.allowedFileTypes;
            newSubdirectoryController.tableCellID = self.tableCellID;
            
            [newSubdirectoryController listDirectoryAtPath:subpath];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            [self.navigationController pushViewController:newSubdirectoryController animated:YES];
        }
        else
        {
            currentFileName = selectedFile.filename;
            
            // Check if our delegate handles file selection
            if ([self.rootViewDelegate respondsToSelector:@selector(dropboxBrowser:didSelectFile:)]) {
                [self.rootViewDelegate dropboxBrowser:self didSelectFile:selectedFile];
            }
            else if ([self.rootViewDelegate respondsToSelector:@selector(dropboxBrowser:selectedFile:)])
            {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                [self.rootViewDelegate dropboxBrowser:self selectedFile:selectedFile];
#pragma clang diagnostic pop
            }
            else
            {
                // Download file
                //sagar - check internet connection before connecting to dropbox for listing the files
                NSString *URLString = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.google.com"]];
                
                if(URLString != NULL) {
                    [self downloadFile:selectedFile replaceLocalVersion:NO];
                    [tableView deselectRowAtIndexPath:indexPath animated:YES];
                    [tableView reloadData];
                    [_progress setHidden:NO];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iEditSmart" message:@"Please Check the internet Connection."  delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alert show];
                }
            }
        }
        
    }
}

#pragma mark -
//------------------------------------------------------------------------------------------------------------//
//------- Content Refresh ------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - Content Refresh

- (void)updateTableData {
    [dropBoxTableView deselectRowAtIndexPath:[dropBoxTableView indexPathForSelectedRow] animated:YES];
    
    [dropBoxTableView reloadData];
    [self customizeView];
    //    [self.refreshControl endRefreshing];
}

- (void)updateContent {
    //    [self listDirectoryAtPath:currentPath];
}


//------------------------------------------------------------------------------------------------------------//
//------- Files and Directories ------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - Dropbox File and Directory Functions

- (BOOL)listDirectoryAtPath:(NSString *)path {
    if ([self isDropboxLinked]) {
        [[self restClient] loadMetadata:path];
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isDropboxLinked {
    return [[DBSession sharedSession] isLinked];
}

- (BOOL)downloadFile:(DBMetadata *)file replaceLocalVersion:(BOOL)replaceLocalVersion {
    // Begin Background Process
    [_progress setHidden:NO];
    
    backgroundProcess = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:backgroundProcess];
        backgroundProcess = UIBackgroundTaskInvalid;
    }];
    
    // Check if the file is a directory
    if (file.isDirectory) return NO;
    
    // Set download success
    BOOL downloadSuccess = NO;
    
    // Setup the File Manager
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Create the local file path
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *localPath = [documentsPath stringByAppendingPathComponent:file.filename];
    
    // Check if the local version should be overwritten
    if (replaceLocalVersion) {
        isLocalFileOverwritten = YES;
        [fileManager removeItemAtPath:localPath error:nil];
    } else {
        isLocalFileOverwritten = NO;
    }
    
    // Check if a file with the same name already exists locally
    NSString* ext = [localPath pathExtension];
    NSString *m4aFilePathReplacingZip = [localPath stringByReplacingOccurrencesOfString:@"zip"
                                                                             withString:@"m4a"];
    //NSString *localPathZipFolderButReplacingExtensionWithM4A;
    
    NSString *localPathForBothZipAndM4AFile;
    
    
    
    if([ext isEqualToString:@"zip"]){
        localPathForBothZipAndM4AFile = m4aFilePathReplacingZip;
    } else if([ext isEqualToString:@"m4a"]){
        localPathForBothZipAndM4AFile = localPath;
    }
    
    
    
    
    if ([fileManager fileExistsAtPath:localPathForBothZipAndM4AFile] == NO) //sagar if file does not exists
    {
        // Prevent the user from downloading any more files while this donwload is in progress
        dropBoxTableView.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.75 animations:^{
            dropBoxTableView.alpha = 0.8;
        }];
        
        // Start the file download
        //        [self startDownloadFile];
        if(![ext isEqualToString:@"zip"]){
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        
        [defaults setObject:@"yesDownloading" forKey:@"isDownloading"];
        }
        [[self restClient] loadFile:file.path intoPath:localPath];
        
        // The download was a success
        downloadSuccess = YES;
        [ALToastView toastInView:self.view withText:@"Download started."];
        
    } else {
        // Create the local URL and get the modification date
        NSString* ext = [localPath pathExtension];
        NSString *m4aFilePathReplacingZip = [localPath stringByReplacingOccurrencesOfString:@"zip"
                                                                                 withString:@"m4a"];
        NSURL *fileUrl;
        if([ext isEqualToString:@"zip"]){
            fileUrl= [NSURL fileURLWithPath:m4aFilePathReplacingZip];
        }else {
            fileUrl= [NSURL fileURLWithPath:localPath];
        }
        NSDate *fileDate;
        NSError *error;
        [fileUrl getResourceValue:&fileDate forKey:NSURLContentModificationDateKey error:&error];
        
        if (!error)
        {
            NSComparisonResult result;
            result = [file.lastModifiedDate compare:fileDate]; // Compare the Dates
            
            if (result == NSOrderedAscending)
            {
                // Dropbox file is older than local file
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"File Conflict" message:[NSString stringWithFormat:@"%@ has already been downloaded from Dropbox. You can overwrite the local version with the Dropbox one. The file in local files is newer than the Dropbox file.", [file.filename stringByReplacingOccurrencesOfString:@"zip" withString:@"m4a"]] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Overwrite", nil];
                alertView.tag = kFileExistsAlertViewTag;
                [alertView show];
                
                NSDictionary *infoDictionary = @{@"file": file, @"message": @"File already exists in Dropbox and locally. The local file is newer."};
                NSError *error = [NSError errorWithDomain:@"[DropboxBrowser] File Conflict Error: File already exists in Dropbox and locally. The local file is newer." code:kDBDropboxFileOlderError userInfo:infoDictionary];
                
                if ([self.rootViewDelegate respondsToSelector:@selector(dropboxBrowser:fileConflictWithLocalFile:withDropboxFile:withError:)]) {
                    [self.rootViewDelegate dropboxBrowser:self fileConflictWithLocalFile:fileUrl withDropboxFile:file withError:error];
                } else if ([[self rootViewDelegate] respondsToSelector:@selector(dropboxBrowser:fileConflictError:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    [[self rootViewDelegate] dropboxBrowser:self fileConflictError:infoDictionary];
#pragma clang diagnostic pop
                }
                
            } else if (result == NSOrderedDescending) {
                // Dropbox file is newer than local file
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"File Conflict" message:[NSString stringWithFormat:@"%@ has already been downloaded from Dropbox. You can overwrite the local version with the Dropbox file. The file in Dropbox is newer than the local file.", [file.filename stringByReplacingOccurrencesOfString:@"zip" withString:@"m4a"]] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Overwrite", nil];
                alertView.tag = kFileExistsAlertViewTag;
                [alertView show];
                
                NSDictionary *infoDictionary = @{@"file": file, @"message": @"File already exists in Dropbox and locally. The Dropbox file is newer."};
                NSError *error = [NSError errorWithDomain:@"[DropboxBrowser] File Conflict Error: File already exists in Dropbox and locally. The Dropbox file is newer." code:kDBDropboxFileNewerError userInfo:infoDictionary];
                
                if ([self.rootViewDelegate respondsToSelector:@selector(dropboxBrowser:fileConflictWithLocalFile:withDropboxFile:withError:)]) {
                    [self.rootViewDelegate dropboxBrowser:self fileConflictWithLocalFile:fileUrl withDropboxFile:file withError:error];
                } else if ([[self rootViewDelegate] respondsToSelector:@selector(dropboxBrowser:fileConflictError:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    [[self rootViewDelegate] dropboxBrowser:self fileConflictError:infoDictionary];
#pragma clang diagnostic pop
                }
            } else if (result == NSOrderedSame) {
                // Dropbox File and local file were both modified at the same time
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"File Conflict" message:[NSString stringWithFormat:@"%@ has already been downloaded from Dropbox. You can overwrite the local version with the Dropbox file. Both the local file and the Dropbox file were modified at the same time.", [file.filename stringByReplacingOccurrencesOfString:@"zip" withString:@"m4a"]] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Overwrite", nil];
                alertView.tag = kFileExistsAlertViewTag;
                [alertView show];
                
                NSDictionary *infoDictionary = @{@"file": file, @"message": @"File already exists in Dropbox and locally. Both files were modified at the same time."};
                NSError *error = [NSError errorWithDomain:@"[DropboxBrowser] File Conflict Error: File already exists in Dropbox and locally. Both files were modified at the same time." code:kDBDropboxFileSameAsLocalFileError userInfo:infoDictionary];
                
                if ([self.rootViewDelegate respondsToSelector:@selector(dropboxBrowser:fileConflictWithLocalFile:withDropboxFile:withError:)]) {
                    [self.rootViewDelegate dropboxBrowser:self fileConflictWithLocalFile:fileUrl withDropboxFile:file withError:error];
                } else if ([[self rootViewDelegate] respondsToSelector:@selector(dropboxBrowser:fileConflictError:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    [[self rootViewDelegate] dropboxBrowser:self fileConflictError:infoDictionary];
#pragma clang diagnostic pop
                }
            }
            
            
        } else {
            downloadSuccess = NO;
        }
    }
    [self updateTableData];
    dropBoxTableView.userInteractionEnabled = YES;
    
    return downloadSuccess;
}

- (void)loadShareLinkForFile:(DBMetadata*)file {
    [self.restClient loadSharableLinkForFile:file.path shortUrl:YES];
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

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    NSMutableArray *dirList = [[NSMutableArray alloc] init];
    if ([overlayView isActive]) {
        [overlayView hide];
    }
    if (metadata.isDirectory) {
        for (DBMetadata *file in metadata.contents) {
            if ([file.filename hasSuffix:@".exe"] || file.isDirectory) {
                // Add to list if not '.exe' and either the file is a directory, there are no allowed files set or the file ext is contained in the allowed types
                //                if ([file isDirectory] || allowedFileTypes.count == 0 || [allowedFileTypes containsObject:[file.filename pathExtension]] ) {
                [dirList removeObject:file];
                //                }
            } else {
                [dirList addObject:file];
            }
        }
    }
    
    fileList = dirList;
    
    [self updateTableData];
    
}

- (void)restClient:(DBRestClient *)client loadedSearchResults:(NSArray *)results forPath:(NSString *)path keyword:(NSString *)keyword {
    fileList = [NSMutableArray arrayWithArray:results];
    [self updateTableData];
}

- (void)restClient:(DBRestClient *)restClient searchFailedWithError:(NSError *)error {
    [self updateTableData];
    
}
//
- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
    [self updateTableData];
}

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)localPath {
    //[self downloadedFile];
    if ([overlayView isActive]) {
        [overlayView hide];
    }
    
    [self resetProgress];
    
    
    
    NSString* m4aFilenameFromZipFolder = [NSString stringWithFormat:@"%@.m4a", [[localPath lastPathComponent] stringByDeletingPathExtension]];
    NSString *m4aFilePathReplacingZip = [localPath stringByReplacingOccurrencesOfString:@"zip"
                                                                             withString:@"m4a"];
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSMutableDictionary *recordingDictionaryComposite;
    NSString* m4aFilenameWithCompositeFromZipFolder = [NSString stringWithFormat:@"%@composite.m4a", [[localPath lastPathComponent] stringByDeletingPathExtension]];
        NSString *m4aFilePathWithComposite = [NSString stringWithFormat:@"%@/%@", documentsDirectory,m4aFilenameWithCompositeFromZipFolder];

    NSMutableDictionary *recordingDictionaryEdit1;
    NSString* edit1FileNameFromZipFolder = [NSString stringWithFormat:@"%@-1.m4a", [[localPath lastPathComponent] stringByDeletingPathExtension]];
    NSString *edit1FilePathWithComposite = [NSString stringWithFormat:@"%@/%@", documentsDirectory,edit1FileNameFromZipFolder];
    
    NSMutableDictionary *recordingDictionaryEdit2;
    NSString* edit2FileNameFromZipFolder = [NSString stringWithFormat:@"%@-2.m4a", [[localPath lastPathComponent] stringByDeletingPathExtension]];
    NSString *edit2FilePathWithComposite = [NSString stringWithFormat:@"%@/%@", documentsDirectory,edit2FileNameFromZipFolder];
    
    NSMutableDictionary *recordingDictionaryEdit3;
    NSString* edit3FileNameFromZipFolder = [NSString stringWithFormat:@"%@-3.m4a", [[localPath lastPathComponent] stringByDeletingPathExtension]];
    NSString *edit3FilePathWithComposite = [NSString stringWithFormat:@"%@/%@", documentsDirectory,edit3FileNameFromZipFolder];
    
    NSMutableDictionary *recordingDictionaryEdit4;
    NSString* edit4FileNameFromZipFolder = [NSString stringWithFormat:@"%@-4.m4a", [[localPath lastPathComponent] stringByDeletingPathExtension]];
    NSString *edit4FilePathWithComposite = [NSString stringWithFormat:@"%@/%@", documentsDirectory,edit4FileNameFromZipFolder];
    
    NSMutableDictionary *recordingDictionaryEdit5;
    NSString* edit5FileNameFromZipFolder = [NSString stringWithFormat:@"%@-5.m4a", [[localPath lastPathComponent] stringByDeletingPathExtension]];
    NSString *edit5FilePathWithComposite = [NSString stringWithFormat:@"%@/%@", documentsDirectory,edit5FileNameFromZipFolder];
    
    NSMutableDictionary *recordingDictionaryEdit6;
    NSString* edit6FileNameFromZipFolder = [NSString stringWithFormat:@"%@-6.m4a", [[localPath lastPathComponent] stringByDeletingPathExtension]];
    NSString *edit6FilePathWithComposite = [NSString stringWithFormat:@"%@/%@", documentsDirectory,edit6FileNameFromZipFolder];
    
    NSMutableDictionary *recordingDictionaryEdit7;
    NSString* edit7FileNameFromZipFolder = [NSString stringWithFormat:@"%@-7.m4a", [[localPath lastPathComponent] stringByDeletingPathExtension]];
    NSString *edit7FilePathWithComposite = [NSString stringWithFormat:@"%@/%@", documentsDirectory,edit7FileNameFromZipFolder];
    
    NSMutableDictionary *recordingDictionaryEdit8;
    NSString* edit8FileNameFromZipFolder = [NSString stringWithFormat:@"%@-8.m4a", [[localPath lastPathComponent] stringByDeletingPathExtension]];
    NSString *edit8FilePathWithComposite = [NSString stringWithFormat:@"%@/%@", documentsDirectory,edit8FileNameFromZipFolder];
    
    NSMutableDictionary *recordingDictionaryEdit9;
    NSString* edit9FileNameFromZipFolder = [NSString stringWithFormat:@"%@-9.m4a", [[localPath lastPathComponent] stringByDeletingPathExtension]];
    NSString *edit9FilePathWithComposite = [NSString stringWithFormat:@"%@/%@", documentsDirectory,edit9FileNameFromZipFolder];
    
    NSMutableDictionary *recordingDictionaryEdit10;
    NSString* edit10FileNameFromZipFolder = [NSString stringWithFormat:@"%@-10.m4a", [[localPath lastPathComponent] stringByDeletingPathExtension]];
    NSString *edit10FilePathWithComposite = [NSString stringWithFormat:@"%@/%@", documentsDirectory,edit10FileNameFromZipFolder];
    
    
    
    [ALToastView toastInView:self.view withText:@"File downloaded successfully."];
    
    NSString* ext = [localPath pathExtension];
    
    NSMutableDictionary  *recordingDictionary;
    /*if([ext isEqualToString:@"zip"]){
        
    } else if([ext isEqualToString:@"m4a"]) {
        
    }*/
    
    NSMutableArray *bookmarks=[[NSMutableArray alloc]init];
    dataModel.isMaster=YES;
    
    
        
        
        bookmarksArray =[[NSMutableArray alloc]init];
        
        //sagar - unzipping the directory
       // NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *zipFilePath =localPath;
        
        //NSString *output = [documentsDirectory stringByAppendingPathComponent:@"unZipDirName"];
        NSString *output = documentsDirectory;
        ZipArchive* za = [[ZipArchive alloc] init];
        
        if( [za UnzipOpenFile:zipFilePath] ) {
            if( [za UnzipFileTo:output overWrite:YES] != NO ) {
                //unzip data success remove zip folder
                [[NSFileManager defaultManager] removeItemAtPath:zipFilePath error:nil];
            }
            [za UnzipCloseFile];
        }
        //unzipping finished
    
    if([ext isEqualToString:@"zip"]){
        recordingDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                               m4aFilenameFromZipFolder, @"Name",
                               m4aFilePathReplacingZip, @"Path",
                               [NSDate date], @"date",
                               nil];
        if ([[NSFileManager defaultManager] isReadableFileAtPath:m4aFilePathWithComposite] ){
            recordingDictionaryComposite = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            m4aFilenameWithCompositeFromZipFolder, @"Name",
                                            m4aFilePathWithComposite, @"Path",
                                            [NSDate date], @"date",
                                            nil];
        }
        if ([[NSFileManager defaultManager] isReadableFileAtPath:edit1FilePathWithComposite] ){
            recordingDictionaryEdit1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        edit1FileNameFromZipFolder, @"Name",
                                        edit1FilePathWithComposite, @"Path",
                                        [NSDate date], @"date",
                                        nil];
        }
        if ([[NSFileManager defaultManager] isReadableFileAtPath:edit2FilePathWithComposite] ){
            recordingDictionaryEdit2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        edit2FileNameFromZipFolder, @"Name",
                                        edit2FilePathWithComposite, @"Path",
                                        [NSDate date], @"date",
                                        nil];
        }
        if ([[NSFileManager defaultManager] isReadableFileAtPath:edit3FilePathWithComposite] ){
            recordingDictionaryEdit3 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        edit3FileNameFromZipFolder, @"Name",
                                        edit3FilePathWithComposite, @"Path",
                                        [NSDate date], @"date",
                                        nil];
        }
        
        if ([[NSFileManager defaultManager] isReadableFileAtPath:edit4FilePathWithComposite] ){
            recordingDictionaryEdit4 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        edit4FileNameFromZipFolder, @"Name",
                                        edit4FilePathWithComposite, @"Path",
                                        [NSDate date], @"date",
                                        nil];
        }
        
        if ([[NSFileManager defaultManager] isReadableFileAtPath:edit5FilePathWithComposite] ){
            recordingDictionaryEdit5 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        edit5FileNameFromZipFolder, @"Name",
                                        edit5FilePathWithComposite, @"Path",
                                        [NSDate date], @"date",
                                        nil];
        }
        if ([[NSFileManager defaultManager] isReadableFileAtPath:edit6FilePathWithComposite] ){
            recordingDictionaryEdit6 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        edit6FileNameFromZipFolder, @"Name",
                                        edit6FilePathWithComposite, @"Path",
                                        [NSDate date], @"date",
                                        nil];
        }
        if ([[NSFileManager defaultManager] isReadableFileAtPath:edit7FilePathWithComposite] ){
            recordingDictionaryEdit7 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        edit7FileNameFromZipFolder, @"Name",
                                        edit7FilePathWithComposite, @"Path",
                                        [NSDate date], @"date",
                                        nil];
        }
        if ([[NSFileManager defaultManager] isReadableFileAtPath:edit8FilePathWithComposite] ){
            recordingDictionaryEdit8 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        edit8FileNameFromZipFolder, @"Name",
                                        edit8FilePathWithComposite, @"Path",
                                        [NSDate date], @"date",
                                        nil];
        }
        if ([[NSFileManager defaultManager] isReadableFileAtPath:edit9FilePathWithComposite] ){
            recordingDictionaryEdit9 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        edit9FileNameFromZipFolder, @"Name",
                                        edit9FilePathWithComposite, @"Path",
                                        [NSDate date], @"date",
                                        nil];
        }
        if ([[NSFileManager defaultManager] isReadableFileAtPath:edit10FilePathWithComposite] ){
            recordingDictionaryEdit10 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        edit10FileNameFromZipFolder, @"Name",
                                        edit10FilePathWithComposite, @"Path",
                                        [NSDate date], @"date",
                                        nil];
        }
        
        NSString *editFileWithParmsFileNameWithoutExtension = [m4aFilenameFromZipFolder stringByDeletingPathExtension];
        NSString *editFileWithParmsFileNameWithExtension = [NSString stringWithFormat:@"%@.txt",editFileWithParmsFileNameWithoutExtension];
        NSString *editTextFullPath = [output stringByAppendingPathComponent:editFileWithParmsFileNameWithExtension];
       
        NSString* contentEdit = [NSString stringWithContentsOfFile:editTextFullPath
                                                      encoding:NSUTF8StringEncoding
                                                         error:NULL];
        //sagar remove textfile in document directory
        //[[NSFileManager defaultManager] removeItemAtPath:textFullPath error:nil];
        
        NSData* plistEditData = [contentEdit dataUsingEncoding:NSUTF8StringEncoding];
        if(plistEditData != nil){
        NSString *errorEdit;
        NSPropertyListFormat formatEdit;
        NSMutableDictionary* plistEditDict = [NSPropertyListSerialization propertyListFromData:plistEditData mutabilityOption:NSPropertyListImmutable format:&formatEdit errorDescription:&errorEdit];
        NSLog( @"plist is %@ and count is %d", plistEditDict, plistEditDict.count );
        if(!plistEditDict){
            NSLog(@"Error: %@",errorEdit);
        }
        
        NSDictionary *editContentDictionary=[[NSDictionary alloc]init];
        
        editContentDictionary = plistEditDict;
        
        NSMutableArray *editArray = [[NSMutableArray alloc] init];
        [editArray addObject:editContentDictionary];
        
        if (editContentDictionary.count>0)
        {
            dataModel.chunksArray=editContentDictionary;
        }
        //sagar remove edit textfile in document directory
        //[[NSFileManager defaultManager] removeItemAtPath:editTextFullPath error:nil];
    }
        
        NSString *textFullPath = [output stringByAppendingPathComponent:@"textfile.txt"];
        //NSDictionary *dictFromFile = [NSDictionary dictionaryWithContentsOfFile:textFullPath];
        
        
        
        NSString* content = [NSString stringWithContentsOfFile:textFullPath
                                                      encoding:NSUTF8StringEncoding
                                                         error:NULL];
        //sagar remove textfile in document directory
        [[NSFileManager defaultManager] removeItemAtPath:textFullPath error:nil];
        
        NSData* plistData = [content dataUsingEncoding:NSUTF8StringEncoding];
        NSString *error;
        NSPropertyListFormat format;
        NSDictionary* plist = [NSPropertyListSerialization propertyListFromData:plistData mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&error];
        NSLog( @"plist is %@ and count is %d", plist, plist.count );
        if(!plist){
            NSLog(@"Error: %@",error);
        }
        
        //NSString *imageDesc;
        
        NSArray *bookmarkTitle=[plist valueForKey:@"title"];
        NSArray *timeString = [plist valueForKey:@"time"];
        NSArray *imagePath = [plist valueForKey:@"imagePath"];
        //int time =[timeString intValue];
        NSMutableDictionary *bookmarkcontentDictionary=[[NSMutableDictionary alloc]init];
        if(plist.count > 0 ){
        for(int i=0;i<plist.count;i++){
            [bookmarkcontentDictionary setObject:[NSNumber numberWithInt:[[timeString objectAtIndex:i] intValue]] forKey:Bookmark_param_time];
            [bookmarkcontentDictionary setObject:[bookmarkTitle objectAtIndex:i]     forKey:Bookmark_param_title];
            [bookmarkcontentDictionary setObject:[bookmarkTitle objectAtIndex:i] forKey:Bookmark_param_text];
            [bookmarkcontentDictionary setObject:[NSDate date] forKey:Bookmark_param_date];
            
            //if (imageDesc) {
            [bookmarkcontentDictionary setObject:[imagePath objectAtIndex:i] forKey:Bookmark_param_imagePath];
            //}
            [bookmarksArray addObject:bookmarkcontentDictionary];
            [dataModel insertRecordingsInLibrary:recordingDictionary andBookmarks:bookmarksArray];
            if ([[NSFileManager defaultManager] isReadableFileAtPath:m4aFilePathWithComposite] ){
            [dataModel insertRecordingsInLibrary:recordingDictionaryComposite andBookmarks:nil];
            
            }if ([[NSFileManager defaultManager] isReadableFileAtPath:edit1FilePathWithComposite] ){
            [dataModel insertRecordingsInLibrary:recordingDictionaryEdit1 andBookmarks:nil];
            }
            if ([[NSFileManager defaultManager] isReadableFileAtPath:edit2FilePathWithComposite] ){
            [dataModel insertRecordingsInLibrary:recordingDictionaryEdit2 andBookmarks:nil];
            }
            if ([[NSFileManager defaultManager] isReadableFileAtPath:edit3FilePathWithComposite] ){
            [dataModel insertRecordingsInLibrary:recordingDictionaryEdit3 andBookmarks:nil];
            }
            if ([[NSFileManager defaultManager] isReadableFileAtPath:edit4FilePathWithComposite] ){
                [dataModel insertRecordingsInLibrary:recordingDictionaryEdit4 andBookmarks:nil];
            }
            if ([[NSFileManager defaultManager] isReadableFileAtPath:edit5FilePathWithComposite] ){
                [dataModel insertRecordingsInLibrary:recordingDictionaryEdit5 andBookmarks:nil];
            }
            if ([[NSFileManager defaultManager] isReadableFileAtPath:edit6FilePathWithComposite] ){
                [dataModel insertRecordingsInLibrary:recordingDictionaryEdit6 andBookmarks:nil];
            }
            if ([[NSFileManager defaultManager] isReadableFileAtPath:edit7FilePathWithComposite] ){
                [dataModel insertRecordingsInLibrary:recordingDictionaryEdit7 andBookmarks:nil];
            }
            if ([[NSFileManager defaultManager] isReadableFileAtPath:edit8FilePathWithComposite] ){
                [dataModel insertRecordingsInLibrary:recordingDictionaryEdit8 andBookmarks:nil];
            }
            if ([[NSFileManager defaultManager] isReadableFileAtPath:edit9FilePathWithComposite] ){
                [dataModel insertRecordingsInLibrary:recordingDictionaryEdit9 andBookmarks:nil];
            }
            if ([[NSFileManager defaultManager] isReadableFileAtPath:edit10FilePathWithComposite] ){
                [dataModel insertRecordingsInLibrary:recordingDictionaryEdit10 andBookmarks:nil];
            }
            [bookmarksArray removeAllObjects];
        }
        } else {
            [dataModel insertRecordingsInLibrary:recordingDictionary andBookmarks:bookmarksArray];
            if ([[NSFileManager defaultManager] isReadableFileAtPath:m4aFilePathWithComposite] ){
                [dataModel insertRecordingsInLibrary:recordingDictionaryComposite andBookmarks:nil];
                
            }if ([[NSFileManager defaultManager] isReadableFileAtPath:edit1FilePathWithComposite] ){
                [dataModel insertRecordingsInLibrary:recordingDictionaryEdit1 andBookmarks:nil];
            }
            if ([[NSFileManager defaultManager] isReadableFileAtPath:edit2FilePathWithComposite] ){
                [dataModel insertRecordingsInLibrary:recordingDictionaryEdit2 andBookmarks:nil];
            }
            if ([[NSFileManager defaultManager] isReadableFileAtPath:edit3FilePathWithComposite] ){
                [dataModel insertRecordingsInLibrary:recordingDictionaryEdit3 andBookmarks:nil];
            }
            if ([[NSFileManager defaultManager] isReadableFileAtPath:edit4FilePathWithComposite] ){
                [dataModel insertRecordingsInLibrary:recordingDictionaryEdit4 andBookmarks:nil];
            }
            if ([[NSFileManager defaultManager] isReadableFileAtPath:edit5FilePathWithComposite] ){
                [dataModel insertRecordingsInLibrary:recordingDictionaryEdit5 andBookmarks:nil];
            }
            if ([[NSFileManager defaultManager] isReadableFileAtPath:edit6FilePathWithComposite] ){
                [dataModel insertRecordingsInLibrary:recordingDictionaryEdit6 andBookmarks:nil];
            }
            if ([[NSFileManager defaultManager] isReadableFileAtPath:edit7FilePathWithComposite] ){
                [dataModel insertRecordingsInLibrary:recordingDictionaryEdit7 andBookmarks:nil];
            }
            if ([[NSFileManager defaultManager] isReadableFileAtPath:edit8FilePathWithComposite] ){
                [dataModel insertRecordingsInLibrary:recordingDictionaryEdit8 andBookmarks:nil];
            }
            if ([[NSFileManager defaultManager] isReadableFileAtPath:edit9FilePathWithComposite] ){
                [dataModel insertRecordingsInLibrary:recordingDictionaryEdit9 andBookmarks:nil];
            }
            if ([[NSFileManager defaultManager] isReadableFileAtPath:edit10FilePathWithComposite] ){
                [dataModel insertRecordingsInLibrary:recordingDictionaryEdit10 andBookmarks:nil];
            }
            [bookmarksArray removeAllObjects];
        }
        
        
        
    }
    else {
        recordingDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                               [localPath lastPathComponent], @"Name",
                               localPath, @"Path",
                               [NSDate date], @"date",
                               nil];
        [dataModel insertRecordingsInLibrary:recordingDictionary andBookmarks:bookmarksArray];
    }
    
    
    
    //    }
}

- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error {
    //[self downloadedFileFailed];
    [self resetProgress];
    
    if ([overlayView isActive]) {
        [overlayView hide];
    }
    
}



- (void)restClient:(DBRestClient *)client loadProgress:(CGFloat)progress forFile:(NSString *)destPath {
    //[self updateDownloadProgressTo:progress];
    [_progress setProgress:progress];
}

- (void)restClient:(DBRestClient *)client loadedSharableLink:(NSString *)link forFile:(NSString *)path {
    if ([self.rootViewDelegate respondsToSelector:@selector(dropboxBrowser:didLoadShareLink:)]) {
        [self.rootViewDelegate dropboxBrowser:self didLoadShareLink:link];
    }
}

- (void)restClient:(DBRestClient *)client loadSharableLinkFailedWithError:(NSError *)error {
    if ([self.rootViewDelegate respondsToSelector:@selector(dropboxBrowser:didFailToLoadShareLinkWithError:)]) {
        [self.rootViewDelegate dropboxBrowser:self didFailToLoadShareLinkWithError:error];
    } else if ([self.rootViewDelegate respondsToSelector:@selector(dropboxBrowser:failedLoadingShareLinkWithError:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [self.rootViewDelegate dropboxBrowser:self failedLoadingShareLinkWithError:error];
#pragma clang diagnostic pop
    }
}



@end
