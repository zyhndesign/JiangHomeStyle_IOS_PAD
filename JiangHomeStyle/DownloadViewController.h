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
    UILabel *musicLabel;
    UILabel *landscapeLabel;
    UILabel *humanityLabel;
    UILabel *storyLabel;
    UILabel *communityLabel;
    
    UIButton* musicCancelBtn;
    UIButton* landscapeCancelBtn;
    UIButton* humanityCancelBtn;
    UIButton* storyCancelBtn;
    UIButton* communityCancelBtn;
    
    NSMutableArray *musicArray;
    
}
@property (weak, nonatomic) id<MJPopupDelegate> delegate;

//异步加载需要下载的音乐数据
-(void) loadMusicData;

//队列顺序异步下载音乐数据
-(void) downloadMusicFile:(NSArray *)dataArray;

//获取需要下载的风景数据，队列顺序异步进行下载
-(void) downloadLandscapeData;

//获取需要下载的人文数据，队列顺序异步进行下载
-(void) downloadHumanityData;

//获取需要下载的物语数据，队列顺序异步进行下载
-(void) downloadStoryData;

//获取需要下载的社区数据，队列顺序异步进行下载
-(void) downloadCommunityData;

@end

@protocol MJPopupDelegate <NSObject>

@optional
- (void)closeButtonClicked;

@end