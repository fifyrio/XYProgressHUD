//
//  UIView+XYHUDOperation.h
//  tableView
//
//  Created by wuw on 2017/5/18.
//  Copyright © 2017年 Kingnet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (XYHUDOperation)

/*
 *NSOperationQueue单例，用于添加operation
 */
- (NSOperationQueue *)getOperationQueue;

/*
 *缓存在StackHUDs数组里的位置
 */
- (NSInteger)getStackHUDsIndex;

- (void)setStackHUDsIndex:(NSInteger)stackHUDsIndex;

@end
