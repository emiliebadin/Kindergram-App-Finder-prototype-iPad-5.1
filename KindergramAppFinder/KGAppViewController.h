//
//  KGAppViewController.h
//  KindergramAppFinder
//
//  Created by Christopher Lenz on 06.09.12.
//  Copyright (c) 2012 Kindergram. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KGAppViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UIImageView *tempImageView;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;
@property (strong, nonatomic) UIColor *drawColor;
@end
