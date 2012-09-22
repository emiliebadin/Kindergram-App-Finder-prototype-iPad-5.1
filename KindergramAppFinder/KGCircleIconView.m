//
//  KGCircleIconView.m
//  KindergramAppFinder
//
//  Created by Christopher Lenz on 04.09.12.
//  Copyright (c) 2012 Kindergram. All rights reserved.
//

#import "KGCircleIconView.h"

#import <QuartzCore/QuartzCore.h>


@interface KGCircleIconView ()
- (void)configure;
@end


@implementation KGCircleIconView
@synthesize imageView = _imageView;
@synthesize textLabel = _textLabel;
@synthesize fillColor = _fillColor;

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

- (UIColor *)fillColor
{
    if (!_fillColor) {
        _fillColor = [UIColor clearColor];
    }
    return _fillColor;
}

#pragma mark UIView

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.layer.shadowPath = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(self.bounds, 2, 2)].CGPath;
}

#pragma mark Internals

- (void)configure
{
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = NO;
    self.userInteractionEnabled = NO;

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CircleIconBlue.png"]];
    self.bounds = imageView.bounds;
    [self addSubview:imageView];
    self.imageView = imageView;

    UILabel *textLabel = [[UILabel alloc] initWithFrame:self.bounds];
    textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.font = [UIFont fontWithName:@"AmericanTypewriter" size:17];
    textLabel.textAlignment = UITextAlignmentCenter;
    textLabel.textColor = [UIColor whiteColor];
    [self addSubview:textLabel];
    self.textLabel = textLabel;

    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowOffset = (CGSize){0, -1};
    self.layer.shadowRadius = 1;
}

@end
