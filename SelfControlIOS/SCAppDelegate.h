//
//  SCAppDelegate.h
//  SelfControlIOS
//
//  Created by Charles Stigler on 25/02/2017.
//  Copyright © 2017 SelfControl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCMainViewController.h"

@interface SCAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, weak) SCMainViewController *mainViewController;

@end
