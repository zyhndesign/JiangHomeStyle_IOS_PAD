//
//  DownloadTableViewCell.h
//  JiangHomeStyle
//
//  Created by 工业设计中意（湖南） on 14-4-29.
//  Copyright (c) 2014年 cidesign. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadTableViewCell : UITableViewCell
{
    IBOutlet UILabel *downLoadName;
    IBOutlet UILabel *downloadResult;
    IBOutlet UILabel *downProgress;
    IBOutlet UIImageView *downSignImg;
}
@property (strong, nonatomic) IBOutlet UILabel *downLoadName;
@property (strong, nonatomic) IBOutlet UILabel *downloadResult;
@property (strong, nonatomic) IBOutlet UILabel *downProgress;
@property (strong, nonatomic) IBOutlet UIImageView *downSignImg;

@end
