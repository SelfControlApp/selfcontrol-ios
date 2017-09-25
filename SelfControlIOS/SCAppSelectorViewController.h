//
//  SCAppSelectorViewController.h
//  SelfControlIOS
//
//  Created by Charles Stigler on 06/08/2017.
//  Copyright © 2017 SelfControl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCBlockListViewController.h"
#import "SCBlockManager.h"
#import "SCAppSelectorDelegate.h"

@interface SCAppSelectorViewController : UITableViewController

@property (weak) id<SCAppSelectorDelegate> delegate;

@end
