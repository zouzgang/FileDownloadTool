//
//  LPFileDownloadManager.m
//  FileDownloadTool
//
//  Created by dito on 16/4/7.
//  Copyright © 2016年 zouzhigang. All rights reserved.
//

#import "LPFileDownloadManager.h"
#import "LPFileManager.h"

@interface LPFileDownloadManager () <LPFileDownloadOperationDelegate>

@property (nonatomic, strong) NSOperationQueue *downloadQueue;
@property (nonatomic, strong) NSMutableArray *suspendDownloadArray;
@property (nonatomic, strong) NSMutableArray *downloadModelArray;

@end

@implementation LPFileDownloadManager {
    
}

+ (instancetype)sharedFileDownloadManager {
    static dispatch_once_t onceToken;
    static LPFileDownloadManager *fileDownloadManager = nil;
    dispatch_once(&onceToken, ^{
        fileDownloadManager = [[LPFileDownloadManager alloc] init];
    });
    
    return fileDownloadManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _suspendDownloadArray = [NSMutableArray array];
        _downloadModelArray = [NSMutableArray array];
        _downloadQueue = [[NSOperationQueue alloc] init];
        _downloadQueue.maxConcurrentOperationCount = 3;
    }
    return self;
}

#pragma mark - Public Methods
- (void)addDownloadWithModel:(id<LPFileDownloadProtocal>)downloadModel {
    LPFileDownloadOperation *fileDownload = [[LPFileDownloadOperation alloc] initWithModel:downloadModel delegate:self];
    if ([downloadModel exitItem]) {
        downloadModel.downloadState = FileDownloadStateDownloading;
        [downloadModel updateItem];
    } else {
        downloadModel.downloadState = FileDownloadStateDownloading;
        [downloadModel addItem];
    }
    [_downloadQueue addOperation:fileDownload];
}

- (void)suspendDownloadWithModel:(id<LPFileDownloadProtocal>)downloadModel {
    for (LPFileDownloadOperation *downloadOperation in _downloadQueue.operations) {
        if ([downloadOperation.fileID isEqualToString:downloadModel.fileID]) {
            [downloadOperation cancelDownloadIfDeleteFile:NO];
            [_suspendDownloadArray addObject:downloadOperation];
        }
    }
}

- (void)recoverDownloadWithModel:(id<LPFileDownloadProtocal>)downloadModel {
    downloadModel.downloadState = FileDownloadStateDownloading;
    [downloadModel updateItem];
    LPFileDownloadOperation *fileDownload = [[LPFileDownloadOperation alloc] initWithModel:downloadModel delegate:self];
    
    [_downloadQueue addOperation:fileDownload];
}

- (void)cancelDownloadWithModel:(id<LPFileDownloadProtocal>)downloadModel {
    if (downloadModel.downloadState == FileDownloadStateDownloading) {
        for (LPFileDownloadOperation *downloadOperation in _downloadQueue.operations) {
            if ([downloadOperation.fileID isEqualToString:downloadModel.fileID]) {
                [downloadOperation cancelDownloadIfDeleteFile:YES];
                [_suspendDownloadArray removeObject:downloadOperation];
            }
        }
    } else {
        [downloadModel removeItem];
    }
}

- (void)suspendAllDownload {
    
}

- (void)startAllDownload {
    //todo
    NSMutableArray *models = [LPFileManager getDataAtFilePath:kModelKey];
    for (id<LPFileDownloadProtocal> model in models) {
        if (model.downloadState == FileDownloadStateFinish ||
            model.downloadState == FileDownloadStateSuspending) {
            return;
        }
        LPFileDownloadOperation *fileDownload = [[LPFileDownloadOperation alloc] initWithModel:model delegate:self];
        [_downloadQueue addOperation:fileDownload];
    }

}

- (FileDownloadState)getFileDownloadStateWithModek:(id<LPFileDownloadProtocal>)downloadModel {
    //todo
    return FileDownloadStateWaiting;
}

#pragma mark - Private Methods


#pragma mark - LPFileDownloadOperationDelegate

- (void)fileDownloadOperationStart:(LPFileDownloadOperation *)downloadOperation downloadComplete:(BOOL)downloadComplete {
    if (downloadComplete) {
        
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_delegate && [_delegate respondsToSelector:@selector(fileDownloadManagerStartDownload:)]) {
                [_delegate fileDownloadManagerStartDownload:downloadOperation];
            }
        });
    }
}

- (void)fileDownloadOperationUpdate:(LPFileDownloadOperation *)downloadOperation didReceiveData:(uint64_t)receiveLength progress:(NSString *)progress downloadSpeed:(NSString *)downloadSpeed {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate && [_delegate respondsToSelector:@selector(fileDownloadManagerUpdateProgress:didReceiveData:progress:)]) {
            [_delegate fileDownloadManagerUpdateProgress:downloadOperation didReceiveData:receiveLength progress:progress];
        }
    });
}

- (void)fileDownloadFinish:(LPFileDownloadOperation *)downloadOperation onSuccess:(BOOL)downloadSuccess error:(NSError *)error didFinishDownloadingToURL:(NSURL *)location{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate && [_delegate respondsToSelector:@selector(fileDownloadManagerFinishDownload:onSuccess:error:didFinishDownloadingToURL:)]) {
            [_delegate fileDownloadManagerFinishDownload:downloadOperation onSuccess:downloadSuccess error:error didFinishDownloadingToURL:location];
        }
    });
}

@end
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
