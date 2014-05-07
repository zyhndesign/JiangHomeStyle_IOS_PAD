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

- (void)panelClick:(id)sender
{
    if (detailViewController != nil)
    {
        detailViewController = nil;
    }
    
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


-(NSOperation *) loadingImageOperation:(NSMutableDictionary*) muDict andImageView:(UIImageView*) uiImg
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
        return operation;
    }
    return nil;
}

-(void) addVideoImage:(UIView *)view
{
    UIImage *videoImage = [UIImage imageNamed:@"hasvideo"];
    UIImageView *videoImgView = [[UIImageView alloc] initWithImage:videoImage];
    videoImgView.contentMode = UIViewContentModeScaleAspectFit;
    videoImgView.frame = CGRectMake(0, 0, 80, 80);
    [view addSubview:videoImgView];
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
