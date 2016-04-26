//
//  AppDelegate.h
//  ElegantAlbum
//
//  Created by Kaibo Lu on 16/1/24.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface EAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

