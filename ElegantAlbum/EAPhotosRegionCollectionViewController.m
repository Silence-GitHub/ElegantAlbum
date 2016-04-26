//
//  EAPhotosRegionCollectionViewController.m
//  ElegantAlbum
//
//  Created by 陆凯波 on 16/2/5.
//  Copyright © 2016年 Kaibo. All rights reserved.
//

#import "EAPhotosRegionCollectionViewController.h"

@interface EAPhotosRegionCollectionViewController ()

@end

@implementation EAPhotosRegionCollectionViewController

#pragma mark - Properties

@synthesize fetchedObjectsGroupEndIndexesArr = _fetchedObjectsGroupEndIndexesArr;

- (NSMutableArray *)fetchedObjectsGroupEndIndexesArr {
    if (!_fetchedObjectsGroupEndIndexesArr) {
        _fetchedObjectsGroupEndIndexesArr = [NSMutableArray arrayWithObject:@(self.fetchedObjectsSortedArr.count-1)];
    }
    return _fetchedObjectsGroupEndIndexesArr;
}

#pragma mark - View controller life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

// Override super method
- (BOOL)canAddPhoto:(EAPhoto *)photo {
#warning Should check photo region to determine whether to add photo
    return YES;
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
    return YES;
}

- (void)setupLeftBarButtonItems {
    
    UIButton *backButton = [EAPublic backButtonItemCustomView];
    [backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItems = @[backButtonItem];
}

- (void)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Collection view data source

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    return nil;
}

#pragma mark - Collection view delegate flow layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    return CGSizeZero;
}

@end
