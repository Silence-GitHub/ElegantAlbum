//
//  EAAlbum+CoreDataProperties.h
//  ElegantAlbum
//
//  Created by 陆凯波 on 16/2/21.
//  Copyright © 2016年 Kaibo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "EAAlbum.h"

NS_ASSUME_NONNULL_BEGIN

@interface EAAlbum (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *creationDate;
@property (nullable, nonatomic, retain) NSDate *modificationDate;
@property (nullable, nonatomic, retain) NSString *note;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSSet<EAPhoto *> *photos;

@end

@interface EAAlbum (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(EAPhoto *)value;
- (void)removePhotosObject:(EAPhoto *)value;
- (void)addPhotos:(NSSet<EAPhoto *> *)values;
- (void)removePhotos:(NSSet<EAPhoto *> *)values;

@end

NS_ASSUME_NONNULL_END
