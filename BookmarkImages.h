//
//  BookmarkImages.h
//  iEditFast
//
//  Created by SUSHIL on 5/21/14.
//  Copyright (c) 2014 Bajratech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Bookmarks;

@interface BookmarkImages : NSManagedObject

@property (nonatomic, retain) NSString * filepath;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) Bookmarks *forBookmark;

@end
