//
//  CommunityViewController.m
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-8-29.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import "CommunityViewController.h"
#import "MKBlockTimer/NSObject+MKBlockTimer.h"
#import "DBUtils.h"
#import "Constants.h"
#import "TimeUtil.h"
#import "VarUtils.h"
#import "FileUtils.h"
#import "AFNetworking.h"
#import "MJPopup/UIViewController+MJPopupViewController.h"
#import "PopupDetailViewController.h"
#import "googleAnalytics/GAIDictionaryBuilder.h"

@interface CommunityViewController ()<MJPopupDelegate>
{
    
}


@end

@implementation CommunityViewController

@synthesize communityScrollView,communityPageControl;

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
    pageControlBeingUsed = NO;
	// Do any additional setup after loading the view.
    self.screenName = @"社区界面";
    
    [[GAI sharedInstance].defaultTracker set:self.screenName
                                       value:@"CommunityController Screen"];
    
    // Send the screen view.
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    int countArticle = [db countByCategory:COMMUNITY_CATEGORY];
    countPage = (countArticle / COMMUNITY_INSIDE_NUM);
    if ((countArticle % COMMUNITY_INSIDE_NUM) > 0)
    {
        countPage = countPage + 1;
    }
    
    muDistionary = [NSMutableDictionary dictionaryWithCapacity:3];
    currentPage = 0;
    
    for (int i = 0; i < 2; i++)
    {
        if (i <= countPage)
        {
            [self assemblePanel:i];
        }
    }
    
    self.communityScrollView.contentSize = CGSizeMake(self.communityScrollView.frame.size.width * countPage, self.communityScrollView.frame.size.height);
    
    self.communityScrollView.delegate = self;
    
    self.communityPageControl.currentPage = 0;
    self.communityPageControl.numberOfPages = countPage;
}


- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!pageControlBeingUsed)
    {
        CGFloat pageWidth = self.communityScrollView.frame.size.width;
        currentPage = floor((self.communityScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        self.communityPageControl.currentPage = currentPage;
    }
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self addNewModelInScrollView:currentPage];
    pageControlBeingUsed = NO;
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self removeOldModelInScrollView:currentPage];
    pageControlBeingUsed = NO;
}

-(void) addNewModelInScrollView:(int) pageNum
{
    //[self logTimeTakenToRunBlock:^{
        if (nil != communityScrollView)
        {
            UIView* subview3 = [muDistionary objectForKey:[NSNumber numberWithInt:(pageNum + 1)]];
            if (nil == subview3 && (pageNum + 1 < countPage))
            {
                [self assemblePanel:(pageNum + 1)];
            }
            
            UIView* subview4 = [muDistionary objectForKey:[NSNumber numberWithInt:(pageNum - 1)]];
            if (nil == subview4 && (pageNum - 1 >= 0))
            {
                [self assemblePanel:(pageNum - 1)];
            }
        }
    //} withPrefix:@"add community panel"];
}

-(void) removeOldModelInScrollView:(int)pageNum
{
   // [self logTimeTakenToRunBlock:^{
        UIView* subview1 = [muDistionary objectForKey:[NSNumber numberWithInt:(pageNum + 2)]];
        if (nil != subview1 && (pageNum + 2) < countPage)
        {
            NSLog(@"remove view with ID: %i",(pageNum + 2));
            [subview1 removeFromSuperview];
            [muDistionary removeObjectForKey:[NSNumber numberWithInt:(pageNum + 2)]];
        }
        
        UIView* subview2 = [muDistionary objectForKey:[NSNumber numberWithInt:(pageNum - 2)]];
        if (nil != subview2 && (pageNum - 2 >= 0))
        {
            NSLog(@"remove view with ID: %i",(pageNum - 2));
            [subview2 removeFromSuperview];
            [muDistionary removeObjectForKey:[NSNumber numberWithInt:(pageNum - 2)]];
        }
    //} withPrefix:@"remove community panel"];
}


-(void) assemblePanel:(int) pageNum
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSMutableArray * muArray = [db getCommunityDataByPage:pageNum];
    
    CGRect frame;
    
    UIView *subview = [[bundle loadNibNamed:@"CommunityViewModel_iPad" owner:self options:nil] lastObject];
        
    frame.origin.x = self.communityScrollView.frame.size.width * (pageNum);
    frame.origin.y = 0;
    frame.size.width = self.communityScrollView.frame.size.width;
    frame.size.height = subview.frame.size.height;
    if (subview != nil && muArray != nil)
    {
        
        UIControl *firstPanel = (UIControl*)[subview viewWithTag:606];
        UIControl *secondPanel = (UIControl*)[subview viewWithTag:611];
        UIControl *thirdPanel = (UIControl*)[subview viewWithTag:616];
        
        subview.frame = frame;
        
        UIImageView *firstImg = (UIImageView*)[subview viewWithTag:602];
        UILabel* firstLabelTitle = (UILabel*)[subview viewWithTag:604];
        UILabel* firstLabelTime = (UILabel*)[subview viewWithTag:603];
        UILabel* firstLabelDesc = (UILabel*)[subview viewWithTag:605];
        
        UIView* lineView1 = (UIView*)[subview viewWithTag:617];
        UIView* lineView2 = (UIView*)[subview viewWithTag:618];
        UIView* lineView3 = (UIView*)[subview viewWithTag:619];
            
        //根据数据加载subview
        if (muArray.count >= 1 && [muArray objectAtIndex:0])
        {
            NSMutableDictionary *muDict = [muArray objectAtIndex:0];
            
            //异步加载图片
            [self loadingImage:muDict andImageView:firstImg];
                        
            [firstLabelTitle setText:[muDict objectForKey:@"title"]];
            [firstLabelTime setText:[TimeUtil convertTimeFormat:[muDict objectForKey:@"timestamp"]]];
            [firstLabelDesc setText:[muDict objectForKey:@"description"]];
            [firstLabelDesc sizeToFit];
            //[homeTopTitle setValue:[muDict objectForKey:@"serverID"] forUndefinedKey:@"serverID"];
            firstPanel.accessibilityLabel = [muDict objectForKey:@"serverID"];
            [firstPanel addTarget:self action:@selector(panelClick:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        else
        {
            firstImg.hidden = YES;
            firstLabelTitle.hidden = YES;
            firstLabelTime.hidden = YES;
            firstLabelDesc.hidden = YES;
            lineView1.hidden = YES;
        }
        
        UIImageView *secondImg = (UIImageView*)[subview viewWithTag:607];
        UILabel* secondLabelTitle = (UILabel*)[subview viewWithTag:609];
        UILabel* secondLabelTime = (UILabel*)[subview viewWithTag:608];
        UILabel* secondLabelDesc = (UILabel*)[subview viewWithTag:610];
        if (muArray.count >= 2 && [muArray objectAtIndex:1])
        {
            NSMutableDictionary *muDict = [muArray objectAtIndex:1];
            
            //异步加载图片
            [self loadingImage:muDict andImageView:secondImg];            
            
            [secondLabelTitle setText:[muDict objectForKey:@"title"]];
            
            [secondLabelTime setText:[TimeUtil convertTimeFormat:[muDict objectForKey:@"timestamp"]]];            
            
            [secondLabelDesc setText:[muDict objectForKey:@"description"]];
            secondPanel.accessibilityLabel = [muDict objectForKey:@"serverID"];
            [secondPanel addTarget:self action:@selector(panelClick:) forControlEvents:UIControlEventTouchUpInside];
               
        }
        else
        {
            secondImg.hidden = YES;
            secondLabelTitle.hidden = YES;
            secondLabelTime.hidden = YES;
            secondLabelDesc.hidden = YES;
            lineView2.hidden = YES;
        }
        
        UIImageView *thirdImg = (UIImageView*)[subview viewWithTag:612];
        UILabel* thirdLabelTitle = (UILabel*)[subview viewWithTag:614];
        UILabel* thirdLabelTime = (UILabel*)[subview viewWithTag:613];
        UILabel* thirdLabelDesc = (UILabel*)[subview viewWithTag:615];
        
        if (muArray.count >= 3 && [muArray objectAtIndex:2])
        {
            NSMutableDictionary *muDict = [muArray objectAtIndex:2];
            
            //异步加载图片
            [self loadingImage:muDict andImageView:thirdImg];
                        
            [thirdLabelTitle setText:[muDict objectForKey:@"title"]];
            
            
            [thirdLabelTime setText:[TimeUtil convertTimeFormat:[muDict objectForKey:@"timestamp"]]];
            
            [thirdLabelDesc setText:[muDict objectForKey:@"description"]];
            thirdPanel.accessibilityLabel = [muDict objectForKey:@"serverID"];
            [thirdPanel addTarget:self action:@selector(panelClick:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        else
        {
            thirdImg.hidden = YES;
            thirdLabelTitle.hidden = YES;
            thirdLabelTime.hidden = YES;
            thirdLabelDesc.hidden = YES;
            lineView3.hidden = YES;
        }
        
        
        [self.communityScrollView addSubview:subview];
                
        [muDistionary setObject:subview forKey:[NSNumber  numberWithInt:(pageNum)]];
    }
}

-(void) loadingImage:(NSMutableDictionary*) muDict andImageView:(UIImageView*) uiImg
{
    NSString *path = [[[PATH_OF_DOCUMENT stringByAppendingPathComponent:@"thumb"] stringByAppendingPathComponent:[muDict objectForKey:@"serverID"]] stringByAppendingString:@".jpg"];
    
    if ([fileUtils fileISExist:path])
    {
        //加载本地文件
        [uiImg setImageWithURL:[NSURL fileURLWithPath:path]];
    }
    else //加载网络文件，并下载到本地
    {
        NSMutableString *muString = [muDict objectForKey:@"profile_path"];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[muString substringToIndex:[muString length] - 4] stringByAppendingString:@"-400x400.jpg"]]];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"loading image is success");
            [uiImg setImageWithURL:[NSURL fileURLWithPath:path]];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"loading image is failure %@",[error description]);
        }];
        [operation start];
    }
    
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
/*
-(NSString*) addLineFeedForString:(NSString *) str
{
    NSString *muStr = [[NSMutableString alloc] initWithString:[str stringByAppendingString:@"\n \n \n \n \n \n \n \n \n \n \n \n \n \n \n"]];
    return muStr;
}
*/
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pageChanged:(id)sender {
    pageControlBeingUsed = YES;
}
@end
