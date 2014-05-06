//
//  SuperColumnViewController.h
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 14-5-5.
//  Copyright (c) 2014年 cidesign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupDetailViewController.h"

@class GAITrackedViewController;

@interface SuperColumnViewController : GAITrackedViewController<MJPopupDelegate>
{

}

/**
 *  异步加载ScrollView页面中的缩略图
 *
 *  @param muDict 文件路径（网络／本地）
 *  @param uiImg  需要加载的UIImageView控件
 */
-(void) loadingImage:(NSMutableDictionary*) muDict andImageView:(UIImageView*) uiImg;

/**
 *  给指定的UIView对象加载该篇文章是否有视频的标示
 *
 *  @param view UIView对象
 */
-(void) addVideoImage:(UIView *)view;


@end
