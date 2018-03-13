//
//  ViewController.m
//  XYProgressHUD
//
//  Created by wuw on 2017/5/19.
//  Copyright © 2017年 wuw. All rights reserved.
//

#import "ViewController.h"
#import "ViewCell.h"
#import "HeaderView.h"
#import "XYProgressHUD.h"

#import "XYProgressHUDManager.h"

static NSString * const kViewCell = @"ViewCell";

static NSString * const kHeaderView = @"HeaderView";

static NSString * const kStatus = @"Hello Will";

static NSTimeInterval const kDuration = 3.0;

@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, copy) NSArray *dataArray;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segementControl;

@property (nonatomic) XYSegementType currentSegementType;

@property (nonatomic) XYProgressHUDStyle hudStyle;

@end

@implementation ViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    [self setupData];
    [self setupSubviews];
}

#pragma mark - Init
- (void)setupData{
    NSArray *notSingletonArray = @[
                                   @{
                                       @"header":@"提示：Not singleton用于依次显示多个HUD的场景,采用FIFO(先进先出)策略",
                                       @"data":@[],
                                       },
                                   @{
                                       @"header":@"显示单个HUD",
                                       @"data":@[@"showStatus", @"showStatus:duration", @"showLoadingWithDuration", @"showLoadingWithDuration:status"],
                                       },
                                   @{
                                       @"header":@"显示多个HUD",
                                       @"data":@[@"showStatus->showStatus", @"showLoading->showStatus", @"showLoading->showLoading", @"showLoadingStatus->showStatus"],
                                       },
                                   ];
    
    NSArray *singletonArray = @[
                                @{
                                    @"header":@"提示：Singleton用于显示单个HUD的场景，如果多个HUD同时显示，会起冲突",
                                    @"data":@[],
                                    },
                                @{
                                    @"header":@"显示单个HUD并自动关闭",
                                    @"data":@[@"showStatus", @"showStatus:duration", @"showLoadingWithDuration", @"showLoadingWithDuration:status"],
                                    },
                                @{
                                    @"header":@"显示单个HUD并手动关闭",
                                    @"data":@[@"showLoadingIndefinitely", @"showLoadingIndefinitelyWithStatus", @"dismiss", @"dismissLoadingWithDelay", @"dismissLoadingWithDelay:completion"],
                                    },
                                ];
    
    self.dataArray = @[notSingletonArray, singletonArray];
}

- (void)setupSubviews{
    [self.collectionView registerNib:[UINib nibWithNibName:kViewCell bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kViewCell];
    [self.collectionView registerNib:[UINib nibWithNibName:kHeaderView bundle:[NSBundle mainBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderView];
    
    [self.segementControl addTarget:self action:@selector(didClickSegmentedControlAction:)forControlEvents:UIControlEventValueChanged];
}

#pragma mark - 功能模块
- (void)didClickSegmentedControlAction:(UISegmentedControl *)segmentControl{
    self.currentSegementType = segmentControl.selectedSegmentIndex;
    [self.collectionView reloadData];
}
- (IBAction)didClickHUDStyle:(UISegmentedControl *)segmentControl {
    self.hudStyle = segmentControl.selectedSegmentIndex;
}

- (void)didClickItemInIndexpath:(NSIndexPath *)indexPath{
    switch (self.currentSegementType) {
        
        case XYSegementTypeNotSingleton:
        {
            switch (indexPath.section) {
                case 0:
                    break;
                case 1:
                {
                    switch (indexPath.row) {
                        case 0:
                        {
                            XYProgressHUD *hud = [XYProgressHUD initHUD];
                            hud.defaultStyle = self.hudStyle;
                            [hud fifo_showStatus:kStatus];
                        }
                            break;
                        case 1:
                        {
                            XYProgressHUD *hud = [XYProgressHUD initHUD];
                            hud.defaultStyle = self.hudStyle;
                            [hud fifo_showStatus:kStatus duration:kDuration];
                        }
                            break;
                        case 2:
                        {
                            XYProgressHUD *hud = [XYProgressHUD initHUD];
                            hud.defaultStyle = self.hudStyle;
                            [hud fifo_showLoadingWithDuration:kDuration];
                        }
                            break;
                        case 3:
                        {
                            XYProgressHUD *hud = [XYProgressHUD initHUD];
                            hud.defaultStyle = self.hudStyle;
                            [hud fifo_showLoadingWithDuration:kDuration status:kStatus];
                        }
                            break;
                        default:
                            break;
                    }
                }
                    break;
                case 2:
                {
                    switch (indexPath.row) {
                        case 0:
                        {
                            XYProgressHUD *hud_1 = [XYProgressHUD initHUD];
                            hud_1.defaultStyle = self.hudStyle;
                            [hud_1 fifo_showStatus:[NSString stringWithFormat:@"%@1",kStatus] duration:kDuration];
                            
                            XYProgressHUD *hud_2 = [XYProgressHUD initHUD];
                            hud_2.defaultStyle = self.hudStyle;
                            [hud_2 fifo_showStatus:[NSString stringWithFormat:@"%@2",kStatus] duration:kDuration];
                        }
                            break;
                        case 1:
                        {
                            XYProgressHUD *hud_1 = [XYProgressHUD initHUD];
                            hud_1.defaultStyle = self.hudStyle;
                            [hud_1 fifo_showLoadingWithDuration:kDuration];
                            
                            XYProgressHUD *hud_2 = [XYProgressHUD initHUD];
                            hud_2.defaultStyle = self.hudStyle;
                            [hud_2 fifo_showStatus:kStatus duration:kDuration];
                        }
                            break;
                        case 2:
                        {
                            XYProgressHUD *hud_1 = [XYProgressHUD initHUD];
                            hud_1.defaultStyle = self.hudStyle;
                            [hud_1 fifo_showLoadingWithDuration:kDuration];
                            
                            XYProgressHUD *hud_2 = [XYProgressHUD initHUD];
                            hud_2.defaultStyle = self.hudStyle;
                            [hud_2 fifo_showLoadingWithDuration:kDuration];
                        }
                            break;
                        case 3:
                        {
                            XYProgressHUD *hud_1 = [XYProgressHUD initHUD];
                            hud_1.defaultStyle = self.hudStyle;
                            [hud_1 fifo_showLoadingWithDuration:kDuration status:kStatus];
                            
                            XYProgressHUD *hud_2 = [XYProgressHUD initHUD];
                            hud_2.defaultStyle = self.hudStyle;
                            [hud_2 fifo_showStatus:kStatus duration:kDuration];
                        }
                            break;
                        default:
                            break;
                    }
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case XYSegementTypeSingleton:
        {
            switch (indexPath.section) {
                case 0:
                    break;
                case 1:
                {
                    switch (indexPath.row) {
                        case 0:
                        {
                            [XYProgressHUD setDefaultStyle:self.hudStyle];
                            [XYProgressHUD showStatus:kStatus];
                        }
                            break;
                        case 1:
                        {
                            [XYProgressHUD setDefaultStyle:self.hudStyle];
                            [XYProgressHUD showStatus:kStatus duration:kDuration];
                        }
                            break;
                        case 2:
                        {
                            [XYProgressHUD setDefaultStyle:self.hudStyle];
                            [XYProgressHUD showLoadingWithDuration:kDuration];
                        }
                            break;
                        case 3:
                        {
                            [XYProgressHUD setDefaultStyle:self.hudStyle];
                            [XYProgressHUD showLoadingWithDuration:kDuration status:kStatus];
                        }
                            break;
                        default:
                            break;
                    }
                }
                    break;
                case 2:
                {
                    switch (indexPath.row) {
                        case 0:
                        {
                            /*
                            [XYProgressHUD setDefaultStyle:XYProgressHUDStyleCustom];
                            [XYProgressHUD setFont:[UIFont systemFontOfSize:11]];
                            [XYProgressHUD setForegroundColor:[UIColor blueColor]];
                            [XYProgressHUD showStatus:@"Hello"];
                            */
                            [XYProgressHUD setDefaultStyle:self.hudStyle];
                            [XYProgressHUD showLoadingIndefinitely];
                            
                            
                        }
                            break;
                        case 1:
                        {
                            /*
                            [XYProgressHUD showStatus:@"fuck"];
                            */
                            
                            [XYProgressHUD setDefaultStyle:self.hudStyle];
                            [XYProgressHUD showLoadingIndefinitelyWithStatus:kStatus];
                          
                        }
                            break;
                        case 2:
                        {
                            [XYProgressHUD setDefaultStyle:self.hudStyle];
                            [XYProgressHUD dismissLoading];
                        }
                            break;
                        case 3:
                        {
                            [XYProgressHUD setDefaultStyle:self.hudStyle];
                            [XYProgressHUD dismissLoadingWithDelay:kDuration];
                        }
                            break;
                        case 4:
                        {
                            [XYProgressHUD setDefaultStyle:self.hudStyle];
                            [XYProgressHUD dismissLoadingWithDelay:kDuration completion:^{
                                NSLog(@"finished");
                            }];
                        }
                            break;
                        default:
                            break;
                    }
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    NSArray *data = self.dataArray[self.currentSegementType];
    return data.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSArray *data = self.dataArray[self.currentSegementType];
    NSDictionary *dic = data[section];
    NSArray *array = dic[@"data"];
    return array.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kViewCell forIndexPath:indexPath];
    NSArray *data = self.dataArray[self.currentSegementType];
    NSDictionary *dic = data[indexPath.section];
    NSArray *array = dic[@"data"];
    cell.titleLabel.text = array[indexPath.row];    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    HeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderView forIndexPath:indexPath];
    NSArray *data = self.dataArray[self.currentSegementType];
    NSDictionary *dic = data[indexPath.section];
    headerView.titleLabel.text = dic[@"header"];
    return headerView;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self didClickItemInIndexpath:indexPath];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(ScreenW, 58);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return CGSizeMake(ScreenW, 60);
    }else{
        return CGSizeMake(ScreenW, 44);
    }
    
}
- (IBAction)onclickRun:(id)sender {
//    dispatch_async([XYProgressHUDManager setterQueue], ^{
//        NSLog(@"1");
//        sleep(1);
//    });
//    
//    dispatch_async([XYProgressHUDManager setterQueue], ^{
//        NSLog(@"2");
//        sleep(1);
//    });
    [[XYProgressHUDManager manager] showHUD];
    [[XYProgressHUDManager manager] showHUD];
}

@end
