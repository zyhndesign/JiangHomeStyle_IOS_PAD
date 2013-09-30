//
//  HomeTopViewController.h
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-9-6.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "googleAnalytics/GAI.h"
#import "PopupDetailViewController.h"

@interface HomeTopViewController : GAITrackedViewController<MJPopupDelegate>
{
    MPMoviePlayerViewController *mp;
    MPMoviePlayerController *player;
    UIImageView* homeTopImgBg;
    UILabel* homeTopTitle;
    UILabel* homeTopTime;
}
@end