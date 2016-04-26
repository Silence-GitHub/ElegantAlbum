//
//  EAWaitingViewController.m
//  ElegantAlbum
//
//  Created by Kaibo Lu on 16/2/29.
//

#import "EAWaitingViewController.h"

@interface EAWaitingViewController ()

@end

@implementation EAWaitingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor grayColor];
    self.view.alpha = 0.7f;
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.center = self.view.center;
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
