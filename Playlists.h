//
//  Playlists.h
//  iEditFast
//
//  Created by SUSHIL on 5/21/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Library, PlaylistItems;

@interface Playlists : NSManagedObject

@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *containsRecordings;
@property (nonatomic, retain) NSSet *playlistitems;
@end

@interface Playlists (CoreDataGeneratedAccessors)

- (void)addContainsRecordingsObject:(Library *)value;
- (void)removeContainsRecordingsObject:(Library *)value;
- (void)addContainsRecordings:(NSSet *)values;
- (void)removeContainsRecordings:(NSSet *)values;

- (void)addPlaylistitemsObject:(PlaylistItems *)value;
- (void)removePlaylistitemsObject:(PlaylistItems *)value;
- (void)addPlaylistitems:(NSSet *)values;
- (void)removePlaylistitems:(NSSet *)values;

@end
