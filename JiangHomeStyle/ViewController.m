//
//  ViewController.m
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-8-23.
//  Copyright (c) 2013年 工业设计中意（湖南）. All rights reserved.
//

#import "ViewController.h"
#import "HomeViewController.h"
#import "LandscapeTopViewController.h"
#import "LandscapeViewController.h"
#import "HumanityViewController.h"
#import "StoryViewController.h"
#import "CommunityViewController.h"
#import "HomeTopViewController.h"
#import "HumanityTopViewController.h"
#import "StoryTopViewController.h"
#import "CommunityTopViewController.h"
#import "FooterViewController.h"
#import "AFNetworking/AFJSONRequestOperation.h"
#import "AFNetworking.h"
#import "Constants.h"
#import "AudioStreamer.h"
#import "JSONKit.h"
#import "Reachability/Reachability.h"
#import "googleAnalytics/GAIDictionaryBuilder.h"
#import "MCProgressBarView.h"
#import "DBUtils.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize scrollView;
@synthesize topView;
@synthesize musicAuthor, musicName, playBtn, nextBtn;
@synthesize landscapeBtn, humanityBtn, storyboard, communityBtn;

extern DBUtils *db;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenName = @"查看内容详情界面";    
    
    [[GAI sharedInstance].defaultTracker set:self.screenName
                                       value:@"ViewController Screen"];
    
    // Send the screen view.
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    currentMusicNum = 0;
    
    CGRect screenBounds = [[UIScreen mainScreen]bounds];
    
    NSBundle* mainBundle = [NSBundle mainBundle];
    
    CGFloat originHeight = 0.0;
        
    homeTopViewController = [[HomeTopViewController new] initWithNibName:@"HomeTopController_iPad" bundle:mainBundle];
    UIImageView* homeTopImgBg = (UIImageView *)[homeTopViewController.view viewWithTag:203];
    CGSize homeTopCGSize = homeTopImgBg.frame.size;
    [scrollView addSubview:homeTopViewController.view];
    [self addChildViewController:homeTopViewController];
    
    homeBottomViewController = [[HomeViewController new] initWithNibName:@"HomeBottomController_iPad" bundle:mainBundle];
    CGSize homeBottomCGSize = homeBottomViewController.view.frame.size;
    
    originHeight = originHeight + homeTopCGSize.height;
    homeBottomViewController.view.frame = CGRectMake(0, originHeight,homeBottomCGSize.width,homeBottomCGSize.height);
    [scrollView addSubview:homeBottomViewController.view];
    [self addChildViewController:homeBottomViewController];
    
    landscapeTopViewController = [[LandscapeTopViewController new] initWithNibName:@"LandscapeTopController_iPad" bundle:mainBundle];
    CGSize landscapeTopCGSize = landscapeTopViewController.view.frame.size;
        
    originHeight = originHeight + homeBottomCGSize.height;
    landscapeTopViewController.view.frame = CGRectMake(0, originHeight,landscapeTopCGSize.width,landscapeTopCGSize.height);
    landscapeYValue = originHeight;
    [scrollView addSubview:landscapeTopViewController.view];
    
    landscapeBottomViewController = [[LandscapeViewController new] initWithNibName:@"LandscapeBottomController_iPad" bundle:mainBundle];
    CGSize landscapeBottomCGSize = landscapeTopViewController.view.frame.size;
        
    originHeight = originHeight + homeBottomCGSize.height;
    landscapeBottomViewController.view.frame = CGRectMake(0, originHeight,landscapeBottomCGSize.width,landscapeBottomCGSize.height);
    [scrollView addSubview:landscapeBottomViewController.view];
    [self addChildViewController:landscapeBottomViewController];
    
    humanityTopViewController = [[HumanityTopViewController new] initWithNibName:@"HumanityTopController_iPad" bundle:mainBundle];
    CGSize humanityTopCGSize = humanityTopViewController.view.frame.size;
    
    originHeight = originHeight + landscapeBottomCGSize.height;
    humanityTopViewController.view.frame = CGRectMake(0, originHeight,humanityTopCGSize.width,humanityTopCGSize.height);
    humanityYValue = originHeight;
    [scrollView addSubview:humanityTopViewController.view];
    
    humanityBottomViewController = [[HumanityViewController new] initWithNibName:@"HumanityBottomController_iPad" bundle:mainBundle];
    CGSize humanityBottomCGSize = humanityBottomViewController.view.frame.size;
    
    originHeight = originHeight + humanityTopCGSize.height;
    humanityBottomViewController.view.frame = CGRectMake(0, originHeight,humanityBottomCGSize.width,humanityBottomCGSize.height);
    [scrollView addSubview:humanityBottomViewController.view];
    [self addChildViewController:humanityBottomViewController];
    
    storyTopViewController = [[StoryTopViewController new] initWithNibName:@"StoryTopController_iPad" bundle:mainBundle];
    CGSize storyTopCGSize = storyTopViewController.view.frame.size;
    
    originHeight = originHeight + humanityBottomCGSize.height;
    storyTopViewController.view.frame = CGRectMake(0, originHeight,storyTopCGSize.width,storyTopCGSize.height);
    storyYValue = originHeight;
    [scrollView addSubview:storyTopViewController.view];
    
    storyBottomViewController = [[StoryViewController new] initWithNibName:@"StoryBottomController_iPad" bundle:mainBundle];
    CGSize storyBottomCGSize = storyBottomViewController.view.frame.size;
    
    originHeight = originHeight + storyTopCGSize.height;
    storyBottomViewController.view.frame = CGRectMake(0, originHeight,storyBottomCGSize.width,storyBottomCGSize.height);
    [scrollView addSubview:storyBottomViewController.view];
    [self addChildViewController:storyBottomViewController];
    
    communityTopViewController = [[CommunityTopViewController new] initWithNibName:@"CommunityTopController_iPad" bundle:mainBundle];
    CGSize communityTopCGSize = communityTopViewController.view.frame.size;
    
    originHeight = originHeight + storyBottomCGSize.height;
    communityTopViewController.view.frame = CGRectMake(0, originHeight,communityTopCGSize.width,communityTopCGSize.height);
    communityYValue = originHeight;
    [scrollView addSubview:communityTopViewController.view];
    
    communityBottomViewController = [[CommunityViewController new] initWithNibName:@"CommunityBottomController_iPad" bundle:mainBundle];
    CGSize communityBottomCGSize = communityBottomViewController.view.frame.size;
    
    originHeight = originHeight + communityTopCGSize.height;
    communityBottomViewController.view.frame = CGRectMake(0, originHeight,communityBottomCGSize.width,communityBottomCGSize.height);
    [scrollView addSubview:communityBottomViewController.view];
    [self addChildViewController:communityBottomViewController];
    
    //NSArray *nibFooterView = [mainBundle loadNibNamed:@"Footer" owner:self options:nil];
    //UIView *footerView = [nibFooterView objectAtIndex:0];
    
    footerViewController = [[FooterViewController new] initWithNibName:@"Footer" bundle:mainBundle];
    CGSize footerCGSize = footerViewController.view.frame.size;
    
    originHeight = originHeight + communityBottomCGSize.height;
    footerViewController.view.frame = CGRectMake(0, originHeight,footerCGSize.width,footerCGSize.height);
    [scrollView addSubview:footerViewController.view];
    [self addChildViewController:footerViewController];
    
    CGFloat contentSizeHeight = homeTopCGSize.height + homeBottomCGSize.height + landscapeTopCGSize.height + landscapeBottomCGSize.height + humanityTopCGSize.height + humanityBottomCGSize.height + storyTopCGSize.height + storyBottomCGSize.height + communityTopCGSize.height + communityBottomCGSize.height + footerCGSize.height;
    
    scrollView.contentSize = CGSizeMake(screenBounds.size.width, contentSizeHeight);
    scrollView.bounces = NO;
    scrollView.delegate = self;
    
    [self addProgressBarAtRect:CGRectMake(781, 63, 175, 5) taperOff:YES progress:-0.1];
    
    playBtn = (UIButton *)[self.view viewWithTag:152];
    [playBtn setBackgroundColor:[UIColor clearColor]];
    [playBtn setBackgroundImage:[UIImage imageNamed:@"music_btn_play_normal"] forState:UIControlStateNormal];
    [playBtn setBackgroundImage:[UIImage imageNamed:@"music_btn_play_pressed"] forState:UIControlStateHighlighted];
    
    nextBtn = (UIButton *)[self.view viewWithTag:153];
    [nextBtn setBackgroundColor:[UIColor clearColor]];
    [nextBtn setBackgroundImage:[UIImage imageNamed:@"music_btn_next_normal"] forState:UIControlStateNormal];
    [nextBtn setBackgroundImage:[UIImage imageNamed:@"music_btn_next_pressed"] forState:UIControlStateHighlighted];
    
    musicAuthor = (UILabel *)[self.view viewWithTag:154];
    musicName = (UILabel *)[self.view viewWithTag:155];
    
    landscapeBtn = (UIButton *)[self.view viewWithTag:156];
    [landscapeBtn addTarget:self action:@selector(scrollViewLandscapeTo) forControlEvents:UIControlEventTouchUpInside];
    
    humanityBtn = (UIButton *)[self.view viewWithTag:157];
    [humanityBtn addTarget:self action:@selector(scrollViewHumanityTo ) forControlEvents:UIControlEventTouchUpInside];
    
    storyBtn = (UIButton *)[self.view viewWithTag:158];
    [storyBtn addTarget:self action:@selector(scrollViewStoryTo ) forControlEvents:UIControlEventTouchUpInside];
    
    communityBtn = (UIButton *)[self.view viewWithTag:159];
    [communityBtn addTarget:self action:@selector(scrollViewCommunityTo ) forControlEvents:UIControlEventTouchUpInside];
    
    [self setNavBtnBackgroundLandscape:true Humanity:true Story:true Community:true];
    
    musicArray = [NSMutableArray new];
    [self loadMusicPlayMusic];
    
    [playBtn addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    [nextBtn addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *logoImgView = (UIImageView *)[self.view viewWithTag:160];
    logoImgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logoOnClick)];
    [logoImgView addGestureRecognizer:singleTap];
     
}

-(void)logoOnClick
{
    [scrollView setContentOffset:CGPointMake(scrollView.frame.origin.x, 0) animated:YES];
}
-(void) scrollViewLandscapeTo
{
    [scrollView setContentOffset:CGPointMake(scrollView.frame.origin.x, landscapeYValue) animated:YES];
    [self setNavBtnSelectState:true Humanity:false Story:false Community:false];
}

-(void) scrollViewStoryTo
{
    [scrollView setContentOffset:CGPointMake(scrollView.frame.origin.x, storyYValue) animated:YES];
    [self setNavBtnSelectState:false Humanity:false Story:true Community:false];
}

-(void) scrollViewHumanityTo
{
    [scrollView setContentOffset:CGPointMake(scrollView.frame.origin.x, humanityYValue) animated:YES];
    [self setNavBtnSelectState:false Humanity:true Story:false Community:false];
}

-(void) scrollViewCommunityTo
{
    [scrollView setContentOffset:CGPointMake(scrollView.frame.origin.x, communityYValue) animated:YES];
    [self setNavBtnSelectState:false Humanity:false Story:false Community:true];
}

-(void) setNavBtnBackgroundLandscape:(BOOL)landscape Humanity:(BOOL) humanity Story:(BOOL) story Community:(BOOL)community
{
    if (landscape && landscapeBtn != nil)
    {
        [landscapeBtn setBackgroundImage:[UIImage imageNamed:@"top_nav_btn_fengjing_normal"] forState:UIControlStateNormal];
        [landscapeBtn setBackgroundImage:[UIImage imageNamed:@"top_nav_btn_fengjing_pressed"] forState:UIControlStateHighlighted];
        [landscapeBtn setBackgroundImage:[UIImage imageNamed:@"top_nav_btn_fengjing_pressed"] forState:UIControlStateSelected];
    }
    
    if (humanity && humanityBtn != nil)
    {
        [humanityBtn setBackgroundImage:[UIImage imageNamed:@"top_nav_btn_renwen_normal"] forState:UIControlStateNormal];
        [humanityBtn setBackgroundImage:[UIImage imageNamed:@"top_nav_btn_renwen_pressed"] forState:UIControlStateHighlighted];
        [humanityBtn setBackgroundImage:[UIImage imageNamed:@"top_nav_btn_renwen_pressed"] forState:UIControlStateSelected];
    }
    
    if (story && storyBtn != nil)
    {
        [storyBtn setBackgroundImage:[UIImage imageNamed:@"top_nav_btn_wuyu_normal"] forState:UIControlStateNormal];
        [storyBtn setBackgroundImage:[UIImage imageNamed:@"top_nav_btn_wuyu_pressed"] forState:UIControlStateHighlighted];
        [storyBtn setBackgroundImage:[UIImage imageNamed:@"top_nav_btn_wuyu_pressed"] forState:UIControlStateSelected];
    }
    
    if (community && communityBtn != nil)
    {
        [communityBtn setBackgroundImage:[UIImage imageNamed:@"top_nav_btn_shequ_normal"] forState:UIControlStateNormal];
        [communityBtn setBackgroundImage:[UIImage imageNamed:@"top_nav_btn_shequ_pressed"] forState:UIControlStateHighlighted];
        [communityBtn setBackgroundImage:[UIImage imageNamed:@"top_nav_btn_shequ_pressed"] forState:UIControlStateSelected];
    }
}

- (void) setNavBtnSelectState:(BOOL)landBtnState Humanity:(BOOL)humanityBtnState Story:(BOOL)storyBtnState Community:(BOOL)communityState
{
    if (landBtnState && landscapeBtn != nil)
    {
        [landscapeBtn setSelected:true];
        [storyBtn setSelected:false];
        [humanityBtn setSelected:false];
        [communityBtn setSelected:false];
    }
    
    if (humanityBtnState && humanityBtn != nil)
    {
        [humanityBtn setSelected:true];
        [landscapeBtn setSelected:false];
        [storyBtn setSelected:false];
        [communityBtn setSelected:false];
    }
    
    if (storyBtnState && storyBtn != nil)
    {
        [storyBtn setSelected:true];
        [landscapeBtn setSelected:false];
        [humanityBtn setSelected:false];
        [communityBtn setSelected:false];
    }
    
    if (communityState && communityBtn != nil)
    {
        [communityBtn setSelected:true];
        [landscapeBtn setSelected:false];
        [landscapeBtn setSelected:false];
        [storyBtn setSelected:false];
    }
    
    if (!landBtnState && !humanityBtnState && !storyBtnState && !communityState)
    {
        [communityBtn setSelected:false];
        [landscapeBtn setSelected:false];
        [landscapeBtn setSelected:false];
        [storyBtn setSelected:false];
    }
}

-(void) loadMusicPlayMusic
{
    NSString *visitPath = [INTERNET_VISIT_PREFIX stringByAppendingString:@"/travel/wp-admin/admin-ajax.php?action=zy_get_music&programId=1"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:INTERNET_VISIT_PREFIX]];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET" path:visitPath parameters:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *nsStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSData* jsonData = [nsStr dataUsingEncoding:NSUTF8StringEncoding];
       
        NSDictionary *nsDict = [jsonData objectFromJSONData];
        NSArray *array = [nsDict objectForKey:@"data"];
        NSMutableDictionary* muDict = nil;
        
        for (int i = 0; i < array.count; i++)
        {
             muDict = [NSMutableDictionary new];
             NSDictionary *article = [array objectAtIndex:i];
             [muDict setObject:[article objectForKey:@"music_title"] forKey:@"music_title"];
             [muDict setObject:[article objectForKey:@"music_author"] forKey:@"music_author"];
             [muDict setObject:[article objectForKey:@"music_path"] forKey:@"music_path"];
             [musicArray addObject:muDict];
        }
        /*
        if ([musicArray count] > 0)
        {
            [self loadMusicPlayMusic];
        }
        */
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //加载本地音乐
        NSMutableArray* musicData = [db queryMusicData];
        NSMutableDictionary* muDict = nil;
        
        for (int i = 0; i < musicData.count; i++)
        {
            muDict = [NSMutableDictionary new];
            NSDictionary *article = [musicData objectAtIndex:i];
            [muDict setObject:[article objectForKey:@"musicTitle"] forKey:@"music_title"];
            [muDict setObject:[article objectForKey:@"musicAuthor"] forKey:@"music_author"];
            [muDict setObject:[article objectForKey:@"musicPath"] forKey:@"music_path"];
            [musicArray addObject:muDict];
        }
    }];
    [operation start];
}

-(void) play
{
    if (nil != musicArray && [musicArray count] != 0)
    {
        if (!streamer)
        {
            NSDictionary *nsDict = [musicArray objectAtIndex:0];
            streamer = [[AudioStreamer alloc] initWithURL:[NSURL URLWithString:[nsDict objectForKey:@"music_path"]]];
            [musicAuthor setText:[@"Directed By " stringByAppendingString:[nsDict objectForKey:@"music_author"]]];
            [musicName setText:[nsDict objectForKey:@"music_title"]];
            
            // set up display updater
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                        [self methodSignatureForSelector:@selector(updateProgress)]];
            [invocation setSelector:@selector(updateProgress)];
            [invocation setTarget:self];
            
            timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                 invocation:invocation
                                                    repeats:YES];
            
            currentMusicNum = 0;
        }
        
        if ([streamer isPlaying])
        {
            [streamer pause];
            [self setBtnPause];
        }
        else
        {
            [streamer start];
            
            NSLog(@"start......");
            [self setBtnPlay];
        }
    }
    else  //播放本地音乐
    {
        [self showPlayMusicTips];
        /*
        if ([streamer isPlaying])
        {
            [streamer pause];
            [self setBtnPause];
        }
        else
        {
            NSString *mp3Path = [[NSBundle mainBundle] pathForResource:@"music_1" ofType:@"mp3"];            
            NSURL *defaultMusicUrl = [NSURL fileURLWithPath:mp3Path isDirectory:NO];
            
            NSLog(@"*****: %@",[defaultMusicUrl description]);
            
            NSFileManager *fileManage = [NSFileManager defaultManager];
            NSString * path = [[NSBundle mainBundle] resourcePath] ;
            NSArray *file = [fileManage subpathsOfDirectoryAtPath:path error:nil];
            NSLog(@"*****2: %@",[file description]);
            
            streamer = [[AudioStreamer alloc] initWithURL:defaultMusicUrl];
            [musicAuthor setText:@"Directed By MATI"];
            [musicName setText:@"YiLi Shushu Tamber 1"];
            
            // set up display updater
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                        [self methodSignatureForSelector:@selector(updateProgress)]];
            [invocation setSelector:@selector(updateProgress)];
            [invocation setTarget:self];
            
            timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                 invocation:invocation
                                                    repeats:YES];
            [streamer start];
        }      
        */
    }
}

-(void) stop
{
    // release streamer
	if (streamer)
	{
		[streamer stop];
	}
}

-(void) next
{
    if (nil != musicArray && [musicArray count] > 0)
    {
        ++currentMusicNum;
        if (currentMusicNum < [musicArray count])
        {
            if (streamer)
            {
                [streamer stop];
                progressBarView.progress = -0.1;
            }
            [self playNextMusic:currentMusicNum];
        }
        else
        {
            if (streamer)
            {
                [streamer stop];
            }
            if (nil != musicArray)
            {
                currentMusicNum = 0;
                progressBarView.progress = -0.1;
                [self playNextMusic:currentMusicNum];
            }        
        }
    }
    else
    {
        [self showPlayMusicTips];
    }
}

-(void) playNextMusic:(int) _currentMusicNum
{
    NSDictionary *nsDict = [musicArray objectAtIndex:_currentMusicNum];
    streamer = [[AudioStreamer alloc] initWithURL:[NSURL URLWithString:[nsDict objectForKey:@"music_path"]]];
    [musicAuthor setText:[@"Directed By " stringByAppendingString:[nsDict objectForKey:@"music_author"]]];
    [musicName setText:[nsDict objectForKey:@"music_title"]];
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                [self methodSignatureForSelector:@selector(updateProgress)]];
    [invocation setSelector:@selector(updateProgress)];
    [invocation setTarget:self];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                         invocation:invocation
                                            repeats:YES];
    
    if (nil != streamer)
    {
        [streamer start];
        [self setBtnPlay];
    }
}

- (void)updateProgress
{
    if (streamer.progress != 0.0)
    {
        if ((int)streamer.progress < (int)streamer.duration)
        {
            progressBarView.progress = streamer.progress/streamer.duration;
        }
        else
        {
            progressBarView.progress = -0.1;
            if ([streamer isFinishing])
            {
                if([timer isValid])
                {
                    [timer invalidate];
                }
            }
        }
    }
    
}

-(void) setBtnPause
{
    [playBtn setBackgroundImage:[UIImage imageNamed:@"music_btn_play_normal"] forState:UIControlStateNormal];
    [playBtn setBackgroundImage:[UIImage imageNamed:@"music_btn_play_pressed"] forState:UIControlStateHighlighted];
    
}

-(void) setBtnPlay
{
    [playBtn setBackgroundImage:[UIImage imageNamed:@"music_btn_pause_normal"] forState:UIControlStateNormal];
    [playBtn setBackgroundImage:[UIImage imageNamed:@"music_btn_pause_pressed"] forState:UIControlStateHighlighted];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) showPlayMusicTips
{
    Reachability *reacheNet = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    switch ([reacheNet currentReachabilityStatus]) {
        case NotReachable: //not network reach
            {
                UIAlertView *musicTips = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"播放音乐，请连接网络！" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil];
                [musicTips show];
            }
            break;
        case ReachableViaWWAN: //use 3g network
            NSLog(@"3g network....");
            [self loadMusicPlayMusic];
            
            break;
        case ReachableViaWiFi: //use wifi network
            NSLog(@"wifi network....");
            [self loadMusicPlayMusic];
            break;
        default:
            break;
    }    
}

- (void)addProgressBarAtRect:(CGRect)rect taperOff:(BOOL)taperOff progress:(double)progress
{
    UIImage * backgroundImage = [[UIImage imageNamed:@"music_progressbar_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    UIImage * foregroundImage = [[UIImage imageNamed:@"music_progressbar"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    
    progressBarView = [[MCProgressBarView alloc] initWithFrame:rect
                                               backgroundImage:backgroundImage
                                               foregroundImage:foregroundImage];
    
    if (taperOff) {
        progressBarView.offsetForZero = 10.0;
    }
    progressBarView.progress = progress;
    
    [self.view addSubview:progressBarView];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    NSLog(@"back to top .......");
    return NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)_scrollView
{
    CGFloat offsetY = _scrollView.contentOffset.y;
    
    if (offsetY >= landscapeYValue && offsetY < humanityYValue)
    {
        [self setNavBtnSelectState:true Humanity:false Story:false Community:false];
    }
    else if (offsetY >= humanityYValue && offsetY < storyYValue)
    {
        [self setNavBtnSelectState:false Humanity:true Story:false Community:false];
    }
    else if (offsetY >= storyYValue && offsetY < communityYValue)
    {
        [self setNavBtnSelectState:false Humanity:false Story:true Community:false];
    }
    else if (offsetY >= communityYValue)
    {
        [self setNavBtnSelectState:false Humanity:false Story:false Community:true];
    }
    else if (offsetY < landscapeYValue)
    {
        [self setNavBtnSelectState:false Humanity:false Story:false Community:false];
    }
}
@end
