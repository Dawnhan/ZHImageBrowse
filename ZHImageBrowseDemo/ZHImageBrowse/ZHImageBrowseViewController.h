//
//  ZHImageBrowseViewController.h
//  ZHImageBrowseDemo
//
//  Created by 郑晗 on 2019/4/2.
//  Copyright © 2019年 郑晗. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZHImageBrowseViewController : UIViewController

@property (nonatomic ,strong)NSArray *dataSource;

@property (nonatomic ,assign)NSInteger defaultIndex;

@end

NS_ASSUME_NONNULL_END
