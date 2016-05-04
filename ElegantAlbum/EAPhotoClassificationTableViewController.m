//
//  EAMainTableViewController.m
//  ElegantAlbum
//
//  Created by Kaibo Lu on 16/1/24.
//

#import "EAPhotoClassificationTableViewController.h"
#import "EAWaitingViewController.h"
#import "EAPhotosMapViewController.h"
#import "EAPhotosStateCollectionViewController.h"
#import "EAPhotosDateCollectionViewController.h"
#import "EAPhotosHourCollectionViewController.h"
#import "EANoteAlbumTableViewController.h"
#import "EANGTableViewController.h"
#import "EAPhotosAlbumCollectionViewController.h"

#import "EAPhoto.h"
#import "EAPhotoTemp.h"

#import "EAPublic.h"
#import "EAAppDelegate.h"

@interface EAPhotoClassificationTableViewController ()

@end

@implementation EAPhotoClassificationTableViewController {
    NSMutableDictionary *_urlToPhotoDic;
}

#pragma mark - Properties

- (NSManagedObjectContext *)managedObjectContext {
    if (!_managedObjectContext) {
        EAAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        _managedObjectContext = appDelegate.managedObjectContext;
    }
    return _managedObjectContext;
}

#pragma mark - View controller life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationActive:) name:APPLICATION_ACTIVE_NOTIFICATION object:nil];
    
    UIButton *leftMenuButton = [EAPublic leftMenuButtonItemCustomViewClosed:NO];
    [leftMenuButton addTarget:self action:@selector(leftMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftMenuButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftMenuButton];
    
    UIBarButtonItem *refreshButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
    
    self.navigationItem.leftBarButtonItems = @[leftMenuButtonItem, refreshButtonItem];
}

- (void)applicationActive:(NSNotification *)notification {
    [self checkAndCreateEAPhotoWhenActive];
}

- (void)leftMenuButtonPressed:(id)sender {
    [self.viewDeckController toggleLeftView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

static NSString *NUMBER_OF_ASSETS_KEY = @"Number_of_assets_key";

- (void)refresh:(id)sender {
    
    EAWaitingViewController *waitingVC = [EAWaitingViewController new];
    if ([EAPublic iOSVersion] >= 8.0f) {
        waitingVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    } else {
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
    }
    
    __block BOOL reachNilGroup = NO;
    __weak typeof(self) weakSelf = self;
    [self presentViewController:waitingVC animated:NO completion:^{
        
        weakSelf.viewDeckController.panningMode = IIViewDeckNoPanning;
        
        [weakSelf deleteEmptyPhotos:weakSelf.managedObjectContext];
        
        _urlToPhotoDic = [NSMutableDictionary dictionary];
        
        ALAssetsLibrary *lib = [ALAssetsLibrary new];
        [lib enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            NSLog(@"Asset group: %@", group);
            if (!group) {
                reachNilGroup = YES;
                NSLog(@"Asset group is nil");
                return;
            }
            
            NSNumber *type = [group valueForProperty:ALAssetsGroupPropertyType];
            if (type.unsignedIntegerValue == ALAssetsGroupPhotoStream) {
                // Do not add photo stream
                return;
            }
            
            [group setAssetsFilter:[ALAssetsFilter allPhotos]]; // Photo only
            
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                NSLog(@"Asset: %@", result);
                if (!result) {
                    NSLog(@"Asset is nil");
                    return;
                }
                
                NSURL *url = [result valueForProperty:ALAssetPropertyAssetURL];
                
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"EAPhoto" inManagedObjectContext:weakSelf.managedObjectContext];
                [fetchRequest setEntity:entity];
                // Specify criteria for filtering which objects to fetch
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"url == %@", url.absoluteString];
                [fetchRequest setPredicate:predicate];
                
                NSError *error = nil;
                NSArray *fetchedObjects = [weakSelf.managedObjectContext executeFetchRequest:fetchRequest error:&error];
                if (fetchedObjects == nil) {
                    NSLog(@"Error: %@\nUser information: %@", error, error.userInfo);
                    
                } else if (fetchedObjects.count == 0) {
                    // Find new photo
                    // Store temp data to create photo later
                    // Should not create photo here
                    // It is fetching concurrently and creating photo will raise exception
                    EAPhotoTemp *tempPhoto = [EAPhotoTemp new];
                    tempPhoto.url = url.absoluteString;
                    tempPhoto.creationDate = [result valueForProperty:ALAssetPropertyDate];
                    tempPhoto.loc = [result valueForProperty:ALAssetPropertyLocation];
                    _urlToPhotoDic[tempPhoto.url] = tempPhoto;
                    
                } else if (fetchedObjects.count == 1) {
                    // Photo already saved
                    [weakSelf updateEAPhoto:fetchedObjects.firstObject withAsset:result];
                }
            }];
        } failureBlock:^(NSError *error) {
            NSLog(@"Error: %@\nUser information: %@", error, error.userInfo);
        }];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Wait enumerating groups
            while (!reachNilGroup) {
                NSLog(@"Waiting refreshing. Have not reached nil group yet");
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Create new photos
                for (EAPhotoTemp *photo in _urlToPhotoDic.allValues) {
                    NSLog(@"Create photo with temp photo");
                    [weakSelf createEAPhotoWithPhoto:photo managedObjectContext:weakSelf.managedObjectContext];
                }
                // Should not save core data here because creating new EAPhotos has not been completed yet
                
                [weakSelf dismissViewControllerAnimated:NO completion:^{
                    NSLog(@"Finish refreshing");
                    // Post notification
                    [[NSNotificationCenter defaultCenter] postNotificationName:FINISH_REFRESHING_PHOTO_NOTIFICATION object:nil];
                    [weakSelf.viewDeckController toggleLeftView];
                    weakSelf.viewDeckController.panningMode = IIViewDeckFullViewPanning;
                }];
            });
        });
    }];
}

- (void)deleteEmptyPhotos:(NSManagedObjectContext *)managedObjectContext {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"EAPhoto" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"Error: %@\nUser information: %@", error, error.userInfo);
    } else if (fetchedObjects.count) {
        
        ALAssetsLibrary *lib = [ALAssetsLibrary new];
        NSUInteger numberOfPhoto = fetchedObjects.count;
        __block NSUInteger numberOfCheckedPhoto = 0;
        
        for (EAPhoto *photo in fetchedObjects) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [lib assetForURL:[NSURL URLWithString:photo.url] resultBlock:^(ALAsset *asset) {
                    if (asset == nil) {
                        // 删除空照片
                        [photo.managedObjectContext deleteObject:photo];
                        NSLog(@"Did delete empty photo");
                    }
                    ++numberOfCheckedPhoto;
                } failureBlock:^(NSError *error) {
                    NSLog(@"Error: %@\nUser information: %@", error, error.userInfo);
                }];
            });
        }
        
        while (numberOfCheckedPhoto < numberOfPhoto) {
            NSLog(@"Waiting deleting photos");
        }
        NSLog(@"Finish deleting photos");
    } else {
        NSLog(@"No empty photo to delete");
    }
}

- (EAPhoto *)createEAPhotoWithPhoto:(EAPhotoTemp *)photo managedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    
    EAPhoto *newPhoto = [NSEntityDescription
                                           insertNewObjectForEntityForName:@"EAPhoto"
                                           inManagedObjectContext:managedObjectContext];
    
    newPhoto.url = photo.url;
    newPhoto.creationDate = photo.creationDate;
    newPhoto.modificationDate = photo.creationDate;

    if (photo.loc) {
        
        newPhoto.latitude = @(photo.loc.coordinate.latitude);
        newPhoto.longitude = @(photo.loc.coordinate.longitude);
        
        CLGeocoder *geocoder = [CLGeocoder new];
        [geocoder reverseGeocodeLocation:photo.loc completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            // This block is on the main thread
            
            if (placemarks.firstObject) {
                newPhoto.address = placemarks.firstObject.name;
                newPhoto.country = placemarks.firstObject.country;
                newPhoto.state = placemarks.firstObject.administrativeArea;
                newPhoto.city = placemarks.firstObject.locality;
                newPhoto.district = placemarks.firstObject.subLocality;
                newPhoto.street = placemarks.firstObject.thoroughfare;
                newPhoto.streetNO = placemarks.firstObject.subThoroughfare;
            } else if (error) {
                NSLog(@"Error: %@\nUser information: %@", error, error.userInfo);
            }
        }];
    }
    return newPhoto;
}

- (void)updateEAPhoto:(EAPhoto *)photo withAsset:(ALAsset *)asset {
    
    CLLocation *loc = [asset valueForProperty:ALAssetPropertyLocation];
    
    if (loc && !photo.address) {

        CLGeocoder *geocoder = [CLGeocoder new];
        [geocoder reverseGeocodeLocation:loc completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            // This block is on the main thread
            
            if (placemarks.firstObject) {
                photo.address = placemarks.firstObject.name;
                photo.country = placemarks.firstObject.country;
                photo.state = placemarks.firstObject.administrativeArea;
                photo.city = placemarks.firstObject.locality;
                photo.district = placemarks.firstObject.subLocality;
                photo.street = placemarks.firstObject.thoroughfare;
                photo.streetNO = placemarks.firstObject.subThoroughfare;
            } else if (error) {
                NSLog(@"Error: %@\nUser information: %@", error, error.userInfo);
            }
        }];
    }
}

- (void)checkAndCreateEAPhotoWhenActive {
    
    NSDate *lastDate = [[NSUserDefaults standardUserDefaults] valueForKey:APPLICATION_WILL_RESIGN_ACTIVE_DATE_KEY];
    if (!lastDate) {
        // Launch this application first time so no last app resign active date
        return;
    }
    
    _urlToPhotoDic = [NSMutableDictionary dictionary];
    __weak typeof(self) weakSelf = self;
    __block BOOL reachNilGroup = NO;
    
    ALAssetsLibrary *lib = [ALAssetsLibrary new];
    [lib enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        NSLog(@"Asset group: %@", group);
        if (!group) {
            reachNilGroup = YES;
            NSLog(@"Asset group is nil");
            return;
        }
        
        [group setAssetsFilter:[ALAssetsFilter allPhotos]]; // Photo only
        
        [group enumerateAssetsWithOptions:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (!result) {
                NSLog(@"Asset is nil");
                return;
            }
            NSDate *assetDate = [result valueForProperty:ALAssetPropertyDate];
            if ([assetDate compare:lastDate] != NSOrderedDescending) {
                // Not new photo
                return;
            }
            NSURL *url = [result valueForProperty:ALAssetPropertyAssetURL];
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"EAPhoto" inManagedObjectContext:weakSelf.managedObjectContext];
            [fetchRequest setEntity:entity];
            // Specify criteria for filtering which objects to fetch
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"url == %@", url.absoluteString];
            [fetchRequest setPredicate:predicate];
            
            NSError *error = nil;
            NSArray *fetchedObjects = [weakSelf.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if (fetchedObjects == nil) {
                NSLog(@"Error: %@\nUser information: %@", error, error.userInfo);
                
            } else if (fetchedObjects.count == 0) {
                // Find new photo
                // Store temp data to create photo later
                // Should not create photo here
                // It is fetching concurrently and creating photo will raise exception
                EAPhotoTemp *tempPhoto = [EAPhotoTemp new];
                tempPhoto.url = url.absoluteString;
                tempPhoto.creationDate = assetDate;
                tempPhoto.loc = [result valueForProperty:ALAssetPropertyLocation];
                _urlToPhotoDic[tempPhoto.url] = tempPhoto;
            }
        }];
    } failureBlock:^(NSError *error) {
        NSLog(@"Error: %@\nUser information: %@", error, error.userInfo);
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Wait enumerating groups
        while (!reachNilGroup) {
            NSLog(@"Waiting refreshing. Have not reached nil group yet");
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Create new photos
            NSMutableSet<EAPhoto *> *photos = [NSMutableSet setWithCapacity:_urlToPhotoDic.count];
            for (EAPhotoTemp *tempPhoto in _urlToPhotoDic.allValues) {
                NSLog(@"Create photo with temp photo");
                EAPhoto *photo = [weakSelf createEAPhotoWithPhoto:tempPhoto managedObjectContext:weakSelf.managedObjectContext];
                [photos addObject:photo];
            }
            // Should not save core data here because creating new EAPhotos has not been completed yet
            
            [[NSNotificationCenter defaultCenter] postNotificationName:FINISH_REFRESHING_PHOTO_NOTIFICATION object:nil userInfo:@{ NEW_PHOTOS_KEY : photos }];
        });
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APPLICATION_ACTIVE_NOTIFICATION object:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [EAPublic mainClassifications].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Classifications" forIndexPath:indexPath];
    
    cell.detailTextLabel.text = nil;
    
    NSArray *classifications = [EAPublic mainClassifications];
    cell.textLabel.text = classifications[indexPath.row];
    
    NSString *imageName;
    if (indexPath.row == 0) {
        imageName = @"Calendar";
    } else if (indexPath.row == 1) {
        imageName = @"Clock";
    } else if (indexPath.row == 2) {
        imageName = @"Location";
    } else if (indexPath.row == 3) {
        imageName = @"City";
    } else if (indexPath.row == 4) {
        imageName = @"Note";
    } else if (indexPath.row == 5) {
        imageName = @"National_geographic";
    }
    cell.imageView.image = [UIImage imageNamed:imageName];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"select %@ row", [tableView cellForRowAtIndexPath:indexPath].textLabel.text);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.viewDeckController.centerController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nc = (UINavigationController *)self.viewDeckController.centerController;
        id firstChild = nc.viewControllers.firstObject; // first child of navigation controller
        UIViewController<IIViewDeckControllerDelegate> *newFirstChild;
        
        if (indexPath.row == 0) {
            // Date
            if (![firstChild isMemberOfClass:[EAPhotosDateCollectionViewController class]]) {
                newFirstChild = [[EAPhotosDateCollectionViewController alloc] initWithCollectionViewLayout:[XLPlainFlowLayout new]];
            }
        } else if (indexPath.row == 1) {
            // Clock
            if (![firstChild isMemberOfClass:[EAPhotosHourCollectionViewController class]]) {
                newFirstChild = [[EAPhotosHourCollectionViewController alloc] initWithCollectionViewLayout:[XLPlainFlowLayout new]];
            }
        } else if (indexPath.row == 2) {
            // Map
            if (![firstChild isMemberOfClass:[EAPhotosMapViewController class]]) {
                newFirstChild = [EAPhotosMapViewController new];
            }
        } else if (indexPath.row == 3) {
            // State
            if (![firstChild isMemberOfClass:[EAPhotosStateCollectionViewController class]]) {
                newFirstChild = [[EAPhotosStateCollectionViewController alloc] initWithCollectionViewLayout:[XLPlainFlowLayout new]];
            }
        } else if (indexPath.row == 4) {
            // Note
            if (![firstChild isMemberOfClass:[EANoteAlbumTableViewController class]]) {
                newFirstChild = [[UIStoryboard storyboardWithName:@"EAMain" bundle:nil] instantiateViewControllerWithIdentifier:@"Note album table view controller"];
            }
        }
        
        if (newFirstChild) {
            NSLog(@"Show new view controller");
            // First child controller of (center) navigation controller changed
            // Show new view controller
            self.viewDeckController.delegate = newFirstChild;
            [nc setViewControllers:@[newFirstChild] animated:YES];
            newFirstChild.title = [EAPublic mainClassifications][indexPath.row];
        } else {
            NSLog(@"Pop to root view controller");
            // First child controller of (center) navigation controller not change
            // Pop to root
            [nc popToRootViewControllerAnimated:YES];
        }
    }
    
    [self.viewDeckController toggleLeftView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return (tableView.bounds.size.height - CGRectGetMaxY(self.navigationController.navigationBar.frame)) / [EAPublic mainClassifications].count;
}

@end
