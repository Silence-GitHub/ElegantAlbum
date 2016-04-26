//
//  EANoteAlbumTableViewCell.h
//  ElegantAlbum
//
//  Created by Kaibo Lu on 16/3/28.
//

#import <UIKit/UIKit.h>

@interface EANoteAlbumTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *albumImageView;
@property (strong, nonatomic) IBOutlet UILabel *albumNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *albumPhotoCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *albumModificationDateLabel;
@end
