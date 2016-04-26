//
//  EANetworkViewController.m
//  ElegantAlbum
//
//  Created by Kaibo Lu on 16/4/11.
//

#import "EANetworkViewController.h"
#import "EANetworkClassificationTableViewController.h"
#import "EANGTableViewController.h"

#import "EAPublic.h"

@interface EANetworkViewController ()

@end

@implementation EANetworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    EANetworkClassificationTableViewController *leftTVC = [[UIStoryboard storyboardWithName:@"EAMain" bundle:nil] instantiateViewControllerWithIdentifier:@"Network classification table view controller"];
    UINavigationController *leftNC = [[UINavigationController alloc] initWithRootViewController:leftTVC];
    
    EANGTableViewController *ngTVC = [[UIStoryboard storyboardWithName:@"EAMain" bundle:nil] instantiateViewControllerWithIdentifier:@"National geographic table view controller"];
    ngTVC.url = NATIONAL_GEOGRAPHIC_URL;
    self.delegate = ngTVC;
    UINavigationController *centerNC = [[UINavigationController alloc] initWithRootViewController:ngTVC];
    ngTVC.title = @"National geographic";
    
    self.leftController = leftNC;
    self.centerController = centerNC;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
