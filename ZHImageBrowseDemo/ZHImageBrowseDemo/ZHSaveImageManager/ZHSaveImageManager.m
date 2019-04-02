//
//  ZHSaveImageManager.m
//  ZHImageViewDemo
//
//  Created by 郑晗 on 2019/3/22.
//  Copyright © 2019年 郑晗. All rights reserved.
//

#import "ZHSaveImageManager.h"
#import <Photos/Photos.h>
#import "UIView+Toast.h"

@implementation ZHSaveImageManager

#pragma mark -保存图片到相册

+ (void)saveTheImage:(nonnull UIImage *)image {
    
    PHAuthorizationStatus oldStatus = [PHPhotoLibrary authorizationStatus];
    // 检查用户访问权限
    // 如果用户还没有做出选择，会自动弹框
    // 如果之前已经做过选择，会直接执行block
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == PHAuthorizationStatusDenied ) { // 用户拒绝当前App访问权限
                if (oldStatus != PHAuthorizationStatusNotDetermined) {
                    //用户拒绝访问相册
                }
            } else if (status == PHAuthorizationStatusAuthorized) { // 用户允许当前App访问
                [ZHSaveImageManager saveImageIntoAlbum:image];
            } else if (status == PHAuthorizationStatusRestricted) { // 无法访问相册
                [[UIApplication sharedApplication].keyWindow makeToast:@"无法访问相册"];
            }
        });
    }];
}

+ (void)saveImageIntoAlbum:(nonnull UIImage *)image  {
    
    // 1.先保存图片到相机胶卷
    PHFetchResult<PHAsset *> *createdAssets = [self createdAssets:image];
    if (createdAssets == nil) {
        [[UIApplication sharedApplication].keyWindow makeToast:@"保存图片失败"];
    }
    
    // 2.拥有一个自定义相册
    PHAssetCollection * assetCollection = self.createCollection;
    if (assetCollection == nil) {
        [[UIApplication sharedApplication].keyWindow makeToast:@"创建相册失败"];
    }
    
    // 3.将刚才保存到相机胶卷里面的图片引用到自定义相册
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary]performChangesAndWait:^{
        PHAssetCollectionChangeRequest *requtes = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
        
        [requtes insertAssets:createdAssets atIndexes:[NSIndexSet indexSetWithIndex:0]];
        
    } error:&error];
    if (error) {
        [[UIApplication sharedApplication].keyWindow makeToast:@"保存图片失败"];
    } else {
        [[UIApplication sharedApplication].keyWindow makeToast:@"图片保存成功"];

    }
}

#pragma mark - 获取当前App对应的自定义相册

+ (PHAssetCollection*)createCollection {
    //获取App名字
    NSString *title = [NSBundle mainBundle].infoDictionary[(__bridge NSString*)kCFBundleNameKey];
    
    //获取所有自定义相册
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    //查询当前App对应的自定义相册
    for (PHAssetCollection *collection in collections) {
        if ([collection.localizedTitle isEqualToString:title]) {
            return collection;
        }
    }
    
    //如果当前对应的app相册没有被创建
    NSError *error = nil;
    __block NSString *createCollectionID = nil;
    [[PHPhotoLibrary sharedPhotoLibrary]performChangesAndWait:^{
        
        //创建一个自定义相册
        createCollectionID = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title].placeholderForCreatedAssetCollection.localIdentifier;
        
    } error:&error];
    
    if (error) {
        //创建相册失败
        return nil;
    }
    //根据唯一标识，获得刚才创建的相册
    PHAssetCollection *createCollection = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createCollectionID] options:nil].firstObject;
    return createCollection;
}

#pragma mark -获取相片
+ (PHFetchResult<PHAsset *> *)createdAssets:(nonnull UIImage *)image {
    // 同步执行修改操作
    NSError *error = nil;
    __block NSString *assertId = nil;
    // 保存图片到相机胶卷
    [[PHPhotoLibrary sharedPhotoLibrary]performChangesAndWait:^{
        assertId =  [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } error:&error];
    if (error) {
        //保存失败
        return nil;
    }
    // 获取相片
    PHFetchResult<PHAsset *> *createdAssets = [PHAsset fetchAssetsWithLocalIdentifiers:@[assertId] options:nil];
    return createdAssets;
}
@end
