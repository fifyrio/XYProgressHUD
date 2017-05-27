//
//  AppDelegate.m
//  XYProgressHUD
//
//  Created by wuw on 2017/5/19.
//  Copyright © 2017年 wuw. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    ViewController* mainVC = [[ViewController alloc] init];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:mainVC];
    
    self.window.rootViewController = navVC;
    return YES;
}


@end
