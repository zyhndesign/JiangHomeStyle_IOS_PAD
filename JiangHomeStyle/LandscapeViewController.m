//
//  LandscapeViewController.m
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-8-29.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import "LandscapeViewController.h"
#import "MKBlockTimer/NSObject+MKBlockTimer.h"
#import "DBUtils.h"
#import "Constants.h"
#import "TimeUtil.h"
#import "VarUtils.h"
#import "FileUtils.h"
#import "AFNetworking.h"
#import "PopupDetailViewController.h"
#import "googleAnalytics/GAIDictionaryBuilder.h"
#import "UILabel+VerticalAlign.h"

@interface LandscapeViewController ()
{    
}
@end

@implementation LandscapeViewController


@synthesize landscapeBtmBgView;

extern DBUtils *db;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    //NSLog(@"inint landscape view 1");
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self = [[LandscapeViewController new] initWithNibName:@"LandscapeTopController_iPad" bundle:[NSBundle mainBundle]];
        //NSLog(@"inint landscape view 2");
    }
    
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"view did load in LandscapeViewController...");
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.screenName = @"风景界面";
    
    [[GAI sharedInstance].defaultTracker set:self.screenName
                                       value:@"LandscapeController Screen"];
    
    // Send the screen view.
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    //[landscapeBtmBgView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"dmxj_bg.png"]]];
    int countArticle = [db countByCategory:LANDSCAPE_CATEGORY];
    countPage = (countArticle / LANDSCAPE_PAGE_INSIDE_NUM);
    if ((countArticle % LANDSCAPE_PAGE_INSIDE_NUM) > 0)
    {
        countPage = countPage + 1;
    }
    
    landscapeBtmBgView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"dmxj_bg.png"]];
    columnScrollView = (UIScrollView *)[self.view viewWithTag:330];
    pageControl = (UIPageControl *)[self.view viewWithTag:331];
    columnScrollView.contentSize = CGSizeMake(columnScrollView.frame.size.width * countPage, columnScrollView.frame.size.height);
    columnScrollView.delegate = self;
    
    pageControl.currentPage = 0;
    pageControl.numberOfPages = countPage;
    
    pageControlBeingUsed = NO;
    
    
    muDistionary = [NSMutableDictionary dictionaryWithCapacity:4];
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
    NSMutableArray * muArray = [db getLandscapeDataByPage:pageNum];
    
    CGRect frame;
    UIView *subview = [[bundle loadNibNamed:@"LandscapeViewModel_iPad" owner:self options:nil] lastObject];
    
    frame.origin.x = columnScrollView.frame.size.width * (pageNum);
    frame.origin.y = 15;
    frame.size.width = columnScrollView.frame.size.width;
    frame.size.height = subview.frame.size.height;
    
    NSOperation *downOperation = nil;
    
    if (subview != nil && muArray != nil)
    {
        UIControl *firstPanel = (UIControl*)[subview viewWithTag:318];
        UIControl *secondPanel = (UIControl*)[subview viewWithTag:319];
        UIControl *thirdPanel = (UIControl*)[subview viewWithTag:320];
        UIControl *fourPanel = (UIControl*)[subview viewWithTag:321];
        
        UIView *firstLine = (UIView*)[subview viewWithTag:322];
        UIView *secondLine = (UIView*)[subview viewWithTag:323];
        UIView *thirdLine = (UIView*)[subview viewWithTag:324];
        
        subview.frame = frame;
        
        //根据数据加载subview
        if (muArray.count >= 1 && [muArray objectAtIndex:0])
        {
            NSMutableDictionary *muDict = [muArray objectAtIndex:0];
            
            UIImageView *firstImg = (UIImageView*)[subview viewWithTag:302];
            //异步加载图片
            downOperation = [self loadingImageOperation:muDict andImageView:firstImg];
            if (downOperation != nil)
            {
                [thumbDownQueue addOperation:downOperation];
            }
            
            UILabel* firstLabelTitle = (UILabel*)[subview viewWithTag:303];
            [firstLabelTitle setText:[muDict objectForKey:@"title"]];
            UILabel* firstLabelTime = (UILabel*)[subview viewWithTag:304];
            [firstLabelTime setText:[TimeUtil convertTimeFormat:[muDict objectForKey:@"timestamp"]]];
            UILabel* firstLabelDesc = (UILabel*)[subview viewWithTag:305];
            
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
            firstPanel.hidden = YES;
            firstLine.hidden = YES;            
        }
        if (muArray.count >= 2 && [muArray objectAtIndex:1])
        {
            NSMutableDictionary *muDict = [muArray objectAtIndex:1];
            UIImageView *secondImg = (UIImageView*)[subview viewWithTag:306];
            //异步加载图片
            downOperation = [self loadingImageOperation:muDict andImageView:secondImg];
            if (downOperation != nil)
            {
                [thumbDownQueue addOperation:downOperation];
            }
            
            UILabel* secondLabelTitle = (UILabel*)[subview viewWithTag:307];
            [secondLabelTitle setText:[muDict objectForKey:@"title"]];
            
            UILabel* secondLabelTime = (UILabel*)[subview viewWithTag:308];
            [secondLabelTime setText:[TimeUtil convertTimeFormat:[muDict objectForKey:@"timestamp"]]];
            
            UILabel* secondLabelDesc = (UILabel*)[subview viewWithTag:309];
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
            secondPanel.hidden = YES;
            secondLine.hidden = YES;
        }
        
        if (muArray.count >= 3 && [muArray objectAtIndex:2])
        {
            NSMutableDictionary *muDict = [muArray objectAtIndex:2];
            UIImageView *thirdImg = (UIImageView*)[subview viewWithTag:313];
            //异步加载图片
            downOperation = [self loadingImageOperation:muDict andImageView:thirdImg];
            if (downOperation != nil)
            {
                [thumbDownQueue addOperation:downOperation];
            }
            
            UILabel* thirdLabelTitle = (UILabel*)[subview viewWithTag:310];
            [thirdLabelTitle setText:[muDict objectForKey:@"title"]];
            
            UILabel* thirdLabelTime = (UILabel*)[subview viewWithTag:311];
            [thirdLabelTime setText:[TimeUtil convertTimeFormat:[muDict objectForKey:@"timestamp"]]];
            UILabel* thirdLabelDesc = (UILabel*)[subview viewWithTag:312];
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
            thirdPanel.hidden = YES;
            thirdLine.hidden = YES;
        }
        
        if (muArray.count >= 4 && [muArray objectAtIndex:3])
        {
            NSMutableDictionary *muDict = [muArray objectAtIndex:3];
            UIImageView *fourImg = (UIImageView*)[subview viewWithTag:314];
            //异步加载图片
            downOperation = [self loadingImageOperation:muDict andImageView:fourImg];
            if (downOperation != nil)
            {
                [thumbDownQueue addOperation:downOperation];
            }
            
            UILabel* fourLabelTitle = (UILabel*)[subview viewWithTag:315];
            [fourLabelTitle setText:[muDict objectForKey:@"title"]];
            UILabel* fourLabelTime = (UILabel*)[subview viewWithTag:316];
            [fourLabelTime setText:[TimeUtil convertTimeFormat:[muDict objectForKey:@"timestamp"]]];
            UILabel* fourLabelDesc = (UILabel*)[subview viewWithTag:317];
            [fourLabelDesc setText:[muDict objectForKey:@"description"]];
            [fourLabelDesc alignTop];
            fourLabelDesc.lineBreakMode = NSLineBreakByTruncatingTail;
            
            fourPanel.accessibilityLabel = [muDict objectForKey:@"serverID"];
            [fourPanel addTarget:self action:@selector(panelClick:) forControlEvents:UIControlEventTouchUpInside];
            
            if ([[muDict objectForKey:@"hasVideo"] intValue] == 1)
            {
                [self addVideoImage:fourImg];
            }
        }
        else
        {
            fourPanel.hidden = YES;
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

- (IBAction)changePage:(id)sender
{
    pageControlBeingUsed = YES;
}
@end
