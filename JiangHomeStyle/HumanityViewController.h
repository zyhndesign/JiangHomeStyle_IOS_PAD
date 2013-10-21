//
//  HumanityViewController.h
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-8-29.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "googleAnalytics/GAI.h"

@interface HumanityViewController : GAITrackedViewController<UIScrollViewDelegate>
{
    NSMutableDictionary *muDistionary;
    UIScrollView *humanityScrollView;
    int currentPage;
    int countPage;
    BOOL pageControlBeingUsed;
}
@property (weak, nonatomic) IBOutlet UIPageControl *humanityPageContral;
@property (strong, nonatomic) IBOutlet UIScrollView *humanityScrollView;
- (IBAction)pageChanged:(id)sender;

//加载视频标识
-(void) addVideoImage:(UIView *)view;

//异步加载图片
-(void) loadingImage:(NSMutableDictionary*) muDict andImageView:(UIImageView*) uiImg;
@end
