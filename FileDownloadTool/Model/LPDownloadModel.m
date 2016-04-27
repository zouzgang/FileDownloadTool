//
//  LPDownloadModel.m
//  FileDownloadTool
//
//  Created by dito on 16/4/7.
//  Copyright © 2016年 zouzhigang. All rights reserved.
//

#import "LPDownloadModel.h"
#import "LPFileManager.h"

@interface LPDownloadModel ()

@end

@implementation LPDownloadModel
@synthesize fileName = _fileName, fileURL = _fileURL, fileID = _fileID, directoryPath = _directoryPath, downloadState = _downloadState, resumeData = _resumeData, progress = _progress, locationURL = _locationURL, downloadSpeed = _downloadSpeed, fileSize = _fileSize;

- (id<LPFileDownloadProtocal>)initModelWithFieldID:(NSString *)fieldID fileName:(NSString *)fileName fileURL:(NSString *)fileURL {
    self = [super init];
    if (self) {
        _fileID = fieldID;
        _fileName = fileName;
        _fileURL = fileURL;
        _downloadState = FileDownloadStateWaiting;
    }
    
    return self;
}

#pragma mark - encode and decoder
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _fileID = [aDecoder decodeObjectForKey:@"fileId"];
        self.fileName = [aDecoder decodeObjectForKey:@"fileName"];
        self.fileURL = [aDecoder decodeObjectForKey:@"fileUrl"];
        self.fileSize = [aDecoder decodeObjectForKey:@"fileSize"];
//        self.totalSize = [aDecoder decodeObjectForKey:@"totalSize"];
//        self.downloadSize = [aDecoder decodeObjectForKey:@"downloadSize"];
        self.downloadSpeed = [aDecoder decodeObjectForKey:@"downloadSpeed"];
        self.progress = [aDecoder decodeObjectForKey:@"progress"];
        self.downloadState = ((NSNumber *)[aDecoder decodeObjectForKey:@"downloadState"]).integerValue;
        self.locationURL = [aDecoder decodeObjectForKey:@"locationURL"];
        self.resumeData = [aDecoder decodeObjectForKey:@"resumeData"];
    }
    return  self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.fileID forKey:@"fileId"];
    [aCoder encodeObject:self.fileName forKey:@"fileName"];
    [aCoder encodeObject:self.fileURL forKey:@"fileUrl"];
    [aCoder encodeObject:self.fileSize forKey:@"fileSize"];
//    [aCoder encodeObject:self.totalSize forKey:@"totalSize"];
//    [aCoder encodeObject:self.downloadSize forKey:@"downloadSize"];
    [aCoder encodeObject:self.downloadSpeed forKey:@"downloadSpeed"];
    [aCoder encodeObject:self.progress forKey:@"progress"];
    [aCoder encodeObject:@(self.downloadState) forKey:@"downloadState"];
    [aCoder encodeObject:self.locationURL forKey:@"locationURL"];
    [aCoder encodeObject:self.resumeData forKey:@"resumeData"];
}

#pragma mark - Protocal

- (BOOL)exitItem {
    return [LPFileManager hasItemFileID:self.fileID];
}

- (void)addItem {
    [LPFileManager addItem:self];
}

- (void)removeItem {
    [LPFileManager deleteItemFielID:self.fileID];
}

- (void)updateItem {
    [LPFileManager deleteItemFielID:self.fileID];
    [LPFileManager addItem:self];
}

#pragma  mark - Factory Methods
+ (NSArray *)fetchAllDownloadModels {
    return [LPFileManager getDataAtFilePath:kModelKey].copy;
}

+ (NSArray *)fetchDownloadingModels {
    NSMutableArray *arrayM = [NSMutableArray array];
    NSArray <LPDownloadModel *> *models = [LPFileManager getDataAtFilePath:kModelKey].copy;
    for (NSUInteger i = 0; i < models.count; i++) {
        if (models[i].downloadState == FileDownloadStateFinish) {
            [arrayM addObject:models[i]];
        }
    }

    return arrayM.copy;
}

@end















