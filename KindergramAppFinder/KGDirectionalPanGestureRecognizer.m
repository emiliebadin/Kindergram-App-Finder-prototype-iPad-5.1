//
//  KGDirectionalPanGestureRecognizer.m
//  KindergramAppFinder
//
//  Created by Christopher Lenz on 10.09.12.
//  Copyright (c) 2012 Kindergram. All rights reserved.
//

#import "KGDirectionalPanGestureRecognizer.h"

@implementation KGDirectionalPanGestureRecognizer {
    BOOL _drag;
    int _moveX;
    int _moveY;
}
@synthesize direction = _direction;
@synthesize threshold = _threshold;

- (CGFloat)threshold
{
    if (!_threshold) {
        _threshold = 5.0;
    }
    return _threshold;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    if (self.state == UIGestureRecognizerStateFailed) {
        return;
    }

    CGPoint nowPoint = [[touches anyObject] locationInView:self.view];
    CGPoint prevPoint = [[touches anyObject] previousLocationInView:self.view];
    _moveX += prevPoint.x - nowPoint.x;
    _moveY += prevPoint.y - nowPoint.y;
    if (!_drag) {
        if (abs(_moveX) > self.threshold) {
            if (_direction == KGDirectionalPangestureRecognizerVertical) {
                self.state = UIGestureRecognizerStateFailed;
            }else {
                _drag = YES;
            }
        }else if (abs(_moveY) > self.threshold) {
            if (_direction == KGDirectionalPanGestureRecognizerHorizontal) {
                self.state = UIGestureRecognizerStateFailed;
            }else {
                _drag = YES;
            }
        }
    }
}

- (void)reset
{
    [super reset];
    _drag = NO;
    _moveX = 0;
    _moveY = 0;
}

@end
