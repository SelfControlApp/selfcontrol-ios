//
//  SCUtils+SCViewUtils.h
//  SelfControlIOS
//
//  Created by Charles Stigler on 23/09/2017.
//  Copyright © 2017 SelfControl. All rights reserved.
//

#import "SCUtils.h"

// This needs to be a separate category from the normal SCUtils because SCUtils is used in the filter extension binaries,
// and therefore can't link to any classes that aren't included in the filter extension

@interface SCUtils (SCViewUtils)

+ (NSString*)blockListSummaryString;

@end
