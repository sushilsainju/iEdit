//
//  iEditAppDelegate.m
//  iEditFast
//
//  Created by SUSHIL on 2/10/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import "iEditAppDelegate.h"
#import <DropboxSDK/DropboxSDK.h>
#import <CoreData/CoreData.h>
#import "SharedStore.h"
//#import <SpeechKit/SpeechKit.h>

@implementation iEditAppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize RecordingSetting,autoImageTimer;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] ;
    mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    self.window.backgroundColor = [UIColor whiteColor];
//    [self.window setRootViewController:mainViewController];
    [self setupTabBarController];
    //speech to text
//    iSpeechSDK *sdk = [iSpeechSDK sharedSDK];
//    sdk.APIKey = @"ea54bead0789e7fcf2c573ff5dd13604";
    
    RecordingSetting=recording_ALAC;
    if (![DEFAULTS valueForKey:Key_savedAutoImageValue])
    {
        autoImageTimer=autoimage_None;
        [DEFAULTS setInteger:autoImageTimer forKey:Key_savedAutoImageValue];
        [DEFAULTS synchronize];
    }
    else
    {
        NSInteger record=[DEFAULTS integerForKey:Key_savedAutoImageValue];
        autoImageTimer=record;

    }
    if (![DEFAULTS valueForKey:cameraTimerStringArray])
    {
        [self autoimageSettings];
    }
    if (![DEFAULTS valueForKey:editIntervalArray]||![DEFAULTS valueForKey:editIntervalArrayinSeconds])
    {
        [self editIntervalSettings ];
    }
    
    if ([DEFAULTS valueForKey:Key_savedRecorderSetting])
    {
        NSInteger record=[DEFAULTS integerForKey:Key_savedRecorderSetting];
        if (record==recording_AAC)
        {
            RecordingSetting=recording_AAC;

        }
        else
        {
            RecordingSetting=recording_ALAC;

        }
    }
    else
    {
        [DEFAULTS setInteger:RecordingSetting forKey:Key_savedRecorderSetting];
    }
   
       [self.window makeKeyAndVisible];
    DBSession *dropboxSession = [[DBSession alloc]
                        initWithAppKey:DROPBOX_AppKey
                        appSecret:DROPBOX_AppSecret
                        root:kDBRootAppFolder]; // either kDBRootAppFolder or kDBRootDropbox
    [DBSession  setSharedSession:dropboxSession];
       return YES;
    
    
}
//SPEECHKIT
//- (void)setupSpeechKitConnection {
//    [SpeechKit setupWithID:@"NMDPTRIAL_sushil20140602070543"
//                      host:@"sandbox.nmdp.nuancemobility.net"
//                      port:443
//                    useSSL:NO
//                  delegate:nil];
//    // Set earcons to play
//    SKEarcon* earconStart	= [SKEarcon earconWithName:@"earcon_listening.wav"];
//    SKEarcon* earconStop	= [SKEarcon earconWithName:@"earcon_done_listening.wav"];
//    SKEarcon* earconCancel	= [SKEarcon earconWithName:@"earcon_cancel.wav"];
//    
//    [SpeechKit setEarcon:earconStart forType:SKStartRecordingEarconType];
//    [SpeechKit setEarcon:earconStop forType:SKStopRecordingEarconType];
//    [SpeechKit setEarcon:earconCancel forType:SKCancelRecordingEarconType];
//}

-(void)autoimageSettings
{
    NSArray *array = [[NSArray alloc] initWithObjects:
                      @"Off",
                      @"2 seconds",
                      @"4 seconds",
                      @"6 seconds",
                      nil];
    
    NSArray *secondsarray = [[NSArray alloc] initWithObjects:
                             [NSNumber numberWithInteger:0],
                             [NSNumber numberWithInteger:2],
                             [NSNumber numberWithInteger:4],
                             [NSNumber numberWithInteger:6],
                                                          nil];
    [DEFAULTS setObject:secondsarray forKey:cameraTimerArrayinSeconds];
    
    [DEFAULTS setObject:array forKey:cameraTimerStringArray];
    [DEFAULTS synchronize];

}

-(void)editIntervalSettings
{
    NSArray *array = [[NSArray alloc] initWithObjects:
                      @"Current",
                      @"5 seconds",
                      @"10 seconds",
                      @"1 minute",
                      @"2 minutes",
                      @"5 minutes",
                      @"10 minutes",
                      nil];
    
    NSArray *secondsarray = [[NSArray alloc] initWithObjects:
                             [NSNumber numberWithInteger:0],
                             [NSNumber numberWithInteger:5],
                             [NSNumber numberWithInteger:10],
                             [NSNumber numberWithInteger:60],
                             [NSNumber numberWithInteger:120],
                             [NSNumber numberWithInteger:300],
                             [NSNumber numberWithInteger:600],
                             nil];
    [DEFAULTS setObject:secondsarray forKey:editIntervalArrayinSeconds];
    
    [DEFAULTS setObject:array forKey:editIntervalArray];
    
    
    
    [DEFAULTS synchronize];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"App linked successfully!");
            // At this point you can start making API calls
        }
        return YES;
    }
    // Add whatever other url handling code your app requires here
    return NO;
}

-(void)setSampleRateArray
{
    if (![DEFAULTS valueForKey:sampleRateValueArray])
    {

    NSArray *sampleRate = [[NSArray alloc] initWithObjects:
                             [NSNumber numberWithInteger:44100],
                             [NSNumber numberWithInteger:22000],
                             [NSNumber numberWithInteger:11000],
                                       nil];
        [DEFAULTS setObject:sampleRate forKey:sampleRateValueArray];
        
        NSArray *sampleRateString = [[NSArray alloc] initWithObjects:
                               @"44.1 KHz",
                               @"22 KHz",
                               @"11 KHz",
                               nil];
        [DEFAULTS setObject:sampleRateString forKey:sampleRateStringArray];
        [DEFAULTS synchronize];

    }
}

-(void)setbitRateArray
{
    if (![DEFAULTS valueForKey:bitRateValueArray])
    {
        
        NSArray *bitRate = [[NSArray alloc] initWithObjects:
                               [NSNumber numberWithInteger:8],
                               [NSNumber numberWithInteger:16],
//                                [NSNumber numberWithInteger:32],
//                                [NSNumber numberWithInteger:64],
                               nil];
        [DEFAULTS setObject:bitRate forKey:bitRateValueArray];
        
        NSArray *sampleRateString = [[NSArray alloc] initWithObjects:
                                     @"8 bits",
                                     @"16 bits",
                                     
                                     nil];
        [DEFAULTS setObject:sampleRateString forKey:bitRateStringArray];
        [DEFAULTS synchronize];
    }
}

-(void)setupTabBarController
{
    CRTabBarController *tabBarController = [[CRTabBarController alloc] init];

    NSMutableArray* viewControllers = [[NSMutableArray alloc] init];
    
    // DECLARING ROOT VIEW CONTROLLERS FOR NAVIGATION CONTROLLERS
    LibraryViewController *libraryView = [[[LibraryViewController alloc] initWithNibName:@"LibraryViewController" bundle:nil] init];
    BookmarksViewController *bookmarksView = [[[BookmarksViewController alloc] initWithNibName:@"BookmarksViewController" bundle:nil] init];
    DropboxViewController *dropboxView = [[[DropboxViewController alloc] initWithNibName:@"DropboxViewController" bundle:nil] init];
    SettingsViewController *settingsView = [[[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil] init];
    SearchViewController *searchView = [[[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil] init];
    MainViewController *mainView = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    PlaylistViewController *playlistView=[[PlaylistViewController alloc] initWithNibName:@"PlaylistViewController" bundle:nil];

    playlistView.title=@"Playlists";
    mainView.title=@"iEditSmart";//ieditSmart//iEditFaster
    searchView.title=@"Search";
    settingsView.title=@"Settings";
    libraryView.title=@"Library";
    dropboxView.title=@"Dropbox";
    bookmarksView.title=@"Bookmarks";

    UINavigationController *playlistNavigationController = [[UINavigationController alloc] initWithRootViewController:playlistView];
    UITabBarItem* playlistTabBarItem = [[UITabBarItem alloc] init];
    [playlistTabBarItem  setFinishedSelectedImage: [UIImage imageNamed: @"SELplaylist"]
                   withFinishedUnselectedImage: [UIImage imageNamed: @"TR_playlist"]];
    [playlistNavigationController setTabBarItem: playlistTabBarItem];

    
    UINavigationController *mainViewNavigationController = [[UINavigationController alloc] initWithRootViewController:mainView];
    UITabBarItem* tabBarItem = [[UITabBarItem alloc] init];
    [tabBarItem  setFinishedSelectedImage: [UIImage imageNamed: @"SELrecord"]
              withFinishedUnselectedImage: [UIImage imageNamed: @"TR_record"]];
    [mainViewNavigationController setTabBarItem: tabBarItem];
    
    UINavigationController *libraryNavigationController = [[UINavigationController alloc] initWithRootViewController:libraryView];
    UITabBarItem* libraryTabBarItem = [[UITabBarItem alloc] init];
    [libraryTabBarItem  setFinishedSelectedImage: [UIImage imageNamed: @"SELlibrary"]
                   withFinishedUnselectedImage: [UIImage imageNamed: @"TR_library"]];
//    crSavedProductsController.view.backgroundColor = [UIColor purpleColor];
    [libraryNavigationController setTabBarItem: libraryTabBarItem];
    
    UINavigationController *dropboxNavigationController = [[UINavigationController alloc] initWithRootViewController:dropboxView];
    UITabBarItem* dropboxTabBarItem = [[UITabBarItem alloc] init];
    [dropboxTabBarItem  setFinishedSelectedImage: [UIImage imageNamed: @"SELdropbox"]
                     withFinishedUnselectedImage: [UIImage imageNamed: @"TR_dropbox"]];
    [dropboxNavigationController setTabBarItem: dropboxTabBarItem];
    
    
    
    UINavigationController *bookMarksNavigationProductsController = [[UINavigationController alloc] initWithRootViewController:bookmarksView];
    UITabBarItem* bookmarksTabBarItem = [[UITabBarItem alloc] init];
    [bookmarksTabBarItem  setFinishedSelectedImage: [UIImage imageNamed: @"SELbookmark"]
                      withFinishedUnselectedImage: [UIImage imageNamed: @"TR_bookmark"]];
//    crRecentProductsController.view.backgroundColor = [UIColor redColor];
    [bookMarksNavigationProductsController setTabBarItem: bookmarksTabBarItem];
    
   
    
    UINavigationController *SettingsNavigationController = [[UINavigationController alloc] initWithRootViewController:settingsView];
    UITabBarItem *settingsTabBarItem = [[UITabBarItem alloc] init];
    [settingsTabBarItem  setFinishedSelectedImage: [UIImage imageNamed: @"SELsettings"]
                    withFinishedUnselectedImage: [UIImage imageNamed: @"TR_setting"]];
    [SettingsNavigationController setTabBarItem: settingsTabBarItem];
    
    UINavigationController *searchNavigationController = [[UINavigationController alloc] initWithRootViewController:searchView];
    UITabBarItem* searchTabBarItem = [[UITabBarItem alloc] init];
    [searchTabBarItem  setFinishedSelectedImage: [UIImage imageNamed: @"SELsearch"]
                    withFinishedUnselectedImage: [UIImage imageNamed: @"TR_search"]];
    [searchNavigationController setTabBarItem: searchTabBarItem];

    //TabBariItems array
    [viewControllers addObject:libraryNavigationController];
    [viewControllers addObject:mainViewNavigationController];
    [viewControllers addObject:playlistNavigationController];
    [viewControllers addObject:dropboxNavigationController];
    [viewControllers addObject:bookMarksNavigationProductsController];
    [viewControllers addObject:SettingsNavigationController];
    [viewControllers addObject:searchNavigationController];

    
	tabBarController.delegate = self;
	tabBarController.viewControllers = viewControllers;
    
    [self.window addSubview:[tabBarController view]];
    self.window.rootViewController = tabBarController;
    
    UITabBarController *tabBar = (UITabBarController *)self.window.rootViewController;
    [tabBar setSelectedIndex:1];
    
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    NSLog(@"%@", _managedObjectModel);
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"iEdtitFast" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"iEdit.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        //        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}
#pragma mark -
#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark -

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
