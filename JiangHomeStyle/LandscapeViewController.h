//
//  LandscapeViewController.h
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-8-29.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "googleAnalytics/GAI.h"

@interface LandscapeViewController : GAITrackedViewController<UIScrollViewDelegate>
{
    UIScrollView *landscapeScrollView;
    NSMutableDictionary *muDistionary;
    int currentPage;
    int countPage;
}

@property (weak, nonatomic) IBOutlet UIView *landscapeBtmBgView;
@property (strong, nonatomic) IBOutlet UIScrollView *landscapeScrollView;

@end
