//
//  LPDownloadModel.h
//  FileDownloadTool
//
//  Created by dito on 16/4/7.
//  Copyright © 2016年 zouzhigang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPFileDownloadOperation.h"

@interface LPDownloadModel : NSObject <LPFileDownloadProtocal>


- (id<LPFileDownloadProtocal>)initModelWithFieldID:(NSString *)fieldID fileName:(NSString *)fileName fileURL:(NSString *)fileURL;

+ (NSArray *)fetchAllDownloadModels;

+ (NSArray *)fetchDownloadingModels;


@end
