//
//  iEditDataModel.h
//  iEditFast
//
//  Created by SUSHIL on 3/10/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iEditAppDelegate.h"
#import "SharedStore.h"

@class Library;
@interface iEditDataModel : NSObject<NSFetchedResultsControllerDelegate>
{
    NSManagedObjectContext *managedObjectContext;

}

@property(nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property(nonatomic, retain) NSMutableArray *chunksArray;
@property(assign) BOOL isMaster;




// Returns the Recording  at the specified position in the library.
//-(Library *)recordingAtIndex:(int)index;

-(NSDictionary *)getMasterRecording:(Library *)chunkRecording ;
-(NSArray *)getBookmarksForrecording:(Library *)Recording ;
-(NSArray *)getChunksForrecording:(Library *)Recording;
-(NSArray *)getAssociatedFilesForrecording:(Library *)Recording;

//-(NSMutableArray *)getPlaylistItems:(Playlists *)Selectedplaylist;

// Save recordinf file in library a Recipe object from the list.
-(void)insertRecordingsInLibrary:(NSMutableDictionary *)recordingDictionary andBookmarks:(NSArray *)BookmarksArray;
-(void)renameLibraryFile:(NSMutableDictionary *)fileDictionary;

-(void) editBookmarkNotes:(Bookmarks *)bookmarks withText:(NSString *)notes;

//Insert Playlist
-(Playlists *)createPlaylist:(NSString *)playlistname withRecordings:(NSArray *)recordingsArray;
-(void) editplaylist:(NSString *)name anddate:(NSDate *)date withrecordings:(NSArray *) recordings;
-(void) clearplaylist:(NSString *)name anddate:(NSDate *)date;
-(void) removeplaylistItem:(NSString *)name anddate:(NSDate *)date andFilename:(NSString *)filename;
-(void)PlaylistDetails:(Playlists *)createdplaylist withRecordings:(NSArray *)recordingsArray;
-(void) addItems:(NSArray *) recordings toPlaylist:(Playlists *)currentPlaylist;

-(void)renameChunkFile:(Library *)chunkRecording withOldPath:(NSString *)oldFilepath;

-(void)handleMasterFileDeletion:(Library *)recording;


@end
