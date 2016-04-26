//
//  EAPhotosMapViewController.h
//  ElegantAlbum
//
//  Created by 陆凯波 on 16/2/5.
//  Copyright © 2016年 Kaibo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "EAPublic.h"
#import "EAAppDelegate.h"

#import "EAPhoto.h"
#import "EAPhotoAnnotation.h"

#import "EAPhotosRegionCollectionViewController.h"

@interface EAPhotosMapViewController : UIViewController <MKMapViewDelegate, IIViewDeckControllerDelegate>

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIView *maskView; // mask to avoid user interaction when showing slide menu

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end
