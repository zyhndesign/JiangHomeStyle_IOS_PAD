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

@interface PopupDetailViewController ()<UIWebViewDelegate,UIAlertViewDelegate>

@end

@implementation PopupDetailViewController

@synthesize webView, delegate;
@synthesize backBtn;
@synthesize serverID;

extern FileUtils *fileUtils;
extern DBUtils *db;

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
    UIActivityIndicatorView *activityIndictor = (UIActivityIndicatorView *)[[_webView superview] viewWithTag:911];
    //[activityIndictor setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    activityIndictor.hidden = NO;
    [activityIndictor startAnimating];
}

-(void)webViewDidFinishLoad:(UIWebView *)_webView
{
    UIActivityIndicatorView *activityIndictor = (UIActivityIndicatorView *)[[_webView superview] viewWithTag:911];
    if ([activityIndictor isAnimating])
    {
        [activityIndictor stopAnimating];
    }
    activityIndictor.hidden = YES;
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

-(void) dealloc
{
    NSLog(@"webview delegate set nil.....");
    webView.delegate = nil;
}
@end
