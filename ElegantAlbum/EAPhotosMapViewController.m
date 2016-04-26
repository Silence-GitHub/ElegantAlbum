//
//  EAPhotosMapViewController.m
//  ElegantAlbum
//
//  Created by 陆凯波 on 16/2/5.
//  Copyright © 2016年 Kaibo. All rights reserved.
//

#import "EAPhotosMapViewController.h"

@interface EAPhotosMapViewController ()

@property (nonatomic, strong) NSMutableArray<EAPhotoAnnotation *> *photoAnnos;

@end

@implementation EAPhotosMapViewController

#pragma mark - Properties

- (MKMapView *)mapView {
    if (!_mapView) {
        _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
        _mapView.delegate = self;
        [self.view addSubview:_mapView];
    }
    return _mapView;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:self.view.frame];
    }
    return _maskView;
}

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
        // Specify criteria for filtering which objects to fetch
        NSNumber *minLat = @(self.mapView.region.center.latitude - self.mapView.region.span.latitudeDelta / 2.0);
        NSNumber *maxLat = @(self.mapView.region.center.latitude + self.mapView.region.span.latitudeDelta / 2.0);
        NSNumber *minLng = @(self.mapView.region.center.longitude - self.mapView.region.span.longitudeDelta / 2.0);
        NSNumber *maxLng = @(self.mapView.region.center.longitude + self.mapView.region.span.longitudeDelta / 2.0);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"latitude > %@ AND latitude < %@ AND longitude > %@ AND longitude < %@", minLat, maxLat, minLng, maxLng];
        [fetchRequest setPredicate:predicate];
        // Specify how the fetched objects should be sorted
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate"                                                          ascending:NO];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
#warning should we use cache ?
        _fetchedResultsController = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:fetchRequest
                                     managedObjectContext:self.managedObjectContext
                                     sectionNameKeyPath:nil
                                     cacheName:nil];
        
        NSError *error;
        if (![_fetchedResultsController performFetch:&error]) {
            NSLog(@"Error: %@\nUser information: %@", error, error.userInfo);
        } else {
            NSLog(@"Fetch %lu photos", (unsigned long)_fetchedResultsController.fetchedObjects.count);
        }
    }
    return _fetchedResultsController;
}

- (NSMutableArray<EAPhotoAnnotation *> *)photoAnnos {
    if (!_photoAnnos) {
        _photoAnnos = [NSMutableArray array];
    }
    return _photoAnnos;
}

#pragma mark - View controller life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishRefreshingPhotos:) name:FINISH_REFRESHING_PHOTO_NOTIFICATION object:nil];
    
    self.mapView.delegate = self; // 为了调用getter，初始化mapView
    
    [self setupLeftBarButtonItems];
}

- (void)finishRefreshingPhotos:(NSNotification *)notification {
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self deselecteSelectedAnnotations];
    [self updateAnnotions];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FINISH_REFRESHING_PHOTO_NOTIFICATION object:nil];
}

#pragma mark - View deck controller delegate

- (void)viewDeckController:(IIViewDeckController*)viewDeckController willOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    NSLog(@"View deck controller will open view side");
    
    // Hide tab bar
    [self hideOrShowTabBar:self.tabBarController.tabBar onView:self.view hide:YES completion:nil];
    
    // Disable user interaction
    
    self.navigationItem.leftBarButtonItems = nil;
    
    [self.view addSubview:self.maskView];
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController willCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    NSLog(@"View deck controller will close view side");
    
    // Show tab bar
    [self hideOrShowTabBar:self.tabBarController.tabBar onView:self.view hide:NO completion:nil];
    
    // Enable user interaction
    
    [self setupLeftBarButtonItems];
    
    [self.maskView removeFromSuperview];
}

- (void)hideOrShowTabBar:(__weak UITabBar *)tabBar onView:(__weak UIView *)view hide:(BOOL)hide completion:(void (^)(BOOL finished))completion {
    
    [UIView animateWithDuration:0.5 animations:^{
        CGFloat x = tabBar.frame.origin.x;
        CGFloat width = tabBar.frame.size.width;
        CGFloat height = tabBar.frame.size.height;
        CGFloat y = view.bounds.size.height + (hide ? height : - height);
        tabBar.frame = CGRectMake(x, y, width, height);
    } completion:completion];
}

#pragma mark - Map view delegate

static NSString *annoViewReuseId = @"Photo";

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    EAPhotoAnnotation *photoAnno = annotation;
    
    MKAnnotationView *annoView = [mapView dequeueReusableAnnotationViewWithIdentifier:annoViewReuseId];
    if (!annoView) {
        annoView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annoViewReuseId];
        annoView.canShowCallout = YES;
    }
    
    ALAssetsLibrary *lib = [ALAssetsLibrary new];
    [lib assetForURL:[NSURL URLWithString:photoAnno.photo.url] resultBlock:^(ALAsset *asset) {
        UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
        image = [EAPublic image:image withSize:CGSizeMake(THUMBNAIL_SIDE_LENGTH_MEDIUM, THUMBNAIL_SIDE_LENGTH_MEDIUM)];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, THUMBNAIL_SIDE_LENGTH_MEDIUM, THUMBNAIL_SIDE_LENGTH_MEDIUM)];
        imageView.image = image;
        annoView.leftCalloutAccessoryView = imageView;
    } failureBlock:^(NSError *error) {
        NSLog(@"Error: %@\nUser information: %@", error, error.userInfo);
    }];
    
    UIButton *disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    annoView.rightCalloutAccessoryView = disclosureButton;
    
    return annoView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    NSLog(@"select annotation view");
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    EAPhotoAnnotation *anno = view.annotation;
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:anno.containedPhotoAnnotations.count + 1];
    [photos addObject:anno.photo];
    for (EAPhotoAnnotation *containedAnno in anno.containedPhotoAnnotations) {
        [photos addObject:containedAnno.photo];
    }
    
    if (photos.count > 1) {
        
        EAPhotosRegionCollectionViewController *photoCVC = [[EAPhotosRegionCollectionViewController alloc] initWithCollectionViewLayout:[XLPlainFlowLayout new]];
        photoCVC.fetchedObjectsSortedArr = photos;
        [self.navigationController pushViewController:photoCVC animated:YES];
        
    } else {
        
        EAPhotosPageViewController *pageVC = [[EAPhotosPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        pageVC.photos = photos;
        pageVC.firstPhotoIndex = 0;
        [self.navigationController pushViewController:pageVC animated:YES];
    }
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    
    NSLog(@"region will change");
    NSLog(@"number of selected annotations = %lu", (unsigned long)mapView.selectedAnnotations.count);
    [self deselecteSelectedAnnotations];
}

- (void)deselecteSelectedAnnotations {
    for (id<MKAnnotation> anno in self.mapView.selectedAnnotations) {
        [self.mapView deselectAnnotation:anno animated:YES];
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    NSLog(@"region did changed");
    [self updateAnnotions];
    NSLog(@"Number of annotations = %lu", self.photoAnnos.count);
}

- (void)updateAnnotions {
    self.fetchedResultsController = nil;
    
    NSLog(@"update annotations");
    NSLog(@"Before removing: number of photos = %lu", (unsigned long)((EAPhotoAnnotation *)self.photoAnnos.firstObject).containedPhotoAnnotations.count);
    
    CLLocationDegrees radius = [self radiusBetweenAnnotations];
    
    // Remove
    if (self.photoAnnos.count) {
        
        NSMutableArray *annosToRemove = [NSMutableArray array];
        NSMutableArray *annosToSeparate = [NSMutableArray array];
        
        for (EAPhotoAnnotation *annoShown in self.photoAnnos) {
            
            MKMapPoint point = MKMapPointForCoordinate(annoShown.coordinate);
            if (!MKMapRectContainsPoint(self.mapView.visibleMapRect, point)) {
                // Photos are not in visible region
                // Should not display
                [annosToRemove addObject:annoShown];
                
            } else {
                
                NSMutableArray *annosToSepTemp = [NSMutableArray array];
                for (EAPhotoAnnotation *annoContained in annoShown.containedPhotoAnnotations) {
                    
                    double dr2 = pow(annoContained.coordinate.latitude - annoShown.coordinate.latitude, 2) + pow(annoContained.coordinate.longitude - annoShown.coordinate.longitude, 2);
                    NSLog(@"r2 = %f", dr2);
                    if (dr2 > pow(radius, 2)) {
                        // Far enough
                        // Leave group and create new group
                        [annosToSepTemp addObject:annoContained];
                    }
                }
                [annoShown.containedPhotoAnnotations removeObjectsInArray:annosToSepTemp];
                [annosToSeparate addObjectsFromArray:annosToSepTemp];
            }
        }
        [self.photoAnnos removeObjectsInArray:annosToRemove];
        [self.mapView removeAnnotations:annosToRemove];
        
        // add annos to separate
        [self addPhotoAnnotations:annosToSeparate];
        NSLog(@"After removing: number of photos = %lu", (unsigned long)((EAPhotoAnnotation *)self.photoAnnos.firstObject).containedPhotoAnnotations.count);
    }
    
    // Combine
    if (self.photoAnnos.count) {
        NSMutableArray *annosToCombine = [NSMutableArray array];
        for (NSUInteger i = 0; i < self.photoAnnos.count - 1; ++i) {
            for (NSUInteger j = i + 1; j < self.photoAnnos.count; ++j) {
                EAPhotoAnnotation *anno = self.photoAnnos[i];
                EAPhotoAnnotation *anno2 = self.photoAnnos[j];
                double dr2 = pow(anno.coordinate.latitude - anno2.coordinate.latitude, 2) + pow(anno.coordinate.longitude - anno2.coordinate.longitude, 2);
                NSLog(@"r2 = %f", dr2);
                if (dr2 < pow(radius, 2)) {
                    // Near enough
                    // Combine
                    if (![annosToCombine containsObject:anno2]) {
                        [annosToCombine addObjectsFromArray:anno2.containedPhotoAnnotations];
                        anno2.containedPhotoAnnotations = nil;
                        [annosToCombine addObject:anno2];
                    }
                }
            }
        }
        [self.photoAnnos removeObjectsInArray:annosToCombine];
        [self.mapView removeAnnotations:annosToCombine];
        [self addPhotoAnnotations:annosToCombine];
        
        NSLog(@"After adding: number of photos = %lu", (unsigned long)((EAPhotoAnnotation *)self.photoAnnos.firstObject).containedPhotoAnnotations.count);
    }
    
    // Add
    NSMutableArray *annosToAdd = [NSMutableArray array];
    for (EAPhoto *photo in self.fetchedResultsController.fetchedObjects) {
        BOOL shown = NO;
        for (EAPhotoAnnotation *annoShown in self.photoAnnos) {
            if ([annoShown containsPhoto:photo]) {
                shown = YES;
                break;
            }
        }
        if (!shown) {
            NSLog(@"Add new anno");
            EAPhotoAnnotation *newAnno = [[EAPhotoAnnotation alloc] initWithPhoto:photo];
            [annosToAdd addObject:newAnno];
        }
    }
    [self addPhotoAnnotations:annosToAdd];
}

- (void)addPhotoAnnotations:(NSArray *)newAnnos {
    
    for (EAPhotoAnnotation *newAnno in newAnnos) {
        
        [self addPhotoAnnotation:newAnno];
    }
    [self.photoAnnos sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        EAPhotoAnnotation *anno1 = obj1;
        EAPhotoAnnotation *anno2 = obj2;
        return [anno2.photo.creationDate compare:anno1.photo.creationDate]; // Descending
    }];
}

- (void)addPhotoAnnotation:(EAPhotoAnnotation *)newAnno {
    
    CLLocationDegrees radius = [self radiusBetweenAnnotations];
    BOOL addToGroup = NO;
    for (EAPhotoAnnotation *annoShown in self.photoAnnos) {
        double dr2 = pow(newAnno.coordinate.latitude - annoShown.coordinate.latitude, 2) + pow(newAnno.coordinate.longitude - annoShown.coordinate.longitude, 2);
        if (dr2 < pow(radius, 2)) {
            // Near enough
            // Add to group
            NSInteger index = [annoShown addPhotoAnnotation:newAnno];
            if (index == -1) {
                // annotation shown photo is replaced
                // 不移除再添加，则缩略图不更新
                [self.mapView removeAnnotation:annoShown];
                [self.mapView addAnnotation:annoShown];
            }
            addToGroup = YES;
            break;
        }
    }
    if (!addToGroup) {
        // Has not added to group
        // Create new group
        [self.photoAnnos addObject:newAnno];
        [self.mapView addAnnotation:newAnno];
    }
}

- (CLLocationDegrees)radiusBetweenAnnotations {
    
    NSUInteger nCirclesOfRow = self.view.bounds.size.width / MAP_GRID_SIDE_LENGTH;
    
    return self.mapView.region.span.longitudeDelta / nCirclesOfRow / 2.0;
}

@end
