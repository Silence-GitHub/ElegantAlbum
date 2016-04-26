//
//  EANoteAlbumTableViewController.m
//  ElegantAlbum
//
//  Created by 陆凯波 on 16/1/27.
//  Copyright © 2016年 Kaibo. All rights reserved.
//

#import "EANoteAlbumTableViewController.h"
#import "EAPhotosNoteCollectionViewController.h"
#import "EAPhotosAlbumCollectionViewController.h"
#import "EAAlbumDetailTableViewController.h"

#import "EAAlbum.h"
#import "EAPhoto.h"

#import "EANoteAlbumTableViewCell.h"
#import "EANoteAlbumTableHeaderView.h"

#import "EAPublic.h"
#import "EAAppDelegate.h"

@interface EANoteAlbumTableViewController ()

@property (nonatomic, strong) NSMutableArray *albums;

@end

@implementation EANoteAlbumTableViewController

#pragma mark - Properties

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

- (NSFetchedResultsController *)photosWithNotesFRC {
    if (!_photosWithNotesFRC) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"EAPhoto" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        // Specify criteria for filtering which objects to fetch
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT note == %@", nil];
        [fetchRequest setPredicate:predicate];
        // Specify how the fetched objects should be sorted
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"modificationDate"
                                                                       ascending:NO];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
        
        _photosWithNotesFRC = [[NSFetchedResultsController alloc]
                                  initWithFetchRequest:fetchRequest
                                  managedObjectContext:self.managedObjectContext
                                  sectionNameKeyPath:nil
                                  cacheName:PHOTOS_WITH_NOTE_DESCENDING_WITH_MODIFICATION_DATE_CACHE_NAME];
        NSError *error;
        if (![_photosWithNotesFRC performFetch:&error]) {
            NSLog(@"Error: %@\nUser information: %@", error, error.userInfo);
        }
    }
    return _photosWithNotesFRC;
}

- (NSFetchedResultsController *)albumsFRC {
    if (!_albumsFRC) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"EAAlbum" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        // Specify how the fetched objects should be sorted
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"modificationDate"                                                          ascending:NO];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
        
        _albumsFRC = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:fetchRequest
                                     managedObjectContext:self.managedObjectContext
                                     sectionNameKeyPath:nil
                                     cacheName:ALBUMS_DESCENDING_WITH_MODIFICATION_DATE_CACHE_NAME];
        
        NSError *error;
        if (![_albumsFRC performFetch:&error]) {
            NSLog(@"Error: %@\nUser information: %@", error, error.userInfo);
        }
    }
    return _albumsFRC;
}

- (NSMutableArray *)albums {
    if (!_albums) {
        _albums = [NSMutableArray arrayWithArray:self.albumsFRC.fetchedObjects];
        self.albumsFRC = nil;
    }
    return _albums;
}

#pragma mark - View controller life cycle

static NSString *ALBUM_CELL_REUSE_IDENTIFIER = @"Albums";
static NSString *ALBUM_HEADER_REUSE_IDENTIFIER = @"Albums";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishRefreshingPhoto:) name:FINISH_REFRESHING_PHOTO_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoNoteChange:) name:PHOTO_NOTE_CHANGE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumChange:) name:ALBUM_CHANGE_NOTIFICATION object:nil];
    
    [self.tableView registerClass:[EANoteAlbumTableHeaderView class] forHeaderFooterViewReuseIdentifier:ALBUM_HEADER_REUSE_IDENTIFIER];
    
    [self setupLeftBarButtonItems];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAlbum:)];
}

- (void)finishRefreshingPhoto:(NSNotification *)notification {
    NSSet *photos = notification.userInfo[NEW_PHOTOS_KEY];
    if (photos) {
        // Application active
        return;
    }
    // Refresh all photos
    [self.navigationController popToRootViewControllerAnimated:YES];
    self.photosWithNotesFRC = nil;
    self.albums = nil;
    [self.tableView reloadData];
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

- (void)photoNoteChange:(NSNotification *)notification {
    NSLog(@"photo note change");
    NSNumber *number = notification.userInfo[NUMBER_OF_PHOTO_NOTE_CHANGE_KEY];
    
    if (self.photosWithNotesFRC.fetchedObjects.count == 0 && number.intValue > 0) {
        NSLog(@"Add section");
        // No photo with note before
        // Now there is a photo with note
        // Insert section
        if ([self.photosWithNotesFRC performFetch:nil]) {
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    } else if (self.photosWithNotesFRC.fetchedObjects.count == 1 && number.intValue < 0) {
        NSLog(@"Delete section");
        // There is a photo with note before
        // No photo with note now
        // Delete section
        if ([self.photosWithNotesFRC performFetch:nil]) {
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    } else {
        // Update cell
        NSLog(@"Update");
        if ([self.photosWithNotesFRC performFetch:nil]) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    
    // When photo note updated, album updated
    // Maybe need to reorder updated albums
    NSNumber *updateAlbum = notification.userInfo[UPDATE_ALBUM_KEY];
    if (!updateAlbum.boolValue) {
        // Do not need to update album
        return;
    }
    // Need to update album
    EAPhoto *photo = notification.userInfo[PHOTO_KEY];
    if (photo && self.albums.count > photo.albums.count) {
        // Not all albums are updated
        // Need to reorder updated albums
        
        // Get section of albums
        NSUInteger section = 0; // No photo with note
        if (self.photosWithNotesFRC.fetchedObjects.count)
            // Has photo with note
            section = 1;
        
        NSMutableArray<NSNumber *> *indexArr = [NSMutableArray array]; // Index of album to move
        for (NSUInteger i = 0; i < self.albums.count; ++i) {
            if ([photo.albums containsObject:self.albums[i]]) {
                [indexArr addObject:@(i)];
            }
        }
        for (NSUInteger i = 0; i < indexArr.count; ++i) {
            NSUInteger albumIndex = indexArr[i].intValue;
            EAAlbum *album = self.albums[albumIndex];
            [self.albums removeObjectAtIndex:albumIndex];
            [self.albums insertObject:album atIndex:i];
            [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:albumIndex inSection:section] toIndexPath:[NSIndexPath indexPathForRow:i inSection:section]];
        }
    }
}

- (void)albumChange:(NSNotification *)notification {
    NSLog(@"Album change");
    
    NSNumber *number = notification.userInfo[NUMBER_OF_ALBUM_CHANGE_KEY];
    EAAlbum *album = notification.userInfo[ALBUM_KEY];
    
    // Get section of albums
    NSUInteger section = 0; // No photo with note
    if (self.photosWithNotesFRC.fetchedObjects.count)
        // Has photo with note
        section = 1;
    
    if (number.intValue > 0) {
        // Number of album increase
        [self.albums insertObject:album atIndex:0];
        if (self.albums.count == 1) {
            // No album before
            // One album after creating a new album
            // Insert section
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            // Has album before creating a new album
            // Insert row
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:section]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    } else if (number.intValue == 0) {
        // Number of album not change
#warning Use binary search
        NSUInteger index = [self.albums indexOfObject:album];
        [self.albums removeObjectAtIndex:index];
        [self.albums insertObject:album atIndex:0];
        [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:section] toIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:section]] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        // Number of album decrease
        // Children view controller
        [self.navigationController popToViewController:self animated:YES];
#warning Use binary search
        NSUInteger index = [self.albums indexOfObject:album];
        [self.albums removeObjectAtIndex:index];
        if (self.albums.count) {
            // Has album after deletion
            // Delete row
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:section]] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            // No album
            // Delete section
            // Error if delete row
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

- (void)goBack:(id)sender {
    NSLog(@"Go back");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addAlbum:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"New album" message:@"Please enter album name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Delegate may be album or note collection view controller
    self.viewDeckController.delegate = self;
    
    // After deleting album in album detail table controller in which can no pan, pop to this view controller
    // Need to enable panning here
    self.viewDeckController.panningMode = IIViewDeckFullViewPanning;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FINISH_REFRESHING_PHOTO_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PHOTO_NOTE_CHANGE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALBUM_CHANGE_NOTIFICATION object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View deck controller delegate

- (void)viewDeckController:(IIViewDeckController*)viewDeckController willOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    NSLog(@"View deck controller will open view side");
    
    // Hide tab bar
    [EAPublic hideOrShowTabBar:self.tabBarController.tabBar onView:self.view hide:YES completion:nil];
    
    // Disable user interaction
    
    self.navigationItem.leftBarButtonItems = nil;
    
    [self.view addSubview:self.maskView]; // self.view is table view, can scroll event added mask view
    self.tableView.scrollEnabled = NO;
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController willCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    NSLog(@"View deck controller will close view side");
    
    // Show tab bar
    [EAPublic hideOrShowTabBar:self.tabBarController.tabBar onView:self.view hide:NO completion:nil];
    
    // Enable user interaction
    
    [self setupLeftBarButtonItems];
    
    [self.maskView removeFromSuperview];
    self.tableView.scrollEnabled = YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    NSUInteger numberOfSections = 0;
    if (self.photosWithNotesFRC.fetchedObjects.count) {
        numberOfSections += 1;
    }
    if (self.albums.count) {
        numberOfSections += 1;
    }
    NSLog(@"Number of sections = %lu", (unsigned long)numberOfSections);
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView.numberOfSections == 1) {
        if (self.photosWithNotesFRC.fetchedObjects.count) {
            // There are only photos with notes
            NSLog(@"Section %ld has 1 row", (long)section);
            return 1;
        } else {
            // There are only albums
            return self.albums.count;
        }
    } else if (tableView.numberOfSections == 2) {
        NSLog(@"Returning number of row in section %ld", (long)section);
        if (section == 0) {
            // Photos with notes
            NSLog(@"Section 0 has 1 row");
            return 1;
        } else {
            // Albums
            return self.albums.count;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EANoteAlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ALBUM_CELL_REUSE_IDENTIFIER forIndexPath:indexPath];
    
    if (self.tableView.numberOfSections == 1) {
        if (self.photosWithNotesFRC.fetchedObjects.count) {
            // There are only photos with notes
            [self configureCellForPhotoWithNote:cell atIndexPath:indexPath];
        } else {
            // There are only albums
            [self configureCellForAlbum:cell atIndexPath:indexPath];
        }
    } else if (self.tableView.numberOfSections == 2) {
        if (indexPath.section == 0) {
            // Photos with notes
            [self configureCellForPhotoWithNote:cell atIndexPath:indexPath];
        } else {
            // Albums
            [self configureCellForAlbum:cell atIndexPath:indexPath];
        }
    }
    
    return cell;
}

- (void)configureCellForPhotoWithNote:(EANoteAlbumTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    EAPhoto *photo = self.photosWithNotesFRC.fetchedObjects.firstObject;
    NSUInteger numberOfPhotos = self.photosWithNotesFRC.fetchedObjects.count;
    cell.tag = indexPath.row;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        ALAssetsLibrary *lib = [ALAssetsLibrary new];
        [lib assetForURL:[NSURL URLWithString:photo.url] resultBlock:^(ALAsset *asset) {
            UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
            image = [EAPublic image:image withSize:CGSizeMake(THUMBNAIL_SIDE_LENGTH_MAX, THUMBNAIL_SIDE_LENGTH_MAX)];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (cell.tag == indexPath.row) {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    
                    cell.albumImageView.image = image;
                    
                    cell.albumNameLabel.text = @"Photo with note";
                    
                    cell.albumPhotoCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)numberOfPhotos];
                    
                    NSDateFormatter *formatter = [NSDateFormatter new];
                    formatter.dateFormat = @"yyyy-MM-dd HH:mm";
                    cell.albumModificationDateLabel.text = [NSString stringWithFormat:@"Updated at %@", [formatter stringFromDate:photo.modificationDate]];
                }
            });
        } failureBlock:^(NSError *error) {
            NSLog(@"Error: %@\nUser information: %@", error, error.userInfo);
        }];
    });
}

- (void)configureCellForAlbum:(EANoteAlbumTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    EAAlbum *album = self.albums[indexPath.row];
    cell.tag = indexPath.row;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        ALAssetsLibrary *lib = [ALAssetsLibrary new];
        [lib assetForURL:[NSURL URLWithString:album.photos.anyObject.url] resultBlock:^(ALAsset *asset) {
            UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
            image = [EAPublic image:image withSize:CGSizeMake(THUMBNAIL_SIDE_LENGTH_MAX, THUMBNAIL_SIDE_LENGTH_MAX)];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (cell.tag == indexPath.row) {
                    cell.accessoryType = UITableViewCellAccessoryDetailButton;
                    
                    cell.albumImageView.image = image;
                    
                    cell.albumNameLabel.text = album.name;
                    
                    cell.albumPhotoCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)album.photos.count];
                    
                    NSDateFormatter *formatter = [NSDateFormatter new];
                    formatter.dateFormat = @"yyyy-MM-dd HH:mm";
                    cell.albumModificationDateLabel.text = [NSString stringWithFormat:@"Updated at %@", [formatter stringFromDate:album.modificationDate]];
                }
            });
        } failureBlock:^(NSError *error) {
            NSLog(@"Error: %@\nUser information: %@", error, error.userInfo);
        }];
    });
}

#pragma mark - Table view delegate

const static CGFloat X_MARGIN = 15.0f;
const static CGFloat Y_MARGIN = 10.0f;
const static CGFloat  BOTTOM_MARGIN = 10.0f;

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGRect rect = [@"a" boundingRectWithSize:CGSizeMake(100, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : [self.class fontForHeaderTitle] } context:nil];
    return Y_MARGIN + rect.size.height + BOTTOM_MARGIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSLog(@"Number of section note album TVC = %ld", (long)tableView.numberOfSections);
    if (tableView.numberOfSections == 1) {
        if (self.photosWithNotesFRC.fetchedObjects.count) {
            // There are only photos with notes
            return [self viewForHeaderWithTitle:@"Photo with note"];
        } else {
            // There are only albums
            return [self viewForHeaderWithTitle:@"Album"];
        }
    } else if (tableView.numberOfSections == 2) {
        NSLog(@"Returning number of row in section %ld", (long)section);
        if (section == 0) {
            // Photos with notes
            return [self viewForHeaderWithTitle:@"Photo with note"];
        } else {
            // Albums
            return [self viewForHeaderWithTitle:@"Album"];
        }
    }
    return nil;
}

- (EANoteAlbumTableHeaderView *)viewForHeaderWithTitle:(NSString *)title {
    EANoteAlbumTableHeaderView *view = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:ALBUM_HEADER_REUSE_IDENTIFIER];
    view.titleLabel.font = [self.class fontForHeaderTitle];
    view.titleLabel.text = title;
    [view.titleLabel sizeToFit];
    view.titleLabel.frame = CGRectMake(X_MARGIN, Y_MARGIN, view.titleLabel.bounds.size.width, view.titleLabel.bounds.size.height);
    return view;
}

+ (UIFont *)fontForHeaderTitle {
    return [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return ALBUM_TABLE_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.photosWithNotesFRC.fetchedObjects.count && indexPath.section == 0) {
        // Photos with notes
        EAPhotosNoteCollectionViewController *photoCVC = [[EAPhotosNoteCollectionViewController alloc] initWithCollectionViewLayout:[XLPlainFlowLayout new]];
        photoCVC.title = @"Photo with note";
        [self.navigationController pushViewController:photoCVC animated:YES];
        
    } else {
        // Albums
        EAPhotosAlbumCollectionViewController *photoCVC = [[EAPhotosAlbumCollectionViewController alloc] initWithCollectionViewLayout:[XLPlainFlowLayout new]];
        photoCVC.album = self.albums[indexPath.row];
        photoCVC.title = photoCVC.album.name;
        [self.navigationController pushViewController:photoCVC animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    EAAlbumDetailTableViewController *albumDetailTVC = [[UIStoryboard storyboardWithName:@"EAMain" bundle:nil] instantiateViewControllerWithIdentifier:@"Album detail table view controller"];
    albumDetailTVC.album = self.albums[indexPath.row];
    [self.navigationController pushViewController:albumDetailTVC animated:YES];
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    UITextField *textField = [alertView textFieldAtIndex:0];
    NSString *albumName = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (buttonIndex == 1) {
        // Check whether has same name album
        if ([EAAlbum albumNamed:albumName managedObjectContext:self.managedObjectContext]) {
            // Can not create same name album
            // Show alert view
            [[[UIAlertView alloc] initWithTitle:@"Can not create album" message:[NSString stringWithFormat:@"Album named %@ already exists", albumName] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        } else {
            // Create new album
            EAAlbum *newAlbum = [EAAlbum createAlbumWithName:albumName photos:nil managedObjectContext:self.managedObjectContext];
            if (newAlbum) {
                // Post notification
                [[NSNotificationCenter defaultCenter] postNotificationName:ALBUM_CHANGE_NOTIFICATION object:nil userInfo:@{ NUMBER_OF_ALBUM_CHANGE_KEY : @1, ALBUM_KEY : newAlbum }];
            }
        }
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    
    UITextField *textField = [alertView textFieldAtIndex:0];
    NSString *albumName = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return albumName.length;
}

@end
