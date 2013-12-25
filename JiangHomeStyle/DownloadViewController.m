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
#import "ZipArchive/ZipArchive.h"
#import "GDataXMLNode.h"

@interface DownloadViewController ()

@end

extern DBUtils *db;
extern FileUtils *fileUtils;

@implementation DownloadViewController

int landscapeCancelSign = 0;
int humanityCancelSign = 0;
int storyCancelSign = 0;
int communityCancelSign = 0;
int videoCancelSign = 0;

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
    videoLabel = (UILabel *)[self.view viewWithTag:823];
    
    musicCancelBtn = (UIButton*)[self.view viewWithTag:812];
    landscapeCancelBtn = (UIButton*)[self.view viewWithTag:814];
    [landscapeCancelBtn addTarget:self action:@selector(cancelLandscapeDownBtn) forControlEvents:UIControlEventTouchUpInside];
    humanityCancelBtn = (UIButton*)[self.view viewWithTag:816];
    [humanityCancelBtn addTarget:self action:@selector(cancelHumanityDownBtn) forControlEvents:UIControlEventTouchUpInside];
    storyCancelBtn = (UIButton*)[self.view viewWithTag:818];
    [storyCancelBtn addTarget:self action:@selector(cancelStoryDownBtn) forControlEvents:UIControlEventTouchUpInside];
    communityCancelBtn = (UIButton*)[self.view viewWithTag:820];
    [communityCancelBtn addTarget:self action:@selector(cancelCommunityDownBtn) forControlEvents:UIControlEventTouchUpInside];
    videoCancelBtn = (UIButton*)[self.view viewWithTag:822];
    [communityCancelBtn addTarget:self action:@selector(cancelVideoDownBtn) forControlEvents:UIControlEventTouchUpInside];
    //列出下载列表，包括音乐文件、基本文件包、视频文件（列表之前先判断是否已经下载过）
    
    musicImageView = (UIImageView*)[self.view viewWithTag:824];
    landscapeImageView = (UIImageView*)[self.view viewWithTag:825];
    humanityImageView = (UIImageView*)[self.view viewWithTag:826];
    storyImageView = (UIImageView*)[self.view viewWithTag:827];
    communityImageView = (UIImageView*)[self.view viewWithTag:828];
    videoImageView = (UIImageView*)[self.view viewWithTag:829];
    
    
    musicResultLabel = (UILabel*)[self.view viewWithTag:831];
    landscapeResultLabel = (UILabel*)[self.view viewWithTag:832];;
    humanityResultLabel = (UILabel*)[self.view viewWithTag:833];;
    storyResultLabel = (UILabel*)[self.view viewWithTag:834];;
    communityResultLabel = (UILabel*)[self.view viewWithTag:835];;
    videoResultLabel = (UILabel*)[self.view viewWithTag:836];;
    
    //异步获取音乐列表并进行下载
    musicArray = [NSMutableArray new];
    [self loadMusicData];
    
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

-(void)cancelLandscapeDownBtn
{
    landscapeCancelSign = 1;
    [landscapeLabel setHidden:YES];
    [landscapeCancelBtn setHidden:YES];
}

-(void)cancelHumanityDownBtn
{
    humanityCancelSign = 1;
    [humanityLabel setHidden:YES];
    [humanityCancelBtn setHidden:YES];
}

-(void)cancelStoryDownBtn
{
    storyCancelSign = 1;
    [storyLabel setHidden:YES];
    [storyCancelBtn setHidden:YES];
}

-(void)cancelCommunityDownBtn
{
    communityCancelSign = 1;
    [communityLabel setHidden:YES];
    [communityCancelBtn setHidden:YES];
}

-(void)cancelVideoDownBtn
{
    videoCancelSign = 1;
    [videoLabel setHidden:YES];
    [videoCancelBtn setHidden:YES];
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
        NSArray *musicNameArray = [fileUtils getFileListByDir:[PATH_OF_DOCUMENT stringByAppendingPathComponent:@"music"]];
        
        NSLog(@"dir musicArray size is %d",[musicNameArray count]);
        
        for (int i = 0; i < array.count; i++)
        {
            muDict = [NSMutableDictionary new];
            NSDictionary *article = [array objectAtIndex:i];
            //和音乐文件夹下的文件进行比较，查看是否已经下载，如果存在则不进行重复下载
            
            if (![musicNameArray containsObject:[[NSString stringWithFormat:@"%@",[article objectForKey:@"music_id"]] stringByAppendingString:@".mp3"]])
            {
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
            [musicLabel setText:@"100.00%"];
            [musicImageView setHidden:NO];
            [self downloadLinear];
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
    __block int successNum = 0;
    __block int failureNum = 0;
    
    for(NSMutableDictionary *obj in dataArray)
    {
        
        dispatch_async(queue, ^{
            NSString *path = [obj objectForKey:@"musicPath"];
            NSString *musicName = [[NSString stringWithFormat:@"%@",[obj objectForKey:@"musicID"]] stringByAppendingString:@".mp3"];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            NSString *savePath = [[PATH_OF_DOCUMENT stringByAppendingPathComponent:@"music"] stringByAppendingPathComponent:musicName];
            
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            operation.outputStream = [NSOutputStream outputStreamToFileAtPath:savePath append:NO];
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                i++;
                NSLog(@"loading file is over %f", i * percent);
                int labelValue = (i * percent * 100);
                
                if (labelValue >= 99)
                {
                    labelValue = 100;
                    [self downloadLinear];
                }
                successNum++;
                [self updateUIPanelData:MUSIC_CATEGOTY AndPercent:labelValue Success:successNum Failure:failureNum];
                [obj setObject:savePath forKey:@"musicPath"];
                [db insertMusicData:obj];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"loading is failure %@",[error description]);
                NSLog(@"path is : %@",path);
                i++;
                int labelValue = (i * percent * 100);
                
                if (labelValue >= 99)
                {
                    labelValue = 100;
                    [self downloadLinear];
                }
                NSLog(@"label value is %d",labelValue);
                failureNum++;
                [self updateUIPanelData:MUSIC_CATEGOTY AndPercent:labelValue Success:successNum Failure:failureNum];
            }];
            [operation start];
        });
    }
}

//获取需要下载的类别数据，队列顺序异步进行下载
-(void) downloadDataByCategory:(int) category
{
    if (category == LANDSCAPE_CATEGORY)
    {
        [landscapeCancelBtn setHidden:YES];
    }
    else if (category == HUMANITY_CATEGORY)
    {
        [humanityCancelBtn setHidden:YES];
    }
    else if (category == STORY_CATEGORY)
    {
        [storyCancelBtn setHidden:YES];
    }
    else if (category == COMMUNITY_CATEGORY)
    {
        [communityCancelBtn setHidden:YES];
    }
    
    NSMutableArray* categoryDataArray = [db queryDownloadDataByCategory:category];
    dispatch_queue_t queue = dispatch_queue_create("com.mark.serialQueue", NULL);
    __block long long totalFileSize = 0;
    __block long long alreadyDownSize = 0;
    __block int successNum = 0;
    __block int failureNum = 0;
    
    if ([categoryDataArray count] > 0)
    {
        
        for (NSMutableDictionary *nsDict in categoryDataArray)
        {
            NSString *filePath = [[[[PATH_OF_DOCUMENT stringByAppendingPathComponent:@"articles"] stringByAppendingPathComponent:[nsDict objectForKey:@"serverID"]] stringByAppendingPathComponent:@"doc"] stringByAppendingPathComponent:@"main.html"];
            
            if (![fileUtils fileISExist:filePath])
            {
                dispatch_async(queue, ^{
                    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[nsDict objectForKey:@"url"]]];
                    NSString* archivePath = [[[PATH_OF_DOCUMENT stringByAppendingPathComponent:@"temp"] stringByAppendingPathComponent:[nsDict objectForKey:@"serverID"]] stringByAppendingString:@".zip"];
                    NSString *articlesPath = [PATH_OF_DOCUMENT stringByAppendingPathComponent:@"articles"];
                    NSString* fileSizeStr = [nsDict objectForKey:@"size"];
                    totalFileSize = totalFileSize + [fileSizeStr longLongValue];
                    
                    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:archivePath append:NO];
                    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                        NSLog(@"loading zip is success");
                        
                        //解压文件 ,
                        BOOL result = FALSE;
                        ZipArchive *zip = [ZipArchive new];
                        if ([zip UnzipOpenFile:archivePath])
                        {
                            result = [zip UnzipFileTo:articlesPath overWrite:YES];
                        }
                        else
                        {
                            NSLog(@"there is no zip file");
                        }
                        
                        [db updateSignByServerId:[nsDict objectForKey:@"serverID"]];
                        
                        if (result)
                        {
                            NSLog(@"unzip file is success and delete the zip file");
                            [fileUtils removeAtPath:archivePath];
                        }
                        else
                        {
                            NSLog(@"unzip file is failure");
                        }
                        alreadyDownSize = alreadyDownSize + [fileSizeStr longLongValue];
                        if (alreadyDownSize == totalFileSize)
                        {
                            [self updateStateByCategroy:category];
                        }
                        successNum++;
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"loading zip is failure %@",[error description]);
                        alreadyDownSize = alreadyDownSize + [fileSizeStr longLongValue];
                        if (alreadyDownSize == totalFileSize)
                        {
                            [self updateStateByCategroy:category];
                        }
                        failureNum++;
                    }];
                    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                        // NSLog(@"%d-%lld-%lld-%@",bytesRead,totalBytesRead,totalBytesExpectedToRead,operation.request.allHTTPHeaderFields);
                        
                        //_progress.progress=(float)totalBytesRead/(float)totalBytesExpectedToRead;
                        //_provalue.text=[[NSString alloc] initWithFormat:@"%0.2f%%",(float)totalBytesRead/(float)totalBytesExpectedToRead*100];
                        [self updateUIPanelData:category AndPercent:[[[NSString alloc] initWithFormat:@"%0.2f%%",((float)totalBytesRead + alreadyDownSize)/(float)totalFileSize * 100] floatValue] Success:successNum Failure:failureNum];
                        
                       
                    }];
                    [operation start];
                });
            }
        }
        
        if (totalFileSize == 0)
        {
            [self updateUIPanelData:category AndPercent:100.00 Success:successNum Failure:failureNum];
            [self updateStateByCategroy:category];
        }
    }
    else
    {
        [self updateStateByCategroy:category];
    }
}

-(void) downloadVideo
{
    [videoCancelBtn setHidden:YES];
    
    NSMutableArray *videoArray = [db getVideoData];
    NSMutableArray *videoDownArray = [NSMutableArray new];
    NSMutableDictionary *urlDict;
    
    long long totalFileSize = 0;
    __block long long alreadyDownSize = 0;
    for (NSMutableDictionary *nsDict in videoArray)
    {
        //解析doc.xml文件，获取showUrl地址，videoUrl
        NSString *docFilePath   =  [[[PATH_OF_DOCUMENT stringByAppendingPathComponent:@"articles"] stringByAppendingPathComponent:[nsDict objectForKey:@"serverID"]]  stringByAppendingPathComponent:@"doc.xml"];
        //NSString *jsonString  =   [NSString stringWithContentsOfFile:docFilePath encoding:NSUTF8StringEncoding error:nil];
        NSData *xmlData = [[NSData alloc] initWithContentsOfFile:docFilePath];
        
        //使用NSData对象初始化
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData  options:0 error:nil];
        
        //获取根节点（doc）
        GDataXMLElement *rootElement = [doc rootElement];
        
        
        //获取根节点下的节点（videoItems）
        NSArray *videoItems = [rootElement elementsForName:@"videoItems"];
        
        if ([videoItems count] > 0)
        {
            for (GDataXMLElement *videoItem in videoItems)
            {
                NSArray *videoItemData = [videoItem elementsForName:@"videoItem"];
                
                for (GDataXMLElement *video in videoItemData) {
                    urlDict = [NSMutableDictionary new];
                    //获取showUrl节点的值
                    GDataXMLElement *nameElement = [[video elementsForName:@"showUrl"] objectAtIndex:0];
                    showUrl = [nameElement stringValue];
                    NSLog(@"showUrl is:%@",showUrl);
                    
                    //获取videoUrl节点的值
                    GDataXMLElement *ageElement = [[video elementsForName:@"videoUrl"] objectAtIndex:0];
                    videoUrl = [ageElement stringValue];
                    NSLog(@"videoUrl is:%@",videoUrl);
                    
                    //
                    GDataXMLElement *sizeElement = [[video elementsForName:@"size"] objectAtIndex:0];
                    //fileSize = [[sizeElement stringValue] longLongValue];
                    fileSize = [sizeElement stringValue];
                    NSLog(@"fileSize is:%@",fileSize);
                    
                    [urlDict setValue:videoUrl forKey:@"videoUrl"];
                    [urlDict setValue:showUrl forKey:@"showUrl"];
                    [urlDict setValue:fileSize forKey:@"fileSize"];
                    [videoDownArray addObject:urlDict];
                }
            }
        }
    }
    
    if ([videoDownArray count] > 0)
    {
        dispatch_queue_t queue = dispatch_queue_create("com.mark.serialQueue", NULL);
        
        //读取video文件夹下的所有视频文件
        NSArray *videoIsDownArray = [fileUtils getFileListByDir:[PATH_OF_DOCUMENT stringByAppendingPathComponent:@"video"]];
        
        NSLog(@"dir videoArray size is %d",[videoIsDownArray count]);
        
        int countDown = 0;
        
        for (NSMutableDictionary *nsDict in videoDownArray)
        {
            if (![videoIsDownArray containsObject:[self getFileNameFromUrl:[nsDict objectForKey:@"videoUrl"]]])
            {
                countDown++;
                NSLog(@"download video...");
                NSString* fileSizeStr = [nsDict objectForKey:@"fileSize"];
                totalFileSize = totalFileSize + [fileSizeStr longLongValue];
                
                dispatch_async(queue, ^{
                    
                    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[nsDict objectForKey:@"videoUrl"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                    NSString* archivePath = [[PATH_OF_DOCUMENT stringByAppendingPathComponent:@"video"] stringByAppendingPathComponent:[self getFileNameFromUrl:[nsDict objectForKey:@"videoUrl"]]];
                    
                    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:archivePath append:NO];
                    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                       alreadyDownSize = alreadyDownSize + [fileSizeStr longLongValue];
                        NSLog(@"download success");
                        if (alreadyDownSize == totalFileSize)
                        {
                            [videoImageView setHidden:NO];
                        }
                        
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                       alreadyDownSize = alreadyDownSize + [fileSizeStr longLongValue];
                        NSLog(@"download failure");
                        if (alreadyDownSize == totalFileSize)
                        {
                            [videoImageView setHidden:NO];
                        }
                    }];
                    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                        // NSLog(@"%d-%lld-%lld-%@",bytesRead,totalBytesRead,totalBytesExpectedToRead,operation.request.allHTTPHeaderFields);
                        
                        //_progress.progress=(float)totalBytesRead/(float)totalBytesExpectedToRead;
                        videoLabel.text=[[NSString alloc] initWithFormat:@"%0.2f%%",((float)totalBytesRead + alreadyDownSize)/(float)totalFileSize*100];
                    }];
                    [operation start];
                });
    
            }
        }
        
        if (countDown == 0)
        {
            [videoLabel setText:@"100.00%"];
            [videoImageView setHidden:NO];
        }
        
    }
}

-(void) downloadLinear
{
    if (landscapeCancelSign == 0)
    {
        [self downloadDataByCategory:LANDSCAPE_CATEGORY];
    }
    else if (humanityCancelSign == 0)
    {
        [self downloadDataByCategory:HUMANITY_CATEGORY];
    }
    else if (storyCancelSign == 0)
    {
        [self downloadDataByCategory:STORY_CATEGORY];
    }
    else if (communityCancelSign == 0)
    {
        [self downloadDataByCategory:COMMUNITY_CATEGORY];
    }
    else if (videoCancelSign == 0)
    {
        [self downloadVideo];
    }
}

-(void) updateStateByCategroy:(int) category
{
    if (category == LANDSCAPE_CATEGORY)
    {
        [landscapeLabel setText:@"100.00%"];
        [landscapeCancelBtn setHidden:YES];
        [landscapeImageView setHidden:NO];
        if (humanityCancelSign == 0)
        {
            [self downloadDataByCategory:HUMANITY_CATEGORY];
        }
        else
        {
            if (storyCancelSign == 0)
            {
                [self downloadDataByCategory:STORY_CATEGORY];
            }
            else
            {
                if (communityCancelSign == 0)
                {
                    [self downloadDataByCategory:COMMUNITY_CATEGORY];
                }
                else
                {
                    if (videoCancelSign == 0)
                    {
                        [self downloadVideo];
                    }
                }
            }
        }
    }
    else if (category == HUMANITY_CATEGORY)
    {
        [humanityLabel setText:@"100.00%"];
        [humanityCancelBtn setHidden:YES];
        [humanityImageView setHidden:NO];
        if (storyCancelSign == 0)
        {
            [self downloadDataByCategory:STORY_CATEGORY];
        }
        else
        {
            if (communityCancelSign == 0)
            {
                [self downloadDataByCategory:COMMUNITY_CATEGORY];
            }
            else
            {
                if (videoCancelSign == 0)
                {
                    [self downloadVideo];
                }
            }
        }
    }
    else if (category == STORY_CATEGORY)
    {
        [storyLabel setText:@"100.00%"];
        [storyCancelBtn setHidden:YES];
        [storyImageView setHidden:NO];
        if (communityCancelSign == 0)
        {
            [self downloadDataByCategory:COMMUNITY_CATEGORY];
        }
        else
        {
            if (videoCancelSign == 0)
            {
                [self downloadVideo];
            }
        }
    }
    else if (category == COMMUNITY_CATEGORY)
    {
        [communityLabel setText:@"100.00%"];
        [communityCancelBtn setHidden:YES];
        [communityImageView setHidden:NO];
        if (videoCancelSign == 0)
        {
            [self downloadVideo];
        }
    }
    else if (category == VIDEO_CATEGORY)
    {
        [videoLabel setText:@"100.00%"];
        [videoImageView setHidden:NO];
        [videoCancelBtn setHidden:YES];
    }
}

-(void) updateUIPanelData:(int)category AndPercent:(float)value Success:(int)successNum Failure:(int)failureNum
{
    if (category == MUSIC_CATEGOTY)
    {
        [musicLabel setText:[[NSString stringWithFormat:@"%0.2f", value] stringByAppendingString:@"%"]];
        [musicResultLabel setText:[NSString stringWithFormat:@"%d个成功，%d个失败",successNum,failureNum]];
        if (value == 100)
        {
            [musicImageView setHidden:NO];
        }
    }
    else if (category == LANDSCAPE_CATEGORY)
    {
        [landscapeLabel setText:[[NSString stringWithFormat:@"%0.2f", value] stringByAppendingString:@"%"]] ;
        [landscapeResultLabel setText:[NSString stringWithFormat:@"%d个成功，%d个失败",successNum,failureNum]];
        if (value == 100)
        {
            [landscapeImageView setHidden:NO];
        }
    }
    else if (category == HUMANITY_CATEGORY)
    {
        [humanityLabel setText:[[NSString stringWithFormat:@"%0.2f", value] stringByAppendingString:@"%"]] ;
        [humanityResultLabel setText:[NSString stringWithFormat:@"%d个成功，%d个失败",successNum,failureNum]];
        if (value == 100)
        {
            [humanityImageView setHidden:NO];
        }
    }
    else if (category == STORY_CATEGORY)
    {
        [storyLabel setText:[[NSString stringWithFormat:@"%0.2f", value] stringByAppendingString:@"%"]] ;
        [storyResultLabel setText:[NSString stringWithFormat:@"%d个成功，%d个失败",successNum,failureNum]];
        if (value == 100)
        {
            [storyImageView setHidden:NO];
        }
    }
    else if (category == COMMUNITY_CATEGORY)
    {
        [communityLabel setText:[[NSString stringWithFormat:@"%0.2f", value] stringByAppendingString:@"%"]] ;
        [communityResultLabel setText:[NSString stringWithFormat:@"%d个成功，%d个失败",successNum,failureNum]];
        if (value == 100)
        {
            [communityImageView setHidden:NO];
        }
    }
    else if (category == VIDEO_CATEGORY)
    {
        [videoLabel setText:[[NSString stringWithFormat:@"%0.2f", value] stringByAppendingString:@"%"]];
        [videoResultLabel setText:[NSString stringWithFormat:@"%d个成功，%d个失败",successNum,failureNum]];
        if (value == 100)
        {
            [videoImageView setHidden:NO];
        }
    }
}

-(NSString *)getFileNameFromUrl:(NSString *)url
{
    NSArray *array = [url componentsSeparatedByString:@"/"];
    
    return [array objectAtIndex:([array count] - 1)];
}
@end
