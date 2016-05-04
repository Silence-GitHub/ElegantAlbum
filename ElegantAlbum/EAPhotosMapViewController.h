//
//  EAPhotosMapViewController.h
//  ElegantAlbum
//
//  Created by Kaibo Lu on 16/2/5.
//

#import <UIKit/UIKit.h>

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
