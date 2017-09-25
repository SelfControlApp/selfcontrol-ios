//
//  SCBlockManager.m
//  SelfControlIOS
//
//  Created by Charles Stigler on 25/02/2017.
//  Copyright © 2017 SelfControl. All rights reserved.
//

#import "SCBlockManager.h"
#import <NetworkExtension/NetworkExtension.h>
#import "SelfControlIOS-Swift.h"

NS_ASSUME_NONNULL_BEGIN

@interface SCBlockManager ()

@property (nonatomic, readwrite) NSDate* blockEndDate; // readwrite for us only

@end

@implementation SCBlockManager

+ (SCBlockManager *)sharedManager {
    static SCBlockManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [self new];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (!self)
        return nil;

    // initialize blockEndDate from defaults
    _blockEndDate = [[FilterUtilities defaults] objectForKey:@"blockEndDate"];

    // reloadRules will make sure self.blockRules is initialized
    [self reloadRules];
    
    return self;
}

- (void)loadFromPreferences:(void (^)())completionHandler {
    [[NEFilterManager sharedManager] loadFromPreferencesWithCompletionHandler:^(NSError * __nullable error) {
        if (error) {
            NSLog(@"Failed to load the filter configuration: %@", error);
            return;
        }
        
        [self reloadRules];
        completionHandler();
    }];
}

- (void)saveToPreferences:(void (^)(NSError* _Nullable err))completionHandler {
    [[NEFilterManager sharedManager] saveToPreferencesWithCompletionHandler:^(NSError * __nullable error) {
        if (error) {
            if ([error.domain isEqualToString: @"NEConfigurationErrorDomain"] && error.code == 9) {
                // configuration unchanged, not an issue (filter is already set)
                NSLog(@"Filter configuration unchanged, continuing...");
                completionHandler(nil);
                return;
            }
            NSLog(@"Failed to save the filter configuration: %@", error);
            completionHandler(error);
            return;
        }
        
        [[FilterUtilities defaults] setValue:[[[NEFilterManager sharedManager] providerConfiguration] serverAddress] forKey:@"serverAddress"];
        
        completionHandler(nil);
    }];
}

- (void)startBlock:(completion)done {
    [self loadFromPreferences:^{
        if (![[NEFilterManager sharedManager] providerConfiguration]) {
            NEFilterProviderConfiguration *newConfiguration = [NEFilterProviderConfiguration new];
            newConfiguration.username = @"CharlieStigler";
            newConfiguration.organization = @"SelfControl";
            newConfiguration.filterBrowsers = YES;
            newConfiguration.filterSockets = YES;
//            newConfiguration.serverAddress = @"my.great.filter.server";
            [[NEFilterManager sharedManager] setProviderConfiguration:newConfiguration];
        }
        
        [[NEFilterManager sharedManager] setEnabled:YES];
        
        [self reloadRules];
        
        // set ending date
        NSInteger blockLengthSeconds = [[NSUserDefaults standardUserDefaults] integerForKey: @"blockLengthSeconds"];
        self.blockEndDate = [NSDate dateWithTimeInterval: blockLengthSeconds sinceDate: [NSDate date]];
        
        [self saveToPreferences:^(NSError* err){
            if (err) {
                // reset block end date to current time so that we don't think the block is running
                self.blockEndDate = [NSDate date];
            }

            done(err);
        }];
    }];
}

- (void)setBlockEndDate:(NSDate * _Nonnull)blockEndDate {
    _blockEndDate = [blockEndDate copy];
    [[FilterUtilities defaults] setObject: blockEndDate forKey: @"blockEndDate"];
}

- (void)updateFilterRules {
    NSMutableDictionary<NSString *, NSDictionary *> *rulesDictionary = [NSMutableDictionary new];
    [self.appBlockRules enumerateObjectsUsingBlock:^(SCBlockRule *blockRule, NSUInteger index, BOOL *stop) {
        NSString* ruleKey = blockRule.appDict[@"bundleId"];
        if (ruleKey != nil) {
            [rulesDictionary setObject:[blockRule filterRuleDictionary] forKey: ruleKey];
        }
    }];
    [self.hostBlockRules enumerateObjectsUsingBlock:^(SCBlockRule *blockRule, NSUInteger index, BOOL *stop) {
        NSString* ruleKey = blockRule.hostname;
        if (ruleKey != nil) {
            [rulesDictionary setObject:[blockRule filterRuleDictionary] forKey: ruleKey];
        }
    }];
    [[FilterUtilities defaults] setObject:rulesDictionary forKey:@"rules"];
}

- (NSInteger)addBlockRules:(NSArray<SCBlockRule*> *)blockRules type:(SCBlockType)type {
    NSArray<SCBlockRule*>* blockRulesOriginal = [self blockRulesOfType: type];
    NSMutableArray<SCBlockRule *> *blockRulesCopy = [blockRulesOriginal mutableCopy];

    // filter out duplicates in the list
    blockRules = [blockRules filteredArrayUsingPredicate: [NSPredicate predicateWithBlock:^BOOL(SCBlockRule* rule, NSDictionary<NSString *,id> * _Nullable bindings) {
        return ![self ruleIsAlreadyOnBlockList: rule];
    }]];
    
    NSArray* newRules = [blockRules arrayByAddingObjectsFromArray: blockRulesCopy];
    
    [self setBlockRules: newRules type: type];
    
    // return the number of block rules added, since it may have changed when we filtered out duplicates
    return blockRules.count;
}

// returns true if the rule was added, false if it wasn't (generally because it was a duplicate)
- (BOOL)addBlockRule:(SCBlockRule*)blockRule type:(SCBlockType)type {
    NSInteger numRulesAdded = [self addBlockRules: @[blockRule] type: type];
    
    if (numRulesAdded == 0) return NO;
    else return YES;
}

- (void)removeBlockRuleAtIndex:(NSUInteger)index type:(SCBlockType)type {
    NSArray<SCBlockRule*>* rulesOriginal = [self blockRulesOfType: type];
    NSMutableArray<SCBlockRule *> *rulesCopy = [rulesOriginal mutableCopy];

    [rulesCopy removeObjectAtIndex: index];

    [self setBlockRules: rulesCopy type: type];
}

- (NSArray<SCBlockRule *>*)blockRulesOfType:(SCBlockType)type {
    if (type == SCBlockTypeApp) {
        return self.appBlockRules;
    } else {
        return self.hostBlockRules;
    }
}

- (void)setBlockRules:(NSArray<SCBlockRule *>*)blockRules type:(SCBlockType)type {
    if (type == SCBlockTypeApp) {
        self.appBlockRules = blockRules;
    } else {
        self.hostBlockRules = blockRules;
    }
}

- (void)setAppBlockRules:(NSArray<SCBlockRule *> *)appBlockRules {
    _appBlockRules = appBlockRules;
    [self updateFilterRules];
}
- (void)setHostBlockRules:(NSArray<SCBlockRule *> *)hostBlockRules {
    _hostBlockRules = hostBlockRules;
    [self updateFilterRules];
}

- (BOOL)appIsOnBlockList:(NSString*)bundleId {
    NSArray<SCBlockRule*>* existingAppRules = [self appBlockRules];
    
    for (int i = 0; i < existingAppRules.count; i++) {
        if ([existingAppRules[i].appDict[@"bundleId"] isEqualToString: bundleId]) {
            return YES;
        }
    }
 
    return NO;
}
- (BOOL)hostIsOnBlockList:(NSString*)hostname {
    NSArray<SCBlockRule*>* existingHostRules = [self hostBlockRules];
    
    for (int i = 0; i < existingHostRules.count; i++) {
        if ([existingHostRules[i].hostname isEqualToString: hostname]) {
            return YES;
        }
    }
    
    return NO;
}
- (BOOL)ruleIsAlreadyOnBlockList:(SCBlockRule*)rule {
   if ([rule.type isEqualToString: @"app"]) {
       return [self appIsOnBlockList: rule.appDict[@"bundleId"]];
   } else {
       return [self hostIsOnBlockList: rule.hostname];
   }
}

- (void)extendBlockDuration:(NSInteger)seconds {
    self.blockEndDate = [_blockEndDate dateByAddingTimeInterval: seconds];
}

- (BOOL)blockIsRunning {
    return (_blockEndDate.timeIntervalSinceNow > 0);
}

- (void)reloadRules {
    NSDictionary *rulesDictionary = [[FilterUtilities defaults] objectForKey:@"rules"];
    if (!rulesDictionary) {
        // no dictionary, make sure we set a blank array to avoid a crash if blockRules is nil
        self.appBlockRules = [NSArray array];
        self.hostBlockRules = [NSArray array];
        return;
    }
    
    NSMutableArray<SCBlockRule *> *newAppBlockRules = [NSMutableArray new];
    NSMutableArray<SCBlockRule *> *newHostBlockRules = [NSMutableArray new];
    [rulesDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *value, BOOL *stop) {
        if ([value[@"type"] isEqualToString: @"app"]) {
            [newAppBlockRules addObject:[SCBlockRule ruleWithAppDict: value[@"appDict"]]];
        } else if ([value[@"type"] isEqualToString: @"hostname"]) {
            [newHostBlockRules addObject:[SCBlockRule ruleWithHostname:key]];
        }
    }];

    _appBlockRules = [newAppBlockRules copy];
    _hostBlockRules = [newHostBlockRules copy];
}

@end

NS_ASSUME_NONNULL_END
