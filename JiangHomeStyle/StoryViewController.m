//
//  StoryViewController.m
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-8-29.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import "StoryViewController.h"
#import "MKBlockTimer/NSObject+MKBlockTimer.h"
#import "DBUtils.h"
#import "Constants.h"
#import "TimeUtil.h"
#import "VarUtils.h"
#import "FileUtils.h"
#import "AFNetworking.h"
#import "googleAnalytics/GAIDictionaryBuilder.h"

@interface StoryViewController ()
{
    
}

@end

@implementation StoryViewController

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
    self.screenName = @"物语界面";
    
    [[GAI sharedInstance].defaultTracker set:self.screenName
                                       value:@"StoryController Screen"];
    
    // Send the screen view.
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    int countArticle = [db countByCategory:STORY_CATEGORY];
    countPage = (countArticle / STORY_PAGE_INSIDE_NUM);
    if ((countArticle % STORY_PAGE_INSIDE_NUM) > 0)
    {
        countPage = countPage + 1;
    }
    
    columnScrollView = (UIScrollView *)[self.view viewWithTag:530];
    pageControl = (UIPageControl *)[self.view viewWithTag:531];
    columnScrollView.contentSize = CGSizeMake(columnScrollView.frame.size.width * countPage, columnScrollView.frame.size.height);
    columnScrollView.delegate = self;
    
    pageControl.currentPage = 0;
    pageControl.numberOfPages = countPage;
        
    muDistionary = [NSMutableDictionary dictionaryWithCapacity:3];
    currentPage = 0;
    
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
    NSMutableArray * muArray = [db getStoryDataByPage:pageNum];
   
    CGRect frame;
    
    UIView *subview = [[bundle loadNibNamed:@"StoryViewModel_iPad" owner:self options:nil] lastObject];
    frame.origin.x = columnScrollView.frame.size.width * (pageNum);
    frame.origin.y = 0;
    frame.size.width = columnScrollView.frame.size.width;
    frame.size.height = subview.frame.size.height;
    
    if (subview != nil && muArray != nil)
    {
        subview.frame = frame;
        
        //根据数据加载subview
        UIImageView *firstImg = (UIImageView*)[subview viewWithTag:502];
        UILabel* firstLabelTitle = (UILabel*)[subview viewWithTag:503];
        UIImageView *firstBgImg = (UIImageView*)[subview viewWithTag:504];
        
        if (muArray.count >= 1 && [muArray objectAtIndex:0])
        {
            NSMutableDictionary *muDict = [muArray objectAtIndex:0];
            
            //异步加载图片
            [self loadingImage:muDict andImageView:firstImg];
                       
            [firstLabelTitle setText:[muDict objectForKey:@"title"]];
           
            firstImg.accessibilityLabel = [muDict objectForKey:@"serverID"];            
            firstImg.userInteractionEnabled = YES;
            UITapGestureRecognizer *sigTab = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(panelClick:)];
            [firstImg addGestureRecognizer:sigTab];
            
            
            if ([[muDict objectForKey:@"hasVideo"] intValue] == 1)
            {
                [self addVideoImage:firstImg];
            }
        }
        else
        {
            firstImg.hidden = YES;
            firstLabelTitle.hidden = YES;
            firstBgImg.hidden = YES;
        }
        
        UIImageView *secondImg = (UIImageView*)[subview viewWithTag:505];
        UILabel* secondLabelTitle = (UILabel*)[subview viewWithTag:506];
        UIImageView *secondBgImg = (UIImageView*)[subview viewWithTag:507];
        
        if (muArray.count >= 2 && [muArray objectAtIndex:1])
        {
            NSMutableDictionary *muDict = [muArray objectAtIndex:1];
            
            //异步加载图片
            [self loadingImage:muDict andImageView:secondImg];            
            
            [secondLabelTitle setText:[muDict objectForKey:@"title"]];
                        
            secondImg.accessibilityLabel = [muDict objectForKey:@"serverID"];
            secondImg.userInteractionEnabled = YES;
             UITapGestureRecognizer *sigTab = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(panelClick:)];
            [secondImg addGestureRecognizer:sigTab];
            
            if ([[muDict objectForKey:@"hasVideo"] intValue] == 1)
            {
                [self addVideoImage:secondImg];
            }
        }
        else
        {
            secondImg.hidden = YES;
            secondLabelTitle.hidden = YES;
            secondBgImg.hidden = YES;
        }
        
        UIImageView *thirdImg = (UIImageView*)[subview viewWithTag:508];
        UILabel* thirdLabelTitle = (UILabel*)[subview viewWithTag:509];
        UIImageView *thirdBgImg = (UIImageView*)[subview viewWithTag:510];
        
        if (muArray.count >= 3 && [muArray objectAtIndex:2])
        {
            NSMutableDictionary *muDict = [muArray objectAtIndex:2];
            
            //异步加载图片
            [self loadingImage:muDict andImageView:thirdImg];
            
            
            [thirdLabelTitle setText:[muDict objectForKey:@"title"]];
            
            thirdImg.accessibilityLabel = [muDict objectForKey:@"serverID"];
            thirdImg.userInteractionEnabled = YES;
             UITapGestureRecognizer *sigTab = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(panelClick:)];
            [thirdImg addGestureRecognizer:sigTab];
            
            if ([[muDict objectForKey:@"hasVideo"] intValue] == 1)
            {
                [self addVideoImage:thirdImg];
            }
        }
        else
        {
            thirdImg.hidden = YES;
            thirdLabelTitle.hidden = YES;
            thirdBgImg.hidden = YES;
        }
        
        UIImageView *fourImg = (UIImageView*)[subview viewWithTag:511];
        UILabel* fourLabelTitle = (UILabel*)[subview viewWithTag:512];
        UIImageView *fourBgImg = (UIImageView*)[subview viewWithTag:513];
        if (muArray.count >= 4 && [muArray objectAtIndex:3])
        {
            NSMutableDictionary *muDict = [muArray objectAtIndex:3];
            
            //异步加载图片
            [self loadingImage:muDict andImageView:fourImg];
            
            
            [fourLabelTitle setText:[muDict objectForKey:@"title"]];
            
            fourImg.accessibilityLabel = [muDict objectForKey:@"serverID"];
            fourImg.userInteractionEnabled = YES;
             UITapGestureRecognizer *sigTab = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(panelClick:)];
            [fourImg addGestureRecognizer:sigTab];
            
            if ([[muDict objectForKey:@"hasVideo"] intValue] == 1)
            {
                [self addVideoImage:fourImg];
            }
        }
        else
        {
            fourImg.hidden = YES;
            fourLabelTitle.hidden = YES;
            fourBgImg.hidden = YES;
        }
        
        UIImageView *fiveImg = (UIImageView*)[subview viewWithTag:514];
        UILabel* fiveLabelTitle = (UILabel*)[subview viewWithTag:515];
        UIImageView *fiveBgImg = (UIImageView*)[subview viewWithTag:516];
        
        if (muArray.count >= 5 && [muArray objectAtIndex:4])
        {
            NSMutableDictionary *muDict = [muArray objectAtIndex:4];
            
            //异步加载图片
            [self loadingImage:muDict andImageView:fiveImg];            
            
            [fiveLabelTitle setText:[muDict objectForKey:@"title"]];
            
            fiveImg.accessibilityLabel = [muDict objectForKey:@"serverID"];
            fiveImg.userInteractionEnabled = YES;
             UITapGestureRecognizer *sigTab = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(panelClick:)];
            [fiveImg addGestureRecognizer:sigTab];
            
            if ([[muDict objectForKey:@"hasVideo"] intValue] == 1)
            {
                [self addVideoImage:fiveImg];
            }
        }
        else
        {
            fiveImg.hidden = YES;
            fiveLabelTitle.hidden = YES;
            fiveBgImg.hidden = YES;
        }
        
        UIImageView *sixImg = (UIImageView*)[subview viewWithTag:517];
        UILabel* sixLabelTitle = (UILabel*)[subview viewWithTag:518];
        UIImageView *sixBgImg = (UIImageView*)[subview viewWithTag:519];
        if (muArray.count >= 6 && [muArray objectAtIndex:5])
        {
            NSMutableDictionary *muDict = [muArray objectAtIndex:5];
            
            //异步加载图片
            [self loadingImage:muDict andImageView:sixImg];
                        
            [sixLabelTitle setText:[muDict objectForKey:@"title"]];
            
            sixImg.accessibilityLabel = [muDict objectForKey:@"serverID"];
            sixImg.userInteractionEnabled = YES;
             UITapGestureRecognizer *sigTab = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(panelClick:)];
            [sixImg addGestureRecognizer:sigTab];
            
            if ([[muDict objectForKey:@"hasVideo"] intValue] == 1)
            {
                [self addVideoImage:sixImg];
            }
        }
        else
        {
            sixImg.hidden = YES;
            sixLabelTitle.hidden = YES;
            sixBgImg.hidden = YES;
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
