//
//  SCBlockListViewController.h
//  SelfControlIOS
//
//  Created by Charles Stigler on 25/02/2017.
//  Copyright © 2017 SelfControl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCBlockRule.h"

@interface SCBlockListViewController : UITableViewController

- (void)addSitesToList:(NSArray<SCBlockRule*>*)sites;

@end
