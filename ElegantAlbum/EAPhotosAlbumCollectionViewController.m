//
//  EAPhotosAlbumCollectionViewController.m
//  ElegantAlbum
//
//  Created by 陆凯波 on 16/2/22.
//  Copyright © 2016年 Kaibo. All rights reserved.
//

#import "EAPhotosAlbumCollectionViewController.h"
#import "EAAlbumDetailTableViewController.h"
#import "EAPhotoPickerCollectionViewController.h"

@interface EAPhotosAlbumCollectionViewController () <UIActionSheetDelegate>

@end

@implementation EAPhotosAlbumCollectionViewController

#pragma mark - Properties

@synthesize fetchedObjectsSortedArr = _fetchedObjectsSortedArr;
@synthesize rightBarButtonItemsDefault = _rightBarButtonItemsDefault;

- (NSMutableArray *)fetchedObjectsSortedArr {
    if (!_fetchedObjectsSortedArr) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate"                                                          ascending:NO];
        _fetchedObjectsSortedArr = [NSMutableArray arrayWithArray:[self.album.photos sortedArrayUsingDescriptors:@[sortDescriptor]]];
    }
    return _fetchedObjectsSortedArr;
}

- (NSArray *)barButtonItemsBeforeSelection {
    
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(prepareForAction:)];
    actionButton.enabled = NO;
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(prepareForAddingOtherPhotosToAlbum:)];
    UIBarButtonItem *removeButton = [[UIBarButtonItem alloc] initWithTitle:@"Remove" style:UIBarButtonItemStylePlain target:self action:@selector(prepareForRemovingSelectedPhotosFromAlbum:)];
    removeButton.enabled = NO;
    UIBarButtonItem *flexibleSpaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    return @[actionButton, flexibleSpaceButton, addButton, flexibleSpaceButton, removeButton];
}

- (NSArray *)barButtonItemsAfterSelection {
    
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(prepareForAction:)];
    UIBarButtonItem *addToButton = [[UIBarButtonItem alloc] initWithTitle:@"Add to" style:UIBarButtonItemStylePlain target:self action:@selector(prepareForAddingSelectedPhotosToAlbum:)];
    UIBarButtonItem *removeButton = [[UIBarButtonItem alloc] initWithTitle:@"Remove" style:UIBarButtonItemStylePlain target:self action:@selector(prepareForRemovingSelectedPhotosFromAlbum:)];
    UIBarButtonItem *flexibleSpaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    return @[actionButton, flexibleSpaceButton, addToButton, flexibleSpaceButton, removeButton];
}

- (void)prepareForAddingOtherPhotosToAlbum:(id)sender {
    NSLog(@"Add button pressed");
    EAPhotoPickerCollectionViewController *photoPickerCVC = [[EAPhotoPickerCollectionViewController alloc] initWithCollectionViewLayout:[XLPlainFlowLayout new]];
    photoPickerCVC.album = self.album;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:photoPickerCVC];
    __weak typeof(self) weakSelf = self;
    [self presentViewController:nc animated:YES completion:^{
        weakSelf.toolbar.hidden = YES;
    }];
}

- (void)prepareForRemovingSelectedPhotosFromAlbum:(id)sender {
    NSLog(@"Press remove button");
    NSString *actionSheetTitle = @"Sure to remove photos ?";
    if ([self selectedPhotos].count == 1) {
        actionSheetTitle = @"Sure to remove photo ?";
    }
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionSheetTitle delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"YES" otherButtonTitles:nil, nil];
    [actionSheet showFromRect:self.view.bounds inView:self.view animated:YES];
}

- (NSArray *)rightBarButtonItemsDefault {
    if (!_rightBarButtonItemsDefault) {
        UIButton *moreButtonCustomView = [EAPublic moreButtonItemCustomViewPointsInVerticalLine];
        [moreButtonCustomView addTarget:self action:@selector(showAlbumDetail:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] initWithCustomView:moreButtonCustomView];
        UIBarButtonItem *selectButton = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStylePlain target:self action:@selector(startEditingPhotos:)];
        _rightBarButtonItemsDefault = @[moreButton, selectButton];
    }
    return _rightBarButtonItemsDefault;
}

- (void)showAlbumDetail:(id)sender {
    EAAlbumDetailTableViewController *albumDetailTVC = [[UIStoryboard storyboardWithName:@"EAMain" bundle:nil] instantiateViewControllerWithIdentifier:@"Album detail table view controller"];
    albumDetailTVC.album = self.album;
    [self.navigationController pushViewController:albumDetailTVC animated:YES];
    
    [EAPublic hideOrShowTabBar:self.tabBarController.tabBar onView:self.view hide:YES completion:nil];
}

#pragma mark - View controller life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
}

// Override super method
- (void)addNotificationObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumChange:) name:ALBUM_CHANGE_NOTIFICATION object:nil];
}

// Override super method
- (void)setupLeftBarButtonItems {
    
    UIButton *backButton = [EAPublic backButtonItemCustomView];
    [backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItems = @[backButtonItem];
}

- (void)goBack:(id)sender {
    NSLog(@"Go back");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)albumChange:(NSNotification *)notification {
    EAAlbum *album = notification.userInfo[ALBUM_KEY];
    if (album == self.album) {
        // This album changed
        // Need to update
        NSNumber *numberOfAlbum = notification.userInfo[NUMBER_OF_ALBUM_CHANGE_KEY];
        if (numberOfAlbum.intValue == 0) {
            // Album changed
            // Update title
            self.title = album.name;
        }
        
        NSNumber *numberOfPhoto = notification.userInfo[NUMBER_OF_PHOTO_CHANGE_KEY];
        NSSet *photos = notification.userInfo[PHOTOS_KEY];
        if (numberOfPhoto.intValue > 0) {
            // Photos are add to this album
            [self addPhotos:photos];
        } else if (numberOfPhoto.intValue < 0) {
            // Photos were removed from this album
            [self removePhotos:photos];
        }
    }
}

// Override super method
- (BOOL)canAddPhoto:(EAPhoto *)photo {
    return [self.album.photos containsObject:photo];
}

// Override super method
- (NSUInteger)indexOfPhotoToAdd:(EAPhoto *)photo {
    NSUInteger index = 0;
    while (index < self.fetchedObjectsSortedArr.count) {
        EAPhoto *photo2 = self.fetchedObjectsSortedArr[index];
        if ([photo.creationDate compare:photo2.creationDate] == NSOrderedDescending) {
            break;
        }
        ++index;
    }
    return index;
}

// Override super method
- (BOOL)sameSectionForPhoto:(EAPhoto *)photo1 andPhoto:(EAPhoto *)photo2 {
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"yyyy";
    int year1 = [formatter stringFromDate:photo1.creationDate].intValue;
    int year2 = [formatter stringFromDate:photo2.creationDate].intValue;
    if (year1 != year2) {
        return NO;
    }
    formatter.dateFormat = @"MM";
    int month1 = [formatter stringFromDate:photo1.creationDate].intValue;
    int month2 = [formatter stringFromDate:photo2.creationDate].intValue;
    return month1 == month2;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.viewDeckController.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Override super method
- (void)removeNotificationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALBUM_CHANGE_NOTIFICATION object:nil];
}

#pragma mark - Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        // Confirm to remove selected photos from album
        
        // Update core date model
        [self.album removePhotoArray:[self selectedPhotos]];
        
        // Post notification
        [[NSNotificationCenter defaultCenter] postNotificationName:ALBUM_CHANGE_NOTIFICATION object:nil userInfo:@{ NUMBER_OF_ALBUM_CHANGE_KEY : @0, ALBUM_KEY : self.album, NUMBER_OF_PHOTO_CHANGE_KEY : @-1, PHOTOS_KEY : [NSSet setWithArray:[self selectedPhotos]] }];
        
        // Finish editing
        [self finishEditingPhotos:nil];
    }
}

@end
