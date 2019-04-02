//
//  ZHImageView.m
//  ZHImageViewDemo
//
//  Created by 郑晗 on 2017/5/25.
//  Copyright © 2017年 zhenghan. All rights reserved.
//

#import "ZHImageView.h"
#import <Masonry/Masonry.h>
#import <YYWebImage/YYWebImage.h>
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width//屏幕宽度
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height//屏幕高度

@interface ZHImageView()

@property (nonatomic ,strong)UIImageView *imageV;

@end

@implementation ZHImageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.delegate = self;
        self.minimumZoomScale = 1;
        self.maximumZoomScale = 3;
        
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        [self setupUIAndTap];
    }
    return self;
}

- (void)setupUIAndTap
{
    [self addSubview:self.imageV];
    
    //添加手势
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    UILongPressGestureRecognizer *longTap =[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongTap:)];
    
    longTap.minimumPressDuration = 1;
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    doubleTap.numberOfTapsRequired = 2;
    
    [self.imageV addGestureRecognizer:singleTap];
    [self.imageV addGestureRecognizer:doubleTap];
    [self.imageV addGestureRecognizer:longTap];
    //如果双击，则不响应单击事件
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    [self setZoomScale:1];
}
- (void)setImageUrl:(NSString *)imageUrl
{
    if (!imageUrl.length) {
        return;
    }
    _imageUrl = imageUrl;
    
    UIActivityIndicatorView *loadView = [[UIActivityIndicatorView alloc]init];
    loadView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    [loadView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [loadView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.imageV addSubview:loadView];
    
    [loadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.imageV);
    }];
    [loadView startAnimating];
    [self.imageV yy_setImageWithURL:[NSURL URLWithString:imageUrl] placeholder:nil options:(YYWebImageOptionSetImageWithFadeAnimation | YYWebImageOptionUseNSURLCache) completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        [loadView stopAnimating];
        self.imageV.image = image;
    }];
}
#pragma mark - UIScrollViewDelegate

//处理缩放和平移手势，必须需要实现委托下面两个方法
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageV;
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    //重新确定缩放完后的缩放倍数
    [scrollView setZoomScale:scale animated:NO];
}


#pragma mark - Touch the image

-(void)handleSingleTap:(UITapGestureRecognizer *)gestureRecognizer{
    
    if (gestureRecognizer.numberOfTapsRequired == 1) {
        
        if ([self.imageViewDelegate respondsToSelector:@selector(ZHImageViewDelegateSigleTap:)]) {
            [self.imageViewDelegate ZHImageViewDelegateSigleTap:self.imageUrl];
        }
    }
}

-(void)handleDoubleTap:(UITapGestureRecognizer *)gestureRecognizer{
    
    if (gestureRecognizer.numberOfTapsRequired == 2) {
        
        if(self.zoomScale == 1){
            float newScale = [self zoomScale] *2;
            CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
            [self zoomToRect:zoomRect animated:YES];
        }else{
            float newScale = [self zoomScale]/2;
            CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
            [self zoomToRect:zoomRect animated:YES];
        }
    }
}

- (void)handleLongTap:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([self.imageViewDelegate respondsToSelector:@selector(ZHImageViewDelegateLongTap:)]) {
        [self.imageViewDelegate ZHImageViewDelegateLongTap:self.imageUrl];
    }
}
#pragma mark - 缩放大小获取方法
-(CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center{
    
    CGRect zoomRect;
    //大小
    zoomRect.size.height = [self frame].size.height/scale;
    zoomRect.size.width = [self frame].size.width/scale;
    //原点
    zoomRect.origin.x = center.x - zoomRect.size.width/2;
    zoomRect.origin.y = center.y - zoomRect.size.height/2;
    return zoomRect;
}
#pragma mark - get方法

- (UIImageView *)imageV
{
    if (!_imageV) {
        _imageV = [[UIImageView alloc]initWithFrame:self.bounds];
        _imageV.userInteractionEnabled = YES;
        _imageV.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageV;
}


@end
