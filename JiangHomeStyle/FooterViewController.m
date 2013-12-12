//
//  FooterViewController.m
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-12-3.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import "FooterViewController.h"
#import "DownloadViewController.h"
#import "MJPopup/UIViewController+MJPopupViewController.h"
#import "PopupDetailViewController.h"
#import "Reachability/Reachability.h"

@interface FooterViewController ()<MJPopupDelegate>
{
    
}
@end

@implementation FooterViewController

DownloadViewController *downloadViewController;

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
    
    downLoadBtn = (UIButton *)[self.view viewWithTag:810];
    [downLoadBtn addTarget:self action:@selector(downLoadFiles) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)downLoadFiles
{
    //弹出下载面板
    if (downloadViewController == nil)
    {
        Reachability *reacheNet = [Reachability reachabilityWithHostName:@"www.baidu.com"];
        switch ([reacheNet currentReachabilityStatus]) {
            case NotReachable: //not network reach
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"请设置好网络连接" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                break;
            }
            case ReachableViaWWAN: //use 3g network
            {
                NSLog(@"3g network....");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"3G 网络不能下载" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                break;
            }
            case ReachableViaWiFi: //use wifi network
            {
                downloadViewController = [[DownloadViewController alloc] initWithNibName:@"DownloadWin" bundle:nil];
                downloadViewController.delegate = self;
                [self presentPopupViewController:downloadViewController animationType:MJPopupViewAnimationSlideBottomTop];
                break;
            }
            default:
                break;
        }

    }
   
}

- (void) closeButtonClicked
{
    downloadViewController = nil;
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
}
@end
