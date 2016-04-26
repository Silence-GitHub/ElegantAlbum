//
//  EAWebViewController.h
//  ElegantAlbum
//
//  Created by Kaibo Lu on 16/4/9.
//

#import <UIKit/UIKit.h>

@interface EAWebViewController : UIViewController <UIWebViewDelegate>

@property (copy, nonatomic) NSString *url;

@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end
