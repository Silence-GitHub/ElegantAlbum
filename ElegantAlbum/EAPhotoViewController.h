//
//  EAPhotoViewController.h
//  ElegantAlbum
//
//  Created by Kaibo Lu on 16/1/26.
//

#import <UIKit/UIKit.h>

#import "EAPhoto.h"

@interface EAPhotoViewController : UIViewController <UIScrollViewDelegate, UITextViewDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) NSUInteger pageIndex;
@property (nonatomic, strong) EAPhoto *photo;

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UITextView *textView;

@end
