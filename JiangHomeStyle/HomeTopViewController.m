//
//  HomeTopViewController.m
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-9-6.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import "HomeTopViewController.h"
#import "DBUtils.h"
#import "TimeUtil.h"
#import "MJPopup/UIViewController+MJPopupViewController.h"
#import "PopupDetailViewController.h"
#import "FileUtils.h"
#import <MediaPlayer/MediaPlayer.h>
#import "googleAnalytics/GAIDictionaryBuilder.h"

@implementation HomeTopViewController

extern DBUtils *db;
FileUtils *fileUtils;
PopupDetailViewController* detailViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.screenName = @"推荐文章界面";
    
    [[GAI sharedInstance].defaultTracker set:self.screenName
                                       value:@"HomeTopViewController Screen"];
    
    // Send the screen view.
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    fileUtils = [FileUtils new];
    [fileUtils createAppFilesDir];
    homeTopImgBg = (UIImageView *)[self.view  viewWithTag:203];
    homeTopTitle = (UILabel *)[self.view viewWithTag:201];
    homeTopTime = (UILabel *)[self.view viewWithTag:202];
        
    NSMutableArray *array = [db queryHeadline];
   
    if ([array count] > 0)
    {
        NSMutableDictionary *muDict = [array objectAtIndex:0];
        [homeTopTitle setText:[muDict objectForKey:@"title"]];
        [homeTopTime setText:[TimeUtil convertTimeFormat:[muDict objectForKey:@"timestamp"]]];
        
        //[homeTopTitle setValue:[muDict objectForKey:@"serverID"] forUndefinedKey:@"serverID"];
        self.view.accessibilityLabel = [muDict objectForKey:@"serverID"];
                
        //如果存在大图，则加载大背景图，并且需要判断是否为联播视频
        NSString* str = [muDict objectForKey:@"max_bg_img"];
        
        if ([str hasSuffix:@".mp4"])
        {
            
            NSString *path = [[[PATH_OF_DOCUMENT stringByAppendingPathComponent:@"articles"] stringByAppendingPathComponent:[muDict objectForKey:@"serverID"]] stringByAppendingPathComponent:@"bg.mp4"];
            
            
            if ([fileUtils fileISExist:path])
            {                
                NSURL *mp4Url = [NSURL fileURLWithPath:path];
                
                mp = [[MPMoviePlayerViewController alloc] initWithContentURL:mp4Url];
                mp.view.frame = CGRectMake(homeTopImgBg.frame.origin.x, 0.0, homeTopImgBg.frame.size.width, homeTopImgBg.frame.size.height);
                [self.view addSubview:mp.view];
                homeTopImgBg.hidden = YES;
                [self.view sendSubviewToBack:mp.view];
                player = [mp moviePlayer];
                [player setRepeatMode:MPMovieRepeatModeOne];
                mp.view.userInteractionEnabled = NO;
                player.shouldAutoplay = YES;
                player.controlStyle = MPMovieControlStyleNone;
                player.scalingMode = MPMovieScalingModeAspectFill;
                
                //[player setFullscreen:YES];
                [player play];
                
                NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                [center addObserver:self selector:@selector(reActivityAudio) name:@"HOME_PAGE_VIDEO" object:nil];
                
            }
        }
        else if([str hasPrefix:@"bg.jpg"])
        {
            NSString *path = [[[PATH_OF_DOCUMENT stringByAppendingPathComponent:@"articles"] stringByAppendingPathComponent:[muDict objectForKey:@"serverID"]] stringByAppendingString:@"/bg.jpg"];
            
            if ([fileUtils fileISExist:path])
            {
                //加载本地文件
                [homeTopImgBg setImage:[UIImage imageWithContentsOfFile:path]];
            }
        }
    }
    UIControl *viewControl = (UIControl *)[self.view viewWithTag:204];
    [viewControl addTarget:self action:@selector(homeTopArticleClick:) forControlEvents:UIControlEventTouchUpInside];
}

-(void) reActivityAudio
{
    if (nil != player && mp != nil)
    {
        [player play];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)homeTopArticleClick:(id)sender
{
    if (detailViewController != nil)
    {
        detailViewController = nil;
    }
    
    if (detailViewController == nil)
    {
        NSString *articleId = [sender accessibilityLabel];
        if ([sender isKindOfClass:[UITapGestureRecognizer class]] && (articleId == nil))
        {
            articleId = ((UITapGestureRecognizer *)sender).view.accessibilityLabel;
        }
        
        detailViewController = [[PopupDetailViewController alloc] initWithNibName:@"PopupView_iPad" bundle:nil andParams:articleId];
        detailViewController.delegate = self;
        [self presentPopupViewController:detailViewController animationType:MJPopupViewAnimationSlideRightLeft];
    }
}

- (void) closeButtonClicked
{    
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideLeftRight];
    detailViewController = nil;
}
@end
