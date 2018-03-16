//
//  _XYProgressHUD.m
//  XYProgressHUD
//
//  Created by wuw on 2018/3/12.
//  Copyright © 2018年 wuw. All rights reserved.
//

#import "_XYProgressHUD.h"
#import "XYProgressHUDManager.h"

@implementation _XYProgressHUD

#pragma mark - show and hide animation with default time
+ (void)showStatus:(NSString *)status{
    [[XYProgressHUDManager manager] showHUDWithSessionID:nil
                                                  status:status
                                          isUsingLoading:NO
                                                duration:XYProgressHUDDefaultAnimationDuration];
}

+ (void)showLoading{
    [[XYProgressHUDManager manager] showHUDWithSessionID:nil
                                                  status:nil
                                          isUsingLoading:YES
                                                duration:XYProgressHUDDefaultAnimationDuration];
}

+ (void)showStatusAndLoading:(NSString *)status{
    [[XYProgressHUDManager manager] showHUDWithSessionID:nil
                                                  status:status
                                          isUsingLoading:YES
                                                duration:XYProgressHUDDefaultAnimationDuration];
}

#pragma mark - show and hide animation with customized time
+ (void)showStatus:(NSString *)status duration:(NSTimeInterval)duration{
    [[XYProgressHUDManager manager] showHUDWithSessionID:nil
                                                  status:status
                                          isUsingLoading:NO
                                                duration:duration];
}

+ (void)showLoadingWithDuration:(NSTimeInterval)duration{
    [[XYProgressHUDManager manager] showHUDWithSessionID:nil
                                                  status:nil
                                          isUsingLoading:YES
                                                duration:duration];
}

+ (void)showStatusAndLoading:(NSString *)status duration:(NSTimeInterval)duration{
    [[XYProgressHUDManager manager] showHUDWithSessionID:nil
                                                  status:status
                                          isUsingLoading:YES
                                                duration:duration];
}

#pragma mark - show and hide animation by yourself
+ (void)showStatus:(NSString *)status withSessionId:(NSString *)sessionId{
    [[XYProgressHUDManager manager] showHUDWithSessionID:sessionId
                                                  status:status
                                          isUsingLoading:NO duration:XYProgressHUDIndefiniteAnimationDuration];
}

+ (void)showLoadingWithSessionId:(NSString *)sessionId{
    [[XYProgressHUDManager manager] showHUDWithSessionID:sessionId
                                                  status:nil
                                          isUsingLoading:YES duration:XYProgressHUDIndefiniteAnimationDuration];
}

+ (void)showStatusAndLoading:(NSString *)status withSessionId:(NSString *)sessionId{
    [[XYProgressHUDManager manager] showHUDWithSessionID:sessionId
                                                  status:status
                                          isUsingLoading:YES duration:XYProgressHUDIndefiniteAnimationDuration];
}

+ (void)hideWithSessionId:(NSString *)sessionId{
    
}





@end
