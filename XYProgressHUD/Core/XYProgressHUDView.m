//
//  XYProgressHUDView.m
//  XYProgressHUD
//
//  Created by wuw on 2018/3/16.
//  Copyright © 2018年 wuw. All rights reserved.
//

#import "XYProgressHUDView.h"
#import "XYProgressHUDManager.h"
#import "XYIndefiniteAnimatedImageView.h"
#define xy_weakify(var) __weak typeof(var) XYWeak_##var = var;
#define xy_strongify(var) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong typeof(var) var = XYWeak_##var; \
_Pragma("clang diagnostic pop")



@interface XYProgressHUDView (){
    BOOL _isInitializing;
}

@property (nonatomic, strong) UIView *hudView;

@property (nonatomic, strong) UILabel *statusLabel;

@property (nonatomic, strong) UIControl *overlayView;

@property (nonatomic, strong) UIView *indefiniteAnimatedView;

@property (nonatomic, strong) NSTimer *fadeOutTimer;

@property (nonatomic, readwrite) NSUInteger activityCount;

@end

@implementation XYProgressHUDView

#pragma mark - Singleton
+ (instancetype)sharedView {
    static dispatch_once_t once;
    static XYProgressHUDView *sharedView;
    dispatch_once(&once, ^{ sharedView = [[self alloc] initWithFrame:[[[UIApplication sharedApplication] delegate] window].bounds]; });
    
    return sharedView;
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

- (void)_updateViewHierarchy{
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

- (void)_updateHUDFrame{
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
//        [self updateBlurBounds];
        
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
//        [self updateBlurBounds];
        
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
//        [self updateBlurBounds];
        
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

- (void)dismiss{
    [self dismissWithDelay:0.0 completion:nil];
}

- (void)dismissWithDelay:(NSTimeInterval)delay completion:(XYProgressHUDDismissCompletion)completion {
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
            
            /* Reset progress and cancel any running animation
            [self cancelIndefiniteAnimatedViewAnimation];
            */
            
            // Tell the rootViewController to update the StatusBar appearance
            UIViewController *rootController = [[UIApplication sharedApplication] keyWindow].rootViewController;
            if([rootController respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                [rootController setNeedsStatusBarAppearanceUpdate];
            }
            
            // Run an (optional) completionHandler
            if (completion) {
                completion();
            }
            
            /*
            if (self.dismissBlock) {
                self.dismissBlock();
            }
             */
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

#pragma mark - Public
- (void)showStatus:(NSString *)status isUsingLoading:(BOOL)isUsingLoading duration:(NSTimeInterval)duration{
#warning 待定
    self.statusLabel.text = status;
    self.defaultContentStyle = XYProgressHUDContentStyleStatus;
    
    [self _updateViewHierarchy];
    
    [self.hudView addSubview:self.statusLabel];
    [self _updateHUDFrame];
    [self show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismiss];
    });
}

#pragma mark - lazy load
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
