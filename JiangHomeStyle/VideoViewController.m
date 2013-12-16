//
//  VideoViewController.m
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-12-16.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import "VideoViewController.h"
#import <MediaPlayer/MPMoviePlayerController.h>
#import "PopupDetailViewController.h"

@interface VideoViewController ()

@end

@implementation VideoViewController

@synthesize url;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUrl:(NSString *)_url
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.url = _url;
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    backBtn = (UIButton *)[self.view viewWithTag:850];
	// Do any additional setup after loading the view.
    [backBtn setBackgroundImage:[UIImage imageNamed:@"btn_back_pressed"] forState:UIControlStateNormal];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"btn_back_normal"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(BtnCloseClick) forControlEvents:UIControlEventTouchUpInside];
    backBtn.alpha = 1;

	// Do any additional setup after loading the view.
    
    NSURL* fileURl = [NSURL fileURLWithPath:url];
        
    mp = [[MPMoviePlayerViewController alloc] initWithContentURL:fileURl];
    mp.view.frame = CGRectMake(0, 49, 1024, 719);
    [self.view addSubview:mp.view];
    player = [mp moviePlayer];
    //[player setRepeatMode:MPMovieRepeatModeOne];
    //mp.view.userInteractionEnabled = NO;
    player.shouldAutoplay = YES;
    player.controlStyle = MPMovieControlModeDefault;
    player.scalingMode = MPMovieScalingModeAspectFill;
    
    //[player setFullscreen:YES];
    [player play];

}

- (void)BtnCloseClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(closeButtonClicked)])
    {
       [self.delegate closeButtonClicked];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end