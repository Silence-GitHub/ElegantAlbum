//
//  EAPhotosPageViewController.h
//  ElegantAlbum
//
//  Created by Kaibo Lu on 16/1/26.
//

#import <UIKit/UIKit.h>

#import "EAPhoto.h"

@interface EAPhotosPageViewController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, strong) NSArray<EAPhoto *> *photos;
@property (nonatomic) NSUInteger firstPhotoIndex;

@end
