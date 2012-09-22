//
//  KGCircleDetailView.h
//  KindergramAppFinder
//
//  Created by Christopher Lenz on 05.09.12.
//  Copyright (c) 2012 Kindergram. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KGDetailView : UIView
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, assign) NSUInteger numberOfScreenshots;
@property (nonatomic, assign) CGFloat screenshotGap;
@property (nonatomic, strong) UIColor *screenshotBackgroundColor;
@property (nonatomic, assign) CGPoint screenshotOrigin;
@end
