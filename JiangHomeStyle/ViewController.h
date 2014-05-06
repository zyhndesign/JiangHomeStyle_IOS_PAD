//
//  ViewController.h
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-8-23.
//  Copyright (c) 2013年 工业设计中意（湖南）. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "googleAnalytics/GAI.h"
#import <AVFoundation/AVAudioPlayer.h>

@class AudioStreamer;
@class HomeViewController;
@class LandscapeTopViewController;
@class HomeTopViewController;
@class HumanityTopViewController;
@class StoryTopViewController;
@class CommunityTopViewController;
@class MCProgressBarView;
@class FooterViewController;
@class ColumnViewController;

@interface ViewController : GAITrackedViewController<UIScrollViewDelegate>
{
    //UISlider *pregressSilder;
    UIButton *playBtn;
    UIButton *nextBtn;
    UILabel *musicAuthor;
    UILabel *musicName;
    
    UIButton *landscapeBtn;
    UIButton *humanityBtn;
    UIButton *storyBtn;
    UIButton * communityBtn;
    
    AudioStreamer *streamer;
    AVAudioPlayer *audioPlayer;
    
    NSURL *url;
    NSTimer *timer;
    int currentMusicNum;
    NSMutableArray *musicArray;
    
    int landscapeYValue;
    int humanityYValue;
    int storyYValue;
    int communityYValue;
    
    HomeTopViewController* homeTopViewController;
    HomeViewController* homeBottomViewController;
    LandscapeTopViewController* landscapeTopViewController;
    ColumnViewController* landscapeBottomViewController;
    HumanityTopViewController* humanityTopViewController;
    ColumnViewController* humanityBottomViewController;
    StoryTopViewController* storyTopViewController;
    ColumnViewController* storyBottomViewController;
    CommunityTopViewController* communityTopViewController;
    ColumnViewController* communityBottomViewController;
    FooterViewController* footerViewController;
    
    UIScrollView *scrollView;
    
    MCProgressBarView *progressBarView;
    
    int isVideoToMusicPause; //纪录是否是因为视频播放引起暂停
}

@property (nonatomic, retain) AudioStreamer *streamer;
@property (nonatomic, retain) NSURL *url;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UIView *topView;

@property (strong, nonatomic) UISlider *pregressSilder;
@property (strong, nonatomic) UIButton *playBtn;
@property (strong, nonatomic) UIButton *nextBtn;
@property (strong, nonatomic) UILabel *musicAuthor;
@property (strong, nonatomic) UILabel *musicName;

@property (strong, nonatomic) UIButton *landscapeBtn;
@property (strong, nonatomic) UIButton *humanityBtn;
@property (strong, nonatomic) UIButton *storyBtn;
@property (strong, nonatomic) UIButton * communityBtn;

//========================================================================================
/* 音乐播放模块核心部分使用的是AudioPlayer和AudioStreamer库来完成，当播放已经离线的音乐是采用AudioPlayer
 * 来完成，播放在线的网络音乐则使用AudioStreamer来实现。在线播放主要解决可以边播放边缓冲。
 */

/**
 *  暂停播放音乐， 分别判断在streamer 和 audioPlayer 播放模式下，音乐是否在播放，如果在播放则完成暂停处理
 */
-(void)pauseMusic;

/**
 *  播放音乐，分别判断在streamer 和 audioPlayer 播放模式下进行启动
 */
-(void)playingMusic;

/**
 *  添加播放进度条控件
 *
 *  @param rect     进度条大小
 *  @param taperOff 是否要标示进度条初始值
 *  @param progress 进度值
 */
-(void)addProgressBarAtRect:(CGRect)rect
                   taperOff:(BOOL)taperOff
                   progress:(double)progress;

/**
 *  音乐播放时候的网络状态提醒，如果本地没有离线缓存音乐，则只能使用网路播放
 */
-(void) showPlayMusicTips;

/**
 *  设置播放按钮状态为暂停，加载暂停的图片
 */
-(void) setBtnPause;

/**
 *  设置播放按钮当前为播放状态，加载播放图片
 */
-(void) setBtnPlay;

/**
 *  更新播放进度条的值
 */
-(void)updateProgress;

/**
 *  播放下一首音乐
 *
 *  @param _currentMusicNum 播放序号
 */
-(void) playNextMusic:(int) _currentMusicNum;

/**
 *  播放音乐
 */
-(void)play;

/**
 *  停止播放
 */
-(void)stop;

/**
 *  播放下一首
 */
-(void) next;

/**
 *  从网络或者本地加载音乐数据
 */
-(void) loadMusicPlayMusic;

//==========================================================================================

/**
 *  设置导航按钮的状态，四个栏目
 *
 *  @param landBtnState     风景按钮的当前状态（Normal, Pressed）
 *  @param humanityBtnState 人文按钮的当前状态（Normal, Pressed）
 *  @param storyBtnState    物语按钮的当前状态（Normal, Pressed）
 *  @param communityState   社区按钮的当前状态（Normal, Pressed）
 */
-(void) setNavBtnSelectState:(BOOL)landBtnState
                    Humanity:(BOOL)humanityBtnState
                       Story:(BOOL)storyBtnState
                   Community:(BOOL)communityState;

/**
 *  设置导航按钮的状态
 *
 *  @param landscape 风景（True、False）
 *  @param humanity  人文（True、False）
 *  @param story     物语（True、False）
 *  @param community 社区（True、False）
 */
-(void) setNavBtnBackgroundLandscape:(BOOL)landscape
                            Humanity:(BOOL) humanity
                               Story:(BOOL) story
                           Community:(BOOL)community;

/**
 *  设置ScrollView的滚动条到风景栏目
 */
-(void) scrollViewLandscapeTo;

/**
 *  设置ScrollView的滚动条到物语栏目
 */
-(void) scrollViewStoryTo;

/**
 *  设置ScrollView的滚动条到人文栏目
 */
-(void) scrollViewHumanityTo;

/**
 *  设置ScrollView的滚动条到社区栏目
 */
-(void) scrollViewCommunityTo;

/**
 *  logo的点击事件
 */
-(void)logoOnClick;
@end
