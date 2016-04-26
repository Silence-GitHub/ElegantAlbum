//
//  EANoteAlbumTableHeaderView.m
//  ElegantAlbum
//
//  Created by 陆凯波 on 16/4/23.
//  Copyright © 2016年 Kaibo. All rights reserved.
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
