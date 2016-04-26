//
//  EAPhotoPickerCollectionViewController.h
//  ElegantAlbum
//
//  Created by 陆凯波 on 16/4/15.
//  Copyright © 2016年 Kaibo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EAPhotosDateCollectionViewController.h"

#import "EAAlbum.h"

@interface EAPhotoPickerCollectionViewController : EAPhotosDateCollectionViewController

@property (nonatomic, strong) EAAlbum *album;

@end
