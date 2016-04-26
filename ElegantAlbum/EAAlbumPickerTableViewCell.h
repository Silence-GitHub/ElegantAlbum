//
//  EAAlbumPickerTableViewCell.h
//  ElegantAlbum
//
//  Created by 陆凯波 on 16/3/28.
//  Copyright © 2016年 Kaibo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EAAlbumPickerTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *albumImageView;
@property (strong, nonatomic) IBOutlet UILabel *albumNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *albumPhotoCountLabel;
@end
