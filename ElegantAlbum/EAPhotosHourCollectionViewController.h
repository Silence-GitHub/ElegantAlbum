//
//  EAPhotosHourCollectionViewController.h
//  ElegantAlbum
//
//  Created by Kaibo Lu on 16/1/25.
//

#import <UIKit/UIKit.h>

#import "EAPhotosPageViewController.h"
#import "EAAlbumPickerTableViewController.h"

#import "EAPhoto.h"
#import "EAPhotoCollectionViewCell.h"
#import "EAPhotoCollectionSectionHeaderView.h"

#import "EAPublic.h"
#import "EAAppDelegate.h"

static NSString * const PHOTO_CELL_REUSE_IDENTIFIER = @"Photos";
static NSString * const PHOTO_SECTION_HEADER_REUSE_IDENTIFIER = @"Section headers";

@interface EAPhotosHourCollectionViewController : UICollectionViewController  <UICollectionViewDelegateFlowLayout, IIViewDeckControllerDelegate>

@property (nonatomic, strong) NSArray *rightBarButtonItemsDefault;
@property (nonatomic, strong) NSArray *rightBarButtonItemsEditing;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIView *maskView; // mask to avoid user interaction when showing slide menu

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSMutableArray<EAPhoto *> *fetchedObjectsSortedArr;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *fetchedObjectsGroupEndIndexesArr;

- (void)startEditingPhotos:(id)sender;
- (void)finishEditingPhotos:(id)sender;
- (NSMutableArray<EAPhoto *> *)selectedPhotos;

/**
 Add photos to data source, update collection view cells.
 Do not update core data
 */
- (void)addPhotos:(NSSet *)photos;

/**
 Remove photos from data source, update collection view cells.
 Do not update core data
 */
- (void)removePhotos:(NSSet *)photos;

/**
 Sent when action button pressed
 */
- (void)prepareForAction:(id)sender;

/**
 Sent when "add to" button pressed after selecting photos
 */
- (void)prepareForAddingSelectedPhotosToAlbum:(id)sender;

/**
 Sent when "add" button pressed
 */
- (void)prepareForAddingOtherPhotosToAlbum:(id)sender;

@end
