//
//  ZHImageView.h
//  ZHImageViewDemo
//
//  Created by EDZ on 2017/5/25.
//  Copyright © 2017年 zhenghan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZHImageViewDelegate <NSObject>

@optional

/**
 点击代理事件
 */
- (void)ZHImageViewDelegateSigleTap:(NSString *)imageUrl;

@optional

/**
 长按代理事件
 */
- (void)ZHImageViewDelegateLongTap:(NSString *)imageUrl;


@end

@interface ZHImageView : UIScrollView<UIScrollViewDelegate>

/**
 代理
 */
@property (nonatomic ,assign)id<ZHImageViewDelegate> imageViewDelegate;

/**
 图片地址
 */
@property (nonatomic ,copy)NSString *imageUrl;
/**
 是否加载过
 */
@property (nonatomic ,assign)BOOL isLoaded;

@end
