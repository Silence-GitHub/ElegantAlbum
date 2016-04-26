//
//  EAPhotoCollectionViewCell.h
//  ElegantAlbum
//
//  Created by Kaibo Lu on 16/1/25.
//

#import <UIKit/UIKit.h>

@interface EAPhotoCollectionViewCell : UICollectionViewCell

@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *highlightedImageView;

@end
