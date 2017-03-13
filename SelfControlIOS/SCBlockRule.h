//
//  SCBlockRule.h
//  SelfControlIOS
//
//  Created by Charles Stigler on 25/02/2017.
//  Copyright © 2017 SelfControl. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SCBlockRuleFilterAction) {
    SCBlockRuleFilterActionBlock,
    SCBlockRuleFilterActionAllow,
    SCBlockRuleFilterActionNeedMoreRulesAndBlock,
    SCBlockRuleFilterActionNeedMoreRulesAndAllow,
    SCBlockRuleFilterActionNeedMoreRulesFromDataAndBlock,
    SCBlockRuleFilterActionNeedMoreRulesFromDataAndAllow,
    SCBlockRuleFilterActionExamineData,
    SCBlockRuleFilterActionRedirectToSafeURL,
    SCBlockRuleFilterActionRemediate
};

extern NSString *SCBlockRuleFilterActionGetDescription(SCBlockRuleFilterAction action);

@interface SCBlockRule : NSObject

- (instancetype)initWithHostname:(NSString *)hostname;

@property (nonatomic, readonly) NSString *hostname;

- (NSDictionary *)filterRuleDictionary;

@end

NS_ASSUME_NONNULL_END
