//
//  EANoteAlbumTableViewCell.m
//  ElegantAlbum
//
//  Created by 陆凯波 on 16/3/28.
//  Copyright © 2016年 Kaibo. All rights reserved.
//

#import "EANoteAlbumTableViewCell.h"

#import "EAPublic.h"

@implementation EANoteAlbumTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.albumImageView.layer.cornerRadius = ALBUM_TABLE_CELL_IMAGE_CORNER_RADIUS;
    self.albumImageView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
