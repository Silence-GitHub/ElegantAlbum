//
//  EAPhoto.h
//  ElegantAlbum
//
//  Created by 陆凯波 on 16/1/24.
//  Copyright © 2016年 Kaibo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>

@class EAAlbum;

NS_ASSUME_NONNULL_BEGIN

@interface EAPhoto : NSManagedObject

- (void)updateNote:(nullable NSString *)note;

@end

NS_ASSUME_NONNULL_END

#import "EAPhoto+CoreDataProperties.h"
