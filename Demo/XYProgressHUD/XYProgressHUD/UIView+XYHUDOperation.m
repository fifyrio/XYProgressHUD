//
//  UIView+XYHUDOperation.m
//  tableView
//
//  Created by wuw on 2017/5/18.
//  Copyright © 2017年 Kingnet. All rights reserved.
//

#import "UIView+XYHUDOperation.h"
#import <objc/runtime.h>

@implementation UIView (XYHUDOperation)

/*
 *NSOperationQueue单例，用于添加operation
 */
- (NSOperationQueue *)getOperationQueue {
    static NSOperationQueue *operationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        operationQueue = [NSOperationQueue new];
    });
    operationQueue.name = NSStringFromClass([self class]);
    return operationQueue;
}

- (void)setStackHUDsIndex:(NSInteger)stackHUDsIndex {
    objc_setAssociatedObject(self, @selector(getStackHUDsIndex), @(stackHUDsIndex), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)getStackHUDsIndex {
    NSNumber *index = objc_getAssociatedObject(self, _cmd);
    return [index integerValue];
}

@end
