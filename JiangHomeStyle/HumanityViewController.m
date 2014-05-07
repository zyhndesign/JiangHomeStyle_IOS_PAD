//
//  HumanityViewController.m
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-8-29.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import "HumanityViewController.h"
#import "MKBlockTimer/NSObject+MKBlockTimer.h"
#import "DBUtils.h"
#import "Constants.h"
#import "TimeUtil.h"
#import "VarUtils.h"
#import "FileUtils.h"
#import "AFNetworking.h"
#import "googleAnalytics/GAIDictionaryBuilder.h"
#import "UILabel+VerticalAlign.h"

@interface HumanityViewController ()
{
    
}

@end

@implementation HumanityViewController

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
    self.screenName = @"人文界面";
    
    [[GAI sharedInstance].defaultTracker set:self.screenName
                                       value:@"HumanityController Screen"];
    
    // Send the screen view.
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    muDistionary = [NSMutableDictionary dictionaryWithCapacity:3];
    int countArticle = [db countByCategory:HUMANITY_CATEGORY];
    
    countPage = (countArticle / HUMANITY_PAGE_INSIDE_NUM);
    if ((countArticle % HUMANITY_PAGE_INSIDE_NUM) > 0)
    {
        countPage = countPage + 1;
    }
    currentPage = 0;
    
    columnScrollView = (UIScrollView *)[self.view viewWithTag:430];
    pageControl = (UIPageControl *)[self.view viewWithTag:431];
    columnScrollView.contentSize = CGSizeMake(columnScrollView.frame.size.width * countPage, columnScrollView.frame.size.height);
    columnScrollView.delegate = self;
    
    pageControl.currentPage = 0;
    pageControl.numberOfPages = countPage;
    
    thumbDownQueue = [NSOperationQueue new];
    [thumbDownQueue setMaxConcurrentOperationCount:2];
    
    for (int i = 0; i < 2; i++)
    {
        if(i <= countPage)
        {
            [self assemblePanel:i];
        }
    }
}

-(void) assemblePanel:(int) pageNum
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSMutableArray * muArray = [db getHumanityDataByPage:pageNum];    
    CGRect frame;
    
    UIView *subview = [[bundle loadNibNamed:@"HumanityViewModel_iPad" owner:self options:nil] lastObject];
    frame.origin.x = columnScrollView.frame.size.width * (pageNum);
    frame.origin.y = 0;
    frame.size.width = columnScrollView.frame.size.width;
    frame.size.height = subview.frame.size.height;
    
    NSOperation *downOperation = nil;
    
    if (subview != nil && muArray != nil)
    {
        
        UIControl *firstPanel = (UIControl*)[subview viewWithTag:414];
        UIControl *secondPanel = (UIControl*)[subview viewWithTag:415];
        UIControl *thirdPanel = (UIControl*)[subview viewWithTag:416];
        
        UIView *firstLine = (UIView*)[subview viewWithTag:415];
        UIView *secondLine = (UIView*)[subview viewWithTag:416];
        UIView *thirdLine = (UIView*)[subview viewWithTag:417];
        UIView *fourLine = (UIView*)[subview viewWithTag:418];
        
        subview.frame = frame;
        
        //根据数据加载subview
        if (muArray.count >= 1 && [muArray objectAtIndex:0])
        {
            
            NSMutableDictionary *muDict = [muArray objectAtIndex:0];
            
            UIImageView *firstImg = (UIImageView*)[subview viewWithTag:402];
            //异步加载图片
            downOperation = [self loadingImageOperation:muDict andImageView:firstImg];
            if (downOperation != nil)
            {
                [thumbDownQueue addOperation:downOperation];
            }
            
            UILabel* firstLabelTitle = (UILabel*)[subview viewWithTag:403];
            [firstLabelTitle setText:[muDict objectForKey:@"title"]];
            [firstLabelTitle alignTop];
            
            UILabel* firstLabelTime = (UILabel*)[subview viewWithTag:404];
               
            [firstLabelTime setText:[TimeUtil convertTimeFormat:[muDict objectForKey:@"timestamp"]]];
            UILabel* firstLabelDesc = (UILabel*)[subview viewWithTag:405];
            
            [firstLabelDesc setText:[muDict objectForKey:@"description"]];
            [firstLabelDesc alignTop];
            
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
            firstPanel.hidden = YES;
            firstLine.hidden = YES;
        }
        
        if (muArray.count >= 2 && [muArray objectAtIndex:1])
        {
            NSMutableDictionary *muDict = [muArray objectAtIndex:1];
            UIImageView *secondImg = (UIImageView*)[subview viewWithTag:406];
            //异步加载图片
            downOperation = [self loadingImageOperation:muDict andImageView:secondImg];
            if (downOperation != nil)
            {
                [thumbDownQueue addOperation:downOperation];
            }
            
            UILabel* secondLabelTitle = (UILabel*)[subview viewWithTag:407];
            [secondLabelTitle setText:[muDict objectForKey:@"title"]];
            [secondLabelTitle alignTop];
            
            UILabel* secondLabelTime = (UILabel*)[subview viewWithTag:408];
            [secondLabelTime setText:[TimeUtil convertTimeFormat:[muDict objectForKey:@"timestamp"]]];
            
            UILabel* secondLabelDesc = (UILabel*)[subview viewWithTag:409];
            [secondLabelDesc setText:[muDict objectForKey:@"description"]];
            [secondLabelDesc alignTop];
            
            secondPanel.accessibilityLabel = [muDict objectForKey:@"serverID"];
            [secondPanel addTarget:self action:@selector(panelClick:) forControlEvents:UIControlEventTouchUpInside];
            
            if ([[muDict objectForKey:@"hasVideo"] intValue] == 1)
            {
                [self addVideoImage:secondImg];
            }
        }
        else
        {
            secondPanel.hidden = YES;
            secondLine.hidden = YES;
        }
        
        if (muArray.count >= 3 && [muArray objectAtIndex:2])
        {
            NSMutableDictionary *muDict = [muArray objectAtIndex:2];
            UIImageView *thirdImg = (UIImageView*)[subview viewWithTag:410];
            //异步加载图片
            downOperation = [self loadingImageOperation:muDict andImageView:thirdImg];
            if (downOperation != nil)
            {
                [thumbDownQueue addOperation:downOperation];
            }
            
            UILabel* thirdLabelTitle = (UILabel*)[subview viewWithTag:411];
            [thirdLabelTitle setText:[muDict objectForKey:@"title"]];
            [thirdLabelTitle alignTop];
            
            UILabel* thirdLabelTime = (UILabel*)[subview viewWithTag:412];
            [thirdLabelTime setText:[TimeUtil convertTimeFormat:[muDict objectForKey:@"timestamp"]]];
            UILabel* thirdLabelDesc = (UILabel*)[subview viewWithTag:413];
            [thirdLabelDesc setText:[muDict objectForKey:@"description"]];
            [thirdLabelDesc alignTop];
            
            thirdPanel.accessibilityLabel = [muDict objectForKey:@"serverID"];
            [thirdPanel addTarget:self action:@selector(panelClick:) forControlEvents:UIControlEventTouchUpInside];
            
            if ([[muDict objectForKey:@"hasVideo"] intValue] == 1)
            {
                [self addVideoImage:thirdImg];
            }
        }
        else
        {
            thirdPanel.hidden = YES;
            thirdLine.hidden = YES;
            fourLine.hidden = YES;
        }
        
        [columnScrollView addSubview:subview];
          
        [muDistionary setObject:subview forKey:[NSNumber numberWithInt:(pageNum)]];
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
