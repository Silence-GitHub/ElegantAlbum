//
//  EAAlbum.m
//  ElegantAlbum
//
//  Created by Kaibo Lu on 16/1/24.
//

#import "EAAlbum.h"
#import "EAPhoto.h"

@implementation EAAlbum

+ (EAAlbum *)albumNamed:(NSString *)name managedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"EAAlbum" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"Error: %@\nUser information: %@", error, error.userInfo);
    } else {
        // Find album
        return fetchedObjects.firstObject;
    }
    return nil;
}

+ (EAAlbum *)createAlbumWithName:(NSString *)name photos:(nullable NSSet<EAPhoto *> *)photos managedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    
    EAAlbum *album = [NSEntityDescription
                                           insertNewObjectForEntityForName:@"EAAlbum"
                                           inManagedObjectContext:managedObjectContext];
    NSDate *now = [NSDate date];
    album.creationDate = now;
    album.modificationDate = now;
    album.name = name;
    album.photos = photos;
    
    NSError *error;
    if (![managedObjectContext save:&error]) {
        NSLog(@"Error: %@\nUser information: %@", error, error.userInfo);
        return nil;
    }
    return album;
}

- (void)addPhotoArray:(NSArray<EAPhoto *> *)photos {
    
    NSDate *now = [NSDate date];
    
    // Check if there are new photos
    BOOL hasNewPhoto = NO;
    for (EAPhoto *photo in photos) {
        if (![self.photos containsObject:photo]) {
            hasNewPhoto = YES;
            photo.modificationDate = now;
        }
    }
    
    // Add photos
    [self addPhotos:[NSSet setWithArray:photos]];
    
    if (hasNewPhoto) {
        // Update modification date
        self.modificationDate = now;
    }
}

- (void)removePhotoArray:(NSArray<EAPhoto *> *)photos {
    
    NSDate *now = [NSDate date];
    
    // Check if there are photo to remove
    BOOL hasPhotoToRemove = NO;
    for (EAPhoto *photo in photos) {
        if ([self.photos containsObject:photo]) {
            hasPhotoToRemove = YES;
            photo.modificationDate = now;
        }
    }
    
    // Remove photos
    [self removePhotos:[NSSet setWithArray:photos]];
    
    if (hasPhotoToRemove) {
        // Update modification date
        self.modificationDate = now;
    }
}

- (void)updateName:(NSString *)name {
    self.name = name;
    self.modificationDate = [NSDate date];
}

@end
