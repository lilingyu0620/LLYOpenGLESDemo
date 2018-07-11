//
//  ViewController.m
//  ShowImageShader
//
//  Created by lly on 2018/7/11.
//  Copyright © 2018年 lly. All rights reserved.
//

#import "ViewController.h"
#import "ShowView.h"

@interface ViewController ()

@property (nonatomic, strong) ShowView *showView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.showView = [[ShowView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.showView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
