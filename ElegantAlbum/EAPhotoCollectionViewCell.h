//
//  EAPhotoCollectionViewCell.h
//  ElegantAlbum
//
//  Created by 陆凯波 on 16/1/25.
//  Copyright © 2016年 Kaibo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EAPhotoCollectionViewCell : UICollectionViewCell

@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *highlightedImageView;

@end
