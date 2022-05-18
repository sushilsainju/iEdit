//
//  DropboxViewController.h
//  iEditFast
//
//  Created by SUSHIL on 2/13/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import "SWTableViewCell.h"
#import "Library.h"
#import "iEditDataModel.h"
#import "OverlayView.h"
#import "ALToastView.h"



typedef enum kDBFileConflictError : NSInteger {
    kDBDropboxFileNewerError = 1,
    kDBDropboxFileOlderError = 2,
    kDBDropboxFileSameAsLocalFileError = 3
} kDBFileConflictError;

@class iEditDataModel;
@class DBRestClient;
@class DBMetadata;
@protocol DropboxBrowserDelegate;


@interface DropboxViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,DBRestClientDelegate>
{
    DBMetadata *selectedFile;

    DBRestClient *restClient;
    UIBackgroundTaskIdentifier backgroundProcess;
    BOOL isLocalFileOverwritten;
    DropboxViewController *newSubdirectoryController;


}

@property(nonatomic, retain) OverlayView *overlayView;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;

@property (weak, nonatomic) IBOutlet UIView *ContainerView;
@property (weak, nonatomic) IBOutlet UIView *TableViewContainer;
@property (weak, nonatomic) IBOutlet UITableView *dropBoxTableView;
//sagar
@property  (strong,retain) NSMutableArray *bookmarksArray;


/// Dropbox Delegate Property
@property (nonatomic, weak) id <DropboxBrowserDelegate> rootViewDelegate;

/// The file path that the current DropboxBrowserViewController is at
@property (nonatomic, strong) NSString *currentPath;

/// The list of files currently being displayed in the DropboxBrowserViewController
@property (nonatomic, copy, readwrite) NSMutableArray *fileList;


/// Set the tableview cell ID for dequeueing
@property (nonatomic, strong) NSString *tableCellID;
@property (nonatomic, retain) iEditDataModel* dataModel;

@property (nonatomic, strong) Library *libraryManager;
@end

@protocol DropboxBrowserDelegate <NSObject>

@optional

//----------------------------------------------------------------------------------------//
// Available Methods - Use these delegate methods for a variety of operations and events  //
//----------------------------------------------------------------------------------------//

/// Sent to the delegate when there is a successful file download
- (void)dropboxBrowser:(DropboxViewController *)browser didDownloadFile:(NSString *)fileName didOverwriteFile:(BOOL)isLocalFileOverwritten;

/// Sent to the delegate if DropboxBrowser failed to download file from Dropbox
- (void)dropboxBrowser:(DropboxViewController *)browser didFailToDownloadFile:(NSString *)fileName;

/// Sent to the delegate if the selected file already exists locally
- (void)dropboxBrowser:(DropboxViewController *)browser fileConflictWithLocalFile:(NSURL *)localFileURL withDropboxFile:(DBMetadata *)dropboxFile withError:(NSError *)error;

/// Sent to the delegate when the user selects a file. Implementing this method will require you to download or manage the selection on your own. Otherwise, automatically downloads file if not implemented.
- (void)dropboxBrowser:(DropboxViewController *)browser didSelectFile:(DBMetadata *)file;

/// Sent to the delegate if the share link is successfully loaded
- (void)dropboxBrowser:(DropboxViewController *)browser didLoadShareLink:(NSString *)link;

/// Sent to the delegate if there was an error creating or loading share link
- (void)dropboxBrowser:(DropboxViewController *)browser didFailToLoadShareLinkWithError:(NSError *)error;

/// Sent to the delegate when a file download notification is delivered to the user. You can use this method to record the notification ID so you can clear the notification if ncessary.
- (void)dropboxBrowser:(DropboxViewController *)browser deliveredFileDownloadNotification:(UILocalNotification *)notification;

/// Sent to the delegate after the DropboxBrowserViewController is dismissed by the user - Do \b NOT use this method to dismiss the DropboxBrowser
- (void)dropboxBrowserDismissed:(DropboxViewController *)browser;

//---------------------------------------------------------------------------------//
// Deprecated Methods - These methods will become unavailable in a future version  //
//---------------------------------------------------------------------------------//

/** DEPRECATED. Called when a file finishes downloading. @deprecated This method is deprecated. Use \p dropboxBrowser:didDownloadFile:didOverwriteFile:  instead */
- (void)dropboxBrowser:(DropboxViewController *)browser downloadedFile:(NSString *)fileName __deprecated;

/** DEPRECATED. Called when a file finishes downloading. @deprecated This method is deprecated. Use \p dropboxBrowser:didDownloadFile:didOverwriteFile: instead */
- (void)dropboxBrowser:(DropboxViewController *)browser downloadedFile:(NSString *)file isLocalFileOverwritten:(BOOL)isLocalFileOverwritten __deprecated;

/** DEPRECATED. Called when a file is selected for download. @deprecated This method is deprecated. Use \p dropboxBrowser:didSelectFile: instead */
- (void)dropboxBrowser:(DropboxViewController *)browser selectedFile:(DBMetadata *)file __deprecated;

/** DEPRECATED. Called when a file download fails. @deprecated This method is deprecated. Use \p dropboxBrowser:didFailToDownloadFile: instead */
- (void)dropboxBrowser:(DropboxViewController *)browser failedToDownloadFile:(NSString *)fileName __deprecated;

/** DEPRECATED. Called when there is a conflict between a Dropbox file and a local file. @deprecated This method is deprecated. Use \p dropboxBrowser:fileConflictWithLocalFile:withDropboxFile:withError: instead */
- (void)dropboxBrowser:(DropboxViewController *)browser fileConflictError:(NSDictionary *)error __deprecated;

/** DEPRECATED. Called when a there is an error creating a share link. @deprecated This method is deprecated. Use \p dropboxBrowser:didFailToLoadShareLinkWithError: instead */
- (void)dropboxBrowser:(DropboxViewController *)browser failedLoadingShareLinkWithError:(NSError *)error __deprecated;

//--------------------------------------------------------------------------------------//
// Unavailable Methods - These methods are never called and are not in use. Do not use  //
//--------------------------------------------------------------------------------------//
- (void)removeDropboxBrowser __unavailable;
- (void)refreshLibrarySection __unavailable;
- (void)dropboxBrowserDismissed __unavailable;
- (void)dropboxBrowserDownloadedFile:(NSString *)fileName __unavailable;
- (void)dropboxBrowserFailedToDownloadFile:(NSString *)fileName __unavailable;
- (void)dropboxBrowserFileConflictError:(NSDictionary *)conflict __unavailable;


@end
