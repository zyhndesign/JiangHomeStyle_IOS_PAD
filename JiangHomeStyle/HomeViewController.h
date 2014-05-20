//
//  HomeViewController.h
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-8-29.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperColumnViewController.h"

@interface HomeViewController : SuperColumnViewController

@property (weak, nonatomic) IBOutlet UIView *recommandBgView;
@property (weak, nonatomic) IBOutlet UIControl *firstPanelView;
@property (weak, nonatomic) IBOutlet UIControl *secondPanelView;
@property (weak, nonatomic) IBOutlet UIControl *thirdPanelView;

@end
