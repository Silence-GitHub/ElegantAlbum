//
//  EAAlbumDetailTableViewController.m
//  ElegantAlbum
//
//  Created by Kaibo Lu on 16/2/26.
//

#import "EAAlbumDetailTableViewController.h"
#import "EANoteAlbumTableViewController.h"

#import "EAPublic.h"

@interface EAAlbumDetailTableViewController () <UIAlertViewDelegate, UIActionSheetDelegate>

@end

@implementation EAAlbumDetailTableViewController

#pragma mark - View controller life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *backButton = [EAPublic backButtonItemCustomView];
    [backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void)goBack:(id)sender {
    NSLog(@"Go back");
    [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if ([self.navigationController.viewControllers.firstObject isKindOfClass:[EANoteAlbumTableViewController class]]) {
        // Only comes from note album table view controller should show delete album cell
        return 3;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 || section == 2)
        return 1;
    else
        return 3;
}

static NSString *ALBUM_DETAILS_CELL_REUSE_IDENTIFIER = @"Album details";
static NSString *ALBUM_DELETION_CELL_REUSE_IDENTIFIER = @"Album deletion";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ALBUM_DETAILS_CELL_REUSE_IDENTIFIER forIndexPath:indexPath];
        cell.textLabel.text = @"Name";
        cell.detailTextLabel.text = self.album.name;
        return cell;
        
    } else if (indexPath.section == 1) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ALBUM_DETAILS_CELL_REUSE_IDENTIFIER forIndexPath:indexPath];
        
        if (indexPath.row == 0) {
            
            cell.textLabel.text = @"Number of photos";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.album.photos.count];
            
        } else if (indexPath.row == 1) {
            
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.dateFormat = @"yyyy-MM-dd HH:mm";
            cell.textLabel.text = @"Creation time";
            cell.detailTextLabel.text = [formatter stringFromDate:self.album.creationDate];
            
        } else {
            
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.dateFormat = @"yyyy-MM-dd HH:mm";
            cell.textLabel.text = @"Modification time";
            cell.detailTextLabel.text = [formatter stringFromDate:self.album.modificationDate];
        }
        return cell;
        
    } else {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ALBUM_DELETION_CELL_REUSE_IDENTIFIER];
        return cell;
    }
    
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        // Edit album name
        NSLog(@"Edite album name");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Change album name" message:@"Enter new name for album" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView textFieldAtIndex:0].text = self.album.name;
        [alertView show];
        
    } else if (indexPath.section == 2) {
        // Delete album
        NSLog(@"Delete album");
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Sure to delete album ?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Yes" otherButtonTitles:nil, nil];
        [actionSheet showFromRect:self.view.bounds inView:self.view animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return NO;
    }
    return YES;
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"Click button %ld", (long)buttonIndex);
    if (buttonIndex == 1) {
        // Try to save new album name
        NSString *newAlbumName = [[alertView textFieldAtIndex:0].text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (newAlbumName.length && ![newAlbumName isEqualToString:self.album.name]) {
            // Album name is valid
            // Change album name
            [self.album updateName:newAlbumName];
            
            // Update table view cell in this table view controller
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            // Post notification
            [[NSNotificationCenter defaultCenter] postNotificationName:ALBUM_CHANGE_NOTIFICATION object:nil userInfo:@{ NUMBER_OF_ALBUM_CHANGE_KEY : @0, ALBUM_KEY : self.album }];
        }
    }
}

#pragma mark - Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        // Delete album
        [self.album.managedObjectContext deleteObject:self.album];
        
        // Post notification
        [[NSNotificationCenter defaultCenter] postNotificationName:ALBUM_CHANGE_NOTIFICATION object:nil userInfo:@{ NUMBER_OF_ALBUM_CHANGE_KEY : @-1, ALBUM_KEY : self.album }];
    }
}

@end
