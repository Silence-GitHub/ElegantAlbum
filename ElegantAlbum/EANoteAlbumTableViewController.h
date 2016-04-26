//
//  EANoteAlbumTableViewController.h
//  ElegantAlbum
//
//  Created by 陆凯波 on 16/1/27.
//  Copyright © 2016年 Kaibo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "IIViewDeckController.h"

@interface EANoteAlbumTableViewController : UITableViewController <IIViewDeckControllerDelegate>

@property (nonatomic, strong) UIView *maskView; // mask to avoid user interaction when showing slide menu

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *photosWithNotesFRC;
@property (nonatomic, strong) NSFetchedResultsController *albumsFRC;

@end
