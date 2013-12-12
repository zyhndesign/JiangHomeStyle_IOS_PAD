//
//  DownloadViewController.m
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-12-9.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import "DownloadViewController.h"
#import "AFNetworking/AFHTTPRequestOperation.h"
#import "Reachability/Reachability.h"
#import "Constants.h"
#import "AFNetworking/AFJSONRequestOperation.h"
#import "AFNetworking.h"
#import "JSONKit.h"
#import "FileUtils.h"
#import "DBUtils.h"

@interface DownloadViewController ()

@end

extern DBUtils *db;

@implementation DownloadViewController

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
    self.view.backgroundColor = [UIColor clearColor];
    closeBtn = (UIButton *)[self.view viewWithTag:811];
    [closeBtn addTarget:self action:@selector(closeWin) forControlEvents:UIControlEventTouchUpInside];

    musicLabel = (UILabel *)[self.view viewWithTag:813];
    landscapeLabel = (UILabel *)[self.view viewWithTag:815];
    humanityLabel = (UILabel *)[self.view viewWithTag:817];
    storyLabel = (UILabel *)[self.view viewWithTag:819];
    communityLabel = (UILabel *)[self.view viewWithTag:821];
    
    musicCancelBtn = (UIButton*)[self.view viewWithTag:812];
    landscapeCancelBtn = (UIButton*)[self.view viewWithTag:814];;
    humanityCancelBtn = (UIButton*)[self.view viewWithTag:816];;
    storyCancelBtn = (UIButton*)[self.view viewWithTag:818];;
    communityCancelBtn = (UIButton*)[self.view viewWithTag:820];;
    
    //列出下载列表，包括音乐文件、基本文件包、视频文件（列表之前先判断是否已经下载过）
    
    
    //异步获取音乐列表并进行下载
    musicArray = [NSMutableArray new];
    [self loadMusicData];
    //根据类别获取需要下载的文章列表
            
    //开始下载风景数据
    
    //开始下载人文数据
    
    //开始下载物语数据
            
    //开始下载社区数据
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)closeWin
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(closeButtonClicked)])
    {
        [self.delegate closeButtonClicked];
    }
}

//异步加载需要下载的音乐数据
-(void) loadMusicData
{
    NSString *visitPath = [INTERNET_VISIT_PREFIX stringByAppendingString:@"/travel/wp-admin/admin-ajax.php?action=zy_get_music&programId=1"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:INTERNET_VISIT_PREFIX]];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET" path:visitPath parameters:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *nsStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSData* jsonData = [nsStr dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *nsDict = [jsonData objectFromJSONData];
        NSArray *array = [nsDict objectForKey:@"data"];
        NSMutableDictionary* muDict = nil;
        
        //读取music文件夹下的所有音乐文件
        FileUtils *fileUtils = [FileUtils new];
        NSArray *musicNameArray = [fileUtils getFileListByDir:[PATH_OF_DOCUMENT stringByAppendingPathComponent:@"music"]];
        
        for (NSString *str in musicNameArray)
        {
            NSLog(@"file: %@",str);
        }
        
        NSLog(@"dir musicArray size is %d",[musicNameArray count]);
        
        for (int i = 0; i < array.count; i++)
        {
            muDict = [NSMutableDictionary new];
            NSDictionary *article = [array objectAtIndex:i];
            //和音乐文件夹下的文件进行比较，查看是否已经下载，如果存在则不进行重复下载
            
            if (![musicNameArray containsObject:[[NSString stringWithFormat:@"%@",[article objectForKey:@"music_id"]] stringByAppendingString:@".mp3"]])
            {
                NSLog(@"not contain music...");
                [muDict setObject:[article objectForKey:@"music_title"] forKey:@"musicTitle"];
                [muDict setObject:[article objectForKey:@"music_author"] forKey:@"musicAuthor"];
                [muDict setObject:[article objectForKey:@"music_path"] forKey:@"musicPath"];
                [muDict setObject:[article objectForKey:@"music_name"] forKey:@"musicName"];
                [muDict setObject:[article objectForKey:@"music_id"] forKey:@"musicID"];
                [musicArray addObject:muDict];
            }
        }
        
        NSLog(@"musicArray size is %d",[musicArray count]);
        
        if ([musicArray count] > 0)
        {
            [self downloadMusicFile:musicArray];
        }
        else
        {
            [musicLabel setText:@"100%"] ;
        }
        [musicCancelBtn setHidden:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    [operation start];
}

-(void) downloadMusicFile:(NSArray *)dataArray
{
    dispatch_queue_t queue = dispatch_queue_create("com.mark.serialQueue", NULL);
    
    float percent = 1.0 / [dataArray count];
    
    __block int i = 0;
    for(NSMutableDictionary *obj in dataArray)
    {
        
        dispatch_async(queue, ^{
            NSString *path = [obj objectForKey:@"musicPath"];
            NSString *musicName = [[NSString stringWithFormat:@"%@",[obj objectForKey:@"musicID"]] stringByAppendingString:@".mp3"];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
            NSString *savePath = [[PATH_OF_DOCUMENT stringByAppendingPathComponent:@"music"] stringByAppendingPathComponent:musicName];
            
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            operation.outputStream = [NSOutputStream outputStreamToFileAtPath:savePath append:NO];
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                i++;
                NSLog(@"loading file is over %f", i * percent);
                int labelValue = (i * percent * 100);
                
                if (labelValue == 99)
                {
                    labelValue = 100;
                }
                NSLog(@"label value is %d",labelValue);
                [musicLabel setText:[[NSString stringWithFormat:@"%d", labelValue] stringByAppendingString:@"%"]] ;
                [obj setObject:savePath forKey:@"musicPath"];
                [db insertMusicData:obj];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"loading is failure %@",[error description]);
                NSLog(@"path is : %@",path);
                i++;
            }];
            [operation start];
        });
    }
}

//获取需要下载的风景数据，队列顺序异步进行下载
-(void) downloadLandscapeData
{

}

//获取需要下载的人文数据，队列顺序异步进行下载
-(void) downloadHumanityData
{

}

//获取需要下载的物语数据，队列顺序异步进行下载
-(void) downloadStoryData
{

}

//获取需要下载的社区数据，队列顺序异步进行下载
-(void) downloadCommunityData
{

}

@end
