//
//  SCUtils+SCViewUtils.m
//  SelfControlIOS
//
//  Created by Charles Stigler on 23/09/2017.
//  Copyright © 2017 SelfControl. All rights reserved.
//

#import "SCUtils+SCViewUtils.h"
#import "SCBlockManager.h"

@implementation SCUtils (SCViewUtils)

+ (NSString*)blockListSummaryString {
    NSInteger appsBlocked = [SCBlockManager sharedManager].appBlockRules.count;
    NSInteger sitesBlocked = [SCBlockManager sharedManager].hostBlockRules.count;
    
    NSString* appsString = [NSString localizedStringWithFormat: NSLocalizedString(@"%lu app(s)", @"%{number of blocked apps} app(s)"), (unsigned long)appsBlocked];
    NSString* sitesString = [NSString localizedStringWithFormat: NSLocalizedString(@"%lu site(s)", @"{number of blocked sites} site(s)"), (unsigned long)sitesBlocked];
    
    if (!appsBlocked && !sitesBlocked) {
        return NSLocalizedString(@"Nothing", nil);
    } else if (appsBlocked && sitesBlocked) {
        return [NSString localizedStringWithFormat: NSLocalizedString(@"%@ and %@", @"{num blocked apps} apps and {num blocked sites} sites"), appsString, sitesString];
    } else if (appsBlocked) {
        return appsString;
    } else {
        // only sitesBlocked
        return sitesString;
    }
}

@end
