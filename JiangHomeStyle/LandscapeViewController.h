//
//  LandscapeViewController.h
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-8-29.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColumnViewController.h"

@interface LandscapeViewController : ColumnViewController
{
    
}

@property (weak, nonatomic) IBOutlet UIView *landscapeBtmBgView;

- (IBAction)changePage:(id)sender;

//加载视频标识
//-(void) addVideoImage:(UIView *)view;

//异步加载图片
//-(void) loadingImage:(NSMutableDictionary*) muDict andImageView:(UIImageView*) uiImg;
@end
