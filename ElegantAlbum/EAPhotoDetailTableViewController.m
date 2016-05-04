//
//  EAPhotoDetailTableViewController.m
//  ElegantAlbum
//
//  Created by Kaibo Lu on 16/2/29.
//

#import "EAPhotoDetailTableViewController.h"
#import "EAPhotosAlbumCollectionViewController.h"
#import "EAAlbumDetailTableViewController.h"

#import "EAMapSnapshotTableViewCell.h"
#import "EAAlbumPickerTableViewCell.h"
#import "EACreateAlbumTableViewCell.h"

#import "EAAlbum.h"

#import "EAPublic.h"

@interface EAPhotoDetailTableViewController () <UIActionSheetDelegate>

@property (nonatomic, strong) NSMutableArray<EAAlbum *> *albums;

@end

@implementation EAPhotoDetailTableViewController {
    UIImage *_mapSnapshotImage;
    CGFloat _mapSnapshotWidth;
    
    NSIndexPath *_albumIndexPath;
}

#pragma mark - Properties

- (NSMutableArray *)albums {
    if (!_albums) {
        // Update photo note may make some albums have the same modification date
        // So use creation date to sort in this case
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:NO];
        NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO];
        _albums = [NSMutableArray arrayWithArray:[self.photo.albums sortedArrayUsingDescriptors:@[sortDescriptor, sortDescriptor2]]];
    }
    return _albums;
}

#pragma mark - View controller life cycle

const static CGFloat MAP_SNAPSHOT_ASPECT_RATIO = 0.5f;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumChange:) name:ALBUM_CHANGE_NOTIFICATION object:nil];
    
    UIButton *backButton = [EAPublic backButtonItemCustomView];
    [backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    if (self.photo.address.length) {
        MKMapSnapshotOptions *options = [MKMapSnapshotOptions new];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.photo.latitude.doubleValue, self.photo.longitude.doubleValue);
        CLLocationDegrees latitudeDelta = 0.01;
        MKCoordinateSpan span = MKCoordinateSpanMake(latitudeDelta, latitudeDelta * MAP_SNAPSHOT_ASPECT_RATIO);
        options.region = MKCoordinateRegionMake(coordinate, span);
        _mapSnapshotWidth = self.view.bounds.size.width;
        options.size = CGSizeMake(_mapSnapshotWidth, _mapSnapshotWidth * MAP_SNAPSHOT_ASPECT_RATIO);
        options.scale = [UIScreen mainScreen].scale;
        MKMapSnapshotter *snapShotter = [[MKMapSnapshotter alloc] initWithOptions:options];
        __weak typeof(self) weakSelf = self;
        [snapShotter startWithCompletionHandler:^(MKMapSnapshot * _Nullable snapshot, NSError * _Nullable error) {
            // On the main thread
            NSLog(@"Fetching snapshot complete");
            if (snapshot) {
                NSLog(@"Get snapshot");
                _mapSnapshotImage = snapshot.image;
                [weakSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
            } else {
                NSLog(@"Error: %@\nUser information: %@", error, error.userInfo);
            }
        }];
    }
}

- (void)goBack:(id)sender {
    NSLog(@"Go back");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)albumChange:(NSNotification *)notification {
    NSNumber *numberOfAlbumChanged = notification.userInfo[NUMBER_OF_ALBUM_CHANGE_KEY];
    EAAlbum *album = notification.userInfo[ALBUM_KEY];
#warning Use binary search
    NSUInteger index = [self.albums indexOfObject:album];
    if (numberOfAlbumChanged.intValue > 0 || index == NSNotFound) {
        // New album created
        // Insert album to table view
        [self.albums insertObject:album atIndex:0];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if (numberOfAlbumChanged.intValue == 0 && index != NSNotFound) {
        NSSet *photos = notification.userInfo[PHOTOS_KEY];
        if (photos.count == 1 && photos.anyObject == self.photo) {
            NSLog(@"Photo removed from album");
            // Photo removed from album
            // Delete album from table view
            [self.albums removeObjectAtIndex:index];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:2]] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else if (index != 0) {
            NSLog(@"Album was updated for other reason");
            // Album was updated for other reason, e.g. new photo
            // Reorder albums and table view
            [self.albums removeObjectAtIndex:index];
            [self.albums insertObject:album atIndex:0];
            [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:2] toIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.viewDeckController.panningMode = IIViewDeckNoPanning;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.viewDeckController.panningMode = IIViewDeckFullViewPanning;
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALBUM_CHANGE_NOTIFICATION object:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        // Date
        if (self.photo.modificationDate) {
            return 2;
        }
        return 1;
    } else if (section == 1) {
        // Location
        if (self.photo.address) {
            if (_mapSnapshotImage) {
                return 4;
            }
            return 3;
        } else {
            return 1;
        }
    } else if (section == 2) {
        // Album
        return self.photo.albums.count + 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        // Date
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Photo details" forIndexPath:indexPath];
        [self configureCellForDate:cell atIndexPath:indexPath];
        return cell;
        
    } else if (indexPath.section == 1) {
        // Location
        if (indexPath.row < 3) {
            // Address, lat and lng
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Photo details" forIndexPath:indexPath];
            [self configureCellForLocation:cell atIndexPath:indexPath];
            return cell;
        } else {
            // Map snapshot
            EAMapSnapshotTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Map snapshot" forIndexPath:indexPath];
            [self configureCellForMapSnapshot:cell atIndexPath:indexPath];
            return cell;
        }
    } else if (indexPath.row < self.albums.count) {
        // Album exists
        EAAlbumPickerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Albums" forIndexPath:indexPath];
        [self configureCellForAlbum:cell atIndexPath:indexPath];
        return cell;
    } else {
        // Create new album
        EACreateAlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Create album" forIndexPath:indexPath];
        [self configureCellForNewAlbum:cell atIndexPath:indexPath];
        return cell;
    }
    
    return nil;
}

- (void)configureCellForDate:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    if (indexPath.row == 0) {
        // Creation date
        cell.textLabel.text = [NSString stringWithFormat:@"Creation time"];
        cell.detailTextLabel.text = [formatter stringFromDate:self.photo.creationDate];
    } else {
        // Modification date
        cell.textLabel.text = [NSString stringWithFormat:@"Modification time"];
        cell.detailTextLabel.text = [formatter stringFromDate:self.photo.modificationDate];
    }
}

- (void)configureCellForLocation:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    if (self.photo.address) {
        // Has location information
        if (indexPath.row == 0) {
            // Address
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = @"Location";
            cell.detailTextLabel.numberOfLines = 2;
            cell.detailTextLabel.text = self.photo.address;
        } else if (indexPath.row == 1) {
            // Latitude
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.text = @"Latitude";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%f", self.photo.latitude.doubleValue];
        } else {
            // Longitude
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.text = @"Longitude";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%f", self.photo.longitude.doubleValue];
        }
    } else {
        // No location information
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"Location";
        cell.detailTextLabel.text = @"No";
    }
}

- (void)configureCellForMapSnapshot:(EAMapSnapshotTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    cell.snapshotImageView.image = _mapSnapshotImage;
}

- (void)configureCellForAlbum:(EAAlbumPickerTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (indexPath.row < self.albums.count) {
        // Albums for photo
        cell.tag = indexPath.row;
        EAAlbum *album = self.albums[indexPath.row];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            ALAssetsLibrary *lib = [ALAssetsLibrary new];
            [lib assetForURL:[NSURL URLWithString:album.photos.anyObject.url] resultBlock:^(ALAsset *asset) {
                UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
                image = [EAPublic image:image withSize:CGSizeMake(THUMBNAIL_SIDE_LENGTH_MAX, THUMBNAIL_SIDE_LENGTH_MAX)];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (cell.tag == indexPath.row) {
                        cell.albumImageView.image = image;
                        cell.albumNameLabel.text = album.name;
                        cell.albumPhotoCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)album.photos.count];
                    }
                });
            } failureBlock:^(NSError *error) {
                NSLog(@"Error: %@\nUser information: %@", error, error.userInfo);
            }];
        });
    }
}

- (void)configureCellForNewAlbum:(EACreateAlbumTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    // Other album
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.titleLabel.text = @"Add to other album";
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 2 && indexPath.row < self.albums.count) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2 && indexPath.row < self.albums.count) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            // Choose to remove this photo from album
            
            // Cache index path
            _albumIndexPath = indexPath;
            
            // Show action sheet
            EAAlbum *album = self.albums[indexPath.row];
            NSString *actionSheetTile = [NSString stringWithFormat:@"Sure to remove this photo from the album %@ ?", album.name];
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionSheetTile delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"YES" otherButtonTitles:nil, nil];
            [actionSheet showFromRect:self.view.bounds inView:self.view animated:YES];
        }
    }
}


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 3) {
        return _mapSnapshotWidth * MAP_SNAPSHOT_ASPECT_RATIO;
    }
    if (indexPath.section == 2) {
        return ALBUM_TABLE_CELL_HEIGHT;
    }
    return 44;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        // Address
        return YES;
    } else if (indexPath.section == 2) {
        // Album
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Select section %ld row %ld", (long)indexPath.section, (long)indexPath.row);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 2 && indexPath.row < self.albums.count) {
        // Show album detail
        EAAlbum *album = self.albums[indexPath.row];
        EAAlbumDetailTableViewController *albumDetailTVC = [[UIStoryboard storyboardWithName:@"EAMain" bundle:nil] instantiateViewControllerWithIdentifier:@"Album detail table view controller"];
        albumDetailTVC.album = album;
        [self.navigationController pushViewController:albumDetailTVC animated:YES];
    
    } else if (indexPath.section == 2) {
        // Add to other album
        EAAlbumPickerTableViewController *albumPickerTVC = [[UIStoryboard storyboardWithName:@"EAMain" bundle:nil] instantiateViewControllerWithIdentifier:@"Album picker table view controller"];
        albumPickerTVC.photos = [NSMutableArray arrayWithObject:self.photo];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:albumPickerTVC];
        [self presentViewController:navigationController animated:YES completion:nil];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2 && indexPath.row < self.albums.count) {
        return @"Remove";
    }
    return nil;
}

#pragma mark - Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        // Remove this photo from album
        
        // Update core data model
        EAAlbum *album = self.albums[_albumIndexPath.row];
        [album removePhotoArray:@[self.photo]];
        
        // Post notification
        [[NSNotificationCenter defaultCenter] postNotificationName:ALBUM_CHANGE_NOTIFICATION object:nil userInfo:@{ NUMBER_OF_ALBUM_CHANGE_KEY : @0, ALBUM_KEY : album, NUMBER_OF_PHOTO_CHANGE_KEY : @-1, PHOTOS_KEY : [NSSet setWithObject:self.photo] }];
    }
}

@end
