//
//  PopupDetailViewController.m
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-9-4.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import "PopupDetailViewController.h"
#import "Reachability.h"
#import "FileUtils.h"
#import "VarUtils.h"
#import "DBUtils.h"
#import "googleAnalytics/GAI.h"
#import "googleAnalytics/GAIDictionaryBuilder.h"
#import "UIImageView+RotationAnimation.h"
#import "GDataXMLNode.h"
#import <MediaPlayer/MPMoviePlayerController.h>
#import "MJPopup/UIViewController+MJPopupViewController.h"
#import "VideoViewController.h"

@interface PopupDetailViewController ()<UIWebViewDelegate,UIAlertViewDelegate,MJPopupDelegate>

@end

@implementation PopupDetailViewController

@synthesize webView, delegate;
@synthesize backBtn;
@synthesize serverID;

extern FileUtils *fileUtils;
extern DBUtils *db;
VideoViewController *videoViewController = nil;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andParams:(NSString *)_serverID
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.serverID = _serverID;
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    webView.alpha = 1;
    self.screenName = @"查看内容详情界面";
    self.view.backgroundColor = [UIColor clearColor];
    [[GAI sharedInstance].defaultTracker set:self.screenName
                                       value:@"Pop Screen"];
    
    // Send the screen view.
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    webView = (UIWebView *)[self.view viewWithTag:751];
    backBtn = (UIButton *)[self.view viewWithTag:752];
	// Do any additional setup after loading the view.
    [backBtn setBackgroundImage:[UIImage imageNamed:@"btn_back_pressed"] forState:UIControlStateNormal];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"btn_back_normal"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(BtnCloseClick) forControlEvents:UIControlEventTouchUpInside];
    backBtn.alpha = 1;
    //[NSURL fileURLWithPath:]
    NSLog(@"get article id is :%@",self.serverID);
    
    if (nil != self.serverID)
    {
        
        NSString *filePath = [[[[PATH_OF_DOCUMENT stringByAppendingPathComponent:@"articles"] stringByAppendingPathComponent:self.serverID] stringByAppendingPathComponent:@"doc"] stringByAppendingPathComponent:@"main.html"];
        
        [webView.scrollView setAlwaysBounceHorizontal:YES];
        [webView.scrollView setAlwaysBounceVertical:NO];
        
        [webView.scrollView setShowsVerticalScrollIndicator:NO];
        //[webView.scrollView setShowsHorizontalScrollIndicator:YES];
        webView.delegate = self;
        
        if ([fileUtils fileISExist:filePath])
        {
            NSLog(@"loading local file...");
            
            NSURL * url = [NSURL fileURLWithPath:filePath];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            [webView loadRequest:request];
            
        }
        else
        {
            NSLog(@"loading remote file...");
            //UIAlertView *downloadTips = [[UIAlertView alloc] initWithTitle:@"下载文件" message:@"正在加载中..." delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
            UIAlertView *articleTips = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"该文件没有离线保存，需要打开网络下载" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil];
            NSString *url = [db getDownUrlByServerId:serverID];
            NSLog(@"download zip file path is :%@", url);
            Reachability *reacheNet = [Reachability reachabilityWithHostName:@"www.baidu.com"];
            switch ([reacheNet currentReachabilityStatus]) {
                case NotReachable: //not network reach
                    [articleTips show];
                    break;
                case ReachableViaWWAN: //use 3g network
                    NSLog(@"3g network....");
                    [fileUtils downloadZipFile:url andArticleId:self.serverID andTipsAnim:webView];
                    break;
                case ReachableViaWiFi: //use wifi network
                    NSLog(@"wifi network....");
                    [fileUtils downloadZipFile:url andArticleId:self.serverID andTipsAnim:webView];
                    break;
                default:
                    
                    break;
            }
        }
        
        //解析doc.xml文件，获取showUrl地址，videoUrl
        NSString *docFilePath   =  [[[PATH_OF_DOCUMENT stringByAppendingPathComponent:@"articles"] stringByAppendingPathComponent:self.serverID]  stringByAppendingPathComponent:@"doc.xml"];
        //NSString *jsonString  =   [NSString stringWithContentsOfFile:docFilePath encoding:NSUTF8StringEncoding error:nil];
        NSData *xmlData = [[NSData alloc] initWithContentsOfFile:docFilePath];
        
        //使用NSData对象初始化
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData  options:0 error:nil];
        
        //获取根节点（doc）
        GDataXMLElement *rootElement = [doc rootElement];
        
        //获取根节点下的节点（videoItems）
        NSArray *videoItems = [rootElement elementsForName:@"videoItems"];
        
        videoArray = [NSMutableArray new];
        
        if ([videoItems count] > 0)
        {
            for (GDataXMLElement *videoItem in videoItems)
            {
                NSArray *videoItemData = [videoItem elementsForName:@"videoItem"];
                
                for (GDataXMLElement *video in videoItemData) {
                    urlDict = [NSMutableDictionary new];
                    //获取showUrl节点的值
                    GDataXMLElement *nameElement = [[video elementsForName:@"showUrl"] objectAtIndex:0];
                    showUrl = [nameElement stringValue];
                    NSLog(@"showUrl is:%@",showUrl);
                    
                    //获取videoUrl节点的值
                    GDataXMLElement *ageElement = [[video elementsForName:@"videoUrl"] objectAtIndex:0];
                    videoUrl = [ageElement stringValue];
                    NSLog(@"videoUrl is:%@",videoUrl);
                    
                    [urlDict setValue:videoUrl forKey:@"videoUrl"];
                    [urlDict setValue:showUrl forKey:@"showUrl"];
                    
                    [videoArray addObject:urlDict];
                }
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)BtnCloseClick
{
    if ([webView canGoBack])
    {
        [webView goBack];
    }
    else
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(closeButtonClicked)])
        {
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            
            [center postNotificationName:@"HOME_PAGE_VIDEO" object:nil];
            [self.delegate closeButtonClicked];            
        }
    }    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = [request URL];
    
    //判断url是否为视频地址，如果为视频地址则进行拦截播放
    for (NSMutableDictionary *dict in videoArray)
    {
        if ([[urlDict objectForKey:@"showUrl"]isEqualToString:[url description]])
        {
            //判断指定路径是否有视频，没有则进行下载，下载后调用原生播放器进行播放
            NSString *path =[[PATH_OF_DOCUMENT stringByAppendingPathComponent:@"video"] stringByAppendingPathComponent:[self getFileNameFromUrl:[urlDict objectForKey:@"videoUrl"]]];
            if ([fileUtils fileISExist:path])
            {                                
                if (videoViewController == nil)
                {
                    videoViewController = [[VideoViewController alloc] initWithNibName:@"VideoPlay" bundle:nil andUrl:path];
                    videoViewController.delegate = self;                    
                    [self presentPopupViewController:videoViewController animationType:MJPopupViewAnimationSlideRightLeft];
                }
            }            
            return NO;
        }
        else
        {
            return YES;
        }
    }
    return YES;
}

-(void)webView:(UIWebView *)_webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"webview loading file is error...%@",[error localizedFailureReason]);
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"404" ofType:@"html"];
    NSURL *url = [NSURL URLWithString:filePath relativeToURL:[NSURL fileURLWithPath:[filePath stringByDeletingLastPathComponent] isDirectory:YES]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
}

-(void)webViewDidStartLoad:(UIWebView *)_webView
{
    aniLayer1 = (UIImageView *)[self.view viewWithTag:912];
    aniLayer1.hidden = NO;
    [aniLayer1 addRotationClockWise:1 andAngle:3.0 andRepeat:100];
    aniLayer2 = (UIImageView *)[self.view viewWithTag:913];
    aniLayer2.hidden = NO;
    [aniLayer2 addRotationAntiClockWise:1 andAngle:2.0 andRepeat:100];
}

-(void)webViewDidFinishLoad:(UIWebView *)_webView
{
    NSURLRequest *req = _webView.request;
    if (aniLayer1 == nil)
    {
        aniLayer1 = (UIImageView *)[self.view viewWithTag:912];
    }
    [aniLayer1.layer removeAnimationForKey:@"transform.rotation.z"];
    aniLayer1.hidden = YES;
    
    if(aniLayer2 == nil)
    {
        aniLayer2 = (UIImageView *)[self.view viewWithTag:913];
    }
    [aniLayer2.layer removeAnimationForKey:@"transform.rotation.z"];
    
    aniLayer2.hidden = YES;
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(closeButtonClicked)])
        {
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:@"HOME_PAGE_VIDEO" object:nil];
            [self.delegate closeButtonClicked];
        }
    }
    
    if (buttonIndex == 1)
    {
    
    }
}

-(NSString *)getFileNameFromUrl:(NSString *)url
{
    NSArray *array = [url componentsSeparatedByString:@"/"];
    
    return [array objectAtIndex:([array count] - 1)];
}

- (void) closeButtonClicked
{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideLeftRight];
    videoViewController = nil;
}
-(void) dealloc
{
    NSLog(@"webview delegate set nil.....");
    webView.delegate = nil;
}
@end
