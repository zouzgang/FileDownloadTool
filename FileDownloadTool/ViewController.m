//
//  ViewController.m
//  FileDownloadTool
//
//  Created by dito on 16/4/7.
//  Copyright © 2016年 zouzhigang. All rights reserved.
//

#import "ViewController.h"
#import "LPFileDownloadOperation.h"
#import "LPDownloadViewController.h"
#import "LPFileDownloadManager.h"
#import "LPDownloadModel.h"

@interface ViewController () <LPFileDownloadManagerDelegate>

@end

@implementation ViewController {
    UILabel *_speedLabel;
    UILabel *_completeLabel;
    
    
    UIButton *_downloadButtonOne;
    UIButton *_downloadButtonTwo;
    UIButton *_downloadButtonThree;
    UIButton *_downloadButtonFour;
    UIButton *_downloadButtonFive;
    
    UIButton *_myDownload;
    
    LPFileDownloadOperation *_downloadOperation;
    NSOperationQueue *_downloadQueue;
    
    NSArray *_downloadModelArray;

}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"viewController";
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 200, 50)];
    _speedLabel.font = [UIFont systemFontOfSize:16];
    _speedLabel.textColor = [UIColor blackColor];
    [self.view addSubview:_speedLabel];
    _speedLabel.text = @"speed:";
    
    _completeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 150, 200, 50)];
    _completeLabel.font = [UIFont systemFontOfSize:16];
    _completeLabel.textColor = [UIColor blackColor];
    [self.view addSubview:_completeLabel];
    _completeLabel.text = @"test";
    
    _downloadButtonOne = [[UIButton alloc] initWithFrame:CGRectMake(10, 250, 140, 50)];
    [_downloadButtonOne setTitle:@"downloadone" forState:UIControlStateNormal];
    _downloadButtonOne.tag = 1;
    _downloadButtonOne.backgroundColor = [UIColor redColor];
    [_downloadButtonOne setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_downloadButtonOne addTarget:self action:@selector(didDownloadButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_downloadButtonOne];
    
    _downloadButtonTwo = [[UIButton alloc] initWithFrame:CGRectMake(170, 250, 140, 50)];
    [_downloadButtonTwo setTitle:@"downloadtwo" forState:UIControlStateNormal];
    [_downloadButtonTwo setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _downloadButtonTwo.tag = 2;
    _downloadButtonTwo.backgroundColor = [UIColor redColor];
    [_downloadButtonTwo addTarget:self action:@selector(didDownloadButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_downloadButtonTwo];
    
    _downloadButtonThree = [[UIButton alloc] initWithFrame:CGRectMake(10, 320, 140, 50)];
    [_downloadButtonThree setTitle:@"downloadthree" forState:UIControlStateNormal];
    [_downloadButtonThree setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _downloadButtonThree.tag = 3;
    _downloadButtonThree.backgroundColor = [UIColor redColor];
    [_downloadButtonThree addTarget:self action:@selector(didDownloadButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_downloadButtonThree];
    
    _downloadButtonFour = [[UIButton alloc] initWithFrame:CGRectMake(170, 320, 140, 50)];
    [_downloadButtonFour setTitle:@"downloadfour" forState:UIControlStateNormal];
    [_downloadButtonFour setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _downloadButtonFour.tag = 4;
    _downloadButtonFour.backgroundColor = [UIColor redColor];
    [_downloadButtonFour addTarget:self action:@selector(didDownloadButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_downloadButtonFour];
    
    _downloadButtonFive = [[UIButton alloc] initWithFrame:CGRectMake(10, 400, 140, 50)];
    [_downloadButtonFive setTitle:@"downloadfive" forState:UIControlStateNormal];
    [_downloadButtonFive setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _downloadButtonFive.tag = 5;
    _downloadButtonFive.backgroundColor = [UIColor redColor];
    [_downloadButtonFive addTarget:self action:@selector(didDownloadButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_downloadButtonFive];
    
    _myDownload = [[UIButton alloc] initWithFrame:CGRectMake(170, 400, 140, 50)];
    [_myDownload setTitle:@"mydownload" forState:UIControlStateNormal];
    [_myDownload setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _myDownload.backgroundColor = [UIColor greenColor];
    [_myDownload addTarget:self action:@selector(didMyDownloadButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_myDownload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _downloadQueue = [[NSOperationQueue alloc] init];
    _downloadQueue.maxConcurrentOperationCount = 2;
    _downloadModelArray = [[NSArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [LPFileDownloadManager sharedFileDownloadManager].delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [LPFileDownloadManager sharedFileDownloadManager].delegate = nil;
}

#pragma mark - Action
- (void)didDownloadButtonClick:(UIButton *)sender {
    NSString *url;
    if (sender.tag == 1) {
        url = @"http://mw5.dwstatic.com/1/3/1528/133489-99-1436409822.mp4";
        sender.backgroundColor = [UIColor lightGrayColor];
    } else if (sender.tag == 2) {
        url = @"http://mw5.dwstatic.com/1/3/1528/133489-99-1436409822.mp4";
        sender.backgroundColor = [UIColor lightGrayColor];
    } else if (sender.tag == 3) {
        url = @"http://mw5.dwstatic.com/1/3/1528/133489-99-1436409822.mp4";
        sender.backgroundColor = [UIColor lightGrayColor];
    } else if (sender.tag == 4) {
        url = @"https://codeload.github.com/google/material-design-icons/zip/master";
        sender.backgroundColor = [UIColor lightGrayColor];
    } else if (sender.tag == 5) {
        url = @"http://7xrwrm.com1.z0.glb.clouddn.com/Multithreading.pdf";
        sender.backgroundColor = [UIColor lightGrayColor];
    }
    
    LPDownloadModel <LPFileDownloadProtocal>*downloadModel = [[LPDownloadModel alloc] initModelWithFieldID:[NSString stringWithFormat:@"%lu",sender.tag] fileName:[NSString stringWithFormat:@"name%lu",sender.tag] fileURL:url];

    [[LPFileDownloadManager sharedFileDownloadManager] addDownloadWithModel:downloadModel];
    
    sender.enabled = NO;
    [self refreshData];
}

- (void)refreshData {
//    _downloadModelArray = [[NSUserDefaults standardUserDefaults] arrayForKey:kModelKey];
    _completeLabel.text = [NSString stringWithFormat:@"%lu",_downloadModelArray.count];
}


- (void)didMyDownloadButtonClick {
    LPDownloadViewController *myDownload = [[LPDownloadViewController alloc] init];
    [self.navigationController pushViewController:myDownload animated:YES];
}


#pragma mark - LPFileDownloadManagerDelegate

- (void)fileDownloadManagerFinishDownload:(LPFileDownloadOperation *)downloadOperation onSuccess:(BOOL)downloadSucces error:(NSError *)error didFinishDownloadingToURL:(NSURL *)location{
//    NSLog(@"%s--finish",__func__);
}

- (void)fileDownloadManagerUpdateProgress:(LPFileDownloadOperation *)downloadOperation didReceiveData:(uint64_t)receiveLength progress:(NSString *)progress {
    _speedLabel.text = [NSString stringWithFormat:@"speed:%@",progress];
}

- (void)fileDownloadManagerStartDownload:(LPFileDownloadOperation *)downloadOperation {
//    NSLog(@"%s----start",__func__);
}



@end






































