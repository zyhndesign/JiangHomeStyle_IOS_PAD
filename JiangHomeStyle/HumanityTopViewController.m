//
//  HumanityTopViewController.m
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-9-6.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import "HumanityTopViewController.h"
#import "googleAnalytics/GAIDictionaryBuilder.h"

@interface HumanityTopViewController ()

@end

@implementation HumanityTopViewController

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
    self.screenName = @"人文界面";
    
    [[GAI sharedInstance].defaultTracker set:self.screenName
                                       value:@"HumanityTopController Screen"];
    
    // Send the screen view.
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
