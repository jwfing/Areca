//
//  MWMenuViewController.h
//  Areca
//
//  Created by jwfing on 2/19/13.
//  Copyright (c) 2013 AVOS. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MWDropdownViewController;

@interface MWMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
@private
    MWDropdownViewController *_dropdownView;
    UITableView *_menuTableView;
    NSArray *_controllers;
    NSArray *_cellInfos;
}

- (id)initWithDropdownView:(MWDropdownViewController*)dropdownView
           withControllers:(NSArray *)controllers
             withCellInfos:(NSArray *)cellInfos;

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath
					animated:(BOOL)animated
			  scrollPosition:(UITableViewScrollPosition)scrollPosition;

@end
