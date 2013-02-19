//
//  RootViewController.m
//  Areca
//
//  Created by jwfing on 2/19/13.
//  Copyright (c) 2013 AVOS. All rights reserved.
//

#import "RootViewController.h"
#import "CaptureViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (id)initWithTitle:(NSString *)title andDropdownBlock:(DropdownBlock)block
{
    self = [super initWithNibName:@"rootViewController" bundle:nil];
    if (self) {
        // Custom initialization
        self.title = title;
        _dropdownBlock = [block copy];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showDropdownMenu)];
        if ([title compare:@"Home"] == NSOrderedSame) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(captureVideo)];
        }
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

- (void)showDropdownMenu
{
    _dropdownBlock();
}

- (void)captureVideo
{
    CaptureViewController *captureViewController = [[CaptureViewController alloc] initWithNibName:@"captureView" bundle:nil];
    [self.navigationController pushViewController:captureViewController animated:YES];
}

@end
