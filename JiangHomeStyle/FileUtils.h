//
//  FileUtils.h
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-9-6.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileUtils : NSObject

//创建离线文件目录顶级，包括文章和缩略图
-(void) createAppFilesDir;

//创建指定文章的保存目录，文件夹名以sererId命名
-(void) createArticleDir:(NSString*) serverId;

//创建缩略图的保存目录，文件夹名以sererId命名
-(void) createThumbDir:(NSString *)serverId;

//判断文件目录是否存在
-(BOOL) fileISExist:(NSString *)fileString;

//判断文件夹目录是否存在
-(BOOL) archiveIsExist:(NSString *)dirString;

//删除指定文件夹
-(BOOL) deleteDir:(NSString *)dirString;

//下载zip包解压到指定目录
-(void) downloadZipFile:(NSString *) downUrl andArticleId:(NSString *) articleId andTipsAnim:(UIWebView *) webView;
@end
