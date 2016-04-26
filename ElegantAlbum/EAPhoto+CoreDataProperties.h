//
//  EAPhoto+CoreDataProperties.h
//  ElegantAlbum
//
//  Created by Kaibo Lu on 16/2/22.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "EAPhoto.h"

NS_ASSUME_NONNULL_BEGIN

@interface EAPhoto (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *address;
@property (nullable, nonatomic, retain) NSString *city;
@property (nullable, nonatomic, retain) NSString *country;
@property (nullable, nonatomic, retain) NSDate *creationDate;
@property (nullable, nonatomic, retain) NSString *district;
@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSNumber *longitude;
@property (nullable, nonatomic, retain) NSDate *modificationDate;
@property (nullable, nonatomic, retain) NSString *note;
@property (nullable, nonatomic, retain) NSString *state;
@property (nullable, nonatomic, retain) NSString *street;
@property (nullable, nonatomic, retain) NSString *streetNO;
@property (nullable, nonatomic, retain) NSString *url;
@property (nullable, nonatomic, retain) NSSet<EAAlbum *> *albums;

@end

@interface EAPhoto (CoreDataGeneratedAccessors)

- (void)addAlbumsObject:(EAAlbum *)value;
- (void)removeAlbumsObject:(EAAlbum *)value;
- (void)addAlbums:(NSSet<EAAlbum *> *)values;
- (void)removeAlbums:(NSSet<EAAlbum *> *)values;

@end

NS_ASSUME_NONNULL_END
