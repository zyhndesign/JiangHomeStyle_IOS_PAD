//
//  HomeViewController.m
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-8-29.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import "HomeViewController.h"
#import "MJPopup/UIViewController+MJPopupViewController.h"
#import "PopupDetailViewController.h"
#import "DBUtils.h"
#import "AFNetworking/AFNetworking.h"
#import "FileUtils.h"
#import "TimeUtil.h"
#import "googleAnalytics/GAIDictionaryBuilder.h"
#import "UILabel+VerticalAlign.h"

@interface HomeViewController ()<MJPopupDelegate>
{
    
}
@end

@implementation HomeViewController

@synthesize recommandBgView;

@synthesize firstPanelView, secondPanelView, thirdPanelView;

extern DBUtils *db;
extern FileUtils *fileUtils;
extern PopupDetailViewController* detailViewController;

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
                                       value:@"HomeViewController Screen"];
    
    // Send the screen view.
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    [recommandBgView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"headline_lv2_bg.png"]]];
    
    [firstPanelView addTarget:self action:@selector(panelClick:) forControlEvents:UIControlEventTouchUpInside];
    [secondPanelView addTarget:self action:@selector(panelClick:) forControlEvents:UIControlEventTouchUpInside];
    [thirdPanelView addTarget:self action:@selector(panelClick:) forControlEvents:UIControlEventTouchUpInside];
    
    db = [[DBUtils alloc] init];
    NSMutableArray *muArray = [db queryHeadline];
    
    UIImageView *firstPanelImg = (UIImageView *)[self.view viewWithTag:203];
    UILabel *firstPanelTitleLabel = (UILabel *)[self.view viewWithTag:204];
    UILabel *firstPanelTimeLabel = (UILabel *)[self.view viewWithTag:205];
    
    if ([muArray count] >= 2)
    {
        NSMutableDictionary *muDict = [muArray objectAtIndex:1];
        [self loadingImage:muDict andImageView:firstPanelImg];
        [firstPanelTitleLabel setText:[muDict objectForKey:@"title"]];
        [firstPanelTitleLabel alignTop];
        firstPanelTitleLabel.textAlignment = NSTextAlignmentCenter;
        [firstPanelTimeLabel setText:[TimeUtil convertTimeFormat:[muDict objectForKey:@"timestamp"]]];
        firstPanelView.accessibilityLabel = [muDict objectForKey:@"serverID"];
    }
    else
    {
        firstPanelView.hidden = YES;
    }
    
    UIImageView *secondPanelImg = (UIImageView *)[self.view viewWithTag:206];
    UILabel *secondPanelTitleLabel = (UILabel *)[self.view viewWithTag:207];
    UILabel *secondPanelTimeLabel = (UILabel *)[self.view viewWithTag:208];
    if ([muArray count] >= 3)
    {
        NSMutableDictionary *muDict = [muArray objectAtIndex:2];
        [self loadingImage:muDict andImageView:secondPanelImg];
        [secondPanelTitleLabel setText:[muDict objectForKey:@"title"]];
        [secondPanelTitleLabel alignTop];
        secondPanelTitleLabel.textAlignment = NSTextAlignmentCenter;
        [secondPanelTimeLabel setText:[TimeUtil convertTimeFormat:[muDict objectForKey:@"timestamp"]]];
        secondPanelView.accessibilityLabel = [muDict objectForKey:@"serverID"];
    }
    else
    {
        secondPanelView.hidden = YES;
    }
    
    UIImageView *threePanelImg = (UIImageView *)[self.view viewWithTag:209];
    UILabel *thirdPanelTitleLabel = (UILabel *)[self.view viewWithTag:210];
    UILabel *thirdPanelTimeLabel = (UILabel *)[self.view viewWithTag:211];
    if ([muArray count] >= 4)
    {
        NSMutableDictionary *muDict = [muArray objectAtIndex:3];
        [self loadingImage:muDict andImageView:threePanelImg];
        [thirdPanelTitleLabel setText:[muDict objectForKey:@"title"]];
        [thirdPanelTitleLabel alignTop];
        thirdPanelTitleLabel.textAlignment = NSTextAlignmentCenter;
        [thirdPanelTimeLabel setText:[TimeUtil convertTimeFormat:[muDict objectForKey:@"timestamp"]]];
        thirdPanelView.accessibilityLabel = [muDict objectForKey:@"serverID"];
    }
    else
    {
        thirdPanelView.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)panelClick:(id)sender
{
    if (detailViewController == nil)
    {
        detailViewController = [[PopupDetailViewController alloc] initWithNibName:@"PopupView_iPad" bundle:nil andParams:[sender accessibilityLabel]];
        detailViewController.delegate = self;
        
        [self presentPopupViewController:detailViewController animationType:MJPopupViewAnimationSlideRightLeft];
    }
}

- (void) closeButtonClicked
{
    detailViewController = nil;
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideLeftRight];
    
}

-(void) loadingImage:(NSMutableDictionary*) muDict andImageView:(UIImageView*) uiImg
{
    NSString *path = [[[PATH_OF_DOCUMENT stringByAppendingPathComponent:@"thumb"] stringByAppendingPathComponent:[muDict objectForKey:@"serverID"]] stringByAppendingString:@".jpg"];
    if ([fileUtils fileISExist:path])
    {
        //加载本地文件
        //[uiImg setImage:[UIImage imageWithContentsOfFile:path]];
        [uiImg setImageWithURL:[NSURL fileURLWithPath:path]];
    }
    else //加载网络文件，并下载到本地
    {
        
        NSMutableString *muString = [muDict objectForKey:@"profile_path"];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[[muString substringToIndex:[muString length] - 4] stringByAppendingString:@"-300x300.jpg"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSLog(@"loading image is success");
            //[uiImg setImage:[UIImage imageWithContentsOfFile:path]];
            [uiImg setImageWithURL:[NSURL fileURLWithPath:path]];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"loading image is failure %@",[error description]);
        }];
        [operation start];
    }
}

@end
