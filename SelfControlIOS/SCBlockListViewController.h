//
//  SCBlockListViewController.h
//  SelfControlIOS
//
//  Created by Charles Stigler on 25/02/2017.
//  Copyright © 2017 SelfControl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCBlockRule.h"
#import "SCAppSelectorDelegate.h"

@interface SCBlockListViewController : UITableViewController <SCAppSelectorDelegate>

- (void)addRulesToList:(NSArray<SCBlockRule*>*)rules type:(SCBlockType)type;

@end
