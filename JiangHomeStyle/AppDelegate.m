//
//  AppDelegate.m
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-8-23.
//  Copyright (c) 2013年 工业设计中意（湖南）. All rights reserved.
//

#import "AppDelegate.h"

#import "SplashController.h"
#import "googleAnalytics/GAI.h"
#import "TestFlight.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[SplashController alloc] initWithNibName:@"Splash_iPhone" bundle:nil];
    } else {
        self.viewController = [[SplashController alloc] initWithNibName:@"Splash_iPad" bundle:nil];
    }
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    //google analytics-------------------------------------
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval =  20;
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithName:@"JiangHomeStyle" trackingId:@"UA-44083057-1"];
    //-----------------------------------------------------
    
    //test flight------------------------------------------don't use it in release edition
    //[TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    //[TestFlight takeOff:@"ab1fd6ba-8561-4f43-a5b4-8b42921410d2"];
    //-----------------------------------------------------
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"applicationWillEnterForeground....");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"applicationDidBecomeActive....");
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"HOME_PAGE_VIDEO" object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
