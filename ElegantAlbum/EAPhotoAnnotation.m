//
//  EAPhotoAnnotation.m
//  ElegantAlbum
//
//  Created by Kaibo Lu on 16/2/6.
//

#import "EAPhotoAnnotation.h"

@implementation EAPhotoAnnotation

- (NSMutableArray<EAPhotoAnnotation *> *)containedPhotoAnnotations {
    if (!_containedPhotoAnnotations) {
        _containedPhotoAnnotations = [NSMutableArray array];
    }
    return _containedPhotoAnnotations;
}

- (instancetype)initWithPhoto:(EAPhoto *)photo {
    self = [super init];
    if (self) {
        _photo = photo;
    }
    return self;
}

- (BOOL)containsPhoto:(EAPhoto *)photo {
    
    if ([self.photo.url isEqualToString:photo.url]) {
        return YES;
    }
    for (EAPhotoAnnotation *photoAnno in self.containedPhotoAnnotations) {
        if ([photoAnno.photo.url isEqualToString:photo.url]) {
            return YES;
        }
    }
    return NO;
}

- (NSInteger)addPhotoAnnotation:(EAPhotoAnnotation *)otherPhotoAnno {
    NSLog(@"Add photo annotation");
    
    NSInteger index = 0;
    NSComparisonResult result = [self.photo.creationDate compare:otherPhotoAnno.photo.creationDate];
    if (result == NSOrderedAscending) {
        NSLog(@"Other annotation replace photo");
        // Other photo is latter
        EAPhoto *tempPhoto = self.photo;
        self.photo = otherPhotoAnno.photo;
        otherPhotoAnno.photo = tempPhoto;
        [self.containedPhotoAnnotations insertObject:otherPhotoAnno atIndex:0];
        index = -1;
        
    } else if (result == NSOrderedDescending) {
        
        if (self.containedPhotoAnnotations.count != 0) {
            BOOL hasAdded = NO;
            for (NSUInteger i = 0; i < self.containedPhotoAnnotations.count; ++i) {
                NSComparisonResult result2 = [self.containedPhotoAnnotations[i].photo.creationDate compare:otherPhotoAnno.photo.creationDate];
                if (result2 == NSOrderedAscending) {
                    NSLog(@"Other annotation inserted");
                    // Other photo is latter
                    [self.containedPhotoAnnotations insertObject:otherPhotoAnno atIndex:i];
                    index = i;
                    hasAdded = YES;
                    break;
                }
            }
            if (!hasAdded) {
                [self.containedPhotoAnnotations addObject:otherPhotoAnno];
                index = self.containedPhotoAnnotations.count - 1;
            }
        } else {
            [self.containedPhotoAnnotations insertObject:otherPhotoAnno atIndex:0];
        }
    }
    return index;
}

#pragma mark - Annotation protocol

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake(self.photo.latitude.doubleValue, self.photo.longitude.doubleValue);
}

- (NSString *)title {
    NSUInteger count = self.containedPhotoAnnotations.count;
    if (count) {
        return [NSString stringWithFormat:@"%lu photos", (unsigned long)count + 1];
    }
    return @"1 photo";
}

@end
