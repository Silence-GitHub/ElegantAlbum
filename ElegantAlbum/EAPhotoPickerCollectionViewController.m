//
//  EAPhotoPickerCollectionViewController.m
//  ElegantAlbum
//
//  Created by Kaibo Lu on 16/4/15.
//

#import "EAPhotoPickerCollectionViewController.h"

@interface EAPhotoPickerCollectionViewController ()

@end

@implementation EAPhotoPickerCollectionViewController

// Override super method
// Do not need tool bar
- (UIToolbar *)toolbar {
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self startEditingPhotos:nil];
}

// Override super method
- (void)startEditingPhotos:(id)sender {
    self.collectionView.allowsMultipleSelection = YES;
    
    self.navigationItem.rightBarButtonItems = self.rightBarButtonItemsEditing;
    
    [EAPublic hideOrShowTabBar:self.tabBarController.tabBar onView:self.view hide:YES completion:nil];
}

// Override super method
- (void)finishEditingPhotos:(id)sender {}

// Override super method
- (void)setupLeftBarButtonItems {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
}

- (void)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Override super method
- (NSArray *)rightBarButtonItemsDefault {
    return nil;
}

// Override super method
- (NSArray *)rightBarButtonItemsEditing {
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
    return @[doneButtonItem];
}

- (void)doneButtonPressed:(id)sender {
    NSArray *selectedPhotos = [self selectedPhotos];
    if (selectedPhotos.count) {
        [self.album addPhotoArray:selectedPhotos];
        [[NSNotificationCenter defaultCenter] postNotificationName:ALBUM_CHANGE_NOTIFICATION object:nil userInfo:@{ NUMBER_OF_ALBUM_CHANGE_KEY : @0, ALBUM_KEY : self.album, NUMBER_OF_PHOTO_CHANGE_KEY : @1, PHOTOS_KEY : [NSSet setWithArray:selectedPhotos] }];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Collection view data source

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    EAPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PHOTO_CELL_REUSE_IDENTIFIER forIndexPath:indexPath];
    
    EAPhoto *photo;
    if (indexPath.section != 0) {
        NSUInteger index = self.fetchedObjectsGroupEndIndexesArr[indexPath.section - 1].intValue + 1 + indexPath.item;
        photo = self.fetchedObjectsSortedArr[index];
        
    } else {
        photo = self.fetchedObjectsSortedArr[indexPath.item];
    }
    
    __weak typeof(self) weakSelf = self;
    cell.url = photo.url;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        ALAssetsLibrary *lib = [ALAssetsLibrary new];
        [lib assetForURL:[NSURL URLWithString:photo.url] resultBlock:^(ALAsset *asset) {
            UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
            [EAPublic image:image withSize:CGSizeMake(THUMBNAIL_SIDE_LENGTH_MAX, THUMBNAIL_SIDE_LENGTH_MAX)];
            if ([weakSelf.album.photos containsObject:photo]) {
                image = [EAPublic grayImage:image];
            }
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

#pragma mark - Collection view delegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    EAPhoto *photo;
    if (indexPath.section != 0) {
        NSUInteger index = self.fetchedObjectsGroupEndIndexesArr[indexPath.section - 1].intValue + 1 + indexPath.item;
        photo = self.fetchedObjectsSortedArr[index];
        
    } else {
        photo = self.fetchedObjectsSortedArr[indexPath.item];
    }
    
    return ![self.album.photos containsObject:photo];
}

@end
