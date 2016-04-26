//
//  EAPhotoTemp.h
//  ElegantAlbum
//
//  Created by 陆凯波 on 16/4/17.
//  Copyright © 2016年 Kaibo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface EAPhotoTemp : NSObject

@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) CLLocation *loc;

@end
