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
    NSLog(@"INIT!!!");
    
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

- (void)startBlock {
    [self loadFromPreferences:^{
        if (![[NEFilterManager sharedManager] providerConfiguration]) {
            NEFilterProviderConfiguration *newConfiguration = [NEFilterProviderConfiguration new];
            newConfiguration.username = @"CharlieStigler";
            newConfiguration.organization = @"SelfControl, Inc.";
            newConfiguration.filterBrowsers = YES;
            newConfiguration.filterSockets = YES;
//            newConfiguration.serverAddress = @"my.great.filter.server";
            [[NEFilterManager sharedManager] setProviderConfiguration:newConfiguration];
        }
        
        [[NEFilterManager sharedManager] setEnabled:YES];
        
        [self reloadRules];
        
        // set ending date
        NSInteger blockLengthMinutes = [[NSUserDefaults standardUserDefaults] integerForKey: @"blockLengthMinutes"];
        self.blockEndDate = [NSDate dateWithTimeInterval: (blockLengthMinutes * 60) sinceDate: [NSDate date]];
        
        [self saveToPreferences:^(NSError* err){
            NSLog(@"DONE!!!");
        }];
    }];
}

- (void)setBlockEndDate:(NSDate * _Nonnull)blockEndDate {
    _blockEndDate = [blockEndDate copy];
    [[FilterUtilities defaults] setObject: blockEndDate forKey: @"blockEndDate"];
    NSLog(@"block end date: %@", blockEndDate);
}

- (void)setBlockRules:(NSArray<SCBlockRule *> *)blockRules {
    NSMutableDictionary<NSString *, NSDictionary *> *rulesDictionary = [NSMutableDictionary new];
    [blockRules enumerateObjectsUsingBlock:^(SCBlockRule *blockRule, NSUInteger index, BOOL *stop) {
        [rulesDictionary setObject:[blockRule filterRuleDictionary] forKey:blockRule.hostname];
    }];
    
    [[FilterUtilities defaults] setObject:rulesDictionary forKey:@"rules"];
    _blockRules = [blockRules copy];
}

- (void)reloadRules {
    NSDictionary *rulesDictionary = [[FilterUtilities defaults] objectForKey:@"rules"];
    if (!rulesDictionary) {
        // no dictionary, make sure we set a blank array to avoid a crash if blockRules is nil
        _blockRules = [NSArray array];
        return;
    }
    
    NSMutableArray<SCBlockRule *> *blockRules = [NSMutableArray new];
    [rulesDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *value, BOOL *stop) {
        [blockRules addObject:[[SCBlockRule alloc] initWithHostname:key]];
    }];
    _blockRules = [blockRules copy];
}

@end

NS_ASSUME_NONNULL_END
