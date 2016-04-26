//
//  EAPhotosHourCollectionViewController.h
//  ElegantAlbum
//
//  Created by 陆凯波 on 16/1/25.
//  Copyright © 2016年 Kaibo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

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
- (void)addPhotos:(NSSet *)photos;
- (void)removePhotos:(NSSet *)photos;

- (void)prepareForAction:(id)sender;
- (void)prepareForAddingSelectedPhotosToAlbum:(id)sender;

@end
