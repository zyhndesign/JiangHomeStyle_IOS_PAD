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
#import "MJPopup/UIViewController+MJPopupViewController.h"
#import "PopupDetailViewController.h"
#import "googleAnalytics/GAIDictionaryBuilder.h"

@interface HumanityViewController ()<MJPopupDelegate>
{
    
}

@end

@implementation HumanityViewController

@synthesize humanityScrollView,humanityPageContral;

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
    
    for (int i = 0; i < 2; i++)
    {
        if(i <= countPage)
        {
            [self assemblePanel:i];
        }
    }
    
    self.humanityScrollView.contentSize = CGSizeMake(self.humanityScrollView.frame.size.width * countPage, self.humanityScrollView.frame.size.height);
    
    self.humanityScrollView.delegate = self;
    
    self.humanityPageContral.currentPage = 0;
    self.humanityPageContral.numberOfPages = countPage;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!pageControlBeingUsed)
    {
        NSLog(@"beigin...");
        
        CGFloat pageWidth = self.humanityScrollView.frame.size.width;
        currentPage = floor((self.humanityScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        NSLog(@"%i",currentPage);
        
        self.humanityPageContral.currentPage = currentPage;
    }
    
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"beigin. Drag..");
    [self addNewModelInScrollView:currentPage];
    pageControlBeingUsed = NO;
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"beigin.. Uesd.");
    [self removeOldModelInScrollView:currentPage];
    pageControlBeingUsed = NO;
}

-(void) addNewModelInScrollView:(int) pageNum
{
    [self logTimeTakenToRunBlock:^{
        if (nil != humanityScrollView)
        {
            NSLog(@"currentPage : %i",currentPage);
                                
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
    } withPrefix:@"add humanity panel"];
}

-(void) removeOldModelInScrollView:(int)pageNum
{
    [self logTimeTakenToRunBlock:^{
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
    } withPrefix:@"remove humanity panel"];
}

-(void) assemblePanel:(int) pageNum
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSMutableArray * muArray = [db getHumanityDataByPage:pageNum];    
    CGRect frame;
    
    UIView *subview = [[bundle loadNibNamed:@"HumanityViewModel_iPad" owner:self options:nil] lastObject];
    frame.origin.x = self.humanityScrollView.frame.size.width * (pageNum);
    frame.origin.y = 0;
    frame.size.width = self.humanityScrollView.frame.size.width;
    frame.size.height = subview.frame.size.height;
    
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
            [self loadingImage:muDict andImageView:firstImg];
            
            UILabel* firstLabelTitle = (UILabel*)[subview viewWithTag:403];
            [firstLabelTitle setText:[muDict objectForKey:@"title"]];
            UILabel* firstLabelTime = (UILabel*)[subview viewWithTag:404];
               
            [firstLabelTime setText:[TimeUtil convertTimeFormat:[muDict objectForKey:@"timestamp"]]];
            UILabel* firstLabelDesc = (UILabel*)[subview viewWithTag:405];
            
            [firstLabelDesc setText:[muDict objectForKey:@"description"]];
            [firstLabelDesc sizeToFit];
            //[homeTopTitle setValue:[muDict objectForKey:@"serverID"] forUndefinedKey:@"serverID"];
            firstPanel.accessibilityLabel = [muDict objectForKey:@"serverID"];
            [firstPanel addTarget:self action:@selector(panelClick:) forControlEvents:UIControlEventTouchUpInside];
              
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
            [self loadingImage:muDict andImageView:secondImg];
            
            UILabel* secondLabelTitle = (UILabel*)[subview viewWithTag:407];
            [secondLabelTitle setText:[muDict objectForKey:@"title"]];
            
            UILabel* secondLabelTime = (UILabel*)[subview viewWithTag:408];
            [secondLabelTime setText:[TimeUtil convertTimeFormat:[muDict objectForKey:@"timestamp"]]];
            
            UILabel* secondLabelDesc = (UILabel*)[subview viewWithTag:409];
            [secondLabelDesc setText:[muDict objectForKey:@"description"]];
            [secondLabelDesc sizeToFit];
            secondPanel.accessibilityLabel = [muDict objectForKey:@"serverID"];
            [secondPanel addTarget:self action:@selector(panelClick:) forControlEvents:UIControlEventTouchUpInside];
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
            [self loadingImage:muDict andImageView:thirdImg];
            
            UILabel* thirdLabelTitle = (UILabel*)[subview viewWithTag:411];
            [thirdLabelTitle setText:[muDict objectForKey:@"title"]];
            
            UILabel* thirdLabelTime = (UILabel*)[subview viewWithTag:412];
            [thirdLabelTime setText:[TimeUtil convertTimeFormat:[muDict objectForKey:@"timestamp"]]];
            UILabel* thirdLabelDesc = (UILabel*)[subview viewWithTag:413];
            [thirdLabelDesc setText:[muDict objectForKey:@"description"]];
            [thirdLabelDesc sizeToFit];
            thirdPanel.accessibilityLabel = [muDict objectForKey:@"serverID"];
            [thirdPanel addTarget:self action:@selector(panelClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            thirdPanel.hidden = YES;
            thirdLine.hidden = YES;
            fourLine.hidden = YES;
        }
        
        [self.humanityScrollView addSubview:subview];
          
        [muDistionary setObject:subview forKey:[NSNumber numberWithInt:(pageNum)]];
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
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideLeftRight];
    detailViewController = nil;
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
