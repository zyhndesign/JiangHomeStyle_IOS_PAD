//
//  PopupDetailViewController.h
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-9-4.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "googleAnalytics/GAI.h"

@protocol MJPopupDelegate;

@interface PopupDetailViewController : GAITrackedViewController
{
    NSString *serverID;
    UIButton *backBtn;
    UIWebView *webView;
    UIImageView *aniLayer1;
    UIImageView *aniLayer2;
}
@property (strong, nonatomic) UIWebView *webView;
@property (weak, nonatomic) id<MJPopupDelegate> delegate;
@property (strong, nonatomic) UIButton *backBtn;
@property (strong,nonatomic) NSString *serverID;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andParams:(NSString *)serverID;
@end

@protocol MJPopupDelegate <NSObject>

@optional
- (void)closeButtonClicked;

@end