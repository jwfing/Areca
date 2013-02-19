//
//  RootViewController.h
//  Areca
//
//  Created by jwfing on 2/19/13.
//  Copyright (c) 2013 AVOS. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^DropdownBlock)();

@interface RootViewController : UIViewController {
@private
    DropdownBlock _dropdownBlock;
}

- (id)initWithTitle:(NSString*)title andDropdownBlock:(DropdownBlock)block;

@end
