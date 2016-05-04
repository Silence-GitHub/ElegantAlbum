//
//  EAAlbumPickerTableViewController.h
//  ElegantAlbum
//
//  Created by Kaibo Lu on 16/2/21.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "EAPhoto.h"

@interface EAAlbumPickerTableViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray<EAPhoto *> *photos; // to add
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end
