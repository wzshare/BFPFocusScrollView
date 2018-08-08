//
//  BFPFocusView.m
//  BFPFocusScrollView
//
//  Created by wangzhe on 2018/8/7.
//  Copyright © 2018年 wangzhe. All rights reserved.
//

#import "BFPFocusView.h"
#import "NSTimer+Addition.h"

@interface BFPFocusView () <UIScrollViewDelegate>

@property (nonatomic, assign) CGFloat scrollViewStartContentOffsetX;
@property (nonatomic, assign) CGFloat scrollViewStartContentOffsetY;
@property (nonatomic, assign) NSInteger totalPageCount;
@property (nonatomic, assign) NSInteger currentPageIndex;
@property (nonatomic, strong) NSMutableArray *contentViews;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSTimer *animationTimer;
@property (nonatomic, assign) NSTimeInterval animationDuration;
@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation BFPFocusView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _scrollDirection = BFPFocusViewScrollDirectionHorizontal;
        
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.autoresizingMask = 0xFF;
        _scrollView.contentMode = UIViewContentModeCenter;
        _scrollView.contentSize = CGSizeMake(3 * CGRectGetWidth(_scrollView.frame), CGRectGetHeight(_scrollView.frame));
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        [self addSubview:_scrollView];
        
        _currentPageIndex = 0;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame animationDuration:(NSTimeInterval)animationDuration {
    self = [self initWithFrame:frame];
    if (animationDuration > 0.0) {
        _animationDuration = animationDuration;
        _animationTimer = [NSTimer scheduledTimerWithTimeInterval:self.animationDuration
                                                           target:self
                                                         selector:@selector(animationTimerDidFired:)
                                                         userInfo:nil
                                                          repeats:YES];
        [_animationTimer pauseTimer];
    }
    return self;
}

- (void)animationTimerDidFired:(NSTimer *)timer {
    CGPoint newOffset = CGPointZero;
    if (self.scrollDirection == BFPFocusViewScrollDirectionHorizontal) {
        CGFloat width = CGRectGetWidth(self.scrollView.frame);
        newOffset = CGPointMake(2 * width, self.scrollView.contentOffset.y);
    }
    else {
        CGFloat height = CGRectGetHeight(self.scrollView.frame);
        newOffset = CGPointMake(0, 2 * height);
    }
    [self.scrollView setContentOffset:newOffset animated:YES];
}

- (void)setCurrentPageIndex:(NSInteger)currentPageIndex
{
    _currentPageIndex = currentPageIndex;
    [_pageControl setCurrentPage:_currentPageIndex];
}

- (void)reloadData{
    [self configContentViews];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.scrollViewStartContentOffsetX = scrollView.contentOffset.x;
    self.scrollViewStartContentOffsetY = scrollView.contentOffset.y;
    [self.animationTimer pauseTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.animationTimer resumeTimerAfterTimeInterval:self.animationDuration];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.scrollDirection == BFPFocusViewScrollDirectionHorizontal) {
        CGFloat contentOffsetX = scrollView.contentOffset.x;
        if (self.totalPageCount == 2) {
            if (self.scrollViewStartContentOffsetX < contentOffsetX) {
                UIView *tempView = (UIView *)[self.contentViews lastObject];
                tempView.frame = (CGRect){{2 * CGRectGetWidth(scrollView.frame),0},tempView.frame.size};
            } else if (self.scrollViewStartContentOffsetX > contentOffsetX) {
                UIView *tempView = (UIView *)[self.contentViews firstObject];
                tempView.frame = (CGRect){{0,0},tempView.frame.size};
            }
        }
        
        if(contentOffsetX >= (2 * CGRectGetWidth(scrollView.frame))) {
            self.currentPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex + 1];
            NSLog(@"next，当前页:%ld", (long)self.currentPageIndex);
            [self configContentViews];
        }
        if(contentOffsetX <= 0) {
            self.currentPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex - 1];
            NSLog(@"previous，当前页:%ld", (long)self.currentPageIndex);
            [self configContentViews];
        }
        
    }
    else {
        CGFloat contentOffsetY = scrollView.contentOffset.y;
        if (self.totalPageCount == 2) {
            if (self.scrollViewStartContentOffsetY < contentOffsetY) {
                UIView *tempView = (UIView *)[self.contentViews lastObject];
                tempView.frame = (CGRect){{0,2 * CGRectGetHeight(scrollView.frame)},tempView.frame.size};
            } else if (self.scrollViewStartContentOffsetY > contentOffsetY) {
                UIView *tempView = (UIView *)[self.contentViews firstObject];
                tempView.frame = (CGRect){{0,0},tempView.frame.size};
            }
        }
        
        if(contentOffsetY >= (2 * CGRectGetHeight(scrollView.frame))) {
            self.currentPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex + 1];
            NSLog(@"next，当前页:%ld", (long)self.currentPageIndex);
            [self configContentViews];
        }
        if(contentOffsetY <= 0) {
            self.currentPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex - 1];
            NSLog(@"previous，当前页:%ld", (long)self.currentPageIndex);
            [self configContentViews];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.scrollDirection == BFPFocusViewScrollDirectionHorizontal) {
        [scrollView setContentOffset:CGPointMake(CGRectGetWidth(scrollView.frame), 0) animated:YES];
    }
    else {
        [scrollView setContentOffset:CGPointMake(0, CGRectGetHeight(scrollView.frame)) animated:YES];
    }
}

#pragma mark - 私有函数

- (NSInteger)getValidNextPageIndexWithPageIndex:(NSInteger)currentPageIndex;
{
    if(currentPageIndex == -1) {
        return self.totalPageCount - 1;
    } else if (currentPageIndex == self.totalPageCount) {
        return 0;
    } else {
        return currentPageIndex;
    }
}

- (void)configContentViews
{
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self setScrollViewContentDataSource];
    
    NSInteger counter = 0;
    for (UIView *contentView in self.contentViews) {
        UILongPressGestureRecognizer *longTapGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapGestureAction:)];
        [contentView addGestureRecognizer:longTapGesture];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewTapAction:)];
        [contentView addGestureRecognizer:tapGesture];
        
        CGRect rightRect = contentView.frame;
        if (self.scrollDirection == BFPFocusViewScrollDirectionHorizontal) {
            rightRect.origin = CGPointMake(CGRectGetWidth(self.scrollView.frame) * (counter ++), 0);
        }
        else {
            rightRect.origin = CGPointMake(0, CGRectGetHeight(self.scrollView.frame) * (counter ++));
        }
        
        contentView.frame = rightRect;
        [self.scrollView addSubview:contentView];
    }
    if (self.totalPageCount > 1) {
        if (self.scrollDirection == BFPFocusViewScrollDirectionHorizontal)
        {
            [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
        }
        else
        {
            [_scrollView setContentOffset:CGPointMake(0, _scrollView.frame.size.height)];
        }
        
    }
}

- (void)setScrollViewContentDataSource {
    NSInteger previousPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex - 1];
    NSInteger rearPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex + 1];
    
    if (self.contentViews == nil) {
        self.contentViews = [@[] mutableCopy];
    }
    [self.contentViews removeAllObjects];
    
    if (self.fetchContentViewAtIndex) {
        id set = (self.totalPageCount == 1) ? [NSSet setWithObjects:@(previousPageIndex), @(_currentPageIndex), @(rearPageIndex), nil] : @[@(previousPageIndex), @(_currentPageIndex), @(rearPageIndex)];
        for (NSNumber *tempNumber in set) {
            NSInteger tempIndex = [tempNumber integerValue];
            if ([self isValidArrayIndex:tempIndex]) {
                UIView *aView = self.fetchContentViewAtIndex(tempIndex);
                if (aView) {
                    [self.contentViews addObject:aView];
                }
            }
        }
    }
}

- (BOOL)isValidArrayIndex:(NSInteger)index {
    if (index >= 0 && index <= self.totalPageCount - 1) {
        return YES;
    } else {
        return NO;
    }
}

- (UIPageControl *)pageControl {
    if (self.totalPageCount > 1) {
        if (!_pageControl) {
            _pageControl = [[UIPageControl alloc] init];
            _pageControl.backgroundColor = [UIColor clearColor];
            _pageControl.frame = CGRectMake(50, self.frame.size.height - 40, self.frame.size.width - 100, 14);
            _pageControl.currentPage = _currentPageIndex;
        }
        _pageControl.numberOfPages =_totalPageCount;
    }
    return _pageControl;
}

- (void)setTotalPagesCount:(NSInteger (^)(void))totalPagesCount {
    self.totalPageCount = totalPagesCount();
    if (self.totalPageCount > 0) {
        if (self.totalPageCount > 1) {
            self.scrollView.scrollEnabled = YES;
            if (self.scrollDirection == BFPFocusViewScrollDirectionHorizontal)
            {
                self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame), 0);
            }
            else
            {
                self.scrollView.contentOffset = CGPointMake(0,CGRectGetWidth(self.scrollView.frame));
            }
            [self.animationTimer resumeTimerAfterTimeInterval:self.animationDuration];
            
        } else {
            self.scrollView.scrollEnabled = NO;
        }
        [self addSubview:self.pageControl];
    }
}

#pragma mark - 响应事件

- (void)longTapGestureAction:(UILongPressGestureRecognizer *)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateBegan) {
        NSLog(@"UIGestureRecognizerStateBegan");
        [self.animationTimer pauseTimer];
    }
    if (tapGesture.state == UIGestureRecognizerStateEnded) {
        [self.animationTimer resumeTimer];
        NSLog(@"UIGestureRecognizerStateEnded");
    }
}

- (void)contentViewTapAction:(UITapGestureRecognizer *)tap
{
    if (self.TapActionBlock) {
        self.TapActionBlock(self.currentPageIndex);
    }
}

@end
