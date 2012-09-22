//
//  KGViewController.h
//  KindergramAppFinder
//
//  Created by Christopher Lenz on 04.09.12.
//  Copyright (c) 2012 Kindergram. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KGDetailView;
@class KGCircleMenu;

@interface KGViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *titleBackgroundView;
@property (weak, nonatomic) IBOutlet KGCircleMenu *circleMenu;
@property (weak, nonatomic) IBOutlet UIImageView *circleMenuImageView;
@property (weak, nonatomic) IBOutlet UILabel *detailTitleLabel;
@property (weak, nonatomic) IBOutlet KGDetailView *detailView;
@end
