//
//  XYProgressHUD.h
//  tableView
//
//  Created by wuw on 2017/4/19.
//  Copyright © 2017年 Kingnet. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^XYProgressHUDShowCompletion)(void);
typedef void (^XYProgressHUDDismissCompletion)(void);

typedef NS_ENUM(NSInteger, XYProgressHUDStyle) {
    XYProgressHUDStyleLight,        // default style, white HUD with black text, HUD background will be blurred on iOS 8 and above
    XYProgressHUDStyleDark,         // black HUD and white text, HUD background will be blurred on iOS 8 and above
    XYProgressHUDStyleCustom,        // uses the fore- and background color properties
//    XYProgressHUDStyleClear,//HUD background will be clear color
};

typedef NS_ENUM(NSInteger, XYProgressHUDContentStyle){
    XYProgressHUDContentStyleDefault,//有加载动画和提示文字
    XYProgressHUDContentStyleLoading,//只有加载动画
    XYProgressHUDContentStyleStatus,//只有提示文字
};

@interface XYProgressHUD : UIView

@property (assign, nonatomic) UIWindowLevel maxSupportedWindowLevel; // default is UIWindowLevelNormal

@property (assign, nonatomic) NSTimeInterval minimumDismissTimeInterval;            // default is 5.0 seconds

@property (assign, nonatomic) NSTimeInterval fadeInAnimationDuration;  // default is 0.3

@property (assign, nonatomic) NSTimeInterval fadeOutAnimationDuration; // default is 0.3


@property (strong, nonatomic) UIColor *backgroundColor UI_APPEARANCE_SELECTOR;      // default is [UIColor whiteColor]

@property (strong, nonatomic) UIColor *foregroundColor UI_APPEARANCE_SELECTOR;      // default is [UIColor blackColor]

@property (strong, nonatomic) UIColor *backgroundLayerColor UI_APPEARANCE_SELECTOR; // default is [UIColor colorWithWhite:0 alpha:0.4]

@property (assign, nonatomic) CGSize minimumSize UI_APPEARANCE_SELECTOR;            // default is CGSizeZero, can be used to avoid resizing for a larger message

@property (assign, nonatomic) CGFloat cornerRadius UI_APPEARANCE_SELECTOR;          // default is 14 pt

@property (assign, nonatomic) CGFloat ringThickness UI_APPEARANCE_SELECTOR;         // default is 2 pt

@property (assign, nonatomic) CGFloat ringRadius UI_APPEARANCE_SELECTOR;            // default is 18 pt

@property (strong, nonatomic) UIFont *font UI_APPEARANCE_SELECTOR;                  // default is [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]

@property (assign, nonatomic) XYProgressHUDStyle defaultStyle UI_APPEARANCE_SELECTOR;                   // default is XYProgressHUDStyleLight

@property (assign, nonatomic) XYProgressHUDContentStyle defaultContentStyle UI_APPEARANCE_SELECTOR;
// default is XYProgressHUDContentStyleDefault

#pragma mark - Init/Getter (not singleton)
+ (instancetype)initHUD;

+ (instancetype)initHUDWithTag:(NSInteger)tag;

/*
 *通过tag找到自定义的HUD
 */
+ (instancetype)getHUDWithTag:(NSInteger)tag;

/*
 *非单例情况下均默认使用先进先出策略(FIFO)
 */
#pragma mark - Show/Hide methods(not singleton)
/*
 *显示提示文字以默认时间
 */
- (void)fifo_showStatus:(NSString *)status;

/*
 *显示提示文字以一定时间
 */
- (void)fifo_showStatus:(NSString *)status duration:(NSTimeInterval)duration;

/*
 *显示加载动画以一定时间
 */
- (void)fifo_showLoadingWithDuration:(NSTimeInterval)duration;

/*
 *显示加载动画和提示文字以一定时间
 */
- (void)fifo_showLoadingWithDuration:(NSTimeInterval)duration status:(NSString *)status;

/*
 *显示加载动画，一直显示
 */
- (void)fifo_showLoadingIndefinitely;

/*
 *显示加载动画和提示文字，一直显示
 */
- (void)fifo_showLoadingIndefinitelyWithStatus:(NSString *)status;

/*
 *隐藏加载动画
 */
- (void)fifo_dismissLoading;

/*
 *隐藏加载动画以一定时间
 */
- (void)fifo_dismissLoadingWithDelay:(NSTimeInterval)delay;

/*
 *隐藏加载动画以一定时间，带回调函数
 */
- (void)fifo_dismissLoadingWithDelay:(NSTimeInterval)delay completion:(XYProgressHUDDismissCompletion)completion;

#pragma mark - Show /Hide methods(singleton)
/*
 *显示提示文字以默认时间
 */
+ (void)showStatus:(NSString *)status;

/*
 *显示提示文字以一定时间
 */
+ (void)showStatus:(NSString *)status duration:(NSTimeInterval)duration;

/*
 *显示加载动画以一定时间
 */
+ (void)showLoadingWithDuration:(NSTimeInterval)duration;

/*
 *显示加载动画和提示文字以一定时间
 */
+ (void)showLoadingWithDuration:(NSTimeInterval)duration status:(NSString *)status;

/*
 *显示加载动画，一直显示
 */
+ (void)showLoadingIndefinitely;

/*
 *显示加载动画和提示文字，一直显示
 */
+ (void)showLoadingIndefinitelyWithStatus:(NSString *)status;

/*
 *隐藏加载动画
 */
+ (void)dismissLoading;

/*
 *隐藏加载动画以一定时间
 */
+ (void)dismissLoadingWithDelay:(NSTimeInterval)delay;

/*
 *隐藏加载动画以一定时间，并带回调函数
 */
+ (void)dismissLoadingWithDelay:(NSTimeInterval)delay completion:(XYProgressHUDDismissCompletion)completion;

#pragma mark - Customized(singleton)
+ (void)setMinimumDismissTimeInterval:(NSTimeInterval)interval;

+ (void)setFadeInAnimationDuration:(NSTimeInterval)duration;

+ (void)setFadeOutAnimationDuration:(NSTimeInterval)duration;

+ (void)setMaxSupportedWindowLevel:(UIWindowLevel)windowLevel;

+ (void)setBackgroundColor:(UIColor*)color;

+ (void)setForegroundColor:(UIColor*)color;

+ (void)setBackgroundLayerColor:(UIColor*)color;

+ (void)setMinimumSize:(CGSize)minimumSize;

+ (void)setCornerRadius:(CGFloat)cornerRadius;

+ (void)setRingThickness:(CGFloat)ringThickness;

+ (void)setRingRadius:(CGFloat)radius;

+ (void)setDefaultStyle:(XYProgressHUDStyle)style;

+ (void)setDefaultContentStyle:(XYProgressHUDContentStyle)contentStyle;

+ (void)setFont:(UIFont *)font;

@end
