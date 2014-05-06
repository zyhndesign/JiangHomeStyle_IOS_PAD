//
//  ColumnViewController.h
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 14-5-6.
//  Copyright (c) 2014年 cidesign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperColumnViewController.h"

@interface ColumnViewController : SuperColumnViewController <UIScrollViewDelegate>
{
    UIScrollView *columnScrollView;
    NSMutableDictionary *muDistionary;
    int currentPage;
    int countPage;
    BOOL pageControlBeingUsed;
    UIPageControl *pageControl;
}

/**
 *  该方法在按页于横向滚动的的ScrollView控件中，动态的添加页面
 *
 *  @param pageNum 页编号
 */
-(void) addNewModelInScrollView:(int) pageNum;

/**
 *  该方法在按页于横向滚动的的ScrollView控件中，动态的删除页面，以节约内存
 *
 *  @param pageNum 页编号
 */
-(void) removeOldModelInScrollView:(int)pageNum;

/**
 *  该方法在ScrollView中，按照页编号动态加载不同布局的页
 *
 *  @param pageNum 页编号
 */
-(void) assemblePanel:(int) pageNum;

@end
