//
//  EAPublic.m
//  ElegantAlbum
//
//  Created by 陆凯波 on 16/1/25.
//  Copyright © 2016年 Kaibo. All rights reserved.
//

#import "EAPublic.h"

@implementation EAPublic

+ (float)iOSVersion {
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

+ (NSArray *)mainClassifications {
    
    return @[@"Date", @"Clock", @"Map", @"State", @"Note"];
}

+ (NSArray *)nationalGeographicClassifications {
    return @[@"National geographic", @"News", @"Culture", @"Video", @"Photography", @"Animals", @"Environment", @"Travel", @"Adventure"];
}

+ (NSString *)urlForNationalGeographicClassification:(NSString *)classification {
    
    NSArray *classifications = [self.class nationalGeographicClassifications];
    if (![classifications containsObject:classification])
        return nil;
    
    NSString *lastComponent;
    if ([classification isEqualToString:classifications.firstObject]) {
        lastComponent = @"";
    } else {
        lastComponent = [classification lowercaseString];
    }
    return [NATIONAL_GEOGRAPHIC_URL stringByAppendingPathComponent:lastComponent];
}

+ (UIImage *)image:(UIImage *)image withSize:(CGSize)size {
    
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage*)grayImage:(UIImage*)sourceImage {
    
    int width = sourceImage.size.width;
    int height = sourceImage.size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate (nil,width,height,8,0,colorSpace,kCGImageAlphaNone);
    
    CGColorSpaceRelease(colorSpace);
    
    if (context == NULL) {
        return nil;
    }
    
    CGContextDrawImage(context,CGRectMake(0, 0, width, height), sourceImage.CGImage);
    CGImageRef grayImageRef = CGBitmapContextCreateImage(context);
    UIImage *grayImage = [UIImage imageWithCGImage:grayImageRef];
    CGContextRelease(context);
    CGImageRelease(grayImageRef);
    
    return grayImage;
}

+ (UIButton *)backButtonItemCustomView {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 15, 30)];
    [button setImage:[UIImage imageNamed:@"Back"] forState:UIControlStateNormal];
    return button;
}

+ (UIButton *)leftMenuButtonItemCustomViewClosed:(BOOL)closed {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 30)];
    NSString *imageName = closed ? @"More_closed" : @"More_open";
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    return button;
}

+ (UIButton *)moreButtonItemCustomViewPointsInVerticalLine {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 15, 30)];
    [button setImage:[UIImage imageNamed:@"More"] forState:UIControlStateNormal];
    return button;
}

+ (void)hideOrShowTabBar:(__weak UITabBar *)tabBar onView:(__weak UIView *)view hide:(BOOL)hide completion:(void (^)(BOOL finished))completion {
    
    [UIView animateWithDuration:0.5 animations:^{
        CGFloat x = tabBar.frame.origin.x;
        CGFloat width = tabBar.frame.size.width;
        CGFloat height = tabBar.frame.size.height;
        CGFloat y = view.bounds.size.height + (hide ? height : - height);
        tabBar.frame = CGRectMake(x, y, width, height);
    } completion:completion];
}

@end
