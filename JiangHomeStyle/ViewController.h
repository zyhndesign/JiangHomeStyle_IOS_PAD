//
//  ViewController.h
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-8-23.
//  Copyright (c) 2013年 工业设计中意（湖南）. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "googleAnalytics/GAI.h"

@class AudioStreamer;
@class HomeViewController;
@class LandscapeTopViewController;
@class LandscapeViewController;
@class HumanityViewController;
@class StoryViewController;
@class CommunityViewController;
@class HomeTopViewController;
@class HumanityTopViewController;
@class StoryTopViewController;
@class CommunityTopViewController;

@interface ViewController : GAITrackedViewController<UIScrollViewDelegate>
{
    UISlider *pregressSilder;
    UIButton *playBtn;
    UIButton *nextBtn;
    UILabel *musicAuthor;
    UILabel *musicName;
    
    UIButton *landscapeBtn;
    UIButton *humanityBtn;
    UIButton *storyBtn;
    UIButton * communityBtn;
    
    AudioStreamer *streamer;
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
    LandscapeViewController* landscapeBottomViewController;
    HumanityTopViewController* humanityTopViewController;
    HumanityViewController* humanityBottomViewController;
    StoryTopViewController* storyTopViewController;
    StoryViewController* storyBottomViewController;
    CommunityTopViewController* communityTopViewController;
    CommunityViewController* communityBottomViewController;
    
    UIScrollView *scrollView;
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

- (void)play;
- (void)stop;
@end
