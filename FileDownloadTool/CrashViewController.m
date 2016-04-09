//
//  CrashViewController.m
//  FileDownloadTool
//
//  Created by dito on 16/4/9.
//  Copyright © 2016年 zouzhigang. All rights reserved.
//

#import "CrashViewController.h"

@implementation CrashViewController {
    NSArray *_dataArray;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = @[@"1",@"2"];
    NSString *stringTemp = _dataArray[3];
}

@end
