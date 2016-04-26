//
//  EAPhotosPageViewController.h
//  ElegantAlbum
//
//  Created by 陆凯波 on 16/1/26.
//  Copyright © 2016年 Kaibo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EAPhoto.h"

@interface EAPhotosPageViewController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, strong) NSArray<EAPhoto *> *photos;
@property (nonatomic) NSUInteger firstPhotoIndex;

@end
