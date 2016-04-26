//
//  EAWebViewController.m
//  ElegantAlbum
//
//  Created by 陆凯波 on 16/4/9.
//  Copyright © 2016年 Kaibo. All rights reserved.
//

#import "EAWebViewController.h"

#import "EAPublic.h"

@interface EAWebViewController () <UIScrollViewDelegate>

@end

@implementation EAWebViewController {
    CGFloat _contentOffsetY;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _contentOffsetY = 0;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.webView.scrollView.delegate = self;
    
    UIButton *backButton = [EAPublic backButtonItemCustomView];
    [backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    
    UIBarButtonItem *actionButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(prepareForAction:)];
    UIBarButtonItem *refreshButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonPressed:)];
    self.navigationItem.rightBarButtonItems = @[refreshButtonItem, actionButtonItem];
    
    [self refresh:nil];
}

- (void)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForAction:(id)sender {
    NSURL *url = [NSURL URLWithString:self.url];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)refresh:(id)sender {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    [self.webView loadRequest:request];
}

- (void)refreshButtonPressed:(id)sender {
    [self refresh:sender];
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
    [self.webView stopLoading];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (BOOL)prefersStatusBarHidden {
    
    return self.navigationController.navigationBarHidden;
}

#pragma mark - Scroll view delegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    [self.navigationController setNavigationBarHidden:(scrollView.contentOffset.y > _contentOffsetY) animated:YES];
    [self setNeedsStatusBarAppearanceUpdate];
    _contentOffsetY = targetContentOffset->y;
}

#pragma mark - Web view delegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"Error: %@\nUser information: %@", error, error.userInfo);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (self.view.window) {
        [[[UIAlertView alloc] initWithTitle:@"Can not connect to Internet" message:@"Please check your Internet connection and try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}

@end
