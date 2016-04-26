//
//  EAPhotoCollectionSectionHeaderView.m
//  ElegantAlbum
//
//  Created by 陆凯波 on 16/1/25.
//  Copyright © 2016年 Kaibo. All rights reserved.
//

#import "EAPhotoCollectionSectionHeaderView.h"

@implementation EAPhotoCollectionSectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    return self;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

@end
