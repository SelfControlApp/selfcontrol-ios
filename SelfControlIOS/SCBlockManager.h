//
//  SCBlockManager.h
//  SelfControlIOS
//
//  Created by Charles Stigler on 25/02/2017.
//  Copyright © 2017 SelfControl. All rights reserved.
//

#import "SCBlockRule.h"

NS_ASSUME_NONNULL_BEGIN

@interface SCBlockManager : NSObject

+ (SCBlockManager *)sharedManager;

- (void)startBlock;

@property (nonatomic, copy) NSArray<SCBlockRule *> *blockRules;
@property (nonatomic, readonly) NSDate* blockEndDate;

@end

NS_ASSUME_NONNULL_END
