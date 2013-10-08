//
//  CommunityViewController.h
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-8-29.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "googleAnalytics/GAI.h"

@interface CommunityViewController : GAITrackedViewController<UIScrollViewDelegate>
{
    UIScrollView *communityScrollView;
    NSMutableDictionary *muDistionary;
    int currentPage;
    int countPage;
    BOOL pageControlBeingUsed;
}
@property (strong, nonatomic) IBOutlet UIScrollView *communityScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *communityPageControl;
- (IBAction)pageChanged:(id)sender;

@end
