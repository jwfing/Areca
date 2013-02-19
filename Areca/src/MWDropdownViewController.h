//
//  MWDropdownViewController.h
//  Areca
//
//  Created by jwfing on 2/19/13.
//  Copyright (c) 2013 AVOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MWDropdownViewController : UIViewController

@property (strong, nonatomic) UIViewController *menuViewController;
@property (strong, nonatomic) UIViewController *contentViewController;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil cellCount:(int)cellCount;
- (void)presentMenuView:(BOOL)show duration:(NSTimeInterval)duration;
- (void)presentMenuView:(BOOL)show duration:(NSTimeInterval)duration
             completion:(void (^)(BOOL finished))completion;

@end
