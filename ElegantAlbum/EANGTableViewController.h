//
//  EANGTableViewController.h
//  ElegantAlbum
//
//  Created by Kaibo Lu on 16/4/9.
//

#import <UIKit/UIKit.h>

#import "EANGPhoto.h"

#import "IIViewDeckController.h"

@interface EANGTableViewController : UITableViewController <IIViewDeckControllerDelegate>

@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) NSMutableArray<EANGPhoto *> *photos;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) UIView *maskView; // mask to avoid user interaction when showing slide menu

@end
