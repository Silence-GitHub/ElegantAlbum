//
//  EAPhotosStateCollectionViewController.m
//  ElegantAlbum
//
//  Created by Kaibo Lu on 16/1/27.
//

#import "EAPhotosStateCollectionViewController.h"

@interface EAPhotosStateCollectionViewController ()

@end

@implementation EAPhotosStateCollectionViewController

#pragma mark - Properties

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize fetchedObjectsSortedArr = _fetchedObjectsSortedArr;
@synthesize fetchedObjectsGroupEndIndexesArr = _fetchedObjectsGroupEndIndexesArr;

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"EAPhoto" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        // Specify criteria for filtering which objects to fetch
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT state == %@", nil];
        [fetchRequest setPredicate:predicate];
        // Specify how the fetched objects should be sorted
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"state"                                                          ascending:YES selector:@selector(localizedCompare:)];
        NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"creationDate"                                                          ascending:NO];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, sortDescriptor2, nil]];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:fetchRequest
                                     managedObjectContext:self.managedObjectContext
                                     sectionNameKeyPath:nil
                                     cacheName:PHOTOS_WITH_STATE_DESCENDING_WITH_CREATION_DATE_CACHE_NAME];
        
        NSError *error;
        if (![_fetchedResultsController performFetch:&error]) {
            NSLog(@"Error: %@\nUser information: %@", error, error.userInfo);
        }
    }
    return _fetchedResultsController;
}

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
        NSString *state = firstPhoto.state;
        for (NSUInteger i = 1; i < self.fetchedObjectsSortedArr.count; ++i) {
            EAPhoto *photo = self.fetchedObjectsSortedArr[i];
            if (![state isEqualToString:photo.state]) {
                [_fetchedObjectsGroupEndIndexesArr addObject:@(i-1)];
                state = photo.state;
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
- (BOOL)canAddPhoto:(EAPhoto *)photo {
    return photo.state.length;
}

// Override super method
- (NSUInteger)indexOfPhotoToAdd:(EAPhoto *)photo {
    NSUInteger index = 0;
    while (index < self.fetchedObjectsSortedArr.count) {
        EAPhoto *photo2 = self.fetchedObjectsSortedArr[index];
        if ([photo.state isEqualToString:photo2.state] && [photo.creationDate compare:photo2.creationDate] == NSOrderedDescending) {
            break;
        } else if ([photo.state localizedCompare:photo2.state] == NSOrderedAscending) {
            break;
        }
        ++index;
    }
    return index;
}

// Override super method
- (BOOL)sameSectionForPhoto:(EAPhoto *)photo1 andPhoto:(EAPhoto *)photo2 {
    return [photo1.state isEqualToString:photo2.state];
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
        
        int numberOfPhotos;
        if (indexPath.section == 0) {
            numberOfPhotos = self.fetchedObjectsGroupEndIndexesArr.firstObject.intValue + 1;
        } else {
            numberOfPhotos = self.fetchedObjectsGroupEndIndexesArr[indexPath.section].intValue - self.fetchedObjectsGroupEndIndexesArr[indexPath.section - 1].intValue;
        }
        NSString *numberStr = numberOfPhotos == 1 ? @"1 photo" : [NSString stringWithFormat:@"%d photos", numberOfPhotos];
        
        headerView.titleLabel.text = [NSString stringWithFormat:@"%@    %@", photo.state, numberStr];
        [headerView.titleLabel sizeToFit];
        CGFloat height = (COLLECTION_HEADER_HEIGHT - headerView.titleLabel.frame.size.height) / 2.0f;
        headerView.titleLabel.frame = CGRectMake(COLLECTION_HEADER_X, height, headerView.titleLabel.frame.size.width, headerView.titleLabel.frame.size.height);
        
        return headerView;
    }
    return nil;
}

@end
