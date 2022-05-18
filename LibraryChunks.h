//
//  LibraryChunks.h
//  iEditFast
//
//  Created by SUSHIL on 5/21/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ChunkFiles, Library;

@interface LibraryChunks : NSManagedObject

@property (nonatomic, retain) NSNumber * num;
@property (nonatomic, retain) ChunkFiles *chunk;
@property (nonatomic, retain) Library *libraryFile;

@end
