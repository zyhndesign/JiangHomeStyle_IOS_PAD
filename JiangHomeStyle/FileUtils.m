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
#import "UIImageView+RotationAnimation.h"
#import <sys/xattr.h>

@implementation FileUtils

-(void) createAppFilesDir
{
    NSString *articlesPath = [PATH_OF_DOCUMENT stringByAppendingPathComponent:@"articles"];
    NSString *thumbPath = [PATH_OF_DOCUMENT stringByAppendingPathComponent:@"thumb"];
    NSString *tempPath = [PATH_OF_DOCUMENT stringByAppendingPathComponent:@"temp"];
    //保存离线音乐文件
    NSString *musicPath = [PATH_OF_DOCUMENT stringByAppendingPathComponent:@"music"];
    //保存离线视频文件
    NSString *videoPath = [PATH_OF_DOCUMENT stringByAppendingPathComponent:@"video"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:articlesPath withIntermediateDirectories:YES attributes:nil error:nil];
    [fileManager createDirectoryAtPath:thumbPath withIntermediateDirectories:YES attributes:nil error:nil];
    [fileManager createDirectoryAtPath:tempPath withIntermediateDirectories:YES attributes:nil error:nil];
    [fileManager createDirectoryAtPath:musicPath withIntermediateDirectories:YES attributes:nil error:nil];
    [fileManager createDirectoryAtPath:videoPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:PATH_OF_DOCUMENT]];
    [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:articlesPath]];
    [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:thumbPath]];
    [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:tempPath]];
    [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:musicPath]];
    [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:videoPath]];
}

-(void)createArticleDir:(NSString *)serverId
{
    NSString *articlesPath = [[PATH_OF_DOCUMENT stringByAppendingPathComponent:@"articles"] stringByAppendingPathComponent:serverId];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:articlesPath withIntermediateDirectories:YES attributes:nil error:nil];
    [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:articlesPath]];
}

-(void)createThumbDir:(NSString *)serverId
{
    NSString *articlesPath = [[PATH_OF_DOCUMENT stringByAppendingPathComponent:@"thumb"] stringByAppendingPathComponent:serverId];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:articlesPath withIntermediateDirectories:YES attributes:nil error:nil];
    [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:articlesPath]];
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
    UIImageView *aniLayer1 = (UIImageView *)[[webView superview] viewWithTag:912];
    [aniLayer1 addRotationClockWise:2 andAngle:2.0 andRepeat:100];
    UIImageView *aniLayer2 = (UIImageView *)[[webView superview] viewWithTag:913];
    [aniLayer2 addRotationAntiClockWise:2 andAngle:1.0 andRepeat:100];
    
    //下载zip文件包
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:downUrl]];
    NSString* archivePath = [[[PATH_OF_DOCUMENT stringByAppendingPathComponent:@"temp"] stringByAppendingPathComponent:articleId] stringByAppendingString:@".zip"];
    NSString *articlesPath = [PATH_OF_DOCUMENT stringByAppendingPathComponent:@"articles"];
                              
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:archivePath append:NO];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"loading zip is success");
        
        [aniLayer1.layer removeAnimationForKey:@"transform.rotation.z"];
        [aniLayer2.layer removeAnimationForKey:@"transform.rotation.z"];
        aniLayer1.hidden = YES;
        aniLayer2.hidden = YES;
        
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
            NSLog(@"unzip file is success and delete the zip file");
            [self removeAtPath:archivePath];
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

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL*)URL
{
    const char* filePath = [[URL path] fileSystemRepresentation];
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}

-(NSArray *)getFileListByDir:(NSString *)dir
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *fileList = [[NSArray alloc] init];
    //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    fileList = [fileManager contentsOfDirectoryAtPath:dir error:&error];
    
    return fileList;
}

-(void)removeAtPath:(NSString*)path
{
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    if([defaultManager fileExistsAtPath:path]){
        [defaultManager removeItemAtPath:path error:nil];
    }
}

@end
