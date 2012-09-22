//
//  KGViewController.m
//  KindergramAppFinder
//
//  Created by Christopher Lenz on 04.09.12.
//  Copyright (c) 2012 Kindergram. All rights reserved.
//

#import "KGViewController.h"
#import "KGDetailView.h"
#import "KGCircleMenu.h"
#import "KGAppViewController.h"

#import <QuartzCore/QuartzCore.h>

#define COLOR_PURPLE [UIColor colorWithRed:0.667 green:0.502 blue:0.792 alpha:1]
#define COLOR_GREEN [UIColor colorWithRed:0 green:1 blue:0.620 alpha:1]
#define COLOR_BLUE [UIColor colorWithRed:0.008 green:0.769 blue:0.961 alpha:1]


@interface KGViewController () <KGCircleMenuDataSource, KGCircleMenuDelegate>
@end


@implementation KGViewController
@synthesize titleBackgroundView = _titleBackgroundView;
@synthesize circleMenu = _circleMenuView;
@synthesize circleMenuImageView = _circleMenuImageView;
@synthesize detailTitleLabel = _detailTitleLabel;
@synthesize detailView = _detailView;

#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.titleBackgroundView.layer.borderColor = [UIColor colorWithRed:0.871 green:0.871 blue:0.867 alpha:1].CGColor;
    self.titleBackgroundView.layer.borderWidth = 1;

    self.detailView.screenshotBackgroundColor = COLOR_BLUE;
    self.detailView.screenshotGap = 20;
    self.detailView.screenshotOrigin = [self.view convertPoint:self.circleMenu.center
                                                      fromView:self.detailView];
    self.detailView.numberOfScreenshots = 6;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    CGRect detailFrame = self.detailView.frame;
    detailFrame.size.height = CGRectGetMinY(self.circleMenu.frame) - 20 - CGRectGetMinY(detailFrame);
    self.detailView.frame = detailFrame;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Launch App"]) {
        KGAppViewController *appViewController = segue.destinationViewController;
        KGCircleIconView *iconView = sender;
        appViewController.drawColor = iconView.fillColor;
    }
}

#pragma mark KGCircleMenuViewDataSource

- (NSUInteger)numberOfItemsInCircleMenu:(KGCircleMenu *)circleMenuView
{
    return 8;
}

- (KGCircleIconView *)circleMenu:(KGCircleMenu *)circleMenuView
              iconViewForItemAtIndex:(NSInteger)index
{
    NSArray *colors = [NSArray arrayWithObjects:COLOR_BLUE, COLOR_GREEN, COLOR_PURPLE, nil];
    NSArray *imageNames = [NSArray arrayWithObjects:@"CircleIconBlue.png", @"CircleIconGreen.png", @"CircleIconPurple.png", nil];

    KGCircleIconView *iconView = [[KGCircleIconView alloc] init];
    iconView.fillColor = [colors objectAtIndex:index % 3];
    iconView.imageView.image = [UIImage imageNamed:[imageNames objectAtIndex:index % 3]];
//    iconView.textLabel.text = [NSString stringWithFormat:@"%d", index + 1];
    return iconView;
}

#pragma mark KGCircleMenuViewDelegate

- (void)circleMenu:(KGCircleMenu *)circleMenuView
didEndRotatingOnItemAtIndex:(NSInteger)index
{
    NSLog(@"Circle menu came to rest at index %d", index);
}

- (void)circleMenu:(KGCircleMenu *)circleMenu
didRotateToItemAtIndex:(NSInteger)index
{
    [UIView animateWithDuration:.5
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.detailView.screenshotBackgroundColor = [circleMenu iconViewAtIndex:index].fillColor;
                     } completion:nil];
}

- (void)circleMenu:(KGCircleMenu *)circleMenuView
didStartDraggingItemAtIndex:(NSInteger)index
     usingIconView:(KGCircleIconView *)iconView
        atLocation:(CGPoint)location
{
    self.circleMenuImageView.highlighted = YES;
    [UIView animateWithDuration:.3 animations:^{
        iconView.transform = CGAffineTransformScale(iconView.transform, 2, 2);
        iconView.layer.shadowRadius = 10;
        self.detailView.alpha = .5;
    }];
}

- (void)circleMenu:(KGCircleMenu *)circleMenu
    didDragItemAtIndex:(NSInteger)index
         usingIconView:(KGCircleIconView *)iconView
            toLocation:(CGPoint)location
{
}

- (BOOL)circleMenu:(KGCircleMenu *)circleMenu
    canDropItemAtIndex:(NSInteger)index
         usingIconView:(KGCircleIconView *)iconView
            atLocation:(CGPoint)location
{
    return CGRectContainsPoint(self.circleMenuImageView.frame, location);
}

- (void)circleMenu:(KGCircleMenu *)circleMenuView
didDropItemAtIndex:(NSInteger)index
     usingIconView:(KGCircleIconView *)iconView
        atLocation:(CGPoint)location
{
    [UIView animateWithDuration:.3 animations:^{
        iconView.center = self.circleMenuImageView.center;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.5 animations:^{
            self.detailView.alpha = 1;
            self.circleMenuImageView.highlighted = NO;
        } completion:^(BOOL finished) {
            [circleMenuView reloadMenu];
        }];
        [self performSegueWithIdentifier:@"Launch App" sender:iconView];
    }];
}

- (void)circleMenu:(KGCircleMenu *)circleMenu
didCancelDraggingItemAtIndex:(NSInteger)index
     usingIconView:(KGCircleIconView *)iconView
        atLocation:(CGPoint)location
{
    [UIView animateWithDuration:.5 animations:^{
        iconView.transform = CGAffineTransformIdentity;
        self.detailView.alpha = 1;
        self.circleMenuImageView.highlighted = NO;
    }];
}

@end
