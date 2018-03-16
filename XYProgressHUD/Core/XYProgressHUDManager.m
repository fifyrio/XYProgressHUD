//
//  XYProgressHUDManager.m
//  XYProgressHUD
//
//  Created by wuw on 2018/3/12.
//  Copyright © 2018年 wuw. All rights reserved.
//

#import "XYProgressHUDManager.h"
#import "XYProgressHUDOperation.h"

@interface XYProgressHUDManager(){
    dispatch_queue_t _queue;
    NSMutableDictionary *_taskMap;
}

@end

@implementation XYProgressHUDManager

#pragma mark - Life cycle
+ (instancetype)manager{
    static dispatch_once_t onceToken;
    static XYProgressHUDManager *manager;
    dispatch_once(&onceToken, ^{
        dispatch_queue_t queue = dispatch_queue_create("com.will.XYProgressHUD.queue", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
        
        manager = [[[self class] alloc] initWithQueue:queue];
    });
    return manager;
}

- (instancetype)initWithQueue:(dispatch_queue_t)queue
{
    self = [super init];
    if (self) {
        _queue = queue;
        _taskMap = @{}.mutableCopy;
    }
    return self;
}

#pragma mark - Public
- (void)showHUDWithSessionID:(NSString *)sessionID status:(NSString *)status isUsingLoading:(BOOL)isUsingLoading duration:(NSTimeInterval)duration{
    if (!sessionID || !sessionID.length) {
        sessionID = [[NSUUID UUID] UUIDString];
    }
    
    XYProgressHUDOperation *operation = [[XYProgressHUDOperation alloc] initWithSessionID:sessionID];
    operation.status = status;
    operation.isUsingLoading = isUsingLoading;
    operation.duration = duration;
    
    [_taskMap setObject:operation forKey:operation.sessionID];
    if (operation) {
        dispatch_async(_queue, ^{
            [operation start];
        });
    }
}



@end
