//
//  XYIndefiniteAnimatedImageView.m
//  tableView
//
//  Created by wuw on 2017/4/20.
//  Copyright © 2017年 Kingnet. All rights reserved.
//

#import "XYIndefiniteAnimatedImageView.h"
#import "XYProgressHUD.h"

@interface XYIndefiniteAnimatedImageView()

@property (nonatomic, assign) CGFloat radius;

@property (nonatomic, strong) UIColor *strokeColor;

@property (nonatomic, strong) CAShapeLayer *indefiniteAnimatedLayer;

@end

@implementation XYIndefiniteAnimatedImageView

#pragma mark - Life cycle
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.radius = 20;
        self.strokeColor = [UIColor blackColor];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView*)newSuperview {
    if (newSuperview) {
        [self layoutAnimatedLayer];
    } else {
        [_indefiniteAnimatedLayer removeFromSuperlayer];
        _indefiniteAnimatedLayer = nil;
    }
}

- (void)layoutAnimatedLayer {
    CALayer *layer = self.indefiniteAnimatedLayer;
    [self.layer addSublayer:layer];
    
    CGFloat widthDiff = CGRectGetWidth(self.bounds) - CGRectGetWidth(layer.bounds);
    CGFloat heightDiff = CGRectGetHeight(self.bounds) - CGRectGetHeight(layer.bounds);
    layer.position = CGPointMake(CGRectGetWidth(self.bounds) - CGRectGetWidth(layer.bounds) / 2 - widthDiff / 2, CGRectGetHeight(self.bounds) - CGRectGetHeight(layer.bounds) / 2 - heightDiff / 2);
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(self.radius*2, self.radius*2);
}

#pragma mark - Lazy load
- (CAShapeLayer *)indefiniteAnimatedLayer{
    if (!_indefiniteAnimatedLayer) {
        CGPoint arcCenter = CGPointMake(self.radius, self.radius);
        
        _indefiniteAnimatedLayer = [CAShapeLayer layer];
        _indefiniteAnimatedLayer.contentsScale = [[UIScreen mainScreen] scale];
        _indefiniteAnimatedLayer.frame = CGRectMake(0.0f, 0.0f, arcCenter.x*2, arcCenter.y*2);
        _indefiniteAnimatedLayer.fillColor = [UIColor clearColor].CGColor;
        
        NSBundle *bundle = [NSBundle bundleForClass:[XYProgressHUD class]];
        NSURL *url = [bundle URLForResource:@"XYProgressHUD" withExtension:@"bundle"];
        NSBundle *imageBundle = [NSBundle bundleWithURL:url];
        
        NSString *path = [imageBundle pathForResource:@"xy-loading" ofType:@"png"];
        _indefiniteAnimatedLayer.contents = (__bridge id)[[UIImage imageWithContentsOfFile:path] CGImage];
        
        //动画
        NSTimeInterval animationDuration = 1;
        CAMediaTimingFunction *linearCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        animation.fromValue = (id) 0;
        animation.toValue = @(M_PI*2);
        animation.duration = animationDuration;
        animation.timingFunction = linearCurve;
        animation.removedOnCompletion = NO;
        animation.repeatCount = INFINITY;
        animation.fillMode = kCAFillModeForwards;
        animation.autoreverses = NO;
        [_indefiniteAnimatedLayer addAnimation:animation forKey:@"rotate"];
        
    }
    return _indefiniteAnimatedLayer;
}


@end
