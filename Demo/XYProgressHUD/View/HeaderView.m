//
//  HeaderView.m
//  XYProgressHUD
//
//  Created by wuw on 2017/5/19.
//  Copyright © 2017年 wuw. All rights reserved.
//

#import "HeaderView.h"

@interface HeaderView()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineHeight;

@end

@implementation HeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
    _lineHeight.constant = XYLine;
}

@end
