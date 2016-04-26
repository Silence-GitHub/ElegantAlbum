//
//  EAViewDeckController.m
//  ElegantAlbum
//
//  Created by 陆凯波 on 16/4/11.
//  Copyright © 2016年 Kaibo. All rights reserved.
//

#import "EAPublic.h"

#import "EAPhotoClassificationTableViewController.h"
#import "EALocalViewDeckController.h"
#import "EAPhotosDateCollectionViewController.h"

@interface EALocalViewDeckController ()

@end

@implementation EALocalViewDeckController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    EAPhotoClassificationTableViewController *leftTVC = [[UIStoryboard storyboardWithName:@"EAMain" bundle:nil] instantiateViewControllerWithIdentifier:@"Photo classification table view controller"];
    UINavigationController *leftNC = [[UINavigationController alloc] initWithRootViewController:leftTVC];
    
    EAPhotosDateCollectionViewController *photosDateCVC = [[EAPhotosDateCollectionViewController alloc] initWithCollectionViewLayout:[XLPlainFlowLayout new]];
    self.delegate = photosDateCVC;
    UINavigationController *centerNC = [[UINavigationController alloc] initWithRootViewController:photosDateCVC];
    photosDateCVC.title = [EAPublic mainClassifications].firstObject;
    
    self.leftController = leftNC;
    self.centerController = centerNC;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
