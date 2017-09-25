//
//  SCAppSelectorDelegate.h
//  SelfControlIOS
//
//  Created by Charles Stigler on 23/09/2017.
//  Copyright © 2017 SelfControl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCBlockRule.h"

@protocol SCAppSelectorDelegate <NSObject>

- (void)appRuleSelected:(SCBlockRule*)appRule;

@end
