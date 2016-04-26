//
//  EAAlbumPickerTableViewController.m
//  ElegantAlbum
//
//  Created by 陆凯波 on 16/2/21.
//  Copyright © 2016年 Kaibo. All rights reserved.
//

#import "EAAlbumPickerTableViewController.h"

#import "EAAlbum.h"

#import "EAAlbumPickerTableViewCell.h"
#import "EACreateAlbumTableViewCell.h"

#import "EAAppDelegate.h"
#import "EAPublic.h"

@interface EAAlbumPickerTableViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableSet<EAAlbum *> *commonAlbums; // for all photos to add

@end

@implementation EAAlbumPickerTableViewController

#pragma mark - Properties

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
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"EAAlbum" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        // Specify how the fetched objects should be sorted
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"modificationDate"                                                          ascending:NO];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:fetchRequest
                                     managedObjectContext:self.managedObjectContext
                                     sectionNameKeyPath:nil
                                     cacheName:ALBUMS_DESCENDING_WITH_MODIFICATION_DATE_CACHE_NAME];
        
        NSError *error;
        if (![_fetchedResultsController performFetch:&error]) {
            NSLog(@"Error: %@\nUser information: %@", error, error.userInfo);
        }
    }
    return _fetchedResultsController;
}

- (NSMutableSet<EAAlbum *> *)commonAlbums {
    if (!_commonAlbums) {
        _commonAlbums = [NSMutableSet setWithSet:self.photos.firstObject.albums];
        for (EAPhoto *photo in self.photos) {
            [_commonAlbums intersectSet:photo.albums];
        }
    }
    return _commonAlbums;
}

#pragma mark - View controller life cycle

static NSString *ALBUM_CELL_REUSE_IDENTIFIER = @"Albums";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumChanged:) name:ALBUM_CHANGE_NOTIFICATION object:nil];
    
    self.title = [NSString stringWithFormat:@"%lu %@", (unsigned long)self.photos.count, self.photos.count > 1 ? @"photos" : @"photo"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(goBack:)];
    
}

- (void)albumChanged:(NSNotification *)notification {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)goBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return [sectionInfo numberOfObjects] + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row < self.fetchedResultsController.fetchedObjects.count) {
        EAAlbumPickerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ALBUM_CELL_REUSE_IDENTIFIER forIndexPath:indexPath];
        
        EAAlbum *album = [self.fetchedResultsController objectAtIndexPath:indexPath];
        BOOL isCommonAlbum = [self.commonAlbums containsObject:album];
        
        cell.tag = indexPath.row;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            ALAssetsLibrary *lib = [ALAssetsLibrary new];
            [lib assetForURL:[NSURL URLWithString:album.photos.anyObject.url] resultBlock:^(ALAsset *asset) {
                UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
                image = [EAPublic image:image withSize:CGSizeMake(THUMBNAIL_SIDE_LENGTH_MAX, THUMBNAIL_SIDE_LENGTH_MAX)];
                if (isCommonAlbum) {
                    // Common album
                    // Can not add to this album
                    image = [EAPublic grayImage:image];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (cell.tag == indexPath.row) {
                        cell.albumImageView.image = image;
                        
                        cell.albumNameLabel.text = album.name;
                        cell.albumNameLabel.enabled = !isCommonAlbum;
                        
                        cell.albumPhotoCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)album.photos.count];
                        cell.albumPhotoCountLabel.enabled = !isCommonAlbum;
                    }
                });
            } failureBlock:^(NSError *error) {
                NSLog(@"Error: %@\nUser information: %@", error, error.userInfo);
            }];
        });
        
        return cell;
        
    } else {
        
        EACreateAlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Create album" forIndexPath:indexPath];
        
        cell.titleLabel.text = @"New album";
        
        return cell;
    }
    
    return nil;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return ALBUM_TABLE_CELL_HEIGHT;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.fetchedResultsController.fetchedObjects.count) {
        EAAlbum *album = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if ([self.commonAlbums containsObject:album]) {
            // Common album
            // Can not add to this album
            return NO;
        }
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSUInteger numberOfAlbums = self.fetchedResultsController.fetchedObjects.count;
    if (numberOfAlbums && indexPath.row < numberOfAlbums) {
        // Choose to move photos to a saved album
        EAAlbum *album = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [album addPhotoArray:self.photos];
        
        // Post notification
        [[NSNotificationCenter defaultCenter] postNotificationName:ALBUM_CHANGE_NOTIFICATION object:nil userInfo:@{ NUMBER_OF_ALBUM_CHANGE_KEY : @0, ALBUM_KEY : album, NUMBER_OF_PHOTO_CHANGE_KEY : @1, PHOTOS_KEY : [NSSet setWithArray:self.photos] }];
        
#warning Add animation here.
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } else {
        // Choose to create new album
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"New album" message:@"Please enter album name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView show];
    }
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
            EAAlbum *newAlbum = [EAAlbum createAlbumWithName:albumName photos:[NSSet setWithArray:self.photos] managedObjectContext:self.managedObjectContext];
            if (newAlbum) {
                // Post notification
                [[NSNotificationCenter defaultCenter] postNotificationName:ALBUM_CHANGE_NOTIFICATION object:nil userInfo:@{ NUMBER_OF_ALBUM_CHANGE_KEY : @1, ALBUM_KEY : newAlbum, NUMBER_OF_PHOTO_CHANGE_KEY : @1, PHOTOS_KEY : [NSSet setWithArray:self.photos] }];
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
