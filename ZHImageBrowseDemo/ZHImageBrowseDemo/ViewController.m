//
//  ViewController.m
//  ZHImageBrowseDemo
//
//  Created by 郑晗 on 2019/4/2.
//  Copyright © 2019年 郑晗. All rights reserved.
//

#import "ViewController.h"
#import "ZHImageBrowseViewController.h"
@interface ViewController ()
- (IBAction)browseAction:(UIButton *)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (IBAction)browseAction:(UIButton *)sender {
    NSArray *array = @[@"http://img5.adesk.com/5c6a9fc9e7bce75e2ae8e8cc?imageMogr2/thumbnail/!720x1280r/gravity/Center/crop/720x1280",
                       @"http://img5.adesk.com/5c6bb88ae7bce75defa5cf3c?imageMogr2/thumbnail/!720x1280r/gravity/Center/crop/720x1280",
                       @"http://img5.adesk.com/5c6a9fc9e7bce75ea7b30245?imageMogr2/thumbnail/!720x1280r/gravity/Center/crop/720x1280",
                       @"http://img5.adesk.com/5c95a0ace7bce75e0214c4ec?imageMogr2/thumbnail/!720x1280r/gravity/Center/crop/720x1280"];
    ZHImageBrowseViewController *vc = [[ZHImageBrowseViewController alloc]init];
    vc.dataSource = array;
    [self presentViewController:vc animated:YES completion:nil];
}
@end
