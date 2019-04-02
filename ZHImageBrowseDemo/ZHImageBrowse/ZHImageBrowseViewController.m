//
//  ZHImageBrowseViewController.m
//  ZHImageBrowseDemo
//
//  Created by 郑晗 on 2019/4/2.
//  Copyright © 2019年 郑晗. All rights reserved.
//

#import "ZHImageBrowseViewController.h"
#import <Masonry/Masonry.h>
#import "ZHImageView/ZHImageView.h"
#import "ZHSaveImageManager.h"
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width//屏幕宽度
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height//屏幕高度

@interface ZHImageBrowseViewController ()<UIScrollViewDelegate,ZHImageViewDelegate>

@property (nonatomic, strong)UIScrollView *scrollView;

@property (nonatomic, strong) UILabel *indexLab;

@end

@implementation ZHImageBrowseViewController

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.view.backgroundColor = [UIColor blackColor];
    if (self.dataSource.count) {
        [self setupUI];
        [self setupImages];
    }
}

- (void)setupUI
{
    [self.view addSubview:self.scrollView];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * self.dataSource.count, SCREEN_HEIGHT);
    for (int i = 0 ; i < self.dataSource.count; i++) {
        
        ZHImageView *imageV = [[ZHImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH * i, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        imageV.contentMode = UIViewContentModeScaleAspectFit;
        imageV.clipsToBounds = YES;
        imageV.tag = i + 1;
        imageV.imageViewDelegate = self;
        [self.scrollView addSubview:imageV];
        
        UIActivityIndicatorView *loadView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH * i, 0, 100, 100)];
        loadView.tag = 10000+i;
        loadView.center = CGPointMake(SCREEN_WIDTH/2 + SCREEN_WIDTH * i, SCREEN_HEIGHT/2);
        [loadView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [loadView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.scrollView addSubview:loadView];
        
        
    }
    
    self.scrollView.contentOffset = CGPointMake(SCREEN_WIDTH * self.defaultIndex, 0);
    
    self.indexLab = [[UILabel alloc] init];
    self.indexLab.textColor = [UIColor whiteColor];
    self.indexLab.font = [UIFont boldSystemFontOfSize:24];
    self.indexLab.textAlignment = NSTextAlignmentCenter;
    [self.indexLab sizeToFit];
    self.indexLab.text = [NSString stringWithFormat:@"%ld/%ld",self.defaultIndex + 1,self.dataSource.count];
    [self.view addSubview:self.indexLab];
    [self.indexLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-30);
        make.centerX.equalTo(self.view);
    }];
}

- (void)setupImages
{
    NSInteger order = self.scrollView.contentOffset.x / SCREEN_WIDTH;
    if (order == 0) {
        [self initImage:order];
        if (self.dataSource.count > 1) {
            [self initImage:order + 1];
        }
        
    }else if (order == self.dataSource.count - 1){
        [self initImage:order];
        [self initImage:order - 1];
    }else{
        [self initImage:order];
        [self initImage:order + 1];
        [self initImage:order - 1];
        
    }
    
}
- (void)initImage:(NSInteger)order
{
    ZHImageView  *imageV = (ZHImageView *)[self.view viewWithTag:order + 1];
    
    if (imageV.isLoaded) {
        
        return;
    }
    
    imageV.imageUrl = self.dataSource[order];
    
    imageV.isLoaded = YES;
    
}

#pragma mark ---------------------- ZHImageViewDelegate ----------------------
- (void)ZHImageViewDelegateSigleTap:(NSString *)imageUrl
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)ZHImageViewDelegateLongTap:(NSString *)imageUrl
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"下载图片" style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction *action) {
                                               [ZHSaveImageManager saveTheImage:[UIImage imageNamed:imageUrl]];
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction *action) {
                                                
                                                NSLog(@"点击了确定按钮");
                                            }]];
    
    [self presentViewController:alert animated:true completion:nil];
}

/**
 是否隐藏通知栏

 @return 返回YES隐藏，图片展示效果更佳
 */
- (BOOL)prefersStatusBarHidden {
    return YES;
}
#pragma mark ---------------------- UIScrollViewDelegate ----------------------
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self isInteger:scrollView.contentOffset.x]) {
        if (!((int)scrollView.contentOffset.x % (int)SCREEN_WIDTH)) {
            NSInteger index = scrollView.contentOffset.x/SCREEN_WIDTH;
            self.indexLab.text = [NSString stringWithFormat:@"%ld/%ld",index + 1,self.dataSource.count];
            self.defaultIndex = index;
            [self setupImages];
        }
    }
}
- (BOOL)isInteger:(CGFloat)number
{
    float temp = (int)number;
    if(temp != number){
        return NO;
    }
    return YES;
}
#pragma mark ---------------------- 懒加载 ----------------------
- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]init];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.bounces = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.minimumZoomScale = 1;
        _scrollView.maximumZoomScale = 3;
        
    }
    return _scrollView;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
