//
//  EAPhotoViewController.h
//  ElegantAlbum
//
//  Created by 陆凯波 on 16/1/26.
//  Copyright © 2016年 Kaibo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EAPhoto.h"

@interface EAPhotoViewController : UIViewController <UIScrollViewDelegate, UITextViewDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) NSUInteger pageIndex;
@property (nonatomic, strong) EAPhoto *photo;

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UITextView *textView;

@end
