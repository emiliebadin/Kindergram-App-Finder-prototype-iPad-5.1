//
//  KGDirectionalPanGestureRecognizer.h
//  KindergramAppFinder
//
//  Created by Christopher Lenz on 10.09.12.
//  Copyright (c) 2012 Kindergram. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Foundation/Foundation.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

typedef enum {
    KGDirectionalPangestureRecognizerVertical,
    KGDirectionalPanGestureRecognizerHorizontal
} KGDirectionalPangestureRecognizerDirection;

@interface KGDirectionalPanGestureRecognizer : UIPanGestureRecognizer
@property (nonatomic, assign) KGDirectionalPangestureRecognizerDirection direction;
@property (nonatomic, assign) CGFloat threshold;
@end
