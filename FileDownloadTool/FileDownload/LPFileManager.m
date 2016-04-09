//
//  LPFileManager.m
//  FileDownloadTool
//
//  Created by dito on 16/4/7.
//  Copyright © 2016年 zouzhigang. All rights reserved.
//

#import "LPFileManager.h"

@implementation LPFileManager

+ (void)setData:(NSMutableArray *)array atFilePath:(NSString *)filePath {
    if (!array) {
        array = [NSMutableArray array];
    }
    [NSKeyedArchiver archiveRootObject:array toFile:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingString:filePath]];
}

+ (NSMutableArray *)getDataAtFilePath:(NSString *)filePath {
    NSMutableArray *array = (NSMutableArray *)[NSKeyedUnarchiver unarchiveObjectWithFile:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingString:filePath]];
    if (!array) {
        array = [NSMutableArray array];
    }
    return array;
}


+ (BOOL)hasItemFileID:(NSString *)fileID {
    NSArray *models = [self getDataAtFilePath:kModelKey].copy;
    __block BOOL hasItem = NO;
    if (models) {
        [models enumerateObjectsUsingBlock:^(id<LPFileDownloadProtocal>model, NSUInteger idx, BOOL *stop) {
            if ([model.fileID isEqualToString:fileID]) {
                hasItem = YES;
                *stop = YES;
            }
        }];
    }
    return hasItem;

}

+ (id<LPFileDownloadProtocal>)fetchItemWithFileID:(NSString *)fileID {
    NSArray *models = [self getDataAtFilePath:kModelKey].copy;
    __block id<LPFileDownloadProtocal> downModel = nil;
    if (models) {
        [models enumerateObjectsUsingBlock:^(id<LPFileDownloadProtocal>model, NSUInteger idx, BOOL *stop) {
            if ([model.fileID isEqualToString:fileID]) {
                downModel = model;
            }
        }];
    }
    return downModel;
}

+ (void)deleteItemFielID:(NSString *)fileID {
    __block NSMutableArray *models = [self getDataAtFilePath:kModelKey];
    if (models) {
        [models enumerateObjectsUsingBlock:^(id<LPFileDownloadProtocal>model, NSUInteger idx, BOOL *stop) {
            if ([model.fileID isEqualToString:fileID]) {
                [models removeObject:model];
                *stop = YES;
            }
        }];
    }
    [self setData:models atFilePath:kModelKey];
}

+ (void)addItem:(id<LPFileDownloadProtocal>)downloadModel {
    NSMutableArray *models = [self getDataAtFilePath:kModelKey];
    [models addObject:downloadModel];
    [self setData:models atFilePath:kModelKey];
}

+ (void)updateModelFileID:(NSString *)fileID downloadState:(FileDownloadState)downloadState loactionURL:(NSURL *)locationURL {
    
}

@end


























