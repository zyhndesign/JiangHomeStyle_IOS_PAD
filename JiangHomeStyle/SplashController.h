//
//  SplashController.h
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-8-28.
//  Copyright (c) 2013年 工业设计中意（湖南）. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "googleAnalytics/GAI.h"

@class ViewController;

@interface SplashController : GAITrackedViewController
{
    ViewController *viewController;
}
@end
