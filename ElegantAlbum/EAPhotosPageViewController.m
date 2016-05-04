//
//  EAPhotosPageViewController.m
//  ElegantAlbum
//
//  Created by Kaibo Lu on 16/1/26.
//

#import "EAPhotosPageViewController.h"
#import "EAPhotoViewController.h"
#import "EAPhotoDetailTableViewController.h"

#import "EAPublic.h"

@interface EAPhotosPageViewController () <UIActionSheetDelegate>

@end

@implementation EAPhotosPageViewController {
    
    BOOL _animating; // is animating or not
}

#pragma mark - View controller life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataSource = self;
    self.delegate = self;
    _animating = NO;
    
    UIButton *backButton = [EAPublic backButtonItemCustomView];
    [backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.automaticallyAdjustsScrollViewInsets = NO; // 防止隐藏显示状态栏、导航栏时整个页面上下移动
    UIButton *moreButtonCustomView = [EAPublic moreButtonItemCustomViewPointsInVerticalLine];
    [moreButtonCustomView addTarget:self action:@selector(showPhotoDetail:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] initWithCustomView:moreButtonCustomView];
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(prepareForAction:)];
    NSLog(@"action button width = %f, custom view width = %f", actionButton.width, actionButton.customView.bounds.size.width);
    self.navigationItem.rightBarButtonItems = @[moreButton, actionButton];
    
    EAPhotoViewController *photoVC = [EAPhotoViewController new];
    photoVC.photo = self.photos[self.firstPhotoIndex];
    photoVC.pageIndex = self.firstPhotoIndex;
    self.title = [NSString stringWithFormat:@"%lu/%lu", (unsigned long)self.firstPhotoIndex + 1, (unsigned long)self.photos.count]; // " photo index / total number of photos "
    photoVC.view.backgroundColor = [UIColor whiteColor];
    [self setViewControllers:@[photoVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished){
        
        NSLog(@"Finish setting photo VCs");
    }];
}

- (void)goBack:(id)sender {
    NSLog(@"Go back");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showPhotoDetail:(id)sender {
    NSLog(@"Show photo detail");
    EAPhotoDetailTableViewController *photoDetailTVC = [[UIStoryboard storyboardWithName:@"EAMain" bundle:nil] instantiateViewControllerWithIdentifier:@"Photo detail table view controller"];
    EAPhotoViewController *photoVC = self.viewControllers.firstObject;
    photoDetailTVC.photo = photoVC.photo;
    [self.navigationController pushViewController:photoDetailTVC animated:YES];
}

- (void)prepareForAction:(id)sender {
    
    EAPhotoViewController *photoVC = self.viewControllers.firstObject;
    if (photoVC.photo.note) {
        // Has note
        // Show action sheet to choose whether to share note or not
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share photo only", @"Share photo with note", nil];
        [actionSheet showFromRect:self.view.bounds inView:self.view animated:YES];
    } else {
        // No note
        // Share photo only
        [self sharePhotoWithNote:NO];
    }
}

- (void)sharePhotoWithNote:(BOOL)shareNote {
    EAPhotoViewController *photoVC = self.viewControllers.firstObject;
    EAPhoto *photo = photoVC.photo;
    __weak typeof(self) weakSelf = self;
    ALAssetsLibrary *lib = [ALAssetsLibrary new];
    [lib assetForURL:[NSURL URLWithString:photo.url] resultBlock:^(ALAsset *asset) {
        UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage];
        NSArray *activityItems = shareNote ? @[image, photo.note] : @[image];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
        [weakSelf presentViewController:activityVC animated:YES completion:nil];
    } failureBlock:^(NSError *error) {
        NSLog(@"Error: %@\nUser information: %@", error, error.userInfo);
    }];
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

- (BOOL)prefersStatusBarHidden {
    
    return self.navigationController.navigationBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    
    return UIStatusBarAnimationSlide;
}

#pragma mark - Page view controller data source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSLog(@"Return before vc");
    
    if (_animating) {
        return nil;
    }
    
    if ([viewController isKindOfClass:[EAPhotoViewController class]]) {
        EAPhotoViewController *photoVC = (EAPhotoViewController *)viewController;
        
        NSLog(@"Page index = %lu", (unsigned long)photoVC.pageIndex);
        
        if (photoVC.pageIndex == 0) {
            return nil;
        }
        
        EAPhotoViewController *photoVC_new = [EAPhotoViewController new];
        photoVC_new.pageIndex = photoVC.pageIndex - 1;
        photoVC_new.photo = self.photos[photoVC_new.pageIndex];
        if (self.navigationController.navigationBar.hidden) {
            photoVC_new.view.backgroundColor = [UIColor blackColor];
        } else {
            photoVC_new.view.backgroundColor = [UIColor whiteColor];
        }

        return photoVC_new;
    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSLog(@"Return after vc");
    
    if (_animating) {
        return nil;
    }
    
    if ([viewController isKindOfClass:[EAPhotoViewController class]]) {
        EAPhotoViewController *photoVC = (EAPhotoViewController *)viewController;
        
        if (photoVC.pageIndex == self.photos.count - 1) {
            return nil;
        }
        
        EAPhotoViewController *photoVC_new = [EAPhotoViewController new];
        photoVC_new.pageIndex = photoVC.pageIndex + 1;
        photoVC_new.photo = self.photos[photoVC_new.pageIndex];
        if (self.navigationController.navigationBar.hidden) {
            photoVC_new.view.backgroundColor = [UIColor blackColor];
        } else {
            photoVC_new.view.backgroundColor = [UIColor whiteColor];
        }
        
        return photoVC_new;
    }
    
    return nil;
}

#pragma mark - Page view controller delegate

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation {
    
    return UIPageViewControllerSpineLocationMin;
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    
    _animating = YES;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    _animating = NO;
    
    if (completed) {
        EAPhotoViewController *photoVC = self.viewControllers.firstObject;
        self.title = [NSString stringWithFormat:@"%lu/%lu", (unsigned long)photoVC.pageIndex + 1, (unsigned long)self.photos.count]; // " photo index / total number of photos "
    }
}

#pragma mark - Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        // Share photo only
        [self sharePhotoWithNote:NO];
    } else if (buttonIndex == 1) {
        // Share photo with note
        [self sharePhotoWithNote:YES];
    }
}

@end
