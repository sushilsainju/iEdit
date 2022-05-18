//
//  Bookmarks.h
//  iEditFast
//
//  Created by SUSHIL on 7/21/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BookmarkImages, Library;

@interface Bookmarks : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * timeInSeconds;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) Library *forRecording;
@property (nonatomic, retain) NSSet *hasImage;
@end

@interface Bookmarks (CoreDataGeneratedAccessors)

- (void)addHasImageObject:(BookmarkImages *)value;
- (void)removeHasImageObject:(BookmarkImages *)value;
- (void)addHasImage:(NSSet *)values;
- (void)removeHasImage:(NSSet *)values;

@end
