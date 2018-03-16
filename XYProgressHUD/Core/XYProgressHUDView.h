//
//  XYProgressHUDView.h
//  XYProgressHUD
//
//  Created by wuw on 2018/3/16.
//  Copyright © 2018年 wuw. All rights reserved.
//

#import <UIKit/UIKit.h>

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

@interface XYProgressHUDView : UIView

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

+ (instancetype)sharedView;

- (void)showStatus:(NSString *)status isUsingLoading:(BOOL)isUsingLoading duration:(NSTimeInterval)duration;

@end
