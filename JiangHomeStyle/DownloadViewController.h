//
//  DownloadViewController.h
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-12-9.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MJPopupDelegate;

@interface DownloadViewController : UIViewController
{
    UIButton* closeBtn;
    UIProgressView *musicProgressView;
    UIProgressView *landscapeProgressView;
    UIProgressView *humanityProgressView;
    UIProgressView *storyProgressView;
    UIProgressView *communityProgressView;
    UILabel *musicLabel;
    UILabel *landscapeLabel;
    UILabel *humanityLabel;
    UILabel *storyLabel;
    UILabel *communityLabel;
    NSMutableArray *musicArray;
    
}
@property (weak, nonatomic) id<MJPopupDelegate> delegate;

@end

@protocol MJPopupDelegate <NSObject>

@optional
- (void)closeButtonClicked;

@end