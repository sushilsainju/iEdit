//
//  iEditDataModel.m
//  iEditFast
//
//  Created by SUSHIL on 3/10/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import "iEditDataModel.h"
#import "Library.h"
#import "Bookmarks.h"
#import "BookmarkImages.h"
#import "Playlists.h"
#import "PlaylistItems.h"
#import "ChunkFiles.h"

@interface iEditDataModel ()

@end


@implementation iEditDataModel

@synthesize managedObjectContext;
@synthesize chunksArray;
@synthesize isMaster;

-(void)insertRecordingsInLibrary:(NSMutableDictionary *)recordingDictionary andBookmarks:(NSArray *)BookmarksArray
{
    NSInteger bookmarkscount=0;

    NSString *filename;
    Library *recordingLibrary;

    // CHECK IF RECORDING IS ALREADY CREATED
    if ([[recordingDictionary  objectForKey:@"Name"] isKindOfClass:[NSString class]])
    {
        filename=[recordingDictionary objectForKey:@"Name"];
    }
    
    
    
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init] ;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Library" inManagedObjectContext:self.managedObjectContext];
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filename = %@ && date=%@", filename,[recordingDictionary objectForKey:@"date"]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filename = %@", filename];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *recordings = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // IF RECORDING IS NOT CREATED YET
    if (recordings.count == 0) {
        recordingLibrary = [NSEntityDescription insertNewObjectForEntityForName:@"Library" inManagedObjectContext:self.managedObjectContext];
        recordingLibrary.filename = filename;
    }
    else{
        recordingLibrary = (Library *)[recordings objectAtIndex:0];
        NSArray *oldBookmarks=[self getBookmarksForrecording:recordingLibrary];
        bookmarkscount=oldBookmarks.count;
    }
   
    
    if ([[recordingDictionary  objectForKey:@"Name"] isKindOfClass:[NSString class]])
    {
        recordingLibrary.filename=[recordingDictionary objectForKey:@"Name"];
    }
    if ([[recordingDictionary  objectForKey:@"Path"] isKindOfClass:[NSString class]])
    {
        recordingLibrary.filepath=[recordingDictionary objectForKey:@"Path"];
    }
    if ([[recordingDictionary  objectForKey:@"date"] isKindOfClass:[NSDate class]])
    {
        recordingLibrary.date=[recordingDictionary objectForKey:@"date"];
        
    }
    //if([recordingLibrary.filename rangeOfString:@"-"].location == NSNotFound && [recordingLibrary.filename rangeOfString:@"composite"].location == NSNotFound){
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    
    NSString *isDownloading = [defaults valueForKey:@"isDownloading"];
    
    if([recordingLibrary.filename rangeOfString:@"-"].location == NSNotFound){
        NSLog(@"string does not contain -,  so is master");
     recordingLibrary.isMaster=YES;
    } else if (!([recordingLibrary.filename rangeOfString:@"-"].location == NSNotFound) &&([isDownloading isEqualToString:@"yesDownloading"])) {
       // string does  contain - and this file is being downloaded ,  so is master
        recordingLibrary.isMaster = YES;
        [defaults setObject:@"noDownloading" forKey:@"isDownloading"];
        [defaults synchronize];
    } else {
        recordingLibrary.isMaster = NO;
    }
    for (id bookmarkDictionary in BookmarksArray)
    {
        bookmarkscount+=1;
        Bookmarks *bookmarkContents;
        bookmarkContents = (Bookmarks *)[NSEntityDescription insertNewObjectForEntityForName:@"Bookmarks" inManagedObjectContext:self.managedObjectContext];
        NSString *name=[[filename lastPathComponent] stringByDeletingPathExtension];
        NSString *bookmarkname=[NSString stringWithFormat:@"%@ - %ld",name,(long)bookmarkscount];
        bookmarkContents.name=bookmarkname;//[bookmarkDictionary valueForKey:Bookmark_param_title];
        bookmarkContents.text=[bookmarkDictionary valueForKey:Bookmark_param_text];
        bookmarkContents.date=[bookmarkDictionary valueForKeyPath:Bookmark_param_date];
        bookmarkContents.timeInSeconds =[bookmarkDictionary valueForKeyPath:Bookmark_param_time];
        [recordingLibrary addContainsBookmarksObject:bookmarkContents];
        if ([bookmarkDictionary valueForKey:Bookmark_param_imagePath])
        {
            if (![[bookmarkDictionary valueForKey:Bookmark_param_imagePath] isEqualToString:@""])
            {
                
                BookmarkImages *bookmarkimage;
                bookmarkimage = (BookmarkImages *)[NSEntityDescription insertNewObjectForEntityForName:@"BookmarkImages" inManagedObjectContext:self.managedObjectContext];
                [bookmarkimage setFilepath:[bookmarkDictionary valueForKey:Bookmark_param_imagePath]];//;
                [bookmarkContents addHasImageObject:bookmarkimage];
                
                
            }
        }
        
        


    }
    [self updateDB];
    //////////
    if (chunksArray.count>0)
    {
        //sagar added this line
        //recordingLibrary.isMaster = NO;
        for (id chunkDictionary in chunksArray)
        {
            ChunkFiles  *chunkContents;
            chunkContents = (ChunkFiles *)[NSEntityDescription insertNewObjectForEntityForName:@"ChunkFiles" inManagedObjectContext:self.managedObjectContext];
            chunkContents.endTime=[chunkDictionary valueForKey:EDITFILES_param_endtime];
            chunkContents.startTime=[chunkDictionary valueForKey:EDITFILES_param_startTime];
            chunkContents.filePath=[chunkDictionary valueForKey:EDITFILES_param_filePath];
            
            [recordingLibrary addHasChunksObject:chunkContents];
            [chunkContents addPartOfObject:recordingLibrary];
        }
        
    }
    
    [self updateDB];
    [chunksArray removeAllObjects];
    
}


-(void)renameLibraryFile:(NSMutableDictionary *)fileDictionary
{
    
    

    
}

//-(Library *)getMasterRecording:(Library *)chunkFile
//{
//    Library *recording;
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init] ;
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"library" inManagedObjectContext:self.managedObjectContext];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hasChunks", name,date];
//    [fetchRequest setEntity:entity];
//    [fetchRequest setPredicate:predicate];
//    NSError *error = nil;
//    NSArray *playlists = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
//}


-(Playlists *)createPlaylist:(NSString *)playlistname withRecordings:(NSArray *)recordingsArray
{
    Playlists *newPlaylist ;
    newPlaylist = [NSEntityDescription insertNewObjectForEntityForName:@"Playlists" inManagedObjectContext:self.managedObjectContext];
	
    newPlaylist.name=playlistname;
    newPlaylist.createdDate=[NSDate date];
    for(id file in recordingsArray)
    {
        [newPlaylist addContainsRecordingsObject:file];
        [file addContainedInObject:newPlaylist];

    }
    [self updateDB];
    return newPlaylist;
    
}

-(void)PlaylistDetails:(Playlists *)createdplaylist withRecordings:(NSArray *)recordingsArray
{
    PlaylistItems *newItem ;
    
    NSLog(@"pl %@",newItem);
//    [self.managedObjectContext]
//    play.createdDate=[NSDate date];
    for(int i=0;i<recordingsArray.count;i++)
    {
        int order=i+1;
        newItem = [NSEntityDescription insertNewObjectForEntityForName:@"PlaylistItems" inManagedObjectContext:self.managedObjectContext];
        Library *item=  [recordingsArray objectAtIndex:i];
        newItem.itemOrder=[NSNumber numberWithInt:order];
//        newItem.playlistitemLocation=[item valueForKey:@"filepath"];
//        newItem.playlistname=playlistname;
        newItem.recording=item;
        newItem.playlist=createdplaylist;
        

    }
    [self updateDB];

}

-(void) addItems:(NSArray *) recordings toPlaylist:(Playlists *)currentPlaylist
{
    for(id file in recordings)
    {
        [currentPlaylist addContainsRecordingsObject:file];
        [file addContainedInObject:currentPlaylist];
        
    }
    [self updateDB];
}


-(void) editplaylist:(NSString *)name anddate:(NSDate *)date withrecordings:(NSArray *) recordings
{
     Playlists *play ;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init] ;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Playlists" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@ && createdDate=%@", name,date];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *playlists = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    // IF RECORDING IS NOT CREATED YET
    
    if (recordings.count == 0) {
        play = [NSEntityDescription insertNewObjectForEntityForName:@"Playlists" inManagedObjectContext:self.managedObjectContext];
        
    }
    else{
        play = (Playlists *)[playlists objectAtIndex:0];
    }
    
    

    for(id file in recordings)
    {
        [play addContainsRecordingsObject:file];
        [file addContainedInObject:play];
        
    }
    
    [self updateDB];
    fetchRequest=nil;
}


-(void) clearplaylist:(NSString *)name anddate:(NSDate *)date
{
    Playlists *play ;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init] ;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Playlists" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@ && createdDate=%@", name,date];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *playlists = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    // IF RECORDING IS NOT CREATED YET
    
    if (playlists.count == 0)
    {
           }
    else
    {
        play = (Playlists *)[playlists objectAtIndex:0];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
          NSEntityDescription *entity = [NSEntityDescription entityForName:@"Library" inManagedObjectContext:self.managedObjectContext];
       NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"ANY containedIn = %@ ", play];

        
        [fetchRequest setEntity:entity];
        
//        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        [fetchRequest setPredicate:fetchPredicate];
        NSArray *playlistItems=[managedObjectContext executeFetchRequest:fetchRequest error:&error];
        for(id file in playlistItems)
        {
            [play removeContainsRecordingsObject:file];
            [file removeContainedInObject:play];
//            [play addContainsRecordingsObject:file];
//            [file addContainedInObject:play];
            
        }
        [self updateDB];
    }
    
    
    
    

}


-(void) removeplaylistItem:(NSString *)name anddate:(NSDate *)date andFilename:(NSString *)filename
{
    Playlists *play ;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init] ;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Playlists" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@ && createdDate=%@", name,date];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *playlists = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    // IF RECORDING IS NOT CREATED YET
    
    if (playlists.count == 0)
    {
    }
    else
    {
        play = (Playlists *)[playlists objectAtIndex:0];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Library" inManagedObjectContext:self.managedObjectContext];
        NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"ANY containedIn = %@ && filename =%@ ", play,filename];
        
        
        [fetchRequest setEntity:entity];
        
        //        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        [fetchRequest setPredicate:fetchPredicate];
        NSArray *playlistItems=[managedObjectContext executeFetchRequest:fetchRequest error:&error];
        for(id file in playlistItems)
        {
            [play removeContainsRecordingsObject:file];
            [file removeContainedInObject:play];
            //            [play addContainsRecordingsObject:file];
            //            [file addContainedInObject:play];
            
        }
        [self updateDB];
    }
    
    
    
    
    
}


-(void)updateDB{
	NSError *error = nil;
	if ([self.managedObjectContext save:&error])
    {
        NSLog(@"Errore %@",error);
	}
}

-(void)handleMasterFileDeletion:(Library *)recording
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSPredicate *fetchPredicate=[[NSPredicate alloc]init];
    NSError *error = nil;
    
    NSEntityDescription *ChunkEntity = [NSEntityDescription entityForName:@"ChunkFiles" inManagedObjectContext:self.managedObjectContext];
    fetchPredicate = [NSPredicate predicateWithFormat:@"ANY partOf =%@ ", recording];
    [fetchRequest setPredicate:fetchPredicate];
    [fetchRequest setEntity:ChunkEntity];
    NSArray *chunks = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(chunks.count>0)
    {
        for(id chunk in chunks)
        {
            ChunkFiles *_chunk=chunk;
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Library" inManagedObjectContext:self.managedObjectContext];
            fetchPredicate = [NSPredicate predicateWithFormat:@"filepath=%@ ", _chunk.filePath];
            [fetchRequest setPredicate:fetchPredicate];
            [fetchRequest setEntity:entity];
            //    [fetchRequest setPredicate:nil];
            error = nil;
            NSArray *masterrecordings = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if (masterrecordings.count>0)
            {
                Library *masterFile=[masterrecordings objectAtIndex:0];
                masterFile.isMaster=YES;//[NSNumber numberWithInteger:1];
                [self updateDB];
            }
        }
    }
//    NSDictionary *masterFileDictionary=[[NSDictionary alloc]init];
}


-(void)renameChunkFile:(Library *)chunkRecording withOldPath:(NSString *)oldFilepath
{
//    NSNumber *start,*end;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSPredicate *fetchPredicate=[[NSPredicate alloc]init];
    NSError *error = nil;
    
    NSEntityDescription *ChunkEntity = [NSEntityDescription entityForName:@"ChunkFiles" inManagedObjectContext:self.managedObjectContext];
    fetchPredicate = [NSPredicate predicateWithFormat:@"filePath=%@ ", oldFilepath];
    [fetchRequest setPredicate:fetchPredicate];
    [fetchRequest setEntity:ChunkEntity];
    NSArray *chunks = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
//    NSDictionary *masterFileDictionary=[[NSDictionary alloc]init];
    if (chunks.count>0)
    {
        
        ChunkFiles *chunkFile=[chunks objectAtIndex:0];
        chunkFile.filePath=chunkRecording.filepath;
        NSError *error = nil;
        if (![DELEGATE.managedObjectContext save:&error])
        {
            // handle error
            UIAlertView *removeSuccessFulAlert=[[UIAlertView alloc]initWithTitle:@"iEditSmart" message:@"Can not rename file at the moment. Please try again later." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [removeSuccessFulAlert show];
        }
    }

}

-(NSDictionary *)getMasterRecording:(Library *)chunkRecording
{
    
    NSNumber *start,*end;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSPredicate *fetchPredicate=[[NSPredicate alloc]init];
    NSError *error = nil;

    NSEntityDescription *ChunkEntity = [NSEntityDescription entityForName:@"ChunkFiles" inManagedObjectContext:self.managedObjectContext];
    fetchPredicate = [NSPredicate predicateWithFormat:@"filePath=%@ ", chunkRecording.filepath];
    [fetchRequest setPredicate:fetchPredicate];
    [fetchRequest setEntity:ChunkEntity];
     NSArray *chunks = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSDictionary *masterFileDictionary=[[NSDictionary alloc]init];
    if (chunks.count>0)
    {
        ChunkFiles *chunkFile=[chunks objectAtIndex:0];
        start=chunkFile.startTime;
        end=chunkFile.endTime;
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Library" inManagedObjectContext:self.managedObjectContext];
        fetchPredicate = [NSPredicate predicateWithFormat:@"ANY hasChunks = %@ ", chunkFile];
        [fetchRequest setPredicate:fetchPredicate];
        [fetchRequest setEntity:entity];
        //    [fetchRequest setPredicate:nil];
        error = nil;
        NSArray *masterrecordings = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        Library *masterFile=[masterrecordings objectAtIndex:0];
        masterFileDictionary=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            start, EDITFILES_param_startTime,
                                            end, EDITFILES_param_endtime,
                                            masterFile, @"master",
                                            nil];

        return masterFileDictionary;
    }
    else
    {
       
        return masterFileDictionary ;
    }
    
}


-(void) editBookmarkNotes:(Bookmarks *)bookmarks withText:(NSString *)notes
{
    Bookmarks *bookmark;
   
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init] ;
    
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Bookmarks" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@ && date=%@", bookmarks.name,bookmarks.date];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *bookmarksArray = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (bookmarksArray.count>0)
    {
        bookmark=[bookmarksArray objectAtIndex:0];
        bookmark.text=notes;
    }
    [self updateDB];
    


}


-(float )getduration:(NSString *)mediapath
{
    NSURL *afUrl = [NSURL fileURLWithPath:mediapath];
    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:afUrl options:nil];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds =  CMTimeGetSeconds(audioDuration);
    
    float durationInSeconds = floor(audioDurationSeconds);
 
    return durationInSeconds;
}

-(NSArray *)getAssociatedFilesForrecording:(Library *)Recording
{
    
    //    NSNumber *start,*end;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSPredicate *fetchPredicate=[[NSPredicate alloc]init];
    NSError *error = nil;
    NSString *filename=[[Recording.filename lastPathComponent] stringByDeletingPathExtension];
;
    float duration=[self getduration:Recording.filepath];
    NSDate *enddate=[Recording.date dateByAddingTimeInterval:duration];
    NSDate *startDate=[Recording.date dateByAddingTimeInterval:-2*(duration+1)];

    NSEntityDescription *ChunkEntity = [NSEntityDescription entityForName:@"Library" inManagedObjectContext:self.managedObjectContext];
    fetchPredicate = [NSPredicate predicateWithFormat:@"date >= %@ AND date <%@",startDate,enddate];
    [fetchRequest setPredicate:fetchPredicate];
    [fetchRequest setEntity:ChunkEntity];
    NSArray *associatedFiles = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
//    //    NSDictionary *masterFileDictionary=[[NSDictionary alloc]init];
//    if (associatedFiles.count>0)
//    {
//    }
    return associatedFiles;
}


-(NSArray *)getBookmarksForrecording:(Library *)Recording
{
    
//    NSNumber *start,*end;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSPredicate *fetchPredicate=[[NSPredicate alloc]init];
    NSError *error = nil;
    
    NSEntityDescription *ChunkEntity = [NSEntityDescription entityForName:@"Bookmarks" inManagedObjectContext:self.managedObjectContext];
    fetchPredicate = [NSPredicate predicateWithFormat:@"ANY forRecording=%@ ", Recording];
    [fetchRequest setPredicate:fetchPredicate];
    [fetchRequest setEntity:ChunkEntity];
    NSArray *bookmarks = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
//    NSDictionary *masterFileDictionary=[[NSDictionary alloc]init];
    if (bookmarks.count>0)
    {
    }
    return bookmarks;
}


-(NSArray *)getChunksForrecording:(Library *)Recording
{
    
    //    NSNumber *start,*end;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSPredicate *fetchPredicate=[[NSPredicate alloc]init];
    NSError *error = nil;
    
    NSEntityDescription *ChunkEntity = [NSEntityDescription entityForName:@"Bookmarks" inManagedObjectContext:self.managedObjectContext];
    fetchPredicate = [NSPredicate predicateWithFormat:@"ANY forRecording=%@ ", Recording];
    [fetchRequest setPredicate:fetchPredicate];
    [fetchRequest setEntity:ChunkEntity];
    NSArray *bookmarks = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    //    NSDictionary *masterFileDictionary=[[NSDictionary alloc]init];
    if (bookmarks.count>0)
    {
    }
    return bookmarks;
}

@end
