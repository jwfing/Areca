//
//  ViewController.m
//  Areca
//
//  Created by jwfing on 2/17/13.
//  Copyright (c) 2013 AVOS. All rights reserved.
//

#import "ViewController.h"
#import "MWDropdownViewController.h"
#import "MWMenuViewController.h"
#import "RootViewController.h"
#import "MWMenuCell.h"

@interface ViewController ()

@property (nonatomic, strong) MWDropdownViewController *dropDownViewController;
@property (nonatomic, strong) MWMenuViewController *menuViewController;

@end

@implementation ViewController

@synthesize dropDownViewController, menuViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginTap:(id)sender {
    self.dropDownViewController = [[MWDropdownViewController alloc] initWithNibName:nil bundle:nil cellCount:4];
    
    DropdownBlock dropDownBlock = ^() {
        [self.dropDownViewController presentMenuView:YES duration:0.6f];
    };
    NSArray *controllers = @[
                             [[UINavigationController alloc] initWithRootViewController:[[RootViewController alloc] initWithTitle:@"Home" andDropdownBlock:dropDownBlock]],
                             [[UINavigationController alloc] initWithRootViewController:[[RootViewController alloc] initWithTitle:@"Discover" andDropdownBlock:dropDownBlock]],
                             [[UINavigationController alloc] initWithRootViewController:[[RootViewController alloc] initWithTitle:@"Activity" andDropdownBlock:dropDownBlock]],
                             [[UINavigationController alloc] initWithRootViewController:[[RootViewController alloc] initWithTitle:@"Profile" andDropdownBlock:dropDownBlock]],
                             ];
    NSArray *cellInfos = @[
                           @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"Home", @"")},
                           @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"Discover", @"")},
                           @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"Activity", @"")},
                           @{kSidebarCellImageKey: [UIImage imageNamed:@"user.png"], kSidebarCellTextKey: NSLocalizedString(@"Profile", @"")}
                           ];
    self.menuViewController = [[MWMenuViewController alloc] initWithDropdownView:self.dropDownViewController withControllers:controllers withCellInfos:cellInfos];

    [self presentModalViewController:self.dropDownViewController animated:YES];
}
@end
