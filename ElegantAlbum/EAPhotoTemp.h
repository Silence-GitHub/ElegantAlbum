//
//  EAPhotoTemp.h
//  ElegantAlbum
//
//  Created by Kaibo Lu on 16/4/17.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface EAPhotoTemp : NSObject

@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) CLLocation *loc;

@end
