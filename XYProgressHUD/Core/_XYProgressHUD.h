//
//  _XYProgressHUD.h
//  XYProgressHUD
//
//  Created by wuw on 2018/3/12.
//  Copyright © 2018年 wuw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface _XYProgressHUD : NSObject
#pragma mark - show and hide animation with default time
+ (void)showStatus:(NSString *)status;

+ (void)showLoading;

+ (void)showStatusAndLoading:(NSString *)status;

#pragma mark - show and hide animation with customized time
+ (void)showStatus:(NSString *)status duration:(NSTimeInterval)duration;

+ (void)showLoadingWithDuration:(NSTimeInterval)duration;

+ (void)showStatusAndLoading:(NSString *)status duration:(NSTimeInterval)duration;

#pragma mark - show and hide animation by yourself
+ (void)showStatus:(NSString *)status withSessionId:(NSString *)sessionId;

+ (void)showLoadingWithSessionId:(NSString *)sessionId;

+ (void)showStatusAndLoading:(NSString *)status withSessionId:(NSString *)sessionId;

+ (void)hideWithSessionId:(NSString *)sessionId;

@end
