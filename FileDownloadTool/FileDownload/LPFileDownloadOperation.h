//
//  LPFileDownloadOperation.h
//  FileDownloadTool
//
//  Created by dito on 16/4/7.
//  Copyright © 2016年 zouzhigang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LPFileDownloadOperation;

extern NSString *const kModelKey;

typedef NS_ENUM(NSInteger, FileDownloadState){
    FileDownloadStateWaiting,
    FileDownloadStateDownloading,
    FileDownloadStateSuspending,
    FileDownloadStateFail,
    FileDownloadStateFinish,
};

@protocol LPFileDownloadProtocal <NSObject>

@property (nonatomic, copy) NSString *fileID;
@property (nonatomic, copy) NSString *fileURL;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *directoryPath;
@property (nonatomic, strong) NSURL *locationURL;
@property (nonatomic, strong) NSData *resumeData;
@property (nonatomic, copy) NSString *progress;
@property (nonatomic, assign) FileDownloadState downloadState;

- (void)synchronizeModels;
- (void)addItem;
- (void)removeItem;
- (BOOL)exitItem;
- (void)updateItem;

@end


typedef NS_ENUM(NSInteger, FileDownloadOperationState){
    FileDownloadOperationStateWaiting = 0,     //加入到队列中，处于等待状态(默认)
    FileDownloadOperationStateExecuting = 1,   //正在执行状态
    FileDownloadOperationStateFinished = 2,    //已经完成状态
};

@protocol LPFileDownloadOperationDelegate <NSObject>

@optional

- (void)fileDownloadOperationStart:(LPFileDownloadOperation *)downloadOperation downloadComplete:(BOOL)downloadComplete;

- (void)fileDownloadOperationUpdate:(LPFileDownloadOperation *)downloadOperation didReceiveData:(uint64_t)receiveLength progress:(NSString *)progress downloadSpeed:(NSString *)downloadSpeed;

- (void)fileDownloadFinish:(LPFileDownloadOperation *)downloadOperation onSuccess:(BOOL)downloadSuccess error:(NSError *)error didFinishDownloadingToURL:(NSURL *)location;


@end


@interface LPFileDownloadOperation : NSOperation <LPFileDownloadProtocal>

@property (nonatomic, strong) id<LPFileDownloadProtocal>downloadModel;

@property (nonatomic, weak) id<LPFileDownloadOperationDelegate>delegate;


- (id)initWithModel:(id<LPFileDownloadProtocal>)downloadModel delegate:(id<LPFileDownloadOperationDelegate>)delegate;

- (void)cancelDownloadIfDeleteFile:(BOOL)deleteFile;

- (void)recoverDownload;


@end



























