//
//  EAPhotoPickerCollectionViewController.h
//  ElegantAlbum
//
//  Created by Kaibo Lu on 16/4/15.
//

#import <UIKit/UIKit.h>

#import "EAPhotosDateCollectionViewController.h"

#import "EAAlbum.h"

@interface EAPhotoPickerCollectionViewController : EAPhotosDateCollectionViewController

@property (nonatomic, strong) EAAlbum *album;

@end
