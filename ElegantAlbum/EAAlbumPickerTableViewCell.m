//
//  EAAlbumPickerTableViewCell.m
//  ElegantAlbum
//
//  Created by Kaibo Lu on 16/3/28.
//

#import "EAAlbumPickerTableViewCell.h"
#import "EAPublic.h"
@implementation EAAlbumPickerTableViewCell

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
