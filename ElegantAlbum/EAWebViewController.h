//
//  EAWebViewController.h
//  ElegantAlbum
//
//  Created by 陆凯波 on 16/4/9.
//  Copyright © 2016年 Kaibo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EAWebViewController : UIViewController <UIWebViewDelegate>

@property (copy, nonatomic) NSString *url;

@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end
