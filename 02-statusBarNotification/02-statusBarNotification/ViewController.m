//
//  ViewController.m
//  02-statusBarNotification
//
//  Created by 乐校 on 16/4/14.
//  Copyright © 2016年 lexiao. All rights reserved.
//

#import "ViewController.h"
#import "JYStatusBar.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    btn.center = self.view.center;
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)btnClick
{
    JYStatusBar *bar = [JYStatusBar sharedView];
    bar.click = ^() {
        NSLog(@"点击了哎");
    };
    [bar showWithText:@"hello world,jy真是大好人啊，真好啊，好啊，好好学习天天向上，擦擦擦" barColor:[UIColor redColor] textColor:[UIColor greenColor]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
