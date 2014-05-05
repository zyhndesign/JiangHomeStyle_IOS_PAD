//
//  SuperColumnViewController.m
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 14-5-5.
//  Copyright (c) 2014年 cidesign. All rights reserved.
//

#import "SuperColumnViewController.h"
#import "FileUtils.h"
#import "AFNetworking.h"
#import "MJPopup/UIViewController+MJPopupViewController.h"
#import "PopupDetailViewController.h"

@interface SuperColumnViewController ()

@end

@implementation SuperColumnViewController

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
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!pageControlBeingUsed)
    {
        CGFloat pageWidth = columnScrollView.frame.size.width;
        currentPage = floor((columnScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        pageControl.currentPage = currentPage;
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

- (void)panelClick:(id)sender
{
    if (detailViewController == nil)
    {
        NSString *articleId = [sender accessibilityLabel];
        if ([sender isKindOfClass:[UITapGestureRecognizer class]] && (articleId == nil))
        {
            articleId = ((UITapGestureRecognizer *)sender).view.accessibilityLabel;
        }
                
        detailViewController = [[PopupDetailViewController alloc] initWithNibName:@"PopupView_iPad" bundle:nil andParams:articleId];
        detailViewController.delegate = self;
        [self presentPopupViewController:detailViewController animationType:MJPopupViewAnimationSlideRightLeft];
    }
}

- (void) closeButtonClicked
{
    detailViewController = nil;
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideLeftRight];
}


-(void) addNewModelInScrollView:(int) pageNum
{
    if (nil != columnScrollView)
    {
        UIView* subview1 = [muDistionary objectForKey:[NSNumber numberWithInt:(pageNum + 1)]];
        if (nil == subview1 && (pageNum + 1 < countPage))
        {
            [self assemblePanel:(pageNum + 1)];
        }
        
        UIView* subview2 = [muDistionary objectForKey:[NSNumber numberWithInt:(pageNum - 1)]];
        if (nil == subview2 && (pageNum - 1 >= 0))
        {
            [self assemblePanel:(pageNum - 1)];
        }
    }
}

-(void) removeOldModelInScrollView:(int)pageNum
{
    UIView* subview1 = [muDistionary objectForKey:[NSNumber numberWithInt:(pageNum + 2)]];
    if (nil != subview1 && (pageNum + 2) < countPage)
    {
        [subview1 removeFromSuperview];
        [muDistionary removeObjectForKey:[NSNumber numberWithInt:(pageNum + 2)]];
    }
    
    UIView* subview2 = [muDistionary objectForKey:[NSNumber numberWithInt:(pageNum - 2)]];
    if (nil != subview2 && (pageNum - 2 >= 0))
    {
        [subview2 removeFromSuperview];
        [muDistionary removeObjectForKey:[NSNumber numberWithInt:(pageNum - 2)]];
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
        
        NSString *suffixString;
        if ([muString hasSuffix:@".png"])
        {
            suffixString = [[muString substringToIndex:[muString length] - 4] stringByAppendingString:@"-300x300.png"];
        }
        else
        {
            suffixString = [[muString substringToIndex:[muString length] - 4] stringByAppendingString:@"-300x300.jpg"];
        }
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[suffixString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
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

/**
 *  该方法交给继承类去实现
 *
 *  @param pageNum 页码编号
 */
-(void) assemblePanel:(int) pageNum
{

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
