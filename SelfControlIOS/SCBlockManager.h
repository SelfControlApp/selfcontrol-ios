//
//  SCBlockManager.h
//  SelfControlIOS
//
//  Created by Charles Stigler on 25/02/2017.
//  Copyright © 2017 SelfControl. All rights reserved.
//

#import "SCBlockRule.h"

typedef void(^completion)(NSError*);

NS_ASSUME_NONNULL_BEGIN

@interface SCBlockManager : NSObject

+ (SCBlockManager *)sharedManager;

- (void)startBlock:(completion)done;

- (void)addBlockRules:(NSArray<SCBlockRule*> *)blockRules;
- (void)addBlockRule:(SCBlockRule*)blockRule;
- (void)removeBlockRuleAtIndex:(NSUInteger)index;

@property (nonatomic, copy) NSArray<SCBlockRule *> *blockRules;
@property (nonatomic, readonly) NSDate* blockEndDate;
@property (nonatomic, readonly) BOOL blockIsRunning;

@end

NS_ASSUME_NONNULL_END
