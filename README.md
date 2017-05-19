# XYProgressHUD

## 简介
A clean and multithreading progress HUD for your iOS
![Demo Overview](https://github.com/fifyrio/XYProgressHUD/blob/master/Screenshots/screenshots.gif)

## 如何使用

```
#import "XYProgressHUD.h"

```

###只显示一个HUD（单例）
#####提示：单例用于显示单个HUD的场景，如果多个HUD同时显示，会起冲突
* 显示文字，自动隐藏

```
[XYProgressHUD showStatus:@""];

```

* 显示文字以一定时间，自动隐藏

```
[XYProgressHUD showStatus:@"" duration:duration];

```

* 显示加载动画以一定时间，自动隐藏

```
[XYProgressHUD showLoadingWithDuration: duration];

```

* 显示加载动画和文字以一定时间，自动隐藏

```
[XYProgressHUD showLoadingWithDuration: duration status:@""];

```

* 显示加载动画不限时间，手动隐藏

```
[XYProgressHUD showLoadingIndefinitely];

```

* 显示加载动画和文字不限时间，手动隐藏

```
[XYProgressHUD showLoadingIndefinitelyWithStatus:@""];

```

* 隐藏

```
[XYProgressHUD dismissLoading];

```

* 隐藏以一定时间

```
[XYProgressHUD dismissLoadingWithDelay:duration];

```




###只显示一个HUD（非单例）
#####提示：非单例用于依次显示多个HUD的场景,采用FIFO(先进先出)策略

* 显示文字，自动隐藏

```
[[XYProgressHUD initHUD] fifo_showStatus:@""];

```

* 显示文字以一定时间，自动隐藏

```
[[XYProgressHUD initHUD] fifo_showStatus:@"" duration:duration];

```

* 显示加载动画以一定时间，自动隐藏

```
[[XYProgressHUD initHUD] fifo_showLoadingWithDuration:duration];

```

* 显示加载动画和文字以一定时间，自动隐藏

```
[[XYProgressHUD initHUD] fifo_showLoadingWithDuration:duration status:@""];

```


###同时显示多个HUD（非单例）
* showStatus->showStatus

```
XYProgressHUD *hud_1 = [XYProgressHUD initHUD];
[hud_1 fifo_showStatus:@"" duration:duration];
                            
XYProgressHUD *hud_2 = [XYProgressHUD initHUD];
[hud_2 fifo_showStatus:@"" duration:duration];

```

* showLoading->showStatus

```
XYProgressHUD *hud_1 = [XYProgressHUD initHUD];
[hud_1 fifo_showLoadingWithDuration:duration];

XYProgressHUD *hud_2 = [XYProgressHUD initHUD];
[hud_2 fifo_showStatus:@"" duration:duration];

```

* showLoading->showLoading

```
XYProgressHUD *hud_1 = [XYProgressHUD initHUD];
[hud_1 fifo_showLoadingWithDuration:duration];

XYProgressHUD *hud_2 = [XYProgressHUD initHUD];
[hud_2 fifo_showLoadingWithDuration:duration];

```

* showLoadingStatus->showStatus

```
XYProgressHUD *hud_1 = [XYProgressHUD initHUD];
[hud_1 fifo_showLoadingWithDuration:duration status:@""];

XYProgressHUD *hud_2 = [XYProgressHUD initHUD];
[hud_2 fifo_showStatus:@"" duration:duration];

```

##提示
###如何替换加载动画图片
直接修改Resources文件夹里的图片文件即可

##后期会做
* XYProgressHUD若没有设置tag自动设置
* 增加overlayview样式

## Release Versions
* v1.0
show with status/loading
