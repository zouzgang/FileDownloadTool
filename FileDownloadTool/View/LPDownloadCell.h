//
//  LPDownloadCell.h
//  FileDownloadTool
//
//  Created by dito on 16/4/7.
//  Copyright © 2016年 zouzhigang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LPDownloadModel;

@protocol LPDownloadCellDelegate <NSObject>
@optional

- (void)didButtonClickAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface LPDownloadCell : UITableViewCell

@property (nonatomic, strong) LPDownloadModel *downloadModel;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) id<LPDownloadCellDelegate>delegate;

- (void)refresh;

+ (NSString *)cellReuseIdentifier;

@end
