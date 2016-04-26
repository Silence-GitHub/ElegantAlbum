//
//  EAPhotosDateCollectionViewController.m
//  ElegantAlbum
//
//  Created by Kaibo Lu on 16/1/27.
//

#import "EAPhotosDateCollectionViewController.h"

@interface EAPhotosDateCollectionViewController ()

@end

@implementation EAPhotosDateCollectionViewController

#pragma mark - Properties

@synthesize fetchedObjectsSortedArr = _fetchedObjectsSortedArr;
@synthesize fetchedObjectsGroupEndIndexesArr = _fetchedObjectsGroupEndIndexesArr;

- (NSMutableArray *)fetchedObjectsSortedArr {
    if (!_fetchedObjectsSortedArr) {
        _fetchedObjectsSortedArr = [NSMutableArray arrayWithArray:self.fetchedResultsController.fetchedObjects];
        self.fetchedResultsController = nil;
    }
    return _fetchedObjectsSortedArr;
}

- (NSMutableArray *)fetchedObjectsGroupEndIndexesArr {
    if (!_fetchedObjectsGroupEndIndexesArr) {
        _fetchedObjectsGroupEndIndexesArr = [NSMutableArray arrayWithCapacity:self.fetchedObjectsSortedArr.count];
        EAPhoto *firstPhoto = self.fetchedObjectsSortedArr.firstObject;
        NSDateFormatter *yearFormatter = [NSDateFormatter new];
        yearFormatter.dateFormat = @"yyyy";
        int year = [yearFormatter stringFromDate:firstPhoto.creationDate].intValue;
        NSDateFormatter *monthFormatter = [NSDateFormatter new];
        monthFormatter.dateFormat = @"MM";
        int month = [monthFormatter stringFromDate:firstPhoto.creationDate].intValue;
        for (NSUInteger i = 1; i < self.fetchedObjectsSortedArr.count; ++i) {
            EAPhoto *photo = self.fetchedObjectsSortedArr[i];
            int newYear = [yearFormatter stringFromDate:photo.creationDate].intValue;
            int newMonth = [monthFormatter stringFromDate:photo.creationDate].intValue;
            if (year != newYear || month != newMonth) {
                [_fetchedObjectsGroupEndIndexesArr addObject:@(i-1)];
                year = newYear;
                month = newMonth;
            }
        }
        [_fetchedObjectsGroupEndIndexesArr addObject:@(self.fetchedObjectsSortedArr.count-1)];
    }
    return _fetchedObjectsGroupEndIndexesArr;
}

#pragma mark - View controller life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Collection view data source

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        EAPhotoCollectionSectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:PHOTO_SECTION_HEADER_REUSE_IDENTIFIER forIndexPath:indexPath];
        
        NSUInteger index = self.fetchedObjectsGroupEndIndexesArr[indexPath.section].intValue;
        EAPhoto *photo = self.fetchedObjectsSortedArr[index];
        
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"yyyy-MM";
        NSString *dateStr = [formatter stringFromDate:photo.creationDate];
        
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

@end
