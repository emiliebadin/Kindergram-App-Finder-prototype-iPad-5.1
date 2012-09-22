//
//  KGCircleMenu.h
//  KindergramAppFinder
//
//  Created by Christopher Lenz on 10.09.12.
//  Copyright (c) 2012 Kindergram. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KGCircleIconView.h"

@class KGCircleIconView;
@protocol KGCircleMenuDataSource;
@protocol KGCircleMenuDelegate;


@interface KGCircleMenu : UIControl
@property (nonatomic, weak) IBOutlet id <KGCircleMenuDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id <KGCircleMenuDelegate> delegate;
- (KGCircleIconView *)iconViewAtIndex:(NSInteger)index;
- (NSInteger)indexOfSelectedIconView;
- (void)reloadMenu;
- (KGCircleIconView *)selectedIconView;
@end


@protocol KGCircleMenuDataSource
- (NSUInteger)numberOfItemsInCircleMenu:(KGCircleMenu *)circleMenu;
- (KGCircleIconView *)circleMenu:(KGCircleMenu *)circleMenu
          iconViewForItemAtIndex:(NSInteger)index;
@end



@protocol KGCircleMenuDelegate

// Rotation
- (void)circleMenu:(KGCircleMenu *)circleMenu
didRotateToItemAtIndex:(NSInteger)index;
- (void)circleMenu:(KGCircleMenu *)circleMenu
didEndRotatingOnItemAtIndex:(NSInteger)index;

// Drag and Drop
- (void)circleMenu:(KGCircleMenu *)circleMenu
didStartDraggingItemAtIndex:(NSInteger)index
     usingIconView:(KGCircleIconView *)iconView
        atLocation:(CGPoint)location;
- (void)circleMenu:(KGCircleMenu *)circleMenu
    didDragItemAtIndex:(NSInteger)index
     usingIconView:(KGCircleIconView *)iconView
        toLocation:(CGPoint)location;
- (BOOL)circleMenu:(KGCircleMenu *)circleMenu
canDropItemAtIndex:(NSInteger)index
     usingIconView:(KGCircleIconView *)iconView
        atLocation:(CGPoint)location;
- (void)circleMenu:(KGCircleMenu *)circleMenu
didDropItemAtIndex:(NSInteger)index
     usingIconView:(KGCircleIconView *)iconView
        atLocation:(CGPoint)location;
- (void)circleMenu:(KGCircleMenu *)circleMenu
didCancelDraggingItemAtIndex:(NSInteger)index
     usingIconView:(KGCircleIconView *)iconView
        atLocation:(CGPoint)location;

@end
