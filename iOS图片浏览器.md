# iOS图片浏览器
介绍：
这是一个简单的图片浏览器Demo，支持多图浏览，预加载，图片的缩放和图片下载

使用：
ZHImageBrowseViewController *vc = [[ZHImageBrowseViewController alloc]init];
vc.dataSource = array;
vc.defaultIndex = 1;//默认初始浏览第几个图片，不写则从0开始
[self presentViewController:vc animated:YES completion:nil];

Demo https://github.com/Dawnhan/ZHImageBrowse