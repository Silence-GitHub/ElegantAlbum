//
//  EANoteAlbumTableViewController.h
//  ElegantAlbum
//
//  Created by Kaibo Lu on 16/1/27.
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
