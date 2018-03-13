//
//  XYProgressHUDOperation.m
//  XYProgressHUD
//
//  Created by wuw on 2018/3/12.
//  Copyright © 2018年 wuw. All rights reserved.
//

#import "XYProgressHUDOperation.h"

@interface XYProgressHUDOperation ()

@end

@implementation XYProgressHUDOperation

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)start{
    NSLog(@"启动了");
    sleep(2);
}

@end
