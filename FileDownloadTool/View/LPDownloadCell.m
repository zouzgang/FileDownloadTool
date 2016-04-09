//
//  LPDownloadCell.m
//  FileDownloadTool
//
//  Created by dito on 16/4/7.
//  Copyright © 2016年 zouzhigang. All rights reserved.
//

#import "LPDownloadCell.h"
#import "LPDownloadModel.h"
#import <Masonry.h>

@implementation LPDownloadCell {
    UIProgressView *_pressView;
    UILabel *_nameLabel;
    UILabel *_stateLabel;
    UIButton *_button;
    FileDownloadState _downloadState;
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _nameLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:_nameLabel];
    
    _pressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [self.contentView addSubview:_pressView];
    
    _stateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _stateLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:_stateLabel];
    
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.titleLabel.font = [UIFont systemFontOfSize:14];
    [_button setTitle:@"download" forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(didButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_button];
    
    [self updateConstraints];
}

- (void)updateConstraints {
    [_nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(12);
    }];
    
    [_pressView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(_nameLabel.mas_right).offset(12);
        make.width.mas_offset(90);
    }];
    
    [_stateLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(_pressView.mas_right).offset(12);
    }];
    
    [_button mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-12);
        make.size.mas_equalTo(CGSizeMake(100, 60));
    }];
    
    [super updateConstraints];
}

+ (NSString *)cellReuseIdentifier {
    return @"LPDownloadCellIdentifier";
}

- (void)updateViewWithDownloadState {
    if(_downloadState!= _downloadModel.downloadState){
        _downloadState = _downloadModel.downloadState;
        switch (_downloadState) {
            case FileDownloadStateWaiting: {
                _stateLabel.text = @"等待中";
                [_button setTitle:@"下载" forState:UIControlStateNormal];
                break;
            }
            case FileDownloadStateDownloading: {
                _stateLabel.text = @"下载中";
                [_button setTitle:@"暂停" forState:UIControlStateNormal];
                break;
            }
            case FileDownloadStateSuspending: {
                _stateLabel.text = @"暂停中";
                [_button setTitle:@"下载" forState:UIControlStateNormal];
                break;
            }
            case FileDownloadStateFail: {
                _stateLabel.text = @"下载失败";
                [_button setTitle:@"重新下载" forState:UIControlStateNormal];
                break;
            }
            case FileDownloadStateFinish: {
                _stateLabel.text = @"下载完成";
                [_button setTitle:@"查看" forState:UIControlStateNormal];
                break;
            }
            default: {
                break;
            }
        }
    }
}

#pragma mark - Action
- (void)didButtonClick {
    if (_delegate && [_delegate respondsToSelector:@selector(didButtonClickAtIndexPath:)] && _indexPath) {
        [_delegate didButtonClickAtIndexPath:_indexPath];
    }
}


#pragma mark - Access
- (void)setDownloadModel:(LPDownloadModel *)downloadModel {
    _downloadModel = downloadModel;
}

- (void)refresh {
    [self updateViewWithDownloadState];
    _nameLabel.text = _downloadModel.fileName;
    if (_downloadModel.locationURL) {
        _pressView.progress = 1.0f;
    } else {
        _pressView.progress = _downloadModel.progress.floatValue / 100;
    }
}


@end
