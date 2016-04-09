//
//  LPFileManager.h
//  FileDownloadTool
//
//  Created by dito on 16/4/7.
//  Copyright © 2016年 zouzhigang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPFileDownloadOperation.h"

@interface LPFileManager : NSObject


//save and read model
+ (void)setData:(NSMutableArray *)array atFilePath:(NSString *)filePath;

+ (NSMutableArray *)getDataAtFilePath:(NSString *)filePath;

+ (BOOL)hasItemFileID:(NSString *)fileID;

+ (id<LPFileDownloadProtocal>)fetchItemWithFileID:(NSString *)fileID;

+ (void)deleteItemFielID:(NSString *)fileID;

+ (void)addItem:(id<LPFileDownloadProtocal>)downloadModel;

+ (void)updateModelFileID:(NSString *)fileID downloadState:(FileDownloadState)downloadState loactionURL:(NSURL *)locationURL;

@end
