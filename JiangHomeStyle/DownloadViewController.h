//
//  DownloadViewController.h
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-12-9.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DownloadProtocol <NSObject>

- (void) closeButtonClicked;

@end

@interface DownloadViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *downLoadTableView;
    
    NSMutableArray *musicArray;
    NSMutableDictionary* muDict;
    
    NSString *showUrl;
    NSString *videoUrl;
    NSString *fileSize;
    
    NSOperationQueue *musicQueue;
    NSOperationQueue *landscapeQueue;
    NSOperationQueue *humanityQueue;
    NSOperationQueue *storyQueue;
    NSOperationQueue *communityQueue;
    NSOperationQueue *videoQueue;
    
    NSArray *downloadArray;
    NSMutableArray *refreshArray;
}

@property (nonatomic, strong) IBOutlet UITableView *downLoadTableView;

@property (strong, nonatomic) id delegate;

- (IBAction)closeWin:(id)sender;

//异步加载需要下载的音乐数据
-(void) loadMusicData;

//队列顺序异步下载音乐数据
-(void) downloadMusicFile:(NSArray *)dataArray;

//获取需要下载的类别数据，队列顺序异步进行下载
-(void) downloadDataByCategory:(int) category;

@end

