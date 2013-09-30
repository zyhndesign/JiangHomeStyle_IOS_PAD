//
//  StoryViewController.h
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-8-29.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "googleAnalytics/GAI.h"

@interface StoryViewController : GAITrackedViewController<UIScrollViewDelegate>
{
    NSMutableDictionary *muDistionary;
    UIScrollView *storyScrollView;
    int currentPage;
    int countPage;
}
@property (strong, nonatomic) IBOutlet UIScrollView *storyScrollView;
@end
