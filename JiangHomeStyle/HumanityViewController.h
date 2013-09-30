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
}
@property (strong, nonatomic) IBOutlet UIScrollView *humanityScrollView;
@end
