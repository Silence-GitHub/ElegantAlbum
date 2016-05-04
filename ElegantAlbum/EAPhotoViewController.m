//
//  EAPhotoViewController.m
//  ElegantAlbum
//
//  Created by Kaibo Lu on 16/1/26.
//

#import "EAPhotoViewController.h"

#import "EAAppDelegate.h"
#import "EAPublic.h"

@interface EAPhotoViewController ()

@end

@implementation EAPhotoViewController {
    
    CGFloat _originalImageViewHeight;
    CGFloat _originalTextViewY;
}

#pragma mark - Properties

- (NSManagedObjectContext *)managedObjectContext {
    if (!_managedObjectContext) {
        EAAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        _managedObjectContext = appDelegate.managedObjectContext;
    }
    return _managedObjectContext;
}

- (void)setPhoto:(EAPhoto *)photo {
    
    _photo = photo;
    
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        _scrollView = [[UIScrollView alloc] initWithFrame:frame];
        _scrollView.contentSize = CGSizeMake(frame.size.width, frame.size.height);
        _scrollView.delegate = self;
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [UIImageView new];
        [self.scrollView addSubview:_imageView];
    }
    return _imageView;
}

static NSString *PROMPT_STRING = @"Add note here"; // String to display when no note for photo

+ (UIColor *)textColorForTextViewNoNote {
    return [UIColor lightGrayColor];
}

+ (UIColor *)textColorForTextViewWithNote {
    return [UIColor darkTextColor];
}

const static CGFloat TEXT_VIEW_ORIGINAL_HEIGHT = 80.0f;

- (UITextView *)textView {
    if (!_textView) {
        CGRect frame = CGRectMake(0, self.view.bounds.size.height - TEXT_VIEW_ORIGINAL_HEIGHT, self.view.bounds.size.width, TEXT_VIEW_ORIGINAL_HEIGHT);
        _textView = [[UITextView alloc] initWithFrame:frame];
        _originalTextViewY = frame.origin.y;
        _textView.font = [UIFont systemFontOfSize:16];
//        _textView.backgroundColor = [UIColor yellowColor];
        _textView.textAlignment = NSTextAlignmentJustified;
        _textView.delegate = self;
        [self.scrollView addSubview:_textView];
        
        if (self.photo.note.length > 0) {
            // Has note
            _textView.text = self.photo.note;
            _textView.textColor = [self.class textColorForTextViewWithNote];
            CGRect contentRect = [self.photo.note boundingRectWithSize:CGSizeMake(frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : _textView.font} context:nil];
            CGFloat extraHeight = 10.0f;
            NSLog(@"content height = %f, frame height = %f", contentRect.size.height + extraHeight, frame.size.height);
            CGFloat height = MAX(contentRect.size.height + extraHeight, frame.size.height);
            _textView.frame = CGRectMake(frame.origin.x, _originalTextViewY, frame.size.width, height);
            
            self.scrollView.contentSize = CGSizeMake(_textView.frame.size.width, CGRectGetMaxY(_textView.frame));
            
        } else {
            // No note
            _textView.text = PROMPT_STRING;
            _textView.textColor = [self.class textColorForTextViewNoNote];
        }
    }
    return _textView;
}

#pragma mark - View controller life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
    [self.view addGestureRecognizer:tap];
    
    ALAssetsLibrary *lib = [ALAssetsLibrary new];
    __weak typeof(self) weakSelf = self;
    [lib assetForURL:[NSURL URLWithString:self.photo.url] resultBlock:^(ALAsset *asset) {

        UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage scale:1.0f orientation:UIImageOrientationUp];
        weakSelf.imageView.image = image;

        // Adjust image size
        CGFloat viewWidth = weakSelf.view.bounds.size.width;
        CGFloat viewHeight = weakSelf.view.bounds.size.height;
        CGFloat widthRatio = image.size.width / viewWidth;
        CGFloat heightRatio = image.size.height / viewHeight;
        
        NSLog(@"view w = %f, h = %f; image w = %f, h = %f", viewWidth, viewHeight, image.size.width, image.size.height);
        
        CGFloat x, y, imageWidth, imageHeight;
        
        if (widthRatio > 1.0f || heightRatio > 1.0f) {
            
            if (widthRatio > heightRatio) {
                
                weakSelf.scrollView.maximumZoomScale = widthRatio;
                imageWidth = viewWidth;
                imageHeight = image.size.height / widthRatio;
                
            } else {
                
                weakSelf.scrollView.maximumZoomScale = heightRatio;
                imageHeight = viewHeight;
                imageWidth = image.size.width / heightRatio;
            }
        } else {
            
            weakSelf.scrollView.maximumZoomScale = 3.0f;
            imageWidth = image.size.width;
            imageHeight = image.size.height;
        }
        NSLog(@"Max zoom scale = %f", weakSelf.scrollView.maximumZoomScale);
        x = (viewWidth - imageWidth) / 2.0f;
        y = (viewHeight - imageHeight) / 2.0f;
        
        weakSelf.imageView.frame = CGRectMake(x, y, imageWidth, imageHeight);
        
        _originalImageViewHeight = imageHeight;
        
        weakSelf.textView.hidden = [weakSelf.view.backgroundColor isEqual:[UIColor blackColor]];

    } failureBlock:^(NSError *error) {
        NSLog(@"Error: %@\nUser information: %@", error, error.userInfo);
    }];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    CGFloat keyboardHeight = [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    self.view.frame = CGRectMake(0, - keyboardHeight, self.view.bounds.size.width, self.view.bounds.size.height);
}

- (void)tapImage:(id)sender {
    
    if (self.textView.isFirstResponder) {
        [self.textView resignFirstResponder];
        return;
    }
    
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
    self.textView.hidden = self.navigationController.navigationBarHidden;
    if (self.navigationController.navigationBarHidden) {
        self.view.backgroundColor = [UIColor blackColor];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
    }
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // When keyborad shows in other view controller, the view frame changes
    // Change the view frame back when view appear
    self.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

#pragma mark - Scroll view delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    CGFloat y = _originalTextViewY + _originalImageViewHeight * (scrollView.zoomScale - 1);
    self.textView.frame = CGRectMake(0, y, self.view.bounds.size.width * scrollView.zoomScale, self.textView.frame.size.height);
    
    self.scrollView.contentSize = CGSizeMake(self.textView.frame.size.width, CGRectGetMaxY(self.textView.frame));
}

#pragma mark - Text view delegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:PROMPT_STRING]) {
        textView.text = nil;
        textView.textColor = [self.class textColorForTextViewWithNote];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    NSString *text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text.length > 0 && ![text isEqualToString:PROMPT_STRING]) {
        if (![text isEqualToString:self.photo.note]) {
            NSNumber *number = @1; // Number of photo note increase
            if (self.photo.note) {
                // Already has note
                // Number of photo note not change
                number = @0;
            }
            
            [self.photo updateNote:text];
            
            // Number of photo note increase or not change
            // Post notification
            [[NSNotificationCenter defaultCenter] postNotificationName:PHOTO_NOTE_CHANGE_NOTIFICATION object:nil userInfo:@{ NUMBER_OF_PHOTO_NOTE_CHANGE_KEY : number, PHOTO_KEY : self.photo, UPDATE_ALBUM_KEY : @YES }];
        }
        
        textView.text = text;
        
    } else {
        // No note now
        if (self.photo.note) {
            // Has note before
            [self.photo updateNote:nil];
            
            // Number of photo note decrease
            // Post notification
            [[NSNotificationCenter defaultCenter] postNotificationName:PHOTO_NOTE_CHANGE_NOTIFICATION object:nil userInfo:@{ NUMBER_OF_PHOTO_NOTE_CHANGE_KEY : @-1, PHOTO_KEY : self.photo, UPDATE_ALBUM_KEY : @YES }];
        }
        
        textView.text = PROMPT_STRING;
        textView.textColor = [self.class textColorForTextViewNoNote];
    }
    
    // 调整textView、scrollView高度适应内容
    CGFloat x = textView.frame.origin.x;
    CGFloat y = textView.frame.origin.y;
    CGFloat width = textView.frame.size.width;
    CGFloat height = MAX(textView.contentSize.height, TEXT_VIEW_ORIGINAL_HEIGHT);
    textView.frame = CGRectMake(x, y, width, height);
    self.scrollView.contentSize = CGSizeMake(textView.frame.size.width, CGRectGetMaxY(textView.frame));
}

@end
