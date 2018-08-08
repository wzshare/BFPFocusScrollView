//
//  ViewController.m
//  BFPFocusScrollViewDemo
//
//  Created by wangzhe on 2018/8/7.
//  Copyright © 2018年 wangzhe. All rights reserved.
//

#import "ViewController.h"
#import <BFPFocusScrollView/BFPFocusScrollView.h>

@interface ViewController ()
@property (nonatomic, strong) BFPFocusView *focusView;
@property (nonatomic, strong) NSMutableArray *focusImages;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _focusView = [[BFPFocusView alloc] initWithFrame:CGRectMake(0, 84, self.view.frame.size.width, 450) animationDuration:4];
    [self.view addSubview:_focusView];
    
    __weak typeof(self) weakSelf = self;
    _focusView.totalPagesCount = ^NSInteger{
        typeof(self) strongSelf = weakSelf;
        NSInteger count = strongSelf.focusImages.count;
        return count;
    };
    _focusView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex) {
        typeof(self) strongSelf = weakSelf;
        UIView *view = strongSelf.focusImages[pageIndex];
        return view;
    };
    [_focusView reloadData];
}

- (NSArray *)focusImages {
    if (!_focusImages) {
        NSArray *images = @[[UIImage imageNamed:@"focus01"], [UIImage imageNamed:@"focus02"], [UIImage imageNamed:@"focus03"], [UIImage imageNamed:@"focus04"], [UIImage imageNamed:@"focus05"]];
        _focusImages = [NSMutableArray array];
        for (UIImage *image in images) {
            UIImageView *view = [[UIImageView alloc] initWithImage:image];
            [_focusImages addObject:view];
        }
    }
    return _focusImages;
}

@end
