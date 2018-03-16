//
//  UIImage+XYBlur.h
//  XYProgressHUD
//
//  Created by wuw on 2018/3/16.
//  Copyright © 2018年 wuw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (XYBlur)

- (UIImage *)xy_blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur;

@end
