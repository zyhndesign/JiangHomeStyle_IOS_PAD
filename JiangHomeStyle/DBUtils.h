//
//  DBUtils.h
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 13-9-5.
//  Copyright (c) 2013年 cidesign. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBUtils : NSObject
{

}

//创建表
- (BOOL) createTable;

//写入新的纪录
- (BOOL) insertData:(NSMutableDictionary *) nsDict;

//根据serverID 查询详细数据
- (NSDictionary *) queryByServerID:(NSString*) serverId;

//根据类别获取该类别下所有数据，并且以发布时间降序排列
- (NSMutableArray*) queryByCategory:(int) category;

//获取头条文章数据 （按照时间降序排列取前面4条）
- (NSMutableArray*) queryHeadline;

//判断数据库contentlist表中是否有数据
-(BOOL) countArticlesIsEmpty;

//根据serverId删除数据
-(BOOL) deleteDataByServerId:(NSString *)serverId;

//按照serverId更新数据
-(BOOL) updateDataByServerId:(NSString *) serverId withDict:(NSMutableDictionary *) muDict;

//根据ID查询下载zip包地址
-(NSString *) getDownUrlByServerId:(NSString *) serverId;

//按照页码获取风景分类数据
-(NSMutableArray *) getLandscapeDataByPage:(int)currentPage;

//按照页码获取人文分类数据
-(NSMutableArray *) getHumanityDataByPage:(int)currentPage;

//按照页码获取物语分类数据
-(NSMutableArray *) getStoryDataByPage:(int)currentPage;

//按照页码获取社区分类数据
-(NSMutableArray *) getCommunityDataByPage:(int)currentPage;

//按照类别获取第一条新的数据
-(NSDictionary *) getLatestDataByCategory:(int) category;

//按照类别统计所属类别的总数
-(int)countByCategory:(int)category;
@end
