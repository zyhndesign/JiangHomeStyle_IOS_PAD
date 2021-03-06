//
//  CommunityTopViewController.m
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-9-6.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import "CommunityTopViewController.h"
#import "googleAnalytics/GAIDictionaryBuilder.h"

@interface CommunityTopViewController ()

@end

@implementation CommunityTopViewController

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
    // Do any additional setup after loading the view.
    self.screenName = @"社区界面";
    
    [[GAI sharedInstance].defaultTracker set:self.screenName
                                       value:@"CommunityTopController Screen"];
    
    // Send the screen view.
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(communityImageAnimation:) name:@"COMMUNITY_ANIMATION" object:nil];
    
    //风景上移动动画
    communityBgImageView = (UIImageView *)[self.view viewWithTag:601];
}

-(void)communityImageAnimation:(NSNotification *) notification
{
    UIScrollView *scrollView = [notification object];
    
    [UIView animateWithDuration:2.0 delay:0.5 options:UIViewAnimationCurveEaseOut animations:^{
        communityBgImageView.frame = CGRectMake(0, self.view.frame.origin.y - scrollView.contentOffset.y, communityBgImageView.frame.size.width, communityBgImageView.frame.size.height);
        
    } completion:^(BOOL finished){
        
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
