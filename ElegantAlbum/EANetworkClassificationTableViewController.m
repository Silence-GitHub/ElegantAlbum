//
//  EANetworkClassificationTableViewController.m
//  ElegantAlbum
//
//  Created by Kaibo Lu on 16/4/12.
//

#import "EANetworkClassificationTableViewController.h"
#import "EANGTableViewController.h"

#import "EAPublic.h"

@interface EANetworkClassificationTableViewController ()

@end

@implementation EANetworkClassificationTableViewController

#pragma mark - View controller life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *leftMenuButton = [EAPublic leftMenuButtonItemCustomViewClosed:NO];
    [leftMenuButton addTarget:self action:@selector(leftMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftMenuButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftMenuButton];
    self.navigationItem.leftBarButtonItem = leftMenuButtonItem;
}

- (void)leftMenuButtonPressed:(id)sender {
    [self.viewDeckController toggleLeftView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [EAPublic nationalGeographicClassifications].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Classifications" forIndexPath:indexPath];
        
    cell.textLabel.text = [EAPublic nationalGeographicClassifications][indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *classification = [EAPublic nationalGeographicClassifications][indexPath.row];
    NSString *url = [EAPublic urlForNationalGeographicClassification:classification];
    
    if ([self.viewDeckController.centerController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nc = (UINavigationController *)self.viewDeckController.centerController;
        EANGTableViewController *firstChild = nc.viewControllers.firstObject; // first child of navigation controller
        
        if ([firstChild.url isEqualToString:url]) {
            [nc popToRootViewControllerAnimated:YES];
        } else {
            EANGTableViewController *newFirstChild = [[UIStoryboard storyboardWithName:@"EAMain" bundle:nil] instantiateViewControllerWithIdentifier:@"National geographic table view controller"];
            newFirstChild.url = url;
            newFirstChild.title = classification;
            self.viewDeckController.delegate = newFirstChild;
            [nc setViewControllers:@[newFirstChild] animated:YES];
        }
    }
    
    [self.viewDeckController toggleLeftView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

@end
