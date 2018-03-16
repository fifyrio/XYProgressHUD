//
//  XYProgressHUDManager.h
//  XYProgressHUD
//
//  Created by wuw on 2018/3/12.
//  Copyright © 2018年 wuw. All rights reserved.
//

#import <Foundation/Foundation.h>

static const CGFloat XYProgressHUDDefaultAnimationDuration = 0.3;

static const CGFloat XYProgressHUDIndefiniteAnimationDuration = CGFLOAT_MAX;//无线循环

typedef void (^XYProgressHUDShowCompletion)(void);

typedef void (^XYProgressHUDDismissCompletion)(void);

@interface XYProgressHUDManager : NSObject

+ (instancetype)manager;

- (void)showHUDWithSessionID:(NSString *)sessionID status:(NSString *)status isUsingLoading:(BOOL)isUsingLoading duration:(NSTimeInterval)duration;

@end
