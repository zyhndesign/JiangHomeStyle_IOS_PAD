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
#import "MJPopup/UIViewController+MJPopupViewController.h"
#import "PopupDetailViewController.h"
#import "googleAnalytics/GAIDictionaryBuilder.h"
#import "UILabel+VerticalAlign.h"

@interface LandscapeViewController ()<MJPopupDelegate>
{
    
}
@end

@implementation LandscapeViewController


@synthesize landscapeBtmBgView, landscapeScrollView,landscapePageControl;

extern DBUtils *db;
extern FileUtils *fileUtils;
extern PopupDetailViewController* detailViewController;

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
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.screenName = @"风景界面";
    
    [[GAI sharedInstance].defaultTracker set:self.screenName
                                       value:@"LandscapeController Screen"];
    
    // Send the screen view.
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    //[landscapeBtmBgView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"dmxj_bg.png"]]];
    landscapeBtmBgView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"dmxj_bg.png"]];
    
    int countArticle = [db countByCategory:LANDSCAPE_CATEGORY];
    countPage = (countArticle / LANDSCAPE_PAGE_INSIDE_NUM);
    if ((countArticle % LANDSCAPE_PAGE_INSIDE_NUM) > 0)
    {
        countPage = countPage + 1;
    }
    
    muDistionary = [NSMutableDictionary dictionaryWithCapacity:4];
    currentPage = 0;
    
    for (int i = 0; i < 2; i++)
    {
        if (i <= countPage)
        {            
            [self assemblePanel:i];
        }
    }
        
    self.landscapeScrollView.contentSize = CGSizeMake(self.landscapeScrollView.frame.size.width * countPage, self.landscapeScrollView.frame.size.height);
    
    self.landscapeScrollView.delegate = self;
    
    self.landscapePageControl.currentPage = 0;
    self.landscapePageControl.numberOfPages = countPage;
    
    pageControlBeingUsed = NO;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"beigin...");
    
    if (!pageControlBeingUsed)
    {
        CGFloat pageWidth = self.landscapeScrollView.frame.size.width;
        currentPage = floor((self.landscapeScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        //NSLog(@"%i",currentPage);
        
        //NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(addNewModelInScrollView:) object:[NSNumber numberWithInt:currentPage]];
        //NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        //[queue addOperation:operation];
        
        self.landscapePageControl.currentPage = currentPage;
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
    NSLog(@"end.. Uesd.");
    //[self performSelectorInBackground:@selector(removeOldModelInScrollView:) withObject:[NSNumber numberWithInt:currentPage]];
    [self removeOldModelInScrollView:currentPage];
    pageControlBeingUsed = NO;
    
}

-(void) addNewModelInScrollView:(int) pageNum
{
    //[self logTimeTakenToRunBlock:^{
        if (nil != landscapeScrollView)
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
   // } withPrefix:@"add landscape panel"];
    
}

-(void) removeOldModelInScrollView:(int)pageNum
{
    //[self logTimeTakenToRunBlock:^{
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
    //} withPrefix:@"remove landscape panel"];
}


-(void) assemblePanel:(int) pageNum
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSMutableArray * muArray = [db getLandscapeDataByPage:pageNum];
    
    CGRect frame;
    UIView *subview = [[bundle loadNibNamed:@"LandscapeViewModel_iPad" owner:self options:nil] lastObject];
    
    frame.origin.x = self.landscapeScrollView.frame.size.width * (pageNum);
    frame.origin.y = 0;
    frame.size.width = self.landscapeScrollView.frame.size.width;
    frame.size.height = subview.frame.size.height;
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
            [self loadingImage:muDict andImageView:firstImg];
            
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
            [self loadingImage:muDict andImageView:secondImg];
            
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
            [self loadingImage:muDict andImageView:thirdImg];
            
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
            [self loadingImage:muDict andImageView:fourImg];
            
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
        
        [self.landscapeScrollView addSubview:subview];
        
        NSLog(@"add view with ID: %i",(pageNum));
        
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

-(void) addVideoImage:(UIView *)view
{
    UIImage *videoImage = [UIImage imageNamed:@"hasvideo"];
    UIImageView *videoImgView = [[UIImageView alloc] initWithImage:videoImage];
    videoImgView.contentMode = UIViewContentModeScaleAspectFit;
    videoImgView.frame = CGRectMake(0, 0, 80, 80);
    [view addSubview:videoImgView];
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
