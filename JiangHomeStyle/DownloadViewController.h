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
    UILabel *videoLabel;
    
    UIButton* musicCancelBtn;
    UIButton* landscapeCancelBtn;
    UIButton* humanityCancelBtn;
    UIButton* storyCancelBtn;
    UIButton* communityCancelBtn;
    UIButton* videoCancelBtn;
    
    UIImageView* musicImageView;
    UIImageView* landscapeImageView;
    UIImageView* humanityImageView;
    UIImageView* storyImageView;
    UIImageView* communityImageView;
    UIImageView* videoImageView;
    
    UILabel *musicResultLabel;
    UILabel *landscapeResultLabel;
    UILabel *humanityResultLabel;
    UILabel *storyResultLabel;
    UILabel *communityResultLabel;
    UILabel *videoResultLabel;
    
    NSMutableArray *musicArray;
    
    NSString *showUrl;
    NSString *videoUrl;
    NSString *fileSize;
    
    NSOperationQueue *musicQueue;
    NSOperationQueue *landscapeQueue;
    NSOperationQueue *humanityQueue;
    NSOperationQueue *storyQueue;
    NSOperationQueue *communityQueue;
    NSOperationQueue *videoQueue;
}
@property (weak, nonatomic) id<MJPopupDelegate> delegate;

//异步加载需要下载的音乐数据
-(void) loadMusicData;

//队列顺序异步下载音乐数据
-(void) downloadMusicFile:(NSArray *)dataArray;

//获取需要下载的类别数据，队列顺序异步进行下载
-(void) downloadDataByCategory:(int) category;

@end

@protocol MJPopupDelegate <NSObject>

@optional
- (void)closeButtonClicked;

@end