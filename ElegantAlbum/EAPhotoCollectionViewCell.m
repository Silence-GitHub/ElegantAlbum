//
//  EAPhotoCollectionViewCell.m
//  ElegantAlbum
//
//  Created by Kaibo Lu on 16/1/25.
//

#import "EAPhotoCollectionViewCell.h"

#import "EAPublic.h"

@interface EAPhotoCollectionViewCell ()

@end

@implementation EAPhotoCollectionViewCell

- (UIImageView *)imageView {
    if (!_imageView) {
        CGFloat length = self.contentView.bounds.size.width - 2 * THUMBNAIL_EDGE_INSET;
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(THUMBNAIL_EDGE_INSET, THUMBNAIL_EDGE_INSET, length, length)];
        [self.contentView addSubview:_imageView];
    }
    return _imageView;
}

- (UIImageView *)highlightedImageView {
    if (!_highlightedImageView) {
//        // 在右下角打钩
//        CGRect frame = CGRectMake(self.contentView.bounds.size.width - COLLECTION_CELL_HIGHLIGHTED_IMAGE_SIDE_LENGTH_MAX - COLLECTION_CELL_HIGHLIGHTED_IMAGE_MARGIN, self.contentView.bounds.size.height - COLLECTION_CELL_HIGHLIGHTED_IMAGE_SIDE_LENGTH_MAX - COLLECTION_CELL_HIGHLIGHTED_IMAGE_MARGIN, COLLECTION_CELL_HIGHLIGHTED_IMAGE_SIDE_LENGTH_MAX, COLLECTION_CELL_HIGHLIGHTED_IMAGE_SIDE_LENGTH_MAX);
        
        // 在中间打钩
        CGRect frame = CGRectMake((self.contentView.bounds.size.width - COLLECTION_CELL_HIGHLIGHTED_IMAGE_SIDE_LENGTH_MAX) / 2.0f, (self.contentView.bounds.size.height - COLLECTION_CELL_HIGHLIGHTED_IMAGE_SIDE_LENGTH_MAX) / 2.0f, COLLECTION_CELL_HIGHLIGHTED_IMAGE_SIDE_LENGTH_MAX, COLLECTION_CELL_HIGHLIGHTED_IMAGE_SIDE_LENGTH_MAX);
        _highlightedImageView = [[UIImageView alloc] initWithFrame:frame];
        _highlightedImageView.layer.cornerRadius = COLLECTION_CELL_HIGHLIGHTED_IMAGE_SIDE_LENGTH_MAX / 2.0f;
        _highlightedImageView.layer.masksToBounds = YES;
        _highlightedImageView.hidden = YES;
        [self.contentView addSubview:_highlightedImageView];
    }
    return _highlightedImageView;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.imageView.image = nil;
}

@end
