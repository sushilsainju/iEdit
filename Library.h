//
//  Library.h
//  iEditFast
//
//  Created by SUSHIL on 5/21/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Bookmarks, ChunkFiles, PlaylistItems, Playlists;

@interface Library : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * filename;
@property (nonatomic, retain) NSString * filepath;
@property (assign) bool  isMaster;
@property (nonatomic, retain) NSSet *containedIn;
@property (nonatomic, retain) NSSet *containsBookmarks;
@property (nonatomic, retain) NSSet *hasChunks;
@property (nonatomic, retain) NSSet *playlistitems;
@end

@interface Library (CoreDataGeneratedAccessors)

- (void)addContainedInObject:(Playlists *)value;
- (void)removeContainedInObject:(Playlists *)value;
- (void)addContainedIn:(NSSet *)values;
- (void)removeContainedIn:(NSSet *)values;

- (void)addContainsBookmarksObject:(Bookmarks *)value;
- (void)removeContainsBookmarksObject:(Bookmarks *)value;
- (void)addContainsBookmarks:(NSSet *)values;
- (void)removeContainsBookmarks:(NSSet *)values;

- (void)addHasChunksObject:(ChunkFiles *)value;
- (void)removeHasChunksObject:(ChunkFiles *)value;
- (void)addHasChunks:(NSSet *)values;
- (void)removeHasChunks:(NSSet *)values;

- (void)addPlaylistitemsObject:(PlaylistItems *)value;
- (void)removePlaylistitemsObject:(PlaylistItems *)value;
- (void)addPlaylistitems:(NSSet *)values;
- (void)removePlaylistitems:(NSSet *)values;

@end
