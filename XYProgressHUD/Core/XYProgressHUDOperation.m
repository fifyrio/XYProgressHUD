//
//  XYProgressHUDOperation.m
//  XYProgressHUD
//
//  Created by wuw on 2018/3/12.
//  Copyright © 2018年 wuw. All rights reserved.
//

#import "XYProgressHUDOperation.h"
#import "XYProgressHUDView.h"

@interface XYProgressHUDOperation ()

@end

@implementation XYProgressHUDOperation

- (instancetype)initWithSessionID:(NSString *)sessionID
{
    self = [super init];
    if (self) {
        _sessionID = sessionID;
    }
    return self;
}

- (void)start{
    NSLog(@"启动了");
    [self performSelectorOnMainThread:@selector(startRenderUI) withObject:nil waitUntilDone:NO];
    [NSThread sleepForTimeInterval:_duration * 2];
}

#pragma mark -
- (void)startRenderUI{    
    [[XYProgressHUDView sharedView] showStatus:_status isUsingLoading:_isUsingLoading duration:_duration];
}

@end
