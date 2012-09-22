//
//  KGAppViewController.m
//  KindergramAppFinder
//
//  Created by Christopher Lenz on 06.09.12.
//  Copyright (c) 2012 Kindergram. All rights reserved.
//

#import "KGAppViewController.h"

@implementation KGAppViewController {
    CGPoint lastPoint;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat brush;
    CGFloat opacity;
    BOOL moved;
}
@synthesize mainImageView = _mainImageView;
@synthesize tempImageView = _tempImageView;
@synthesize hintLabel = _hintLabel;
@synthesize drawColor = _drawColor;

- (void)viewDidLoad
{
    brush = 10.0;
    opacity = 1.0;
}

- (void)setDrawColor:(UIColor *)drawColor
{
    CGFloat alpha;
    [drawColor getRed:&red green:&green blue:&blue alpha:&alpha];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    moved = NO;
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self.view];

    [UIView animateWithDuration:0.5 animations:^{
        self.hintLabel.alpha = 0;
    } completion:^(BOOL finished) {
        self.hintLabel.alpha = 1;
        self.hintLabel.hidden = YES;
    }];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

    moved = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.view];

    UIGraphicsBeginImageContext(self.view.frame.size);
    [self.tempImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush );
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);

    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.tempImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.tempImageView setAlpha:opacity];
    UIGraphicsEndImageContext();

    lastPoint = currentPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    if (!moved) {
        UIGraphicsBeginImageContext(self.view.frame.size);
        [self.tempImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, opacity);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        self.tempImageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }

    UIGraphicsBeginImageContext(self.mainImageView.frame.size);
    [self.mainImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    [self.tempImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:opacity];
    self.mainImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    self.tempImageView.image = nil;
    UIGraphicsEndImageContext();
}

- (IBAction)backButtonPressed:(UIButton *)sender
{
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

@end
