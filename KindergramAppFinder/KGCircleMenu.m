//
//  KGCircleMenu.m
//  KindergramAppFinder
//
//  Created by Christopher Lenz on 10.09.12.
//  Copyright (c) 2012 Kindergram. All rights reserved.
//

#import "KGCircleMenu.h"
#import "KGCircleIconView.h"
#import "KGDirectionalPanGestureRecognizer.h"

#import <QuartzCore/QuartzCore.h>


@interface KGCircleMenu () <UIGestureRecognizerDelegate>
@property (nonatomic, readonly) NSUInteger numberOfItems;
@property (nonatomic, strong) NSArray *iconViews;
@property (nonatomic, weak) UIPanGestureRecognizer *rotationGestureRecognizer;
@property (nonatomic, weak) KGDirectionalPanGestureRecognizer *draggingGestureRecognizer;
- (float)calculateDistanceFromCenter:(CGPoint)point;
- (void)configure;
- (NSInteger)indexAtAngle:(float)angle;
- (void)didEndRotatingAtAngle:(float)angle;
- (void)didRotateToAngle:(float)angle;
- (void)startDraggingIcon:(UILongPressGestureRecognizer *)gesture;
- (void)continueDraggingIcon:(UILongPressGestureRecognizer *)gesture;
- (void)stopDraggingIcon:(UILongPressGestureRecognizer *)gesture
               cancelled:(BOOL)cancelled;
@end


@implementation KGCircleMenu {
    CGFloat _angle;
    CGFloat _prevAngle;
    KGCircleIconView *_draggedIconView;
    UIView *_dragPlaceholder;
    NSUInteger _numberOfItems;
    CGFloat _offset;
    NSInteger _index;
}
@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize numberOfItems = _numberOfItems;
@synthesize iconViews = _iconViews;
@synthesize rotationGestureRecognizer = _rotationGestureRecognizer;
@synthesize draggingGestureRecognizer = _draggingGestureRecognizer;

#pragma mark Properties

- (NSArray *)iconViews
{
    if (!_iconViews) {
        NSMutableArray *iconViews = [NSMutableArray array];
        for (NSInteger i = 0; i < self.numberOfItems; i++) {
            KGCircleIconView *iconView = [self.dataSource circleMenu:self iconViewForItemAtIndex:i];
            [self addSubview:iconView];
            [iconViews addObject:iconView];
        }
        _iconViews = [iconViews copy];
    }
    return _iconViews;
}

- (NSUInteger)numberOfItems
{
    if (!_numberOfItems) {
        _numberOfItems = [self.dataSource numberOfItemsInCircleMenu:self];
    }
    return _numberOfItems;
}

#pragma mark Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    return self;
}

#pragma mark Public methods

- (KGCircleIconView *)iconViewAtIndex:(NSInteger)index
{
    BOOL negative = index < 0;
    NSUInteger modIndex = abs(index) % self.numberOfItems;
    if (negative && modIndex) {
        modIndex = self.numberOfItems - modIndex;
    }
    id view = [self.iconViews objectAtIndex:modIndex];
    if (![view isKindOfClass:[KGCircleIconView class]]) {
        return nil;
    }
    return view;
}

- (NSInteger)indexOfSelectedIconView
{
    return _index;
}

- (void)reloadMenu
{
    for (KGCircleIconView *iconView in self.iconViews) {
        [iconView removeFromSuperview];
    }
    [_draggedIconView removeFromSuperview];
    [_dragPlaceholder removeFromSuperview];

    _iconViews = nil;
    _draggedIconView = nil;
    _dragPlaceholder = nil;

    [self setNeedsLayout];
}

- (KGCircleIconView *)selectedIconView
{
    return [self iconViewAtIndex:_index];
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

    CGRect bounds = self.bounds;
    CGPoint center = (CGPoint){CGRectGetMidX(bounds), CGRectGetMidY(bounds)};
    CGFloat stepSize = 2 * M_PI / self.numberOfItems;
    NSUInteger index = 0;

    CGFloat radius = MIN(bounds.size.width, bounds.size.height);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        radius *= .33;
    } else {
        radius *= .4;
    }

    for (KGCircleIconView *iconView in self.iconViews) {
        // Calculate the position of the icon depending on the rotation offset
        CGFloat angle = _angle + index * stepSize;
        iconView.center = CGPointMake(center.x + radius * cosf(angle - M_PI_2),
                                      center.y + radius * sinf(angle - M_PI_2));

        CGFloat clampedAngle = fmod(fabs(angle), 2*M_PI);
        if (clampedAngle > M_PI) {
            clampedAngle = 2*M_PI - clampedAngle;
        }

        // Make the icons be more transparent the farther they are from the top
        // center
        iconView.alpha = 1.0 - (clampedAngle / M_PI) * 1.5;
        iconView.layer.shadowOpacity = iconView.alpha / 3;

        index += 1;
    }
}

#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer == self.draggingGestureRecognizer) {
        CGPoint location = [touch locationInView:self];
        KGCircleIconView *iconView = [self selectedIconView];
        if (!CGRectContainsPoint(CGRectInset(iconView.frame, -10, -10), location)) {
            return NO;
        }
    }
    return YES;
}

#pragma mark Actions

- (void)panToDrag:(UILongPressGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            [self startDraggingIcon:gesture];
        }
        case UIGestureRecognizerStateChanged: {
            [self continueDraggingIcon:gesture];
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            [self stopDraggingIcon:gesture
                         cancelled:gesture.state == UIGestureRecognizerStateCancelled];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)panToRotate:(UIPanGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:self];
    float distance = [self calculateDistanceFromCenter:location];

    float dx = location.x - CGRectGetMidX(self.bounds);
    float dy = location.y - CGRectGetMidY(self.bounds);
    float currentAngle = atan2(dy, dx);

    if (gesture.state == UIGestureRecognizerStateBegan) {
        _prevAngle = currentAngle;
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGFloat delta = currentAngle - _prevAngle;
        _prevAngle = currentAngle;
        if (distance >= 25) {
            _angle += delta;
            [self setNeedsLayout];
            [self didRotateToAngle:_angle];
        }
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        if (distance >= 25) {
            CGFloat delta = currentAngle - _prevAngle;
            _angle += delta;
        }
        CGFloat stepSize = 2 * M_PI / self.numberOfItems;
        _angle = roundf(_angle / stepSize) * stepSize;
        [self setNeedsLayout];
        [UIView animateWithDuration:0.3 animations:^{
            [self layoutIfNeeded];
        }];
        [self didEndRotatingAtAngle:_angle];
    }
}

#pragma mark Internals

- (float)calculateDistanceFromCenter:(CGPoint)point
{
    CGPoint center = (CGPoint){CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)};
	float dx = point.x - center.x;
	float dy = point.y - center.y;
	return sqrt(dx*dx + dy*dy);
}

- (void)configure
{
    UIPanGestureRecognizer *rotateGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(panToRotate:)];
    rotateGesture.delegate = self;
    rotateGesture.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:rotateGesture];
    self.rotationGestureRecognizer = rotateGesture;

    KGDirectionalPanGestureRecognizer *dragGesture = [[KGDirectionalPanGestureRecognizer alloc] initWithTarget:self
                                                                                                        action:@selector(panToDrag:)];
    dragGesture.maximumNumberOfTouches = 1;
    dragGesture.delegate = self;
    dragGesture.direction = KGDirectionalPangestureRecognizerVertical;
    dragGesture.threshold = 8;
    [self addGestureRecognizer:dragGesture];
    self.draggingGestureRecognizer = dragGesture;
}

- (void)didEndRotatingAtAngle:(float)angle
{
    return [self.delegate circleMenu:self
             didEndRotatingOnItemAtIndex:_index];
}

- (void)didRotateToAngle:(float)angle
{
    NSInteger index = [self indexAtAngle:angle];
    if (index != _index) {
        _index = index;
        return [self.delegate circleMenu:self
                  didRotateToItemAtIndex:index];
    }
}

- (NSInteger)indexAtAngle:(float)angle
{
    float stepSize = (M_PI * 2) / self.numberOfItems;
    return roundf(-angle / stepSize);
}

- (void)startDraggingIcon:(UILongPressGestureRecognizer *)gesture
{
    KGCircleIconView *iconView = [self selectedIconView];

    // Swap out the actual icon view for a placeholder
    NSMutableArray *iconViews = [self.iconViews mutableCopy];
    NSUInteger index = [self.iconViews indexOfObject:iconView];
    UIView *placeholder = [[UIView alloc] initWithFrame:iconView.frame];
    [iconViews replaceObjectAtIndex:index withObject:placeholder];
    self.iconViews = [iconViews copy];
    [self insertSubview:placeholder atIndex:0];
    _dragPlaceholder = placeholder;
    _draggedIconView = iconView;
    [self bringSubviewToFront:iconView];

    [self.delegate circleMenu:self
  didStartDraggingItemAtIndex:_index
                usingIconView:iconView
                   atLocation:[gesture locationInView:self]];
}

- (void)continueDraggingIcon:(UILongPressGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:self];
    _draggedIconView.center = location;

    [self.delegate circleMenu:self
           didDragItemAtIndex:_index
                usingIconView:_draggedIconView
                   toLocation:location];
}

- (void)stopDraggingIcon:(UILongPressGestureRecognizer *)gesture
               cancelled:(BOOL)cancelled
{
    KGCircleIconView *iconView = _draggedIconView;
    CGPoint location = [gesture locationInView:self];

    cancelled = ![self.delegate circleMenu:self
                        canDropItemAtIndex:_index usingIconView:iconView
                                atLocation:location];

    [UIView animateWithDuration:0.5 animations:^{
        iconView.layer.shadowRadius = 1;
        [self layoutIfNeeded];
    }];

    if (!cancelled) {
        [self.delegate circleMenu:self
               didDropItemAtIndex:_index
                    usingIconView:iconView
                       atLocation:location];
    } else {
        NSMutableArray *iconViews = [self.iconViews mutableCopy];
        NSUInteger index = [self.iconViews indexOfObject:_dragPlaceholder];
        [iconViews replaceObjectAtIndex:index withObject:iconView];
        self.iconViews = [iconViews copy];
        [_dragPlaceholder removeFromSuperview];
        _dragPlaceholder = nil;
        _draggedIconView = nil;

        [self.delegate circleMenu:self
     didCancelDraggingItemAtIndex:_index
                    usingIconView:iconView
                       atLocation:location];
    }
}

@end
