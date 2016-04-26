//
//  EANGTableViewController.m
//  ElegantAlbum
//
//  Created by Kaibo Lu on 16/4/9.
//

#import <AssetsLibrary/AssetsLibrary.h>

#import "UIImageView+WebCache.h"
#import "EAPublic.h"
#import "EAAppDelegate.h"

#import "EAPhoto.h"
#import "EAAlbum.h"

#import "EANGTableViewCell.h"

#import "EANGTableViewController.h"
#import "EAWebViewController.h"

@interface EANGTableViewController () <UIActionSheetDelegate>

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;

@end

@implementation EANGTableViewController {
    BOOL _loading;
    NSIndexPath *_indexPathOfNGPhotoToSave;
}

#pragma mark - Properties

- (NSMutableArray *)photos {
    if (!_photos) {
        _photos = [NSMutableArray array];
    }
    return _photos;
}

- (NSManagedObjectContext *)managedObjectContext {
    if (!_managedObjectContext) {
        EAAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        _managedObjectContext = appDelegate.managedObjectContext;
    }
    return _managedObjectContext;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:self.view.frame];
    }
    return _maskView;
}

#pragma mark - View controller life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupLeftBarButtonItems];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonPressed:)];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [self refresh:nil];
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
    [self refresh:sender];
}

- (void)refresh:(id)sender {
    NSLog(@"Refresh");
    [self.dataTask cancel];
    
    self.photos = nil;
    _loading = YES;
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    __weak typeof(self) weakSelf = self;
    self.dataTask = [session dataTaskWithURL:[NSURL URLWithString:self.url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        _loading = NO;
        if (error) {
            NSLog(@"Error: %@\nUser information: %@", error, error.userInfo);
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                
                if (weakSelf.view.window) {
                    [[[UIAlertView alloc] initWithTitle:@"Can not connect to Internet" message:@"Please check your Internet connection and try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                }
            });
        } else {
            TFHpple *doc = [TFHpple hppleWithHTMLData:data];
            NSArray *elements = [doc searchWithXPathQuery:@"//div[@class='ajax_list']"];
            
            for (TFHppleElement *element in elements) {
                TFHppleElement *aElement1 = [element searchWithXPathQuery:@"//a[@href]"].firstObject;
                
                // Create EANGPhoto that contains data
                EANGPhoto *photo = [EANGPhoto new];
                
                // Get news URL
                NSString *newsURL = [aElement1 objectForKey:@"href"];
                photo.newsURL = [NATIONAL_GEOGRAPHIC_URL stringByAppendingPathComponent:newsURL];
                NSLog(@"News URL: %@", photo.newsURL);
                
                // Get image URL and title
                TFHppleElement *imageElement = [aElement1 firstChildWithTagName:@"img"];
                photo.imageURL = [imageElement objectForKey:@"src"];
                NSLog(@"Image URL: %@", photo.imageURL);
                
                if ([weakSelf.url isEqualToString:[EAPublic nationalGeographicClassifications].firstObject]) {
                    photo.title = [imageElement objectForKey:@"alt"];
                } else {
                    TFHppleElement *aElement2 = [element searchWithXPathQuery:@"//a[@href]"].lastObject;
                    photo.title = aElement2.text;
                }
                NSLog(@"Title: %@", photo.title);
                
                [weakSelf.photos addObject:photo];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                
                [weakSelf.tableView reloadData];
            });
        }
    }];
    
    [self.dataTask resume];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [EAPublic hideOrShowTabBar:self.tabBarController.tabBar onView:self.view hide:NO completion:nil];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = _loading;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View deck controller delegate

- (void)viewDeckController:(IIViewDeckController *)viewDeckController willOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
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
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"Number of photos = %lu", (unsigned long)self.photos.count);
    return self.photos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForRowAtIndexPath at row: %ld", (long)indexPath.row);
    
    EANGTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Photos" forIndexPath:indexPath];
    if ([EAPublic iOSVersion] >= 8.0f) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    
    EANGPhoto *photo = self.photos[indexPath.row];
    
    cell.titleLabel.text = photo.title;
    
    [cell.ngImageView sd_setImageWithURL:[NSURL URLWithString:photo.imageURL] placeholderImage:[UIImage imageNamed:@"Place_holder"]];
    
    if (cell.saveButton.allTargets.count == 0) {
        // Add save photo action
        [cell.saveButton addTarget:self action:@selector(savePhotoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    NSLog(@"Number of save button targets = %lu", (unsigned long)cell.saveButton.allTargets.count);
    
    return cell;
}

- (void)savePhotoButtonTapped:(id)sender {
    NSLog(@"Sender super super view: %@", [[sender superview] superview]);
    EANGTableViewCell *cell = (EANGTableViewCell *)[[sender superview] superview];
    _indexPathOfNGPhotoToSave = [self.tableView indexPathForCell:cell];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save photo only", @"Save photo and note", nil];
    [actionSheet showFromRect:self.view.bounds inView:self.view animated:YES];
}

- (void)savePhotoAndNote:(BOOL)saveNote  {
    EANGTableViewCell *cell = [self.tableView cellForRowAtIndexPath:_indexPathOfNGPhotoToSave];
    EANGPhoto *ngPhoto = self.photos[_indexPathOfNGPhotoToSave.row];
    
    // Write image
    NSDate *creationDate = [NSDate date];
    __weak typeof(self) weakSelf = self;
    ALAssetsLibrary *lib = [ALAssetsLibrary new];
    [lib writeImageToSavedPhotosAlbum:cell.ngImageView.image.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        
        if (error) {
            NSLog(@"Error: %@\nUser information: %@", error, error.userInfo);
        } else {
            // Create new EAPhoto
            EAPhoto *eaPhoto = [NSEntityDescription
                                insertNewObjectForEntityForName:@"EAPhoto"
                                inManagedObjectContext:weakSelf.managedObjectContext];
            eaPhoto.creationDate = creationDate;
            eaPhoto.modificationDate = creationDate;
            eaPhoto.url = assetURL.absoluteString;
            if (saveNote) {
                eaPhoto.note = [ngPhoto.title stringByAppendingString:[NSString stringWithFormat:@"\n%@", ngPhoto.newsURL]];
            }
            
            // EAPhoto belongs to "National geographic" EAAlbum
            // Get album
            EAAlbum *album = [EAAlbum albumNamed:NATIONAL_GEOGRAPHIC_ALBUM_NAME managedObjectContext:weakSelf.managedObjectContext];
            BOOL createAlbum = NO; // indicate whether the album need to create or already exists
            if (!album) {
                // Create album
                album = [EAAlbum createAlbumWithName:NATIONAL_GEOGRAPHIC_ALBUM_NAME photos:nil managedObjectContext:weakSelf.managedObjectContext];
                createAlbum = YES;
            }
            
            // Add photo to album
            // Do not use addPhotoArray: method because it will update modification date of photo and album
            // The modification dates here should be the creation date of photo
            [album addPhotosObject:eaPhoto];
            album.modificationDate = creationDate;
            
            // Post notification
            NSNumber *numberOfAlbumChanged = createAlbum ? @1 : @0;
            [[NSNotificationCenter defaultCenter] postNotificationName:ALBUM_CHANGE_NOTIFICATION object:nil userInfo:@{ NUMBER_OF_ALBUM_CHANGE_KEY : numberOfAlbumChanged, ALBUM_KEY : album, NUMBER_OF_PHOTO_CHANGE_KEY : @1, PHOTOS_KEY : [NSSet setWithObject:eaPhoto] }];
            NSNumber *numberOfPhotoWithNoteChanged = saveNote ? @1 : @0;
            [[NSNotificationCenter defaultCenter] postNotificationName:PHOTO_NOTE_CHANGE_NOTIFICATION object:nil userInfo:@{ NUMBER_OF_PHOTO_NOTE_CHANGE_KEY : numberOfPhotoWithNoteChanged, PHOTO_KEY : eaPhoto, UPDATE_ALBUM_KEY : @NO }]; // Album has been updated by ALBUM_CHANGE_NOTIFICATION; do not update album again
            [[NSNotificationCenter defaultCenter] postNotificationName:PHOTO_CHANGE_NOTIFICAITON object:nil userInfo:@{ NUMBER_OF_PHOTO_CHANGE_KEY : @1, PHOTOS_KEY : [NSSet setWithObject:eaPhoto] }];
            NSLog(@"Post photo change notification");
            
            // Save core data
            NSError *saveError;
            if ([weakSelf.managedObjectContext save:&error]) {
                // Show a view to tell user that photo has been saved
                [weakSelf.class showPromptBoxWithText:@"Photo has been saved" onView:weakSelf.view];
            } else {
                NSLog(@"Error: %@\nUser information: %@", saveError, saveError.userInfo);
            }
        }
    }];
}

+ (void)showPromptBoxWithText:(NSString *)text onView:(UIView *)baseView {
    
    UILabel *label = [UILabel new];
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor whiteColor];
    label.text = text;
    [label sizeToFit];
    
    CGFloat label_x = 10;
    CGFloat label_y = 10;
    CGFloat width = label.bounds.size.width + 2 * label_x;
    CGFloat height = label.bounds.size.height + 2 * label_y;
    CGFloat contentOffsetY = 0; // Add content offset y in case of scroll view
    __weak UIScrollView *scrollView;
    if ([baseView isKindOfClass:[UIScrollView class]]) {
        scrollView = (UIScrollView *)baseView;
        contentOffsetY = scrollView.contentOffset.y;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake((baseView.bounds.size.width - width) / 2.0f, (baseView.bounds.size.height - height) / 2.0f + contentOffsetY, width, height)];
    view.opaque = NO;
    view.backgroundColor = [UIColor blackColor];
    [view addSubview:label];
    label.frame = CGRectMake(label_x, label_y, label.bounds.size.width, label.bounds.size.height);
    view.alpha = 0;
    
    [baseView addSubview:view];
    scrollView.scrollEnabled = NO;
#warning Check how to write better animation code
    __weak UIView *weakView = view;
    [UIView animateWithDuration:0.5 animations:^{
        weakView.alpha = 0.8;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 delay:0.5 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            weakView.alpha = 0;
        } completion:^(BOOL finished) {
            [weakView removeFromSuperview];
            scrollView.scrollEnabled = YES;
        }];
    }];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    EANGPhoto *photo = self.photos[indexPath.row];
    EAWebViewController *webVC = [[UIStoryboard storyboardWithName:@"EAMain" bundle:nil] instantiateViewControllerWithIdentifier:@"Web view controller"];
    webVC.url = photo.newsURL;
    [self.navigationController pushViewController:webVC animated:YES];
    
    [EAPublic hideOrShowTabBar:self.tabBarController.tabBar onView:self.view hide:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EANGPhoto *photo = self.photos[indexPath.row];
    
    CGFloat imageHeight = tableView.bounds.size.width / 4 * 3;
    CGSize titleSize = [photo.title boundingRectWithSize:CGSizeMake(self.view.bounds.size.width - 16.0f, MAXFLOAT)  options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]} context:nil].size;
    
    return imageHeight + 8.0f + titleSize.height + 8.0f + 25.0f + 16.0f;
}

#pragma mark - Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"Click button %ld", (long)buttonIndex);
    if (buttonIndex == 0) {
        // Save photo only
        [self savePhotoAndNote:NO];
    } else if (buttonIndex == 1) {
        // Save photo and note
        [self savePhotoAndNote:YES];
    }
}

@end
