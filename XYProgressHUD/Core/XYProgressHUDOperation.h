//
//  XYProgressHUDOperation.h
//  XYProgressHUD
//
//  Created by wuw on 2018/3/12.
//  Copyright © 2018年 wuw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XYProgressHUDOperation : NSOperation

@property (nonatomic, copy) NSString *sessionID;

@property (nonatomic, copy) NSString *status;

@property (nonatomic, assign) BOOL isUsingLoading;

@property (nonatomic, assign) NSTimeInterval duration;

- (instancetype)initWithSessionID:(NSString *)sessionID;

@end
