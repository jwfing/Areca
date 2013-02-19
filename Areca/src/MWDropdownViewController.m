//
//  MWDropdownViewController.m
//  Areca
//
//  Created by jwfing on 2/19/13.
//  Copyright (c) 2013 AVOS. All rights reserved.
//

#import "MWDropdownViewController.h"
#import "MWMenuCell.h"

@interface MWDropdownViewController () {
    UIView *_menuView;
    UIView *_contentView;
}

@end

@implementation MWDropdownViewController

@synthesize menuViewController = _menuViewController;
@synthesize contentViewController = _contentViewController;

- (void)setMenuViewController:(UIViewController *)menuViewController
{
    if (nil == _menuViewController) {
        menuViewController.view.frame = _menuView.bounds;
        _menuViewController = menuViewController;
        [self addChildViewController:_menuViewController];
        [_menuView addSubview:_menuViewController.view];
        [_menuViewController didMoveToParentViewController:self];
    } else if (_menuViewController != menuViewController) {
		menuViewController.view.frame = _menuView.bounds;
		[_menuViewController willMoveToParentViewController:nil];
		[self addChildViewController:menuViewController];
		self.view.userInteractionEnabled = NO;
		[self transitionFromViewController:_menuViewController
						  toViewController:menuViewController
								  duration:0
								   options:UIViewAnimationOptionTransitionNone
								animations:^{}
								completion:^(BOOL finished){
									self.view.userInteractionEnabled = YES;
									[_menuViewController removeFromParentViewController];
									[menuViewController didMoveToParentViewController:self];
									_menuViewController = menuViewController;
								}
		 ];
    }
}

- (void)setContentViewController:(UIViewController *)contentViewController
{
    if (nil == _contentViewController) {
        contentViewController.view.frame = _contentView.bounds;
        _contentViewController = contentViewController;
        [self addChildViewController:_contentViewController];
        [_contentView addSubview:_contentViewController.view];
        [_contentViewController didMoveToParentViewController:self];
    } else if (_contentViewController != contentViewController) {
		contentViewController.view.frame = _contentView.bounds;
		[_contentViewController willMoveToParentViewController:nil];
		[self addChildViewController:contentViewController];
		self.view.userInteractionEnabled = NO;
		[self transitionFromViewController:_contentViewController
						  toViewController:contentViewController
								  duration:0
								   options:UIViewAnimationOptionTransitionNone
								animations:^{}
								completion:^(BOOL finished){
									self.view.userInteractionEnabled = YES;
									[_contentViewController removeFromParentViewController];
									[contentViewController didMoveToParentViewController:self];
									_contentViewController = contentViewController;
								}
		 ];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil cellCount:(int)cellCount
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        
		_contentView = [[UIView alloc] initWithFrame:self.view.bounds];
		_contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		_contentView.backgroundColor = [UIColor redColor];
        [self.view addSubview:_contentView];

        _menuView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 44.0f, 320.0f, cellCount * [MWMenuCell height])];
        _menuView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        _menuView.backgroundColor = [UIColor blueColor];
        [self.view addSubview:_menuView];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)presentMenuView:(BOOL)show duration:(NSTimeInterval)duration
{
    [self presentMenuView:show duration:duration completion:^(BOOL finished) {}];
}

- (void)presentMenuView:(BOOL)show duration:(NSTimeInterval)duration
             completion:(void (^)(BOOL finished))completion
{
    if (show) {
        [_menuView setHidden:NO];
    } else {
        [_menuView setHidden:YES];
    }
}

@end
