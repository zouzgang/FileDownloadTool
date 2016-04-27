//
//  LPDownloadViewController.m
//  FileDownloadTool
//
//  Created by dito on 16/4/7.
//  Copyright © 2016年 zouzhigang. All rights reserved.
//

#import "LPDownloadViewController.h"
#import "LPDownloadCell.h"
#import "LPFileDownloadManager.h"
#import <Masonry.h>
#import "LPFileManager.h"
#import "LPDownloadModel.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CrashViewController.h"

@interface LPDownloadViewController () <UITableViewDataSource, UITableViewDelegate, LPDownloadCellDelegate, LPFileDownloadManagerDelegate>

@end

@implementation LPDownloadViewController {
    NSArray <LPDownloadModel *>*_downloadModelArray;
    UITableView *_tableView;
}

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"next" style:UIBarButtonItemStylePlain target:self action:@selector(didRightButtonClick)];
    
    [self updateViewConstraints];
}

- (void)updateViewConstraints {
    [_tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [super updateViewConstraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadLocalData];
}

- (void)loadLocalData {
    _downloadModelArray = [LPDownloadModel fetchAllDownloadModels];
//    _downloadModelArray = [LPDownloadModel fetchDownloadingModels];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [LPFileDownloadManager sharedFileDownloadManager].delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [LPFileDownloadManager sharedFileDownloadManager].delegate = nil;
}
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _downloadModelArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LPDownloadCell *downloadCell = [tableView dequeueReusableCellWithIdentifier:[LPDownloadCell cellReuseIdentifier]];
    if (downloadCell == nil) {
        downloadCell = [[LPDownloadCell alloc] init];
    }
    downloadCell.delegate = self;
    downloadCell.indexPath = indexPath;
    downloadCell.downloadModel = _downloadModelArray[indexPath.row];
    [downloadCell refresh];
    return downloadCell;
}

#pragma mark - UITableDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    //删除下载
    LPFileDownloadManager *downloadManager = [LPFileDownloadManager sharedFileDownloadManager];
    
    LPDownloadModel *downModel = [LPFileManager fetchItemWithFileID:_downloadModelArray[indexPath.row].fileID];
    
    [downloadManager cancelDownloadWithModel:downModel];
    [self loadLocalData];
    [_tableView reloadData];
    
    
}

#pragma mark LPDownloadCellDelegate
- (void)didButtonClickAtIndexPath:(NSIndexPath *)indexPath {
    LPFileDownloadManager *downloadManager = [LPFileDownloadManager sharedFileDownloadManager];
    
    LPDownloadModel *downModel = [LPFileManager fetchItemWithFileID:_downloadModelArray[indexPath.row].fileID];
    LPDownloadCell *downloadCell = [self getTargetCellWithFileId:downModel.fileID];
    
    switch (downModel.downloadState) {
        case FileDownloadStateWaiting: {
            //初始状态，点击开始下载
            [downloadManager addDownloadWithModel:downModel];
        }
            break;
            
        case FileDownloadStateDownloading: {
            //下载中，点击暂停
            [downloadManager suspendDownloadWithModel:downModel];
            downloadCell.downloadModel.downloadState = FileDownloadStateSuspending;
        }
            break;
            
        case FileDownloadStateSuspending: {
            //暂停中，点击开始下载
            [downloadManager recoverDownloadWithModel:downModel];
            downloadCell.downloadModel.downloadState = FileDownloadStateDownloading;
        }
            break;
        case FileDownloadStateFail: {
            //下载失败，点击重新下载
            [downloadManager addDownloadWithModel:downModel];
            [_tableView reloadData];
            return;
        }
            break;
            
        case FileDownloadStateFinish: {
            //下载完成，点击查看
            MPMoviePlayerViewController *viewController = [[MPMoviePlayerViewController alloc] initWithContentURL:downModel.locationURL];
            MPMoviePlayerController *player = viewController.moviePlayer;
            player.controlStyle = MPMovieControlStyleFullscreen;
            [self presentMoviePlayerViewControllerAnimated:viewController];
            return;
        }
            break;
            
        default:
            break;
    }
    
    [_tableView reloadData];
}

#pragma mark - Action
- (void)didRightButtonClick {
    CrashViewController *crashVC = [[CrashViewController alloc] init];
    [self.navigationController pushViewController:crashVC animated:YES];
}

#pragma mark - LPFileDownloadManagerDelegate

- (void)fileDownloadManagerFinishDownload:(LPFileDownloadOperation *)downloadOperation onSuccess:(BOOL)downloadSucces error:(NSError *)error didFinishDownloadingToURL:(NSURL *)location{
    LPDownloadCell *downloadCell = [self getTargetCellWithFileId:downloadOperation.fileID];
    if (downloadSucces) {
        downloadCell.downloadModel.downloadState = FileDownloadStateFinish;
        downloadCell.downloadModel.locationURL = location;
    } else {
        downloadCell.downloadModel.downloadState = FileDownloadStateFail;
    }
//    [downloadCell refresh];
}

- (void)fileDownloadManagerUpdateProgress:(LPFileDownloadOperation *)downloadOperation didReceiveData:(uint64_t)receiveLength progress:(NSString *)progress downloadSpeed:(NSString *)downloadSpeed{
    LPDownloadCell *downloadCell = [self getTargetCellWithFileId:downloadOperation.fileID];
    downloadCell.downloadModel.downloadState = FileDownloadStateDownloading;
    downloadCell.downloadModel.progress = progress;
    downloadCell.downloadModel.downloadSpeed = downloadSpeed;
    
//    [downloadCell refresh];
}

- (void)fileDownloadManagerStartDownload:(LPFileDownloadOperation *)downloadOperation {
    LPDownloadCell *downloadCell = [self getTargetCellWithFileId:downloadOperation.fileID];
    downloadCell.downloadModel.downloadState = FileDownloadStateWaiting;
    
//    [downloadCell refresh];
}



#pragma mark - Private
- (LPDownloadCell *)getTargetCellWithFileId:(NSString *)fileId {
    NSArray *cellArr = _tableView.visibleCells;
    for(id obj in cellArr){
        if([obj isKindOfClass:[LPDownloadCell class]]){
            LPDownloadCell *downloadCell = (LPDownloadCell *)obj;
            if([downloadCell.downloadModel.fileID isEqualToString:fileId]){
                return downloadCell;
            }
        }
    }
    return nil;
}



@end









































