//
//  LPFileDownloadManager.h
//  FileDownloadTool
//
//  Created by dito on 16/4/7.
//  Copyright © 2016年 zouzhigang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPFileDownloadOperation.h"

@protocol LPFileDownloadManagerDelegate <NSObject>

@optional

//开始下载
- (void)fileDownloadManagerStartDownload:(LPFileDownloadOperation *)downloadOperation;

//下载过程，更新进度
- (void)fileDownloadManagerUpdateProgress:(LPFileDownloadOperation *)downloadOperation didReceiveData:(uint64_t)receiveLength progress:(NSString *)progress downloadSpeed:(NSString *)downloadSpeed;

//下载完成，包括成功和失败
- (void)fileDownloadManagerFinishDownload:(LPFileDownloadOperation *)downloadOperation onSuccess:(BOOL)downloadSucces error:(NSError *)error didFinishDownloadingToURL:(NSURL *)location;

@end

@interface LPFileDownloadManager : NSObject

@property (nonatomic, assign) NSInteger maxConDownloadCount;
@property (nonatomic, assign, readonly) NSInteger currentDownloadCount;
@property (nonatomic, weak) id<LPFileDownloadManagerDelegate>delegate;

+ (instancetype)sharedFileDownloadManager;

//添加到下载队列
- (void)addDownloadWithModel:(id<LPFileDownloadProtocal>)downloadModel;

//点击下载项 －》暂停
- (void)suspendDownloadWithModel:(id<LPFileDownloadProtocal>)downloadModel;

//点击暂停项 －》立即下载／添加到下载队列
- (void)recoverDownloadWithModel:(id<LPFileDownloadProtocal>)downloadModel;

//取消下载且删除文件，只适用于未下载完成状态
- (void)cancelDownloadWithModel:(id<LPFileDownloadProtocal>)downloadModel;

//暂停全部
- (void)suspendAllDownload;

//恢复全部
- (void)startAllDownload;

//获得状态
- (FileDownloadState)getFileDownloadStateWithFileID:(NSString *)fileID;



@end
