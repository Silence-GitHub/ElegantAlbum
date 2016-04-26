//
//  EANGTableViewCell.h
//  ElegantAlbum
//
//  Created by Kaibo Lu on 16/4/9.
//

#import <UIKit/UIKit.h>

@interface EANGTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *ngImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;

@end
