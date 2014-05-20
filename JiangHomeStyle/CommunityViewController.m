//
//  CommunityViewController.m
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-8-29.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import "CommunityViewController.h"
#import "DBUtils.h"
#import "Constants.h"
#import "TimeUtil.h"
#import "VarUtils.h"
#import "FileUtils.h"
#import "googleAnalytics/GAIDictionaryBuilder.h"
#import "UILabel+VerticalAlign.h"

@interface CommunityViewController ()
{
    
}

@end

@implementation CommunityViewController

extern DBUtils *db;

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
    
    columnScrollView = (UIScrollView *)[self.view viewWithTag:630];
    pageControl = (UIPageControl *)[self.view viewWithTag:631];
    columnScrollView.contentSize = CGSizeMake(columnScrollView.frame.size.width * countPage, columnScrollView.frame.size.height);
    columnScrollView.delegate = self;
    
    pageControl.currentPage = 0;
    pageControl.numberOfPages = countPage;
        
    muDistionary = [NSMutableDictionary dictionaryWithCapacity:3];
    currentPage = 0;
    
    thumbDownQueue = [NSOperationQueue new];
    [thumbDownQueue setMaxConcurrentOperationCount:2];
    
    for (int i = 0; i < 2; i++)
    {
        if (i <= countPage)
        {
            [self assemblePanel:i];
        }
    }    
}

-(void) assemblePanel:(int) pageNum
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSMutableArray * muArray = [db getCommunityDataByPage:pageNum];
    
    CGRect frame;
    
    UIView *subview = [[bundle loadNibNamed:@"CommunityViewModel_iPad" owner:self options:nil] lastObject];
        
    frame.origin.x = columnScrollView.frame.size.width * (pageNum);
    frame.origin.y = 0;
    frame.size.width = columnScrollView.frame.size.width;
    frame.size.height = subview.frame.size.height;
    
    NSOperation *downOperation = nil;
    
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
            downOperation = [self loadingImageOperation:muDict andImageView:firstImg];
            if (downOperation != nil)
            {
                [thumbDownQueue addOperation:downOperation];
            }
                        
            [firstLabelTitle setText:[muDict objectForKey:@"title"]];
            [firstLabelTitle alignTop];
            
            [firstLabelTime setText:[TimeUtil convertTimeFormat:[muDict objectForKey:@"timestamp"]]];
            [firstLabelDesc setText:[muDict objectForKey:@"description"]];
            [firstLabelDesc alignTop];
            firstLabelDesc.lineBreakMode = NSLineBreakByTruncatingTail;
            //[homeTopTitle setValue:[muDict objectForKey:@"serverID"] forUndefinedKey:@"serverID"];
            firstPanel.accessibilityLabel = [muDict objectForKey:@"serverID"];
            [firstPanel addTarget:self action:@selector(panelClick:) forControlEvents:UIControlEventTouchUpInside];
            
            if ([[muDict objectForKey:@"hasVideo"] intValue] == 1)
            {
                [self addVideoImage:firstImg];
            }
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
            downOperation = [self loadingImageOperation:muDict andImageView:secondImg];
            if (downOperation != nil)
            {
                [thumbDownQueue addOperation:downOperation];
            }
            
            [secondLabelTitle setText:[muDict objectForKey:@"title"]];
            [secondLabelTitle alignTop];
            
            [secondLabelTime setText:[TimeUtil convertTimeFormat:[muDict objectForKey:@"timestamp"]]];            
            
            [secondLabelDesc setText:[muDict objectForKey:@"description"]];
            [secondLabelDesc alignTop];
            secondLabelDesc.lineBreakMode = NSLineBreakByTruncatingTail;
            
            secondPanel.accessibilityLabel = [muDict objectForKey:@"serverID"];
            [secondPanel addTarget:self action:@selector(panelClick:) forControlEvents:UIControlEventTouchUpInside];
            
            if ([[muDict objectForKey:@"hasVideo"] intValue] == 1)
            {
                [self addVideoImage:secondImg];
            }
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
            downOperation = [self loadingImageOperation:muDict andImageView:thirdImg];
            if (downOperation != nil)
            {
                [thumbDownQueue addOperation:downOperation];
            }
                        
            [thirdLabelTitle setText:[muDict objectForKey:@"title"]];
            [thirdLabelTitle alignTop];
            
            [thirdLabelTime setText:[TimeUtil convertTimeFormat:[muDict objectForKey:@"timestamp"]]];
            
            [thirdLabelDesc setText:[muDict objectForKey:@"description"]];
            [thirdLabelDesc alignTop];            
            thirdLabelDesc.lineBreakMode = NSLineBreakByTruncatingTail;
            
            thirdPanel.accessibilityLabel = [muDict objectForKey:@"serverID"];
            [thirdPanel addTarget:self action:@selector(panelClick:) forControlEvents:UIControlEventTouchUpInside];
            
            if ([[muDict objectForKey:@"hasVideo"] intValue] == 1)
            {
                [self addVideoImage:thirdImg];
            }
        }
        else
        {
            thirdImg.hidden = YES;
            thirdLabelTitle.hidden = YES;
            thirdLabelTime.hidden = YES;
            thirdLabelDesc.hidden = YES;
            lineView3.hidden = YES;
        }
        
        
        [columnScrollView addSubview:subview];
                
        [muDistionary setObject:subview forKey:[NSNumber  numberWithInt:(pageNum)]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pageChanged:(id)sender {
    pageControlBeingUsed = YES;
}

@end
