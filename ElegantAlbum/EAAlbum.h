//
//  EAAlbum.h
//  ElegantAlbum
//
//  Created by 陆凯波 on 16/1/24.
//  Copyright © 2016年 Kaibo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EAPhoto;

NS_ASSUME_NONNULL_BEGIN

@interface EAAlbum : NSManagedObject

+ (EAAlbum *)albumNamed:(NSString *)name managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (EAAlbum *)createAlbumWithName:(NSString *)name photos:(nullable NSSet<EAPhoto *> *)photos managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (void)addPhotoArray:(NSArray<EAPhoto *> *)photos;
- (void)removePhotoArray:(NSArray<EAPhoto *> *)photos;

- (void)updateName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END

#import "EAAlbum+CoreDataProperties.h"
