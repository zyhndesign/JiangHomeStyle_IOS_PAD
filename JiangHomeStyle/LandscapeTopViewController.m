//
//  LandscapeTopViewController.m
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-9-6.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import "LandscapeTopViewController.h"
#import "googleAnalytics/GAIDictionaryBuilder.h"

@interface LandscapeTopViewController ()

@end

@implementation LandscapeTopViewController

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
    self.screenName = @"风景界面";
    
    [[GAI sharedInstance].defaultTracker set:self.screenName
                                       value:@"LandscapeTopController Screen"];
    
    // Send the screen view.
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
   
    [center addObserver:self selector:@selector(landscapeImageAnimation:) name:@"LANDSCAPE_ANIMATION" object:nil];
    
    //风景上移动动画
    landscapeBgImageView = (UIImageView *)[self.view viewWithTag:301];
    
    
}

-(void)landscapeImageAnimation:(NSNotification *) notification
{
    UIScrollView *scrollView = [notification object];
    
    [UIView animateWithDuration:2.0 delay:0.5 options:UIViewAnimationCurveEaseOut animations:^{
        
        landscapeBgImageView.frame = CGRectMake(0, (self.view.frame.origin.y - scrollView.contentOffset.y), landscapeBgImageView.frame.size.width, landscapeBgImageView.frame.size.height);
        
    } completion:^(BOOL finished){
        
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
