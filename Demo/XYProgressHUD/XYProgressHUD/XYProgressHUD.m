//
//  XYProgressHUD.m
//  tableView
//
//  Created by wuw on 2017/4/19.
//  Copyright © 2017年 Kingnet. All rights reserved.
//

#import "XYProgressHUD.h"
#import "XYIndefiniteAnimatedImageView.h"
#import "UIView+XYHUDOperation.h"

#define xy_weakify(var) __weak typeof(var) XYWeak_##var = var;
#define xy_strongify(var) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong typeof(var) var = XYWeak_##var; \
_Pragma("clang diagnostic pop")

static const CGFloat XYProgressHUDDefaultAnimationDuration = 0.3;

static const double XYProgressHUDUndefinedDuration = -1;

NSString * const XYProgressHUDDidReceiveTouchEventNotification = @"XYProgressHUDDidReceiveTouchEventNotification";

NSString * const XYProgressHUDDidTouchDownInsideNotification = @"XYProgressHUDDidTouchDownInsideNotification";

//typedef   void (^DismissBlock)(void);

@interface XYProgressHUD ()

@property (nonatomic, strong) UIView *hudView;

@property (nonatomic, strong) UILabel *statusLabel;

@property (nonatomic, strong) UIControl *overlayView;

@property (nonatomic, strong) UIView *indefiniteAnimatedView;

@property (nonatomic, strong) NSTimer *fadeOutTimer;

@property (nonatomic, readwrite) NSUInteger activityCount;

@property (nonatomic, copy) void (^dismissBlock)(void);

- (UIColor*)backgroundColorForStyle;

- (UIColor*)foregroundColorForStyle;

@end

@implementation XYProgressHUD{
    BOOL _isInitializing;
}

#pragma mark - Singleton
+ (XYProgressHUD*)sharedView {
    static dispatch_once_t once;    
    static XYProgressHUD *sharedView;
    dispatch_once(&once, ^{ sharedView = [[self alloc] initWithFrame:[[[UIApplication sharedApplication] delegate] window].bounds]; });

    return sharedView;
}

/*
 *用于缓存XYProgressHUD
 */
+ (NSMutableArray *)getStackHUDs{
    static NSMutableArray *stackHUDs = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stackHUDs = [NSMutableArray array];
    });
    return stackHUDs;
}

#pragma mark - Init/Getter (not singleton)
+ (instancetype)initHUD{
    return [[self alloc] initWithFrame:[[[UIApplication sharedApplication] delegate] window].bounds];
}

+ (instancetype)initHUDWithTag:(NSInteger)tag{
    XYProgressHUD *unsharedView = [[self alloc] initWithFrame:[[[UIApplication sharedApplication] delegate] window].bounds];
    unsharedView.tag = tag;
    return unsharedView;
}

/*
 *从缓存数组里取出HUD
 */
+ (instancetype)getHUDWithTag:(NSInteger)tag{
    __block XYProgressHUD *theHUD;
    
    NSMutableArray *huds = [XYProgressHUD getStackHUDs];
    if (huds.count) {
        [huds enumerateObjectsUsingBlock:^(XYProgressHUD * _Nonnull hud, NSUInteger idx, BOOL * _Nonnull stop) {
            if (hud.tag == tag) {
                theHUD = hud;
                *stop = YES;
            }
        }];
    }
    return theHUD;
}

#pragma mark - Instance Methods
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isInitializing = YES;
        
        self.userInteractionEnabled = NO;
        _backgroundColor = [UIColor clearColor];
        _foregroundColor = [UIColor blackColor];
        _backgroundLayerColor = [UIColor colorWithWhite:0 alpha:0.4];
        
        self.alpha = 0.0f;
        self.activityCount = 0;
        _defaultStyle = XYProgressHUDStyleLight;
        _defaultContentStyle = XYProgressHUDContentStyleDefault;
        
        _minimumSize = CGSizeMake(100.0f, 100.0f);
        
        if ([UIFont respondsToSelector:@selector(preferredFontForTextStyle:)]) {
            _font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        } else {
            _font = [UIFont systemFontOfSize:14.0f];
        }
        
        _ringThickness = 2.0f;
        _ringRadius = 18.0f;        
        
        _cornerRadius = 14.0f;
        
        _minimumDismissTimeInterval = 5.0;
        
        _fadeInAnimationDuration = XYProgressHUDDefaultAnimationDuration;
        _fadeOutAnimationDuration = XYProgressHUDDefaultAnimationDuration;
        
        _maxSupportedWindowLevel = UIWindowLevelNormal;
        
        _isInitializing = NO;
    }
    return self;
}

- (void)updateViewHierarchy{
    //add overlayView to front window
    if (!self.overlayView.superview) {
        NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
        for (UIWindow *window in frontToBackWindows) {
            BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
            BOOL windowIsVisible = !window.hidden && window.alpha > 0;
            BOOL windowLevelSupported = (window.windowLevel >= UIWindowLevelNormal && window.windowLevel <= self.maxSupportedWindowLevel);
            
            if(windowOnMainScreen && windowIsVisible && windowLevelSupported) {
                [window addSubview:self.overlayView];
                break;
            }
        }
    }else{
        [self.overlayView.superview bringSubviewToFront:self.overlayView];
    }
    
    //add self to overlayView
    if (!self.superview) {
        [self.overlayView addSubview:self];
    }
    
    //add hudView to self
    if (!self.hudView.superview) {
        [self addSubview:self.hudView];
    }
}

- (void)updateHUDFrame{
    CGFloat hudWidth = 0.0f;
    CGFloat hudHeight = 0.0f;
    
    if (self.defaultContentStyle == XYProgressHUDContentStyleDefault) {
        CGRect labelRect = CGRectZero;
        
        CGFloat verticalSpacing = 12.0f; // |-12-content-(8-label-)12-|
        CGFloat horizontalSpacing = 12.0f; // |-12-content-12-|
        
        // Calculate size of string and update HUD size
        NSString *string = self.statusLabel.text;
        if(string) {
            CGSize constraintSize = CGSizeMake(200.0f, 300.0f);
            if([string respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
                labelRect = [string boundingRectWithSize:constraintSize
                                                 options:(NSStringDrawingOptions)(NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin)
                                              attributes:@{NSFontAttributeName: self.statusLabel.font}
                                                 context:NULL];
            } else {
                CGSize stringSize;
                if([string respondsToSelector:@selector(sizeWithAttributes:)]) {
                    stringSize = [string sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:self.statusLabel.font.fontName size:self.statusLabel.font.pointSize]}];
                } else {
#if TARGET_OS_IOS
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
                    stringSize = [string sizeWithFont:self.statusLabel.font constrainedToSize:CGSizeMake(200.0f, 300.0f)];
#pragma clang diagnostic pop
#endif
                }
                labelRect = CGRectMake(0.0f, 0.0f, stringSize.width, stringSize.height);
            }
            labelRect.size.width = MAX(self.minimumSize.width, horizontalSpacing + CGRectGetWidth(labelRect) + horizontalSpacing);
            
            CGFloat labelHeight = ceilf(CGRectGetHeight(labelRect));
            CGFloat labelWidth = ceilf(CGRectGetWidth(labelRect));
            
            hudHeight = verticalSpacing + CGRectGetHeight(self.indefiniteAnimatedView.frame) + verticalSpacing + labelHeight + verticalSpacing;
            
            hudWidth = labelWidth;
        }
        
        // Update values on subviews
        self.hudView.bounds = CGRectMake(0.0f, 0.0f, MAX(self.minimumSize.width, hudWidth), MAX(self.minimumSize.height, hudHeight));
        [self updateBlurBounds];
        
        self.hudView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
        
        // Animate value update
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        
        
        CGFloat centerY;
        if(string){
            CGFloat contentHeight = CGRectGetHeight(self.indefiniteAnimatedView.frame);
            CGFloat labelHeight = ceilf(CGRectGetHeight(labelRect));
            CGFloat yOffset = MAX(verticalSpacing, (self.minimumSize.height - contentHeight - labelHeight - verticalSpacing) / 2.0f);
            
            centerY = yOffset + contentHeight / 2.0f;
        } else {
            centerY = CGRectGetHeight(self.hudView.bounds) / 2.0f;
        }
        self.indefiniteAnimatedView.center = CGPointMake((CGRectGetWidth(self.hudView.bounds) / 2.0f), centerY);
        
        labelRect.origin.y = CGRectGetMaxY(self.indefiniteAnimatedView.frame) + verticalSpacing;
        
        self.statusLabel.frame = labelRect;
        self.statusLabel.hidden = !string;
        
        [CATransaction commit];
    }else if (self.defaultContentStyle == XYProgressHUDContentStyleLoading) {
        /* Update values on subviews*/
        self.hudView.bounds = CGRectMake(0.0f, 0.0f, self.minimumSize.width, self.minimumSize.height);
        [self updateBlurBounds];
        
        self.hudView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
        
        // Animate value update
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        
        self.indefiniteAnimatedView.center = CGPointMake((CGRectGetWidth(self.hudView.bounds) / 2.0f), CGRectGetHeight(self.hudView.bounds) / 2.0f);
        
        [CATransaction commit];
    }else if (self.defaultContentStyle == XYProgressHUDContentStyleStatus){
        CGRect labelRect = CGRectZero;
        
        CGFloat verticalSpacing = 12.0f; // |-12-content-(8-label-)12-|
        CGFloat horizontalSpacing = 12.0f; // |-12-content-12-|
        
        // Calculate size of string and update HUD size
        NSString *string = self.statusLabel.text;
        if(string) {
            CGSize constraintSize = CGSizeMake(200.0f, 300.0f);
            if([string respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
                labelRect = [string boundingRectWithSize:constraintSize
                                                 options:(NSStringDrawingOptions)(NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin)
                                              attributes:@{NSFontAttributeName: self.statusLabel.font}
                                                 context:NULL];
            } else {
                CGSize stringSize;
                if([string respondsToSelector:@selector(sizeWithAttributes:)]) {
                    stringSize = [string sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:self.statusLabel.font.fontName size:self.statusLabel.font.pointSize]}];
                } else {
#if TARGET_OS_IOS
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
                    stringSize = [string sizeWithFont:self.statusLabel.font constrainedToSize:CGSizeMake(200.0f, 300.0f)];
#pragma clang diagnostic pop
#endif
                }
                labelRect = CGRectMake(0.0f, 0.0f, stringSize.width, stringSize.height);
            }
            labelRect.size.width = horizontalSpacing + CGRectGetWidth(labelRect) + horizontalSpacing;
            
            CGFloat labelHeight = ceilf(CGRectGetHeight(labelRect));
            CGFloat labelWidth = ceilf(CGRectGetWidth(labelRect));
            
            hudHeight = verticalSpacing + labelHeight + verticalSpacing;
            
            hudWidth = labelWidth;
        }
        
        // Update values on subviews
        self.hudView.bounds = CGRectMake(0.0f, 0.0f, hudWidth, hudHeight);
        [self updateBlurBounds];
        
        self.hudView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
        
        // Animate value update
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        
        labelRect.origin.y = verticalSpacing;
        self.statusLabel.frame = labelRect;
        self.statusLabel.hidden = !string;
        
        [CATransaction commit];
    }
}

- (void)cancelIndefiniteAnimatedViewAnimation {
    // Stop animation
    if([self.indefiniteAnimatedView respondsToSelector:@selector(stopAnimating)]) {
        [(id)self.indefiniteAnimatedView stopAnimating];
    }
    // Remove from view
    [self.indefiniteAnimatedView removeFromSuperview];
}

- (void)updateBlurBounds {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if(NSClassFromString(@"UIBlurEffect") && self.defaultStyle != XYProgressHUDStyleCustom) {
        // Remove any old instances of UIVisualEffectViews
        for (UIView *subview in self.hudView.subviews) {
            if([subview isKindOfClass:[UIVisualEffectView class]]) {
                [subview removeFromSuperview];
            }
        }
        
        if(self.backgroundColorForStyle != [UIColor clearColor]) {
            // Create blur effect
            UIBlurEffectStyle blurEffectStyle = self.defaultStyle == XYProgressHUDStyleDark ? UIBlurEffectStyleDark : UIBlurEffectStyleLight;
            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:blurEffectStyle];
            UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            blurEffectView.autoresizingMask = self.hudView.autoresizingMask;
            blurEffectView.frame = self.hudView.bounds;
            
            // Add vibrancy to the blur effect to make it more vivid
            UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
            UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
            vibrancyEffectView.autoresizingMask = blurEffectView.autoresizingMask;
            vibrancyEffectView.bounds = blurEffectView.bounds;
            [blurEffectView.contentView addSubview:vibrancyEffectView];
            
            [self.hudView insertSubview:blurEffectView atIndex:0];
        }
    } else{
        // Remove any old instances of UIVisualEffectViews, when the HUDStyle changed from other to custom
        for (UIView *subview in self.hudView.subviews) {
            if([subview isKindOfClass:[UIVisualEffectView class]]) {
                [subview removeFromSuperview];
            }
        }
    }
#endif
}

- (void)setFadeOutTimer:(NSTimer*)timer {
    if(_fadeOutTimer) {
        [_fadeOutTimer invalidate], _fadeOutTimer = nil;
    }
    if(timer) {
        _fadeOutTimer = timer;
    }
}

#pragma mark - Show/Hide methods(singleton)
/*
 *显示提示文字以默认时间
 */
+ (void)showStatus:(NSString *)status{
    if (!status) {
        return;
    }
    [XYProgressHUD sharedView].statusLabel.text = status;
    [XYProgressHUD sharedView].defaultContentStyle = XYProgressHUDContentStyleStatus;    
    NSTimeInterval duration = [XYProgressHUD sharedView].minimumDismissTimeInterval;
    [[XYProgressHUD sharedView] showWithDuration:duration];
}

/*
 *显示提示文字以一定时间
 */
+ (void)showStatus:(NSString *)status duration:(NSTimeInterval)duration{
    if (!status) {
        return;
    }
    [XYProgressHUD sharedView].statusLabel.text = status;
    [XYProgressHUD sharedView].defaultContentStyle = XYProgressHUDContentStyleStatus;
    [[XYProgressHUD sharedView] showWithDuration:duration];
}

/*
 *显示加载动画以一定时间
 */
+ (void)showLoadingWithDuration:(NSTimeInterval)duration{
    [XYProgressHUD sharedView].statusLabel.text = @"";
    [XYProgressHUD sharedView].defaultContentStyle = XYProgressHUDContentStyleLoading;
    [[XYProgressHUD sharedView] showWithDuration:duration];
}

/*
 *显示加载动画和提示文字以一定时间
 */
+ (void)showLoadingWithDuration:(NSTimeInterval)duration status:(NSString *)status{
    [XYProgressHUD sharedView].statusLabel.text = status;
    [XYProgressHUD sharedView].defaultContentStyle = XYProgressHUDContentStyleDefault;
    [[XYProgressHUD sharedView] showWithDuration:duration];
}


/*
 *显示加载动画，一直显示
 */
+ (void)showLoadingIndefinitely{
    [XYProgressHUD sharedView].statusLabel.text = @"";
    [XYProgressHUD sharedView].defaultContentStyle = XYProgressHUDContentStyleLoading;
    [[XYProgressHUD sharedView] showWithDuration:XYProgressHUDUndefinedDuration];
}

/*
 *显示加载动画和提示文字，一直显示
 */
+ (void)showLoadingIndefinitelyWithStatus:(NSString *)status{
    [XYProgressHUD sharedView].statusLabel.text = status;
    [XYProgressHUD sharedView].defaultContentStyle = XYProgressHUDContentStyleDefault;
    [[XYProgressHUD sharedView] showWithDuration:XYProgressHUDUndefinedDuration];
}

/*
 *隐藏加载动画
 */
+ (void)dismissLoading{
    [[XYProgressHUD sharedView] dismiss];
}

/*
 *隐藏加载动画以一定时间
 */
+ (void)dismissLoadingWithDelay:(NSTimeInterval)delay{
    [[XYProgressHUD sharedView] dismissWithDelay:delay completion:nil];
}

/*
 *隐藏加载动画以一定时间，并带回调函数
 */
+ (void)dismissLoadingWithDelay:(NSTimeInterval)delay completion:(XYProgressHUDDismissCompletion)completion{
    [[XYProgressHUD sharedView] dismissWithDelay:delay completion:completion];
}

#pragma mark - Show/Hide methods(not singleton)
/*
 *显示提示文字以默认时间
 */
- (void)fifo_showStatus:(NSString *)status{
    if (!status) {
        return;
    }
    self.defaultContentStyle = XYProgressHUDContentStyleStatus;
    self.statusLabel.text = status;
    NSTimeInterval duration = self.minimumDismissTimeInterval;
    [self showByFIFOWithDuration:duration];
}

/*
 *显示提示文字以一定时间
 */
- (void)fifo_showStatus:(NSString *)status duration:(NSTimeInterval)duration{
    if (!status) {
        return;
    }
    self.defaultContentStyle = XYProgressHUDContentStyleStatus;
    self.statusLabel.text = status;
    [self showByFIFOWithDuration:duration];
}

/*
 *显示加载动画以一定时间
 */
- (void)fifo_showLoadingWithDuration:(NSTimeInterval)duration{
    self.defaultContentStyle = XYProgressHUDContentStyleLoading;
    [self showByFIFOWithDuration:duration];
}

/*
 *显示加载动画和提示文字以一定时间
 */
- (void)fifo_showLoadingWithDuration:(NSTimeInterval)duration status:(NSString *)status{
    if (!status) {
        return;
    }
    self.statusLabel.text = status;
    [self showByFIFOWithDuration:duration];
}


/*
 *显示加载动画，一直显示
 */
- (void)fifo_showLoadingIndefinitely{
    self.defaultContentStyle = XYProgressHUDContentStyleLoading;
    [self showByFIFOWithDuration:XYProgressHUDUndefinedDuration];
}

/*
 *显示加载动画和提示文字，一直显示
 */
- (void)fifo_showLoadingIndefinitelyWithStatus:(NSString *)status{
    if (!status) {
        return;
    }
    self.statusLabel.text = status;
    NSTimeInterval duration = self.minimumDismissTimeInterval;
    [self showByFIFOWithDuration:duration];
}







/*
 *隐藏加载动画
 */
- (void)fifo_dismissLoading{
    [self fifo_dismissLoadingWithDelay:0 completion:nil];
}


/*
 *隐藏加载动画以一定时间
 */
- (void)fifo_dismissLoadingWithDelay:(NSTimeInterval)delay{
    [self fifo_dismissLoadingWithDelay:delay completion:nil];
}

/*
 *隐藏加载动画以一定时间，带回调函数
 */
- (void)fifo_dismissLoadingWithDelay:(NSTimeInterval)delay completion:(XYProgressHUDDismissCompletion)completion{
    NSArray *operations = [self getOperationQueue].operations;
    NSInteger tag = self.tag;
    if (operations.count) {
        __block NSBlockOperation *theOperation;
        __block BOOL hasOperation = NO;
        
        [operations enumerateObjectsUsingBlock:^(NSBlockOperation * _Nonnull operation, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([operation.name isEqualToString:[NSString stringWithFormat:@"%@-%ld-show", NSStringFromClass([XYProgressHUD class]), tag]]) {
                theOperation = operation;
                hasOperation = YES;
                *stop = YES;
            }
        }];
        
        if (hasOperation) {
            if (!theOperation.isExecuting) {//该进程还没执行就直接停止
                [theOperation cancel];
                
                //从缓存删除self
                NSMutableArray *stackHUDs = [XYProgressHUD getStackHUDs];
                if ([stackHUDs containsObject:self]) {
                    [stackHUDs removeObject:self];
                }
            }else{//该进程已经执行了就开始停止动画
                [self dismissWithDelay:delay completion:completion];
            }
        }
    }
}





#pragma mark - Master show methods(not singleton)
- (void)showByFIFOWithDuration:(double)duration{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    // put in stack
    NSMutableArray *stackHUDs = [XYProgressHUD getStackHUDs];
    if (![stackHUDs containsObject:self]) {
        [stackHUDs addObject:self];
        
        //缓存index,待定
        [self setStackHUDsIndex:stackHUDs.count - 1];
    }
    
    xy_weakify(self);
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            xy_strongify(self);
            
            xy_weakify(self);
            [self setDismissBlock:^{
                xy_strongify(self);
                NSMutableArray *stackHUDs = [XYProgressHUD getStackHUDs];
                if ([stackHUDs containsObject:self]) {
                    [stackHUDs removeObject:self];
                }
                dispatch_semaphore_signal(semaphore);
            }];
            
            //显示HUD
            [self updateViewHierarchy];
            
            if(self.fadeOutTimer) {
                self.activityCount = 0;
            }
            self.fadeOutTimer = nil;
            
            if (self.defaultContentStyle == XYProgressHUDContentStyleLoading) {
                [self.hudView addSubview:self.indefiniteAnimatedView];
            }else if (self.defaultContentStyle == XYProgressHUDContentStyleStatus){
                [self.hudView addSubview:self.statusLabel];
            }else{//default
                [self.hudView addSubview:self.indefiniteAnimatedView];
                [self.hudView addSubview:self.statusLabel];
            }
            
            // Update the activity count
            self.activityCount++;
            
            [self updateHUDFrame];
            [self show];
            
            if (duration >= 0) {
                self.fadeOutTimer = [NSTimer timerWithTimeInterval:duration target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
                [[NSRunLoop mainRunLoop] addTimer:self.fadeOutTimer forMode:NSRunLoopCommonModes];
            }
        });
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }];
    
    operation.name = [NSString stringWithFormat:@"%@-%ld-show",NSStringFromClass([self class]), (long)self.tag];
    
    if ([self getOperationQueue].operations.lastObject) {
        [operation addDependency:[self getOperationQueue].operations.lastObject];
    }
    [[self getOperationQueue] addOperation:operation];
}

#pragma mark - Master show methods(singleton)
- (void)showWithDuration:(double)duration{
    xy_weakify(self);
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        xy_strongify(self);
        
        if (self) {
            [self updateViewHierarchy];
            
            if(self.fadeOutTimer) {
                self.activityCount = 0;
            }
            self.fadeOutTimer = nil;
            
            if (self.defaultContentStyle == XYProgressHUDContentStyleLoading) {
                [self.hudView addSubview:self.indefiniteAnimatedView];
            }else if (self.defaultContentStyle == XYProgressHUDContentStyleStatus){
                [self.hudView addSubview:self.statusLabel];
            }else{//default
                [self.hudView addSubview:self.indefiniteAnimatedView];
                [self.hudView addSubview:self.statusLabel];
            }
            
            // Update the activity count
            self.activityCount++;
            
            [self updateHUDFrame];
            [self show];
            
            if (duration >= 0) {
                self.fadeOutTimer = [NSTimer timerWithTimeInterval:duration target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
                [[NSRunLoop mainRunLoop] addTimer:self.fadeOutTimer forMode:NSRunLoopCommonModes];
            }
        }
    }];
}

- (void)show{
    if(self.alpha != 1.0f || self.hudView.alpha != 1.0f) {
        //clear
        self.hudView.transform = CGAffineTransformIdentity;
        
        // Zoom HUD a little to make a nice appear / pop up animation
        self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1.3, 1.3);
        
        // Set initial values to handle iOS 7 (and above) UIToolbar which not answers well to hierarchy opacity change
        self.alpha = 0.0f;
        self.hudView.alpha = 0.0f;
        
        // Define blocks
        xy_weakify(self);
        __block void (^animationsBlock)(void) = ^{
            xy_strongify(self);
            
            if(self) {
                // Shrink HUD to finish pop up animation
                self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1/1.3f, 1/1.3f);
                self.alpha = 1.0f;
                self.hudView.alpha = 1.0f;
            }
        };
        
        __block void (^completionBlock)(void) = ^{
            xy_strongify(self);
            if(self) {
                // Check if we really achieved to show the HUD (<=> alpha values are applied)
                // and the change of these values has not been cancelled in between
                // e.g. due to a dismissal
                if(self.alpha == 1.0f && self.hudView.alpha == 1.0f){
                    
                }
            }
            
        };
        
        if (self.fadeInAnimationDuration > 0) {
            // Animate appearance
            [UIView animateWithDuration:self.fadeInAnimationDuration
                                  delay:0
                                options:(UIViewAnimationOptions) (UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState)
                             animations:^{
                                 animationsBlock();
                             } completion:^(BOOL finished) {
                                 completionBlock();
                             }];
        } else {
            animationsBlock();
            completionBlock();
        }
        
        // Inform iOS to redraw the view hierarchy
        [self setNeedsDisplay];
    }
}

- (void)dismiss {
    [self dismissWithDelay:0.0 completion:nil];
}

#pragma mark - Master dismiss methods(singleton / not singleton)

- (void)dismissWithDelay:(NSTimeInterval)delay completion:(XYProgressHUDDismissCompletion)completion {
    xy_weakify(self);
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        xy_strongify(self);
        
        if(self){
            // Reset activity count
            self.activityCount = 0;
            
            // Define blocks
            __block void (^animationsBlock)(void) = ^{
                self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1/1.3f, 1/1.3f);
                self.alpha = 0.0f;
                self.hudView.alpha = 0.0f;
            };
            
            __block void (^completionBlock)(void) = ^{
                // Check if we really achieved to dismiss the HUD (<=> alpha values are applied)
                // and the change of these values has not been cancelled in between
                // e.g. due to a new show
                if(self.alpha == 0.0f && self.hudView.alpha == 0.0f){
                    self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1.3f, 1.3f);
                    
                    // Clean up view hierarchy (overlays)
                    [self.overlayView removeFromSuperview];
                    [self.hudView removeFromSuperview];
                    [self removeFromSuperview];
                    
                    // Reset progress and cancel any running animation
                    [self cancelIndefiniteAnimatedViewAnimation];
                     
                    
                    // Tell the rootViewController to update the StatusBar appearance
                    UIViewController *rootController = [[UIApplication sharedApplication] keyWindow].rootViewController;
                    if([rootController respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                        [rootController setNeedsStatusBarAppearanceUpdate];
                    }
                    
                    // Run an (optional) completionHandler
                    if (completion) {
                        completion();
                    }
                    
                    if (self.dismissBlock) {
                        self.dismissBlock();
                    }
                }
            };
            
            if (self.fadeOutAnimationDuration > 0) {
                // Animate appearance
                [UIView animateWithDuration:self.fadeOutAnimationDuration
                                      delay:delay
                                    options:(UIViewAnimationOptions) (UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                                 animations:^{
                                     animationsBlock();
                                 } completion:^(BOOL finished) {
                                     completionBlock();
                                 }];
            } else {
                animationsBlock();
                completionBlock();
            }
            
            // Inform iOS to redraw the view hierarchy
            [self setNeedsDisplay];
        } else if (completion) {
            // Run an (optional) completionHandler
            completion();
        }
    }];
}

#pragma mark - Setters
+ (void)setMinimumDismissTimeInterval:(NSTimeInterval)interval {
    [self sharedView].minimumDismissTimeInterval = interval;
}

+ (void)setFadeInAnimationDuration:(NSTimeInterval)duration {
    [self sharedView].fadeInAnimationDuration = duration;
}

+ (void)setFadeOutAnimationDuration:(NSTimeInterval)duration {
    [self sharedView].fadeOutAnimationDuration = duration;
}

+ (void)setMaxSupportedWindowLevel:(UIWindowLevel)windowLevel {
    [self sharedView].maxSupportedWindowLevel = windowLevel;
}

+ (void)setBackgroundColor:(UIColor*)color{
    [self sharedView].backgroundColor = color;
}

+ (void)setForegroundColor:(UIColor*)color {
    [self sharedView].foregroundColor = color;
}

+ (void)setBackgroundLayerColor:(UIColor*)color {
    [self sharedView].backgroundLayerColor = color;
}

+ (void)setMinimumSize:(CGSize)minimumSize {
    [self sharedView].minimumSize = minimumSize;
}

+ (void)setCornerRadius:(CGFloat)cornerRadius {
    [self sharedView].cornerRadius = cornerRadius;
}

+ (void)setRingThickness:(CGFloat)ringThickness {
    [self sharedView].ringThickness = ringThickness;
}

+ (void)setRingRadius:(CGFloat)radius {
    [self sharedView].ringRadius = radius;
}

+ (void)setDefaultStyle:(XYProgressHUDStyle)style{
    [self sharedView].defaultStyle = style;
}

+ (void)setDefaultContentStyle:(XYProgressHUDContentStyle)contentStyle{
    [self sharedView].defaultContentStyle = contentStyle;
}

+ (void)setFont:(UIFont *)font{
    [self sharedView].font = font;
}

#pragma mark - UIAppearance setters
- (void)setMinimumDismissTimeInterval:(NSTimeInterval)minimumDismissTimeInterval {
    if (!_isInitializing) _minimumDismissTimeInterval = minimumDismissTimeInterval;
}

- (void)setFadeInAnimationDuration:(NSTimeInterval)duration {
    if (!_isInitializing) _fadeInAnimationDuration = duration;
}

- (void)setFadeOutAnimationDuration:(NSTimeInterval)duration  {
    if (!_isInitializing) _fadeOutAnimationDuration = duration;
}

- (void)setMaxSupportedWindowLevel:(UIWindowLevel)maxSupportedWindowLevel {
    if (!_isInitializing) _maxSupportedWindowLevel = maxSupportedWindowLevel;
}

- (void)setBackgroundColor:(UIColor*)color {
    if (!_isInitializing) _backgroundColor = color;
}

- (void)setForegroundColor:(UIColor*)color {
    if (!_isInitializing) _foregroundColor = color;
}

- (void)setBackgroundLayerColor:(UIColor*)color {
    if (!_isInitializing) _backgroundLayerColor = color;
}

- (void)setMinimumSize:(CGSize)minimumSize {
    if (!_isInitializing) _minimumSize = minimumSize;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    if (!_isInitializing) _cornerRadius = cornerRadius;
}

- (void)setRingThickness:(CGFloat)ringThickness {
    if (!_isInitializing) _ringThickness = ringThickness;
}

- (void)setRingRadius:(CGFloat)ringRadius {
    if (!_isInitializing) _ringRadius = ringRadius;
}

- (void)setDefaultStyle:(XYProgressHUDStyle)style {
    if (!_isInitializing) _defaultStyle = style;
}

- (void)setDefaultContentStyle:(XYProgressHUDContentStyle)contentStyle {
    if (!_isInitializing) _defaultContentStyle = contentStyle;
}

- (void)setFont:(UIFont *)font{
    if (!_isInitializing) _font = font;
}

#pragma mark - Event handling
- (void)overlayViewDidReceiveTouchEvent:(id)sender forEvent:(UIEvent*)event {
    [[NSNotificationCenter defaultCenter] postNotificationName:XYProgressHUDDidReceiveTouchEventNotification
                                                        object:self
                                                      userInfo:nil];
    
    UITouch *touch = event.allTouches.anyObject;
    CGPoint touchLocation = [touch locationInView:self];
    
    if(CGRectContainsPoint(self.hudView.frame, touchLocation)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:XYProgressHUDDidTouchDownInsideNotification
                                                            object:self
                                                          userInfo:nil];
    }
}

#pragma mark - Getters
- (UIColor*)backgroundColorForStyle {
    if(self.defaultStyle == XYProgressHUDStyleLight) {
        return [UIColor whiteColor];
    } else if(self.defaultStyle == XYProgressHUDStyleDark) {
        return [UIColor blackColor];
    } else {
        return self.backgroundColor;
    }
}

- (UIColor*)foregroundColorForStyle {
    if(self.defaultStyle == XYProgressHUDStyleLight) {
        return [UIColor blackColor];
    } else if(self.defaultStyle == XYProgressHUDStyleDark) {
        return [UIColor whiteColor];
    } else {
        return self.foregroundColor;
    }
}

#pragma mark - Lazy load
- (UIView *)hudView{
    if (!_hudView) {
        _hudView = [[UIView alloc] initWithFrame:CGRectZero];
        _hudView.layer.masksToBounds = YES;
        _hudView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    }
    
    // Update styling
    _hudView.layer.cornerRadius = self.cornerRadius;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    // On iOS 8, the background color is set via a UIVisualEffectsView, see updateBlurBounds:
    _hudView.backgroundColor = self.defaultStyle == XYProgressHUDStyleCustom ? self.backgroundColor : [UIColor clearColor];
#else
    _hudView.backgroundColor = self.backgroundColorForStyle;
#endif
    return _hudView;
}

- (UIControl*)overlayView {
    if(!_overlayView) {
        _overlayView = [[UIControl alloc] init];
        _overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _overlayView.backgroundColor = [UIColor clearColor];
        [_overlayView addTarget:self action:@selector(overlayViewDidReceiveTouchEvent:forEvent:) forControlEvents:UIControlEventTouchDown];
    }
    
//#warning t
    _overlayView.enabled = NO;
    
    // Update frame
    CGRect windowBounds = [[[UIApplication sharedApplication] delegate] window].bounds;
    _overlayView.frame = windowBounds;
    return _overlayView;
}

- (UILabel*)statusLabel {
    if(!_statusLabel) {
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _statusLabel.backgroundColor = [UIColor clearColor];
        _statusLabel.adjustsFontSizeToFitWidth = YES;
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        _statusLabel.numberOfLines = 0;
    }
    
    /*
    if(!_statusLabel.superview) {
        [self.hudView addSubview:_statusLabel];
    }
     */
    
    // Update styling
    _statusLabel.textColor = self.foregroundColorForStyle;
    _statusLabel.font = self.font;
    
    return _statusLabel;
}

- (UIView*)indefiniteAnimatedView {
    if(_indefiniteAnimatedView && ![_indefiniteAnimatedView isKindOfClass:[XYIndefiniteAnimatedImageView class]]){
        [_indefiniteAnimatedView removeFromSuperview];
        _indefiniteAnimatedView = nil;
    }
    
    if(!_indefiniteAnimatedView){
        _indefiniteAnimatedView = [[XYIndefiniteAnimatedImageView alloc] initWithFrame:CGRectZero];
    }
    
    [_indefiniteAnimatedView sizeToFit];
    
    return _indefiniteAnimatedView;
}
@end
