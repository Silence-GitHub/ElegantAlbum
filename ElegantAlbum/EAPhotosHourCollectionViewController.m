//
//  EAPhotosHourCollectionViewController.m
//  ElegantAlbum
//
//  Created by 陆凯波 on 16/1/25.
//  Copyright © 2016年 Kaibo. All rights reserved.
//

#import <Photos/Photos.h>

#import "EAPhotosHourCollectionViewController.h"

@interface EAPhotosHourCollectionViewController ()

@end

@implementation EAPhotosHourCollectionViewController

#pragma mark - Properties

- (NSManagedObjectContext *)managedObjectContext {
    if (!_managedObjectContext) {
        EAAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        _managedObjectContext = appDelegate.managedObjectContext;
    }
    return _managedObjectContext;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"EAPhoto" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        // Specify how the fetched objects should be sorted
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate"                                                          ascending:NO];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc]
                                                  initWithFetchRequest:fetchRequest
                                                  managedObjectContext:self.managedObjectContext
                                                  sectionNameKeyPath:nil
                                                  cacheName:PHOTOS_DESCENDING_WITH_CREATION_DATE_CACHE_NAME];
        
        NSError *error;
        if (![_fetchedResultsController performFetch:&error]) {
            NSLog(@"Error: %@\nUser information: %@", error, error.userInfo);
        }
    }
    return _fetchedResultsController;
}

- (NSMutableArray *)fetchedObjectsSortedArr {
    if (!_fetchedObjectsSortedArr) {
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"HH";
        NSArray *sortedArray = [self.fetchedResultsController.fetchedObjects sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            
            EAPhoto *photo1 = obj1;
            EAPhoto *photo2 = obj2;
            NSInteger hour1 = [formatter stringFromDate:photo1.creationDate].integerValue;
            NSInteger hour2 = [formatter stringFromDate:photo2.creationDate].integerValue;
            return hour1 - hour2;
        }];
        _fetchedObjectsSortedArr = [NSMutableArray arrayWithArray:sortedArray];
        self.fetchedResultsController = nil;
    }
    return _fetchedObjectsSortedArr;
}

- (NSMutableArray *)fetchedObjectsGroupEndIndexesArr {
    if (!_fetchedObjectsGroupEndIndexesArr) {
        _fetchedObjectsGroupEndIndexesArr = [NSMutableArray array];
        EAPhoto *firstPhoto = self.fetchedObjectsSortedArr.firstObject;
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"HH";
        int hour = [formatter stringFromDate:firstPhoto.creationDate].intValue;
        for (NSUInteger i = 1; i < self.fetchedObjectsSortedArr.count; ++i) {
            EAPhoto *photo = self.fetchedObjectsSortedArr[i];
            int newHour = [formatter stringFromDate:photo.creationDate].intValue;
            if (hour != newHour) {
                [_fetchedObjectsGroupEndIndexesArr addObject:@(i-1)];
                hour = newHour;
            }
        }
        [_fetchedObjectsGroupEndIndexesArr addObject:@(self.fetchedObjectsSortedArr.count-1)];
    }
    return _fetchedObjectsGroupEndIndexesArr;
}

static const CGFloat TOOLBAR_HEIGHT = 44;

- (UIToolbar *)toolbar {
    if (!_toolbar) {
        _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - TOOLBAR_HEIGHT, self.view.bounds.size.width, TOOLBAR_HEIGHT)];
        [self.view addSubview:_toolbar];
    }
    return _toolbar;
}

- (NSArray *)barButtonItemsBeforeSelection {
    
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(prepareForAction:)];
    actionButton.enabled = NO;
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(prepareForAddingOtherPhotosToAlbum:)];
    UIBarButtonItem *flexibleSpaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *deleteButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteButtonPressed:)];
    deleteButtonItem.enabled = NO;
    
    if ([EAPublic iOSVersion] >= 8.0f)
        return @[actionButton, flexibleSpaceButton, addButton, flexibleSpaceButton, deleteButtonItem];
    return @[actionButton, flexibleSpaceButton, addButton];
}

- (void)prepareForAddingOtherPhotosToAlbum:(id)sender {
    NSLog(@"Press add button");
}

- (NSArray *)barButtonItemsAfterSelection {
    
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(prepareForAction:)];
    UIBarButtonItem *addToButton = [[UIBarButtonItem alloc] initWithTitle:@"Add to" style:UIBarButtonItemStylePlain target:self action:@selector(prepareForAddingSelectedPhotosToAlbum:)];
    UIBarButtonItem *flexibleSpaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *deleteButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteButtonPressed:)];
    
    if ([EAPublic iOSVersion] >= 8.0f)
        return @[actionButton, flexibleSpaceButton, addToButton, flexibleSpaceButton, deleteButtonItem];
    return @[actionButton, flexibleSpaceButton, addToButton];
}

- (void)prepareForAction:(id)sender {
    
    NSMutableArray<EAPhoto *> *selectedPhotos = [self selectedPhotos];
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:selectedPhotos.count];
    
    ALAssetsLibrary *lib = [ALAssetsLibrary new];
    for (EAPhoto *photo in selectedPhotos) {
        NSLog(@"Get selected photo url: %@", [NSURL URLWithString:photo.url]);
        // 不把assetForURL:放入其他线程异步执行则死锁，resultBlock不调用
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [lib assetForURL:[NSURL URLWithString:photo.url] resultBlock:^(ALAsset *asset) {
                NSLog(@"Get asset");
                UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage];
                NSLog(@"Update date images");
                [images addObject:image];
                
            } failureBlock:^(NSError *error) {
                NSLog(@"Error: %@\nUser information: %@", error, error.userInfo);
            }];
        });
    }
    
    // 用循环等待取图片完成，比用信号量等待快
    while (images.count < selectedPhotos.count) {}
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:images applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:^{
        NSLog(@"Show activity VC");
    }];
}

- (void)prepareForAddingSelectedPhotosToAlbum:(id)sender {
    
    NSMutableArray<EAPhoto *> *selectedPhotos = [self selectedPhotos];
    EAAlbumPickerTableViewController *albumPickerTVC = [[UIStoryboard storyboardWithName:@"EAMain" bundle:nil] instantiateViewControllerWithIdentifier:@"Album picker table view controller"];
    albumPickerTVC.photos = selectedPhotos;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:albumPickerTVC];
    __weak typeof(self) weakSelf = self;
    [self presentViewController:navigationController animated:YES completion:^{
        weakSelf.toolbar.hidden = YES;
    }];
}

- (NSMutableArray<EAPhoto *> *)selectedPhotos {
    
    NSMutableArray *selectedPhotos = [NSMutableArray arrayWithCapacity:self.collectionView.indexPathsForSelectedItems.count];
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems) {
        EAPhoto *photo = [self photoAtIndexPath:indexPath];
        [selectedPhotos addObject:photo];
    }
    [selectedPhotos sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        EAPhoto *photo1 = obj1;
        EAPhoto *photo2 = obj2;
        return [photo1.creationDate compare:photo2.creationDate]; // Ascending
    }];
    return selectedPhotos;
}

- (EAPhoto *)photoAtIndexPath:(NSIndexPath *)indexPath {
    EAPhoto *photo;
    if (indexPath.section != 0) {
        NSUInteger index = self.fetchedObjectsGroupEndIndexesArr[indexPath.section - 1].intValue + 1 + indexPath.item;
        photo = self.fetchedObjectsSortedArr[index];
        
    } else {
        photo = self.fetchedObjectsSortedArr[indexPath.item];
    }
    return photo;
}

- (void)deleteButtonPressed:(id)sender {
    NSLog(@"Delete button pressed");
    NSMutableArray<NSURL *> *urls = [NSMutableArray array];
    NSArray *selectedPhotos = self.selectedPhotos;
    for (EAPhoto *photo in selectedPhotos) {
        [urls addObject:[NSURL URLWithString:photo.url]];
    }
    
    __weak typeof(self) weakSelf = self;
    [[PHAsset fetchAssetsWithALAssetURLs:urls options:nil] enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest deleteAssets:@[obj]];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                for (EAPhoto *photo in selectedPhotos) {
                    NSLog(@"Searching photo");
                    NSUInteger index = [obj.localIdentifier rangeOfString:@"/"].location;
                    NSString *idStr = [obj.localIdentifier substringToIndex:index];
                    if ([photo.url containsString:idStr]) {
                        NSLog(@"Find EAPhoto");
                        NSLog(@"Delete EAPhoto");
                        [photo.managedObjectContext deleteObject:photo];
                        
                        // Post notification in main queue to update UI
                        // Although album and photo note may be changed, controllers observing PHOTO_NOTE_CHANGE_NOTIFICATION and ALBUM_CHANGE_NOTIFICATION are not created yet. No need to post these two notifications
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:PHOTO_CHANGE_NOTIFICAITON object:nil userInfo:@{ NUMBER_OF_PHOTO_CHANGE_KEY : @-1, PHOTOS_KEY : [NSSet setWithObject:photo] }];
                        });
                        break;
                    }
                }
            } else if (error) {
                NSLog(@"Error: %@\nUser information: %@", error, error.userInfo);
            }
            if (idx == selectedPhotos.count - 1) {
                // Update UI in main queue
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf finishEditingPhotos:nil];
                });
            }
        }];
    }];
}

- (NSArray *)rightBarButtonItemsDefault {
    if (!_rightBarButtonItemsDefault) {
        _rightBarButtonItemsDefault = @[[[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStylePlain target:self action:@selector(startEditingPhotos:)]];
    }
    return _rightBarButtonItemsDefault;
}

- (void)startEditingPhotos:(id)sender {
    self.collectionView.allowsMultipleSelection = YES;
    
    self.navigationItem.rightBarButtonItems = self.rightBarButtonItemsEditing;
    
    [self.toolbar setItems:[self barButtonItemsBeforeSelection] animated:YES];
    self.toolbar.hidden = NO;
    
    [EAPublic hideOrShowTabBar:self.tabBarController.tabBar onView:self.view hide:YES completion:nil];
}

- (NSArray *)rightBarButtonItemsEditing {
    if (!_rightBarButtonItemsEditing) {
        _rightBarButtonItemsEditing = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(finishEditingPhotos:)]];
    }
    return _rightBarButtonItemsEditing;
}

- (void)finishEditingPhotos:(id)sender {
    // Deselect cells
    NSArray *selectedItems = self.collectionView.indexPathsForSelectedItems;
    for (NSIndexPath *indexPath in selectedItems) {
        [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
        EAPhotoCollectionViewCell *cell = (EAPhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        cell.highlightedImageView.hidden = YES;
    }
    
    self.collectionView.allowsMultipleSelection = NO;
    
    self.navigationItem.rightBarButtonItems = self.rightBarButtonItemsDefault;
    
    __weak typeof(self) weakSelf = self;
    [EAPublic hideOrShowTabBar:self.tabBarController.tabBar onView:self.view hide:NO completion:^(BOOL finished) {
        weakSelf.toolbar.hidden = YES;
        [weakSelf.toolbar removeFromSuperview];
        weakSelf.toolbar = nil;
    }];
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:self.view.frame];
    }
    return _maskView;
}

#pragma mark - View controller life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addNotificationObservers];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self setupLeftBarButtonItems];
    
    // Register cell classes
    [self.collectionView registerClass:[EAPhotoCollectionViewCell class] forCellWithReuseIdentifier:PHOTO_CELL_REUSE_IDENTIFIER];
    [self.collectionView registerClass:[EAPhotoCollectionSectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:PHOTO_SECTION_HEADER_REUSE_IDENTIFIER];
}

- (void)addNotificationObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishRefreshingPhoto:) name:FINISH_REFRESHING_PHOTO_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoChange:) name:PHOTO_CHANGE_NOTIFICAITON object:nil];
}

- (void)finishRefreshingPhoto:(NSNotification *)notification {
    NSSet *photos = notification.userInfo[NEW_PHOTOS_KEY];
    if (photos) {
        // Application active
        [self addPhotos:photos];
        return;
    }
    // Refresh all photos
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self finishEditingPhotos:nil];
    self.fetchedObjectsSortedArr = nil;
    self.fetchedObjectsGroupEndIndexesArr = nil;
    [self.collectionView reloadData];
}

- (void)photoChange:(NSNotification *)notification {
    NSNumber *number = notification.userInfo[NUMBER_OF_PHOTO_CHANGE_KEY];
    NSSet *photos = notification.userInfo[PHOTOS_KEY];
    if (number.intValue > 0) {
        // Photo increase
        [self addPhotos:photos];
    } else if (number.intValue < 0) {
        NSLog(@"Photo decrease");
        // Photo decrease
        [self removePhotos:photos];
    }
}

- (void)addPhotos:(NSSet *)photos {
    for (EAPhoto *photo in photos) {
        // Update _fetchedObjectsSortedArr
        if (![self canAddPhoto:photo]) {
            continue;
        }
#warning Use better search method
        NSUInteger indexOfPhoto = [self indexOfPhotoToAdd:photo];
        [self.fetchedObjectsSortedArr insertObject:photo atIndex:indexOfPhoto];
        
        // Check whether need to insert a new section
        // -1 means the same section with the last photo
        // 1 means the same section with the next photo
        // 0 means need to insert a new section
        int sectionToAdd = 0;
        if (indexOfPhoto > 0) {
            // Has last photo
            EAPhoto *lastPhoto = self.fetchedObjectsSortedArr[indexOfPhoto - 1];
            if ([self sameSectionForPhoto:photo andPhoto:lastPhoto]) {
                sectionToAdd = -1;
            }
        }
        if (sectionToAdd == 0) {
            if (indexOfPhoto < self.fetchedObjectsSortedArr.count - 1) {
                // Has next photo
                EAPhoto *nextPhoto = self.fetchedObjectsSortedArr[indexOfPhoto + 1];
                if ([self sameSectionForPhoto:photo andPhoto:nextPhoto]) {
                    sectionToAdd = 1;
                }
            }
        }
        
        // Tail subarray or the whole _fetchedObjectsGroupEndIndexesArr need to update
        // Get first index of _fetchedObjectsGroupEndIndexesArr to change
        int firstIndexToChange = 0;
        int tempIndex = sectionToAdd > -1 ? 0 : -1;
        for (NSNumber *groupEndIndex in self.fetchedObjectsGroupEndIndexesArr) {
            if (indexOfPhoto + tempIndex <= groupEndIndex.intValue) {
                break;
            }
            ++firstIndexToChange;
        }
        
        // Update _fetchedObjectsGroupEndIndexesArr
        int i = firstIndexToChange;
        if (self.fetchedObjectsSortedArr.count == 1 && sectionToAdd == 0) {
            // Do not has photo before and need to insert section
            self.fetchedObjectsGroupEndIndexesArr[0] = @0;
        } else if (firstIndexToChange == self.fetchedObjectsGroupEndIndexesArr.count) {
            // Need to create a new section at the end of original section
            [self.fetchedObjectsGroupEndIndexesArr addObject:@(indexOfPhoto)];
        } else {
            // Already has photo before
            while (i < self.fetchedObjectsGroupEndIndexesArr.count) {
                if (sectionToAdd == -1 || sectionToAdd == 1) {
                    self.fetchedObjectsGroupEndIndexesArr[i] = @(self.fetchedObjectsGroupEndIndexesArr[i].intValue + 1);
                } else {
                    // sectionToAdd == 0
                    if (i == firstIndexToChange) {
                        [self.fetchedObjectsGroupEndIndexesArr insertObject:@(indexOfPhoto) atIndex:i];
                    } else {
                        // i > firstIndexToChange
                        self.fetchedObjectsGroupEndIndexesArr[i] = @(self.fetchedObjectsGroupEndIndexesArr[i].intValue + 1);
                    }
                }
                ++i;
            }
        }
        
        // Get index path of item to add
        NSIndexPath *indexPath;
        NSInteger item = indexOfPhoto; // section 0
        if (firstIndexToChange > 0) {
            // section > 0
            item = indexOfPhoto - self.fetchedObjectsGroupEndIndexesArr[firstIndexToChange - 1].intValue - 1;
        }
        indexPath = [NSIndexPath indexPathForItem:item inSection:firstIndexToChange];
        
        // Add item
        if (sectionToAdd) {
            // Insert item
            [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
        } else {
            // Insert section
            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
        }
    }
}

- (BOOL)canAddPhoto:(EAPhoto *)photo {
    return YES;
}

- (NSUInteger)indexOfPhotoToAdd:(EAPhoto *)photo {
    NSUInteger index = 0;
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"HH";
    while (index < self.fetchedObjectsSortedArr.count) {
        EAPhoto *photo2 = self.fetchedObjectsSortedArr[index];
        int hour1 = [formatter stringFromDate:photo.creationDate].intValue;
        int hour2 = [formatter stringFromDate:photo2.creationDate].intValue;
        if (hour1 == hour2 && [photo.creationDate compare:photo2.creationDate] == NSOrderedDescending) {
            break;
        } else if (hour1 < hour2) {
            break;
        }
        ++index;
    }
    return index;
}

- (BOOL)sameSectionForPhoto:(EAPhoto *)photo1 andPhoto:(EAPhoto *)photo2 {
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"HH";
    int hour1 = [formatter stringFromDate:photo1.creationDate].intValue;
    int hour2 = [formatter stringFromDate:photo2.creationDate].intValue;
    return hour1 == hour2;
}

- (void)removePhotos:(NSSet *)photos {
    NSLog(@"Remove photos");
    for (EAPhoto *photo in photos) {
        // Update _fetchedObjectsSortedArr
#warning Use binary search
        NSUInteger indexOfPhoto = [self.fetchedObjectsSortedArr indexOfObject:photo];
        if (indexOfPhoto == NSNotFound) {
            continue;
        }
        [self.fetchedObjectsSortedArr removeObjectAtIndex:indexOfPhoto];
        NSLog(@"index of photo = %lu", (unsigned long)indexOfPhoto);
        
        // Tail subarray or the whole _fetchedObjectsGroupEndIndexesArr need to update
        // Get first index of _fetchedObjectsGroupEndIndexesArr to change
        int firstIndexToChange = 0;
        for (NSNumber *groupEndIndex in self.fetchedObjectsGroupEndIndexesArr) {
            if (indexOfPhoto <= groupEndIndex.intValue) {
                break;
            }
            ++firstIndexToChange;
        }
        NSLog(@"first index to change = %d", firstIndexToChange);
        
        // Update _fetchedObjectsGroupEndIndexesArr
        BOOL deleteSection = NO;
        int i = firstIndexToChange;
        while (i < self.fetchedObjectsGroupEndIndexesArr.count) {
            if (firstIndexToChange > 0 && i == firstIndexToChange) {
                if (self.fetchedObjectsGroupEndIndexesArr[i].intValue - self.fetchedObjectsGroupEndIndexesArr[i-1].intValue > 1) {
                    self.fetchedObjectsGroupEndIndexesArr[i] = @(self.fetchedObjectsGroupEndIndexesArr[i].intValue - 1);
                } else {
                    [self.fetchedObjectsGroupEndIndexesArr removeObjectAtIndex:firstIndexToChange];
                    deleteSection = YES;
                    continue;
                }
            } else if (i == firstIndexToChange) {
                // firstIndexToChange = 0
                if (self.fetchedObjectsGroupEndIndexesArr[0].intValue > 0) {
                    self.fetchedObjectsGroupEndIndexesArr[0] = @(self.fetchedObjectsGroupEndIndexesArr[0].intValue - 1);
                } else {
                    [self.fetchedObjectsGroupEndIndexesArr removeObjectAtIndex:0];
                    deleteSection = YES;
                    continue;
                }
            } else {
                // i > firstIndexToChange
                self.fetchedObjectsGroupEndIndexesArr[i] = @(self.fetchedObjectsGroupEndIndexesArr[i].intValue - 1);
            }
            ++i;
        }
        
        // Get index path of item to delete
        // Although _fetchedObjectsGroupEndIndexesArr was updated, only tail subarray was updated
        // index path was not changed
        NSIndexPath *indexPath;
        NSInteger item = indexOfPhoto; // section 0
        if (firstIndexToChange > 0) {
            // section > 0
            item = indexOfPhoto - self.fetchedObjectsGroupEndIndexesArr[firstIndexToChange - 1].intValue - 1;
        }
        indexPath = [NSIndexPath indexPathForItem:item inSection:firstIndexToChange];
        
        // Delete item
        if (!deleteSection) {
            // Has photo left
            // Delete item
            [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
        } else {
            // No photo left
            // Delete section
            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
        }
    }
}

- (void)setupLeftBarButtonItems {
    
    UIButton *leftMenuButton = [EAPublic leftMenuButtonItemCustomViewClosed:YES];
    [leftMenuButton addTarget:self action:@selector(leftMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftMenuButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftMenuButton];
    self.navigationItem.leftBarButtonItems = @[leftMenuButtonItem];
}

- (void)leftMenuButtonPressed:(id)sender {
    NSLog(@"More button pressed");
    [self.viewDeckController toggleLeftView];
}

- (void)refreshButtonPressed:(id)sender {
    NSLog(@"Refresh button pressed");
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self finishEditingPhotos:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [self removeNotificationObservers];
}

- (void)removeNotificationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FINISH_REFRESHING_PHOTO_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PHOTO_CHANGE_NOTIFICAITON object:nil];
}

#pragma mark - View deck controller delegate

- (void)viewDeckController:(IIViewDeckController*)viewDeckController willOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    NSLog(@"View deck controller will open view side");
    
    // Hide tab bar
    [EAPublic hideOrShowTabBar:self.tabBarController.tabBar onView:self.view hide:YES completion:nil];
    
    // Disable user interaction
    
    self.navigationItem.leftBarButtonItems = nil;
    
    [self.view addSubview:self.maskView];
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController willCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    NSLog(@"View deck controller will close view side");
    
    if (!self.collectionView.allowsMultipleSelection) {
        // Show tab bar
        [EAPublic hideOrShowTabBar:self.tabBarController.tabBar onView:self.view hide:NO completion:nil];
    }
    
    // Enable user interaction
    
    [self setupLeftBarButtonItems];
    
    [self.maskView removeFromSuperview];
}

#pragma mark - Collection view data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    if (self.fetchedObjectsSortedArr.count == 0) {
        // No photos
        NSLog(@"Section number = 0");
        return 0;
    }
    NSLog(@"Section number = %lu", (unsigned long)self.fetchedObjectsGroupEndIndexesArr.count);
    return self.fetchedObjectsGroupEndIndexesArr.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (section != 0) {
        NSLog(@"%d rows in section %ld", self.fetchedObjectsGroupEndIndexesArr[section].intValue - self.fetchedObjectsGroupEndIndexesArr[section - 1].intValue, (long)section);
        return self.fetchedObjectsGroupEndIndexesArr[section].intValue - self.fetchedObjectsGroupEndIndexesArr[section - 1].intValue;
    } else {
        NSLog(@"%d rows in section %ld", self.fetchedObjectsGroupEndIndexesArr.firstObject.intValue + 1, (long)section);
        return self.fetchedObjectsGroupEndIndexesArr.firstObject.intValue + 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    EAPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PHOTO_CELL_REUSE_IDENTIFIER forIndexPath:indexPath];
    
    EAPhoto *photo;
    if (indexPath.section != 0) {
        NSUInteger index = self.fetchedObjectsGroupEndIndexesArr[indexPath.section - 1].intValue + 1 + indexPath.item;
        photo = self.fetchedObjectsSortedArr[index];
        
    } else {
        photo = self.fetchedObjectsSortedArr[indexPath.item];
    }
    
    cell.url = photo.url;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        ALAssetsLibrary *lib = [ALAssetsLibrary new];
        [lib assetForURL:[NSURL URLWithString:photo.url] resultBlock:^(ALAsset *asset) {
            UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
            [EAPublic image:image withSize:CGSizeMake(THUMBNAIL_SIDE_LENGTH_MAX, THUMBNAIL_SIDE_LENGTH_MAX)];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([cell.url isEqualToString:photo.url]) {
                    cell.imageView.image = image;
                    cell.highlightedImageView.hidden = !cell.selected;
                    cell.highlightedImageView.image = [UIImage imageNamed:@"Collection_cell_highlight"];
                }
            });
        } failureBlock:^(NSError *error) {
            NSLog(@"Error: %@\nUser information: %@", error, error.userInfo);
        }];
    });
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    return CGSizeMake(self.collectionView.bounds.size.width, COLLECTION_HEADER_HEIGHT);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        EAPhotoCollectionSectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:PHOTO_SECTION_HEADER_REUSE_IDENTIFIER forIndexPath:indexPath];
        
        NSUInteger index = self.fetchedObjectsGroupEndIndexesArr[indexPath.section].intValue;
        EAPhoto *photo = self.fetchedObjectsSortedArr[index];
        
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"HH";
        int hour = [formatter stringFromDate:photo.creationDate].intValue;
        NSString *dateStr = [NSString stringWithFormat:@"%d:00", hour];
        
        int numberOfPhotos;
        if (indexPath.section == 0) {
            numberOfPhotos = self.fetchedObjectsGroupEndIndexesArr.firstObject.intValue + 1;
        } else {
            numberOfPhotos = self.fetchedObjectsGroupEndIndexesArr[indexPath.section].intValue - self.fetchedObjectsGroupEndIndexesArr[indexPath.section - 1].intValue;
        }
        NSString *numberStr = numberOfPhotos == 1 ? @"1 photo" : [NSString stringWithFormat:@"%d photos", numberOfPhotos];
        
        headerView.titleLabel.text = [NSString stringWithFormat:@"%@    %@", dateStr, numberStr];
        [headerView.titleLabel sizeToFit];
        CGFloat height = (COLLECTION_HEADER_HEIGHT - headerView.titleLabel.frame.size.height) / 2.0f;
        headerView.titleLabel.frame = CGRectMake(COLLECTION_HEADER_X, height, headerView.titleLabel.frame.size.width, headerView.titleLabel.frame.size.height);
        
        return headerView;
    }
    return nil;
}

#pragma mark - Collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"Select item at section %lu item %lu", (unsigned long)indexPath.section, (unsigned long)indexPath.item);
    
    if (!collectionView.allowsMultipleSelection) {
        
        NSUInteger firstIndex = 0;
        if (indexPath.section > 0) {
            firstIndex = self.fetchedObjectsGroupEndIndexesArr[indexPath.section - 1].intValue + 1;
        }
        NSUInteger lastIndex = self.fetchedObjectsGroupEndIndexesArr[indexPath.section].intValue;
        NSArray *photos = [self.fetchedObjectsSortedArr subarrayWithRange:NSMakeRange(firstIndex, lastIndex - firstIndex + 1)];
        EAPhotosPageViewController *pageVC = [[EAPhotosPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        pageVC.photos = photos;
        pageVC.firstPhotoIndex = indexPath.item;
        [self.navigationController pushViewController:pageVC animated:YES];
        
        [EAPublic hideOrShowTabBar:self.tabBarController.tabBar onView:self.view hide:YES completion:nil];
        
    } else {
        
        EAPhotoCollectionViewCell *cell = (EAPhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        cell.highlightedImageView.hidden = NO;
        
        if (collectionView.indexPathsForSelectedItems.count == 1) {
            [self.toolbar setItems:[self barButtonItemsAfterSelection] animated:YES];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"Deselect item at section %lu item %lu", (unsigned long)indexPath.section, (unsigned long)indexPath.item);
    
    if (self.collectionView.allowsMultipleSelection) {
        
        EAPhotoCollectionViewCell *cell = (EAPhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        cell.highlightedImageView.hidden = YES;
        
        if (collectionView.indexPathsForSelectedItems.count == 0) {
            [self.toolbar setItems:[self barButtonItemsBeforeSelection] animated:YES];
        }
    }
}

#pragma mark - Collection view delegate flow layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(COLLECTION_CELL_SIDE_LENGHT_MAX, COLLECTION_CELL_SIDE_LENGHT_MAX);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    return 0;
}

@end
