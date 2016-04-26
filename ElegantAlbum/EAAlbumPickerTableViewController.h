//
//  EAAlbumPickerTableViewController.h
//  ElegantAlbum
//
//  Created by 陆凯波 on 16/2/21.
//  Copyright © 2016年 Kaibo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "EAPhoto.h"

@interface EAAlbumPickerTableViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray<EAPhoto *> *photos; // to add
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end
