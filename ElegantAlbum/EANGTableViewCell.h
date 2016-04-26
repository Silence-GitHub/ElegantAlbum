//
//  EANGTableViewCell.h
//  ElegantAlbum
//
//  Created by 陆凯波 on 16/4/9.
//  Copyright © 2016年 Kaibo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EANGTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *ngImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;

@end
