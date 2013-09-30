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
#import "MJPopup/UIViewController+MJPopupViewController.h"
#import "PopupDetailViewController.h"
#import "googleAnalytics/GAIDictionaryBuilder.h"

@interface StoryViewController ()<MJPopupDelegate>
{
    
}

@end

@implementation StoryViewController

@synthesize storyScrollView;

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
    
    muDistionary = [NSMutableDictionary dictionaryWithCapacity:3];
    currentPage = 0;
    
    for (int i = 0; i < 2; i++)
    {
        if (i <= countPage)
        {
            [self assemblePanel:i];
        }
    }
    
    self.storyScrollView.contentSize = CGSizeMake(self.storyScrollView.frame.size.width * countPage, self.storyScrollView.frame.size.height);
    
    self.storyScrollView.delegate = self;

}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"beigin...");
    
    CGFloat pageWidth = self.storyScrollView.frame.size.width;
    currentPage = floor((self.storyScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    NSLog(@"%i",currentPage);
    
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"beigin. Drag..");
    [self addNewModelInScrollView:currentPage];
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"beigin.. Uesd.");
    [self removeOldModelInScrollView:currentPage];
}

-(void) addNewModelInScrollView:(int) pageNum
{
    [self logTimeTakenToRunBlock:^{
        if (nil != storyScrollView)
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
    } withPrefix:@"add story panel"];
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
    } withPrefix:@"remove story panel"];
}

-(void) assemblePanel:(int) pageNum
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSMutableArray * muArray = [db getStoryDataByPage:pageNum];
   
    CGRect frame;
    
    UIView *subview = [[bundle loadNibNamed:@"StoryViewModel_iPad" owner:self options:nil] lastObject];
    frame.origin.x = self.storyScrollView.frame.size.width * (pageNum);
    frame.origin.y = 0;
    frame.size.width = self.storyScrollView.frame.size.width;
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
            
            //[homeTopTitle setValue:[muDict objectForKey:@"serverID"] forUndefinedKey:@"serverID"];
            firstImg.accessibilityLabel = [muDict objectForKey:@"serverID"];
            
            firstImg.userInteractionEnabled = YES;
             UITapGestureRecognizer *sigTab = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(panelClick:)];
            [firstImg addGestureRecognizer:sigTab];
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
        }
        else
        {
            sixImg.hidden = YES;
            sixLabelTitle.hidden = YES;
            sixBgImg.hidden = YES;
        }
        
        [self.storyScrollView addSubview:subview];
        
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
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[muString substringToIndex:[muString length] - 4] stringByAppendingString:@"-400x400.jpg"]]];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"loading image is success");
            //[uiImg setImage:[UIImage imageWithContentsOfFile:path]];
            [uiImg setImageWithURL:[NSURL fileURLWithPath:path]];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"loading image is failure %@",[error description]);
        }];
        [operation start];
    }
    
}

- (void)panelClick:(UITapGestureRecognizer*)sender
{
    if (detailViewController == nil)
    {
        detailViewController = [[PopupDetailViewController alloc] initWithNibName:@"PopupView_iPad" bundle:nil andParams:[[sender view] accessibilityLabel]];
        detailViewController.delegate = self;
        [self presentPopupViewController:detailViewController animationType:MJPopupViewAnimationSlideRightLeft];
    }
}

- (void) closeButtonClicked
{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideLeftRight];
    detailViewController = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
