//
//  EANoteAlbumTableHeaderView.m
//  ElegantAlbum
//
//  Created by Kaibo Lu on 16/4/23.
//

#import "EANoteAlbumTableHeaderView.h"

@implementation EANoteAlbumTableHeaderView

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

@end
