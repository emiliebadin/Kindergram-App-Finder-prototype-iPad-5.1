//
//  KGCircleDetailView.m
//  KindergramAppFinder
//
//  Created by Christopher Lenz on 05.09.12.
//  Copyright (c) 2012 Kindergram. All rights reserved.
//

#import "KGDetailView.h"

#import <QuartzCore/QuartzCore.h>


@interface KGDetailView ()
- (void)configure;
- (void)curledShadowForThumbnailInLayer:(CALayer *)layer
                             frameWidth:(CGFloat)frameWidth
                            shadowDepth:(CGFloat)shadowDepth;
- (CGSize)screenshotSize;
@end


@implementation KGDetailView {
    CGSize _screenshotSize;
    NSArray *_screenshotViews;
}
@synthesize titleLabel = _titleLabel;
@synthesize numberOfScreenshots = _numberOfScreenshots;
@synthesize screenshotGap = _screenshotGap;
@synthesize screenshotBackgroundColor = _screenshotBackgroundColor;
@synthesize screenshotOrigin = _screenshotOrigin;

#define SCREENSHOTS_PER_ROW 3
#define SCREENSHOTS_PER_COLUMN 2

#pragma mark Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    return self;
}

#pragma mark Properties

- (void)setNumberOfScreenshots:(NSUInteger)numberOfScreenshots
{
    if (numberOfScreenshots == _numberOfScreenshots) {
        return;
    }

    NSMutableArray *screenshotViews = [_screenshotViews mutableCopy];
    while ([screenshotViews count] > numberOfScreenshots) {
        UIView *screenshotView = [screenshotViews lastObject];
        if (screenshotView) {
            [screenshotViews removeObject:screenshotView];
            [screenshotView removeFromSuperview];
        }
    }
    if (!screenshotViews) {
        screenshotViews = [NSMutableArray array];
    }

    CGRect screenshotFrame = (CGRect){self.screenshotOrigin, [self screenshotSize]};
    while ([screenshotViews count] < numberOfScreenshots) {
        UIView *screenshotView = [[UIView alloc] initWithFrame:screenshotFrame];
        [self curledShadowForThumbnailInLayer:screenshotView.layer
                                   frameWidth:2
                                  shadowDepth:2];
        screenshotView.backgroundColor = self.screenshotBackgroundColor;
        [self addSubview:screenshotView];
        [screenshotViews addObject:screenshotView];
    }

    _screenshotViews = [screenshotViews copy];
    _numberOfScreenshots = numberOfScreenshots;
}

- (void)setScreenshotBackgroundColor:(UIColor *)color
{
    if (color == _screenshotBackgroundColor) {
        return;
    }
    _screenshotBackgroundColor = color;
    for (UIView *screenshotView in _screenshotViews) {
        screenshotView.backgroundColor = color;
    }
}

- (void)setScreenshotGap:(CGFloat)screenshotGap
{
    if (screenshotGap == _screenshotGap) {
        return;
    }
    _screenshotGap = screenshotGap;
    [self setNeedsLayout];
}

- (CGSize)screenshotSize
{
    if (CGSizeEqualToSize(_screenshotSize, CGSizeZero)) {
        CGSize boundsSize = self.bounds.size;

        CGFloat availableWidth = boundsSize.width - self.screenshotGap * (SCREENSHOTS_PER_ROW + 1);
        CGFloat screenshotWidth = rint(availableWidth / SCREENSHOTS_PER_ROW);

        CGFloat availableHeight = boundsSize.height - CGRectGetMaxY(self.titleLabel.frame) - 15 - self.screenshotGap * (SCREENSHOTS_PER_COLUMN);
        CGFloat screenshotHeight = rint(availableHeight / SCREENSHOTS_PER_COLUMN);
        
        _screenshotSize = (CGSize){screenshotWidth, screenshotHeight};
    }
    return _screenshotSize;
}

#pragma mark UIView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self configure];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGPoint screenshotOrigin = (CGPoint){self.screenshotGap,
                                         CGRectGetMaxY(self.titleLabel.frame) + 15};
    CGRect screenshotRect = (CGRect){screenshotOrigin, self.screenshotSize};
    for (UIView *screenshotView in _screenshotViews) {
        screenshotView.center = CGPointMake(CGRectGetMidX(screenshotRect),
                                            CGRectGetMidY(screenshotRect));
        screenshotRect.origin.x += self.screenshotSize.width + self.screenshotGap;
        if (CGRectGetMaxX(screenshotRect) > CGRectGetMaxX(self.bounds)) {
            screenshotRect.origin.x = screenshotOrigin.x;
            screenshotRect.origin.y = CGRectGetMaxY(screenshotRect) + self.screenshotGap;
        }
    }
}

#pragma mark Internals

- (void)configure
{
    self.layer.borderColor = [UIColor colorWithRed:0.871 green:0.871 blue:0.867 alpha:1].CGColor;
    self.layer.borderWidth = 1;
}

- (void)curledShadowForThumbnailInLayer:(CALayer *)layer
                             frameWidth:(CGFloat)frameWidth
                            shadowDepth:(CGFloat)shadowDepth
{
    CGFloat minX = CGRectGetMinX(layer.bounds);
    CGFloat maxX = CGRectGetMaxX(layer.bounds);
    CGFloat minY = CGRectGetMinY(layer.bounds);
    CGFloat maxY = CGRectGetMaxY(layer.bounds);

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(minX, minY)];
    [path addLineToPoint:CGPointMake(maxX, minY)];
    [path addLineToPoint:CGPointMake(maxX, maxY + shadowDepth)];
    [path addCurveToPoint:CGPointMake(minX, maxY + shadowDepth)
            controlPoint1:CGPointMake(maxX - 30, maxY - shadowDepth)
            controlPoint2:CGPointMake(minX + 30, maxY - shadowDepth)];
    [path closePath];

    layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    layer.borderWidth  = frameWidth;
    layer.borderColor = [UIColor whiteColor].CGColor;
    layer.shadowColor = [UIColor darkGrayColor].CGColor;
    layer.shadowOffset = CGSizeMake(0.0, shadowDepth + 1);
    layer.shadowRadius = 3.0;
    layer.shadowOpacity = 0.4;
    layer.shadowPath = path.CGPath;
}

@end
