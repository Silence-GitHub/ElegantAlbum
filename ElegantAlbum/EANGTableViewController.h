//
//  EANGTableViewController.h
//  ElegantAlbum
//
//  Created by 陆凯波 on 16/4/9.
//  Copyright © 2016年 Kaibo. All rights reserved.
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
