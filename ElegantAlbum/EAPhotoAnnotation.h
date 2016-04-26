//
//  EAPhotoAnnotation.h
//  ElegantAlbum
//
//  Created by 陆凯波 on 16/2/6.
//  Copyright © 2016年 Kaibo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "EAPhoto.h"

@interface EAPhotoAnnotation : NSObject <MKAnnotation>

@property (nonatomic, strong) EAPhoto *photo;
@property (nonatomic, strong) NSMutableArray<EAPhotoAnnotation *> *containedPhotoAnnotations;

- (instancetype)initWithPhoto:(EAPhoto *)photo;
- (BOOL)containsPhoto:(EAPhoto *)photo;

/**
 增加照片annotation
 返回-1，photo被新的annotation代替
 返回值>=0，表示在新annotation在containedPhotoAnnotations中插入的index
 */
- (NSInteger)addPhotoAnnotation:(EAPhotoAnnotation *)otherPhotoAnno;

@end
