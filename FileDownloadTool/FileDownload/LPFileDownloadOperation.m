//
//  LPFileDownloadOperation.m
//  FileDownloadTool
//
//  Created by dito on 16/4/7.
//  Copyright © 2016年 zouzhigang. All rights reserved.
//

#import "LPFileDownloadOperation.h"
NSString *const kModelKey = @"/person.data";

const double kBufferSize = 1024.0*1024.0;
const NSTimeInterval kDefaultTimeOut = 60;
const NSTimeInterval kCalculateSpeedTime = 2;

@interface LPFileDownloadOperation ()<NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, assign) FileDownloadOperationState operationState;

@end

@implementation LPFileDownloadOperation {

    NSString *_downloadProgress;
    
    NSURLSession *_URLSession;
    NSURLSessionDownloadTask *_downloadTask;
    
    NSTimer *_timer;
    NSURL *_downloadURL;
    
    uint64_t _receivedDataLength;     //目前下载到的数据量
    uint64_t _expectedDataLength;     //文件期望的数据总量
    uint64_t _timerReceivedDataLength;  //用于计算下载速度
}

@synthesize fileName = _fileName, fileURL = _fileURL, fileID = _fileID, directoryPath = _directoryPath, downloadState = _downloadState, resumeData = _resumeData, progress = _progress, locationURL = _locationURL, downloadSpeed = _downloadSpeed, fileSize = _fileSize;

- (id)initWithModel:(id<LPFileDownloadProtocal>)downloadModel delegate:(id<LPFileDownloadOperationDelegate>)delegate {
    self = [super init];
    if (self) {
        self.downloadModel = downloadModel;
        self.downloadModel.downloadState = FileDownloadStateDownloading;
        _fileID = downloadModel.fileID;
        _fileURL = downloadModel.fileURL;
        _fileName = downloadModel.fileName;
        _directoryPath = downloadModel.directoryPath;
        _operationState = FileDownloadOperationStateWaiting;
        _resumeData = downloadModel.resumeData;
        self.delegate = delegate;
        _downloadURL = [NSURL URLWithString:[downloadModel.fileURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        if ([self.downloadModel exitItem]) {
            [self.downloadModel updateItem];
        } else {
            [self.downloadModel addItem];
        }
    }
    return self;
}

#pragma mark - Override Methods
- (void)start {
    if (self.isCancelled) {
        [self finisWithUnStart];
    } else {
        [self willChangeValueForKey:@"isExecuteing"];
        [self performSelector:@selector(main)];
        self.operationState = FileDownloadOperationStateExecuting;
        [self didChangeValueForKey:@"isExecuteing"];
    }
}

- (void)main {
    if (_delegate &&[_delegate respondsToSelector:@selector(fileDownloadOperationStart:downloadComplete:)]) {
        [_delegate fileDownloadOperationStart:self downloadComplete:YES];
    }
    NSMutableURLRequest *fileRequest = [[NSMutableURLRequest alloc] initWithURL:_downloadURL];
    _URLSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    if (_resumeData) {
        _downloadTask = [_URLSession downloadTaskWithResumeData:_resumeData];
    } else {
        _downloadTask = [_URLSession downloadTaskWithRequest:fileRequest];
    }
    [_downloadTask resume];
}

#pragma mark - Public Methods
- (void)cancelDownloadIfDeleteFile:(BOOL)deleteFile {
    if (!deleteFile) {
        [_downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
            _resumeData = resumeData;
            _downloadModel.resumeData = resumeData;
            _downloadModel.downloadState = FileDownloadStateSuspending;
            _downloadModel.progress = [NSString stringWithFormat:@"%@",@(_receivedDataLength * 100 / _expectedDataLength)];
            [_downloadModel updateItem];
        }];
    } else {
        [_downloadModel removeItem];
    }
    
    [self finishOperation];
}

#pragma mark - NSURLSessionDownnloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:filePath] error:nil];
    _downloadModel.downloadState = FileDownloadStateFinish;
    _downloadModel.locationURL = [NSURL fileURLWithPath:filePath];
    [_downloadModel updateItem];
    
    [self finishOperation];
    if (_delegate && [_delegate respondsToSelector:@selector(fileDownloadFinish:onSuccess:error:didFinishDownloadingToURL:)]) {
        [_delegate fileDownloadFinish:self onSuccess:YES error:nil didFinishDownloadingToURL:[NSURL fileURLWithPath:filePath]];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSURLResponse *response = downloadTask.response;
    NSError *error = nil;
    if (!_fileSize) {
        _fileSize = [self calculateFileSize:totalBytesExpectedToWrite];
        _downloadModel.fileSize = _fileSize;
        [_downloadModel updateItem];
    }
    _receivedDataLength = totalBytesWritten;
    _timerReceivedDataLength += bytesWritten;
    _expectedDataLength = totalBytesExpectedToWrite;
    _downloadProgress = [NSString stringWithFormat:@"%@",@(totalBytesWritten * 100 / totalBytesExpectedToWrite)];
    NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)response;
    if (httpURLResponse.statusCode >= 400) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"HTTP error code %ld(%@)",httpURLResponse.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:httpURLResponse.statusCode]]};
        error = [[NSError alloc] initWithDomain:NSURLErrorDomain code:2 userInfo:userInfo];
    }
    if ([self freeDiskSpace] < _expectedDataLength && _expectedDataLength != -1) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"Not enough free disk space"};
        error = [[NSError alloc] initWithDomain:NSURLErrorDomain code:3 userInfo:userInfo];
    }
    if (!error) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:kCalculateSpeedTime target:self selector:@selector(calculateDownloadSpeed:) userInfo:nil repeats:YES];
        [_timer fire];
        if (_delegate && [_delegate respondsToSelector:@selector(fileDownloadOperationUpdate:didReceiveData:progress:downloadSpeed:)]) {
            [_delegate fileDownloadOperationUpdate:self didReceiveData:bytesWritten progress:_downloadProgress downloadSpeed:_downloadSpeed];
        }
    } else {
        if (_delegate && [_delegate respondsToSelector:@selector(fileDownloadFinish:onSuccess:error:didFinishDownloadingToURL:)]) {
            [_delegate fileDownloadFinish:self onSuccess:NO error:error didFinishDownloadingToURL:nil];
        }
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    
}

#pragma mark - NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
}


#pragma mark - Accessor
- (BOOL)isExecuting {
    return self.operationState == FileDownloadOperationStateExecuting;
}

- (BOOL)isFinished {
    return self.operationState == FileDownloadOperationStateFinished;
}

- (BOOL)isAsynchronous {
    return YES;
}


#pragma mark - Private Method

//未开始就取消
- (void)finisWithUnStart {
    [self willChangeValueForKey:@"isFinished"];
    self.operationState = FileDownloadOperationStateFinished;
    [self didChangeValueForKey:@"isFinished"];
}

//完成活着取消
- (void)finishOperation {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    [_URLSession invalidateAndCancel];
    _URLSession = nil;
    
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    self.operationState = FileDownloadOperationStateFinished;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}


//获取磁盘剩余空间
- (uint64_t)freeDiskSpace {
    uint64_t totalFreeSpace = 0;
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *dictionary = [fileManager attributesOfFileSystemForPath:docPath error:nil];
    if(dictionary){
        totalFreeSpace = [dictionary[NSFileSystemFreeSize] unsignedLongLongValue];
    }
    return totalFreeSpace;
}


//计算网速
- (void)calculateDownloadSpeed:(uint64_t)receiveLength {
    float downloadSpeed = (float)_timerReceivedDataLength/1024.0/kCalculateSpeedTime;
    if(downloadSpeed>=1024.0){
        downloadSpeed /= 1024.0;
        _downloadSpeed = [NSString stringWithFormat:@"%.1fMB/s",downloadSpeed];
    } else{
        _downloadSpeed = [NSString stringWithFormat:@"%.1fKB/s",downloadSpeed];
    }
    _timerReceivedDataLength = 0;
}

//计算文件大小
- (NSString *)calculateFileSize:(uint64_t)length {
    float fileSize = (float)length / 1024.0;
    if(fileSize >= 1024.0 * 1024.0){
        fileSize /= 1024.0 * 1024.0;
        return [NSString stringWithFormat:@"%.2fG",fileSize];
    } else if (fileSize >= 1024.0) {
        fileSize /= 1024.0;
        return [NSString stringWithFormat:@"%.1fMB",fileSize];
    } else{
        return [NSString stringWithFormat:@"%.1fKB",fileSize];
    }
}



 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 


@end
