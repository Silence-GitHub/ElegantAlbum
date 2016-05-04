//
//  EAPublic.h
//  ElegantAlbum
//
//  Created by Kaibo Lu on 16/1/25.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>



#import "TFHpple.h"
#import "IIViewDeckController.h"
#import "XLPlainFlowLayout.h"
#import "EAPhoto.h"



// --------------------Notifications begin--------------------

// Notification when application did become active
#define APPLICATION_ACTIVE_NOTIFICATION @"Application_active_notification"
// Value for key is photo set
#define NEW_PHOTOS_KEY @"New_photos_key"

// Notification for finishing refreshing photo (to make data the same as Apple photo app)
#define FINISH_REFRESHING_PHOTO_NOTIFICATION @"Finish_refreshing_photo_notification"



// Notification for adding and deleting photo
#define PHOTO_CHANGE_NOTIFICAITON @"Photo_change_notificaiton"
// Value for key is NSNumber
// > 0 means number of photo increase
// < 0 means number of photo decrease
// NUMBER_OF_PHOTO_CHANGE_KEY content is the same as ALBUM_CHANGE_NOTIFICATION

// PHOTOS_KEY is the same as ALBUM_CHANGE_NOTIFICATION



// Notification for editing photo note
#define PHOTO_NOTE_CHANGE_NOTIFICATION @"Photo_note_change_notification"
// Value for key is NSNumber
// > 0 means number of photo with note increase
// = 0 means number of photo with note not change
// < 0 means number of photo with note decrease
#define NUMBER_OF_PHOTO_NOTE_CHANGE_KEY @"Number_of_photo_note_change_key"
// Value for key is photo
#define PHOTO_KEY @"Photo_key"
// Value for key is NSNumber
// YES means need to update album
// NO means do not need to update album
// Album and photo (with note) are updated at the same time. If we post ALBUM_CHANGE_NOTIFICATION tells to update album, do not need to update album again
#define UPDATE_ALBUM_KEY @"Update_album_key"



// Notification for adding, deleting and updating album
#define ALBUM_CHANGE_NOTIFICATION @"Album_change_notification"
// Value for key is NSNumber
// > 0 means number of album increase
// = 0 means number of album not change
// < 0 means number of album decrease
#define NUMBER_OF_ALBUM_CHANGE_KEY @"Number_of_album_change_key"
// Value for key is album
#define ALBUM_KEY @"Album_key"
// Value for key is NSNumber
// > 0 means number of photo associated with the album increase
// = 0 means number of photo associated with the album not change
// < 0 means number of photo associated with the album decrease
#define NUMBER_OF_PHOTO_CHANGE_KEY @"Number_of_photo_change_key"
// Value for key is photo set
#define PHOTOS_KEY @"Photos_key"

// --------------------Notifications end--------------------



// --------------------User defaults begin--------------------

// Value for key is NSDate
#define APPLICATION_WILL_RESIGN_ACTIVE_DATE_KEY @"Application_will_resign_active_key"

// --------------------User defaults end--------------------



// --------------------Cache name begin--------------------

#define ALBUMS_DESCENDING_WITH_MODIFICATION_DATE_CACHE_NAME @"Albums_descending_with_modification_date_cache_name"

#define PHOTOS_WITH_NOTE_DESCENDING_WITH_MODIFICATION_DATE_CACHE_NAME @"Photos_with_note_descending_with_modification_date_cache_name"

#define PHOTOS_DESCENDING_WITH_CREATION_DATE_CACHE_NAME @"Photos_descending_with_creation_date_cache_name"

#define PHOTOS_WITH_STATE_DESCENDING_WITH_CREATION_DATE_CACHE_NAME @"Photos_with_state_descending_with_creation_date_cache_name"

// --------------------Cache name begin--------------------



// --------------------Constants for views begin--------------------

#define COLLECTION_HEADER_X 10.0f
#define COLLECTION_HEADER_HEIGHT 40.0f

#define COLLECTION_CELL_SIDE_LENGHT_MAX 80.0f
#define COLLECTION_CELL_HIGHLIGHTED_IMAGE_SIDE_LENGTH_MAX 25.0f
#define COLLECTION_CELL_HIGHLIGHTED_IMAGE_MARGIN 5.0f

#define THUMBNAIL_SIDE_LENGTH_MEDIUM 60.0f
#define THUMBNAIL_SIDE_LENGTH_MAX 78.0f
#define THUMBNAIL_EDGE_INSET 2.0f

#define ALBUM_TABLE_CELL_HEIGHT 74.0f
#define ALBUM_TABLE_CELL_IMAGE_CORNER_RADIUS 5.0f

#define MAP_GRID_SIDE_LENGTH 40.0

// --------------------Constants for views end--------------------



// About National geographic

#define NATIONAL_GEOGRAPHIC_URL @"http://m.nationalgeographic.com.cn"
#define NATIONAL_GEOGRAPHIC_ALBUM_NAME @"National geographic"



@interface EAPublic : NSObject

+ (float)iOSVersion;

+ (NSArray *)mainClassifications;

+ (NSArray *)nationalGeographicClassifications;

+ (NSString *)urlForNationalGeographicClassification:(NSString *)classification;

+ (UIImage *)image:(UIImage *)image withSize:(CGSize)size;

+ (UIImage*)grayImage:(UIImage*)sourceImage;

+ (UIButton *)backButtonItemCustomView;

+ (UIButton *)leftMenuButtonItemCustomViewClosed:(BOOL)closed;

+ (UIButton *)moreButtonItemCustomViewPointsInVerticalLine;

+ (void)hideOrShowTabBar:(__weak UITabBar *)tabBar onView:(__weak UIView *)view hide:(BOOL)hide completion:(void (^)(BOOL finished))completion;

@end
