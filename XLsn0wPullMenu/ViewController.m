//
//  ViewController.m
//  XLsn0wPullMenu
//
//  Created by HL on 2018/8/2.
//  Copyright © 2018年 XL. All rights reserved.
//

#import "ViewController.h"
#import "XLsn0wPullMenu.h"
#import "XLsn0wPullMenuCell.h"
#import "XLsn0wPullMenuModel.h"
#import "NSObject+XLsn0wModel.h"

@interface ViewController () <XLsn0wPullMenuDelegate>

@property (weak, nonatomic) IBOutlet UIButton *pullBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    
   XLsn0wPullMenu* _menu = [[XLsn0wPullMenu alloc] init];
    [self.view addSubview:_menu];
    [_menu setFrame:CGRectMake(15, 185, 101, 34)];
    
    
    NSMutableArray *modelArray = [NSMutableArray array];
    NSArray *titles = @[@{@"title":@"1", @"selected":@0}, @{@"title":@"2", @"selected":@0}, @{@"title":@"3", @"selected":@1}, @{@"title":@"4", @"selected":@0}, @{@"title":@"5", @"selected":@0}, @{@"title":@"6", @"selected":@0},@{@"title":@"7", @"selected":@1},@{@"title":@"8", @"selected":@0}];
    for (NSDictionary *map in titles) {
        XLsn0wPullMenuModel *model = [XLsn0wPullMenuModel convertModelWithDictionary:map];
        [modelArray addObject:model];
    }
    
    [_menu setMenuTitles:modelArray rowHeight:30];
    _menu.delegate = self;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
