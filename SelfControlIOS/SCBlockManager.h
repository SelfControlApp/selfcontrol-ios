//
//  SCBlockManager.h
//  SelfControlIOS
//
//  Created by Charles Stigler on 25/02/2017.
//  Copyright © 2017 SelfControl. All rights reserved.
//

#import "SCBlockRule.h"

typedef void(^completion)(NSError* _Nonnull);

NS_ASSUME_NONNULL_BEGIN

@interface SCBlockManager : NSObject

+ (SCBlockManager *)sharedManager;

- (void)startBlock:(completion)done;

- (void)addBlockRules:(NSArray<SCBlockRule*> *)blockRules type:(SCBlockType)type;
- (void)addBlockRule:(SCBlockRule*)blockRule type:(SCBlockType)type;
- (void)removeBlockRuleAtIndex:(NSUInteger)index type:(SCBlockType)type;
- (NSArray<SCBlockRule *>*)blockRulesOfType:(SCBlockType)type;
- (void)setBlockRules:(NSArray<SCBlockRule *>*)blockRules type:(SCBlockType)type;

@property (nonatomic, copy) NSArray<SCBlockRule *> *appBlockRules;
@property (nonatomic, copy) NSArray<SCBlockRule *> *hostBlockRules;
@property (nonatomic, readonly) NSDate* blockEndDate;
@property (nonatomic, readonly) BOOL blockIsRunning;

@end

NS_ASSUME_NONNULL_END
