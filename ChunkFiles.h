//
//  ChunkFiles.h
//  iEditFast
//
//  Created by SUSHIL on 5/22/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Library;

@interface ChunkFiles : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * endTime;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSDecimalNumber * startTime;
@property (nonatomic, retain) NSSet *partOf;
@end

@interface ChunkFiles (CoreDataGeneratedAccessors)

- (void)addPartOfObject:(Library *)value;
- (void)removePartOfObject:(Library *)value;
- (void)addPartOf:(NSSet *)values;
- (void)removePartOf:(NSSet *)values;

@end
