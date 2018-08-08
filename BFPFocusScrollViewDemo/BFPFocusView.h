//
//  BFPFocusView.h
//  BFPFocusScrollView
//
//  Created by wangzhe on 2018/8/7.
//  Copyright © 2018年 wangzhe. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BFPFocusViewScrollDirection) {
    BFPFocusViewScrollDirectionVertical,
    BFPFocusViewScrollDirectionHorizontal
};

@interface BFPFocusView : UIView

@property (nonatomic, assign) BFPFocusViewScrollDirection scrollDirection;

/**
 数据源：获取总的page个数，如果少于2个，不自动滚动
 **/
@property (nonatomic , copy) NSInteger (^totalPagesCount)(void);

/**
 数据源：获取第pageIndex个位置的contentView
 **/
@property (nonatomic , copy) UIView *(^fetchContentViewAtIndex)(NSInteger pageIndex);

/**
 当点击的时候，执行的block
 **/
@property (nonatomic , copy) void (^TapActionBlock)(NSInteger pageIndex);

/**
 *  初始化
 *
 *  @param frame             frame
 *  @param animationDuration 自动滚动的间隔时长。如果<=0，不自动滚动。
 *
 *  @return instance
 */
- (id)initWithFrame:(CGRect)frame animationDuration:(NSTimeInterval)animationDuration;

- (void)reloadData;

@end
