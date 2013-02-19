//
//  MWMenuViewController.m
//  Areca
//
//  Created by jwfing on 2/19/13.
//  Copyright (c) 2013 AVOS. All rights reserved.
//

#import "MWMenuViewController.h"
#import "MWDropdownViewController.h"
#import "MWMenuCell.h"

const NSTimeInterval kDropdownMenuDefaultAnimationDuration = 0.5f;

@interface MWMenuViewController ()

@end

@implementation MWMenuViewController

- (id)initWithDropdownView:(MWDropdownViewController*)dropdownView
           withControllers:(NSArray *)controllers
             withCellInfos:(NSArray *)cellInfos
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        _dropdownView = dropdownView;
        _controllers = controllers;
        _cellInfos = cellInfos;
        _dropdownView.menuViewController = self;
        _dropdownView.contentViewController = _controllers[0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.frame = CGRectMake(0.0f, 44.0f, 320.0f, [_cellInfos count] * [MWMenuCell height]);
	self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;

    _menuTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _menuTableView.dataSource = self;
    _menuTableView.delegate = self;
	_menuTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	_menuTableView.backgroundColor = [UIColor clearColor];
	_menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _menuTableView.scrollEnabled = NO;
	[self.view addSubview:_menuTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cellInfos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"MWDropdownMenuCell";
    MWMenuCell *cell = (MWMenuCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MWMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	NSDictionary *info = _cellInfos[indexPath.row];
	cell.textLabel.text = info[kSidebarCellTextKey];
	cell.imageView.image = info[kSidebarCellImageKey];
    return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 0.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	_dropdownView.contentViewController = _controllers[indexPath.row];
	[_dropdownView presentMenuView:NO duration:kDropdownMenuDefaultAnimationDuration];
}

#pragma mark Public Methods
- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition {
	[_menuTableView selectRowAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
	if (scrollPosition == UITableViewScrollPositionNone) {
		[_menuTableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
	}
	_dropdownView.contentViewController = _controllers[indexPath.row];
}


@end
