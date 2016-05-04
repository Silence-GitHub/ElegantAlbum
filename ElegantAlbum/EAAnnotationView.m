//
//  EAAnnotationView.m
//  ElegantAlbum
//
//  Created by 陆凯波 on 16/5/4.
//
//

#import "EAAnnotationView.h"

#import "EAPublic.h"

@implementation EAAnnotationView

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(- THUMBNAIL_SIDE_LENGTH_MAX / 5 * 2, 0, THUMBNAIL_SIDE_LENGTH_MAX, THUMBNAIL_SIDE_LENGTH_MAX)]; // set x offset to make view center horizontally; 1/2 is not center, but 2/5 is OK  
        [self addSubview:_imageView];
    }
    return _imageView;
}

@end
