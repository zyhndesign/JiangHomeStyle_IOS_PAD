//
//  FileUtils.m
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-9-6.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import "FileUtils.h"
#import "VarUtils.h"
#import <Foundation/Foundation.h>
#import "AFNetworking/AFNetworking.h"
#import "ZipArchive/ZipArchive.h"

@implementation FileUtils

-(void) createAppFilesDir
{
    NSString *articlesPath = [PATH_OF_DOCUMENT stringByAppendingPathComponent:@"articles"];
    NSString *thumbPath = [PATH_OF_DOCUMENT stringByAppendingPathComponent:@"thumb"];
    NSString *tempPath = [PATH_OF_DOCUMENT stringByAppendingPathComponent:@"temp"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:articlesPath withIntermediateDirectories:YES attributes:nil error:nil];
    [fileManager createDirectoryAtPath:thumbPath withIntermediateDirectories:YES attributes:nil error:nil];
    [fileManager createDirectoryAtPath:tempPath withIntermediateDirectories:YES attributes:nil error:nil];
}

-(void)createArticleDir:(NSString *)serverId
{
    NSString *articlesPath = [[PATH_OF_DOCUMENT stringByAppendingPathComponent:@"articles"] stringByAppendingPathComponent:serverId];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:articlesPath withIntermediateDirectories:YES attributes:nil error:nil];
}

-(void)createThumbDir:(NSString *)serverId
{
    NSString *articlesPath = [[PATH_OF_DOCUMENT stringByAppendingPathComponent:@"thumb"] stringByAppendingPathComponent:serverId];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:articlesPath withIntermediateDirectories:YES attributes:nil error:nil];
}

-(BOOL) fileISExist:(NSString *)fileString
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:fileString];
}

-(BOOL) archiveIsExist:(NSString *)dirString
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = FALSE;
    BOOL isDirExist = [fileManager fileExistsAtPath:dirString isDirectory:&isDir];
    if ((isDirExist && isDir))
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

-(BOOL) deleteDir:(NSString *)dirString
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager removeItemAtPath:dirString error:nil];
}

-(void) downloadZipFile:(NSString *) downUrl andArticleId:(NSString *) articleId andTipsAnim:(UIWebView *) webView
{
    UIActivityIndicatorView *activityIndictor = (UIActivityIndicatorView *)[[webView superview] viewWithTag:911];
    //[activityIndictor setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    activityIndictor.hidden = NO;
    [activityIndictor startAnimating];
    
    //下载zip文件包
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:downUrl]];
    NSString* archivePath = [[[PATH_OF_DOCUMENT stringByAppendingPathComponent:@"temp"] stringByAppendingString:articleId] stringByAppendingString:@".zip"];
    NSString *articlesPath = [PATH_OF_DOCUMENT stringByAppendingPathComponent:@"articles"];
                              
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:archivePath append:NO];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"loading zip is success");
        if ([activityIndictor isAnimating])
        {
            [activityIndictor stopAnimating];
        }
        activityIndictor.hidden = YES;
        
        //解压文件
        BOOL result = FALSE;
        ZipArchive *zip = [ZipArchive new];
        if ([zip UnzipOpenFile:archivePath])
        {
            result = [zip UnzipFileTo:articlesPath overWrite:YES];
            NSString *filePath = [[[[PATH_OF_DOCUMENT stringByAppendingPathComponent:@"articles"] stringByAppendingPathComponent:articleId] stringByAppendingPathComponent:@"doc"] stringByAppendingPathComponent:@"main.html"];
            NSLog(@"%@",filePath);
            NSURL * url = [NSURL fileURLWithPath:filePath];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            [webView loadRequest:request];
        }
        else
        {
            NSLog(@"there is no zip file");
        }
        
        if (result)
        {
            NSLog(@"unzip file is success");
        }
        else
        {
            NSLog(@"unzip file is failure");
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"loading zip is failure %@",[error description]);
        
    }];
    [operation start];

}
@end
