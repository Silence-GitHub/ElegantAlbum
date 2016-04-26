//
//  EAPhotosNoteCollectionViewController.m
//  ElegantAlbum
//
//  Created by Kaibo Lu on 16/1/27.
//

#import "EAPhotosNoteCollectionViewController.h"

@interface EAPhotosNoteCollectionViewController ()

@end

@implementation EAPhotosNoteCollectionViewController

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
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT note == %@", nil];
        [fetchRequest setPredicate:predicate];
        // Specify how the fetched objects should be sorted
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"modificationDate"                                                          ascending:NO];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:fetchRequest
                                     managedObjectContext:self.managedObjectContext
                                     sectionNameKeyPath:nil
                                     cacheName:PHOTOS_WITH_NOTE_DESCENDING_WITH_MODIFICATION_DATE_CACHE_NAME];
        
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
        _fetchedObjectsGroupEndIndexesArr = [NSMutableArray arrayWithObject:@(self.fetchedObjectsSortedArr.count-1)];
    }
    return _fetchedObjectsGroupEndIndexesArr;
}

// Override super method
- (NSArray *)barButtonItemsBeforeSelection {
    
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(prepareForAction:)];
    actionButton.enabled = NO;
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(prepareForAddingOtherPhotosToAlbum:)];
    UIBarButtonItem *flexibleSpaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    return @[actionButton, flexibleSpaceButton, addButton];
}

// Override super method
- (NSArray *)barButtonItemsAfterSelection {
    
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(prepareForAction:)];
    UIBarButtonItem *addToButton = [[UIBarButtonItem alloc] initWithTitle:@"Add to" style:UIBarButtonItemStylePlain target:self action:@selector(prepareForAddingSelectedPhotosToAlbum:)];
    UIBarButtonItem *flexibleSpaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    return @[actionButton, flexibleSpaceButton, addToButton];
}

#pragma mark - View controller life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
}

// Override super method
- (void)addNotificationObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoNoteChange:) name:PHOTO_NOTE_CHANGE_NOTIFICATION object:nil];
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

- (void)photoNoteChange:(NSNotification *)notification {
    NSNumber *number = notification.userInfo[NUMBER_OF_PHOTO_NOTE_CHANGE_KEY];
    EAPhoto *photo = notification.userInfo[PHOTO_KEY];
    if (number.intValue > 0) {
        // Number of photo note increase
        NSLog(@"Before number of note photos = %lu", (unsigned long)self.fetchedObjectsSortedArr.count);
        [self.fetchedObjectsSortedArr insertObject:photo atIndex:0];
        self.fetchedObjectsGroupEndIndexesArr[0] = @(self.fetchedObjectsSortedArr.count-1);
        NSLog(@"After number of note photos = %lu", (unsigned long)self.fetchedObjectsSortedArr.count);
        if (self.fetchedObjectsSortedArr.count == 1) {
            // No photo before
            // Insert section
            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:0]];
        } else {
            // Has photo before
            // Insert items
            [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
        }
    } else if (number.intValue == 0) {
        // Number of photo note not change
#warning Use binary search
        NSUInteger index = [self.fetchedObjectsSortedArr indexOfObject:photo];
        if (index != NSNotFound) {
            [self.fetchedObjectsSortedArr removeObjectAtIndex:index];
            [self.fetchedObjectsSortedArr insertObject:photo atIndex:0];
            [self.collectionView moveItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] toIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        }
    } else {
        // Number of photo note decrease
#warning Use binary search
        NSUInteger index = [self.fetchedObjectsSortedArr indexOfObject:photo];
        if (index != NSNotFound) {
            [self.fetchedObjectsSortedArr removeObjectAtIndex:index];
            self.fetchedObjectsGroupEndIndexesArr[0] = @(self.fetchedObjectsSortedArr.count-1);
            if (self.fetchedObjectsSortedArr.count) {
                // Has photo with note after removing
                // Delete item
                [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
            } else {
                // No photo with note after removing
                // Delete section
                [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:0]];
            }
        }
    }
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PHOTO_NOTE_CHANGE_NOTIFICATION object:nil];
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
