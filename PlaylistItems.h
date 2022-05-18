//
//  PlaylistItems.h
//  iEditFast
//
//  Created by SUSHIL on 8/4/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Library, Playlists;

@interface PlaylistItems : NSManagedObject

@property (nonatomic, retain) NSNumber * itemOrder;
@property (nonatomic, retain) Playlists *playlist;
@property (nonatomic, retain) Library *recording;

@end

@interface PlaylistItems (CoreDataGeneratedAccessors)

- (void)addRecordingObject:(Library *)value;
- (void)removeRecordingObject:(Library *)value;
@end
