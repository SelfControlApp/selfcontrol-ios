//
//  SCAppSelectorViewController.m
//  SelfControlIOS
//
//  Created by Charles Stigler on 06/08/2017.
//  Copyright © 2017 SelfControl. All rights reserved.
//

#import "SCAppSelectorViewController.h"
#import "SCBlockRule.h"
#import "SCBlockManager.h"
#import "SCUtils.h"

@interface SCAppSelectorViewController ()

@property (nonatomic, readonly) NSArray<NSDictionary*>* availableApps;

@end

static NSString * const SCBlockableAppCellIdentifier = @"BlockableApp";

static NSArray<NSDictionary*>* SCBlockableApps = nil;

@implementation SCAppSelectorViewController

@synthesize delegate;

- (instancetype)init {
    SCBlockableApps = @[
                        [SCUtils appDictForBundleId: @"com.facebook.Facebook"],
                        [SCUtils appDictForBundleId: @"com.facebook.Messenger"],
                        [SCUtils appDictForBundleId: @"com.apple.mobilesafari"],
                        [SCUtils appDictForBundleId: @"com.google.chrome.ios"],
                        [SCUtils appDictForBundleId: @"com.atebits.Tweetie2"],
                        [SCUtils appDictForBundleId: @"com.burbn.instagram"],
                        [SCUtils appDictForBundleId: @"com.toyopagroup.picaboo"],
                        [SCUtils appDictForBundleId: @"com.youtube.ios.youtube"],
                        [SCUtils appDictForBundleId: @"com.netflix.Netflix"],
                        [SCUtils appDictForBundleId: @"com.spotify.client"],
                        [SCUtils appDictForBundleId: @"com.dotgears.flap"],
                        [SCUtils appDictForBundleId: @"com.9gag.ios.mobile"],
                        [SCUtils appDictForBundleId: @"com.google.Gmail"],
                        [SCUtils appDictForBundleId: @"com.google.inbox"],
                        [SCUtils appDictForBundleId: @"com.medium.reader"],
                        [SCUtils appDictForBundleId: @"com.tyanya.reddit"],
                        [SCUtils appDictForBundleId: @"com.cardify.tinder"],
                        [SCUtils appDictForBundleId: @"com.tumblr.tumblr"],
                        [SCUtils appDictForBundleId: @"com.nianticlabs.pokemongo"]
                        ];
    SCBlockableApps = @[
                         @{
                             @"name": NSLocalizedString(@"Facebook", nil),
                             @"bundleId": @"com.facebook.Facebook"
                             },
                         @{
                             @"name": NSLocalizedString(@"Facebook Messenger", nil),
                             @"bundleId": @"Messenger"
                             },
                         @{
                             @"name": NSLocalizedString(@"Safari", nil),
                             @"bundleId": @"com.apple.mobilesafari"
                             },
                         @{
                             @"name": NSLocalizedString(@"Chrome", nil),
                             @"bundleId": @"com.google.chrome.ios"
                             },
                         @{
                             @"name": NSLocalizedString(@"Twitter", nil),
                             @"bundleId": @"com.atebits.Tweetie2"
                             },
                         @{
                             @"name": NSLocalizedString(@"Instagram", nil),
                             @"bundleId": @"com.burbn.instagram"
                             },
                         @{
                             @"name": NSLocalizedString(@"Snapchat", nil),
                             @"bundleId": @"com.toyopagroup.picaboo"
                             },
                         @{
                             @"name": NSLocalizedString(@"YouTube", nil),
                             @"bundleId": @"com.youtube.ios.youtube"
                             },
                         @{
                             @"name": NSLocalizedString(@"Netflix", nil),
                             @"bundleId": @"com.netflix.Netflix"
                             },
                         @{
                             @"name": NSLocalizedString(@"Spotify", nil),
                             @"bundleId": @"com.spotify.client"
                             },
                         @{
                             @"name": NSLocalizedString(@"Flappy Bird", nil),
                             @"bundleId": @"com.dotgears.flap"
                             },
                         @{
                             @"name": NSLocalizedString(@"9GAG", nil),
                             @"bundleId": @"com.9gag.ios.mobile"
                             },
                         @{
                             @"name": NSLocalizedString(@"Gmail", nil),
                             @"bundleId": @"com.google.Gmail"
                             },
                         @{
                             @"name": NSLocalizedString(@"Google Inbox", nil),
                             @"bundleId": @"com.google.inbox"
                             },
                         @{
                             @"name": NSLocalizedString(@"Medium", nil),
                             @"bundleId": @"com.medium.reader"
                             },
                         @{
                             @"name": NSLocalizedString(@"Reddit", nil),
                             @"bundleId": @"com.tyanya.reddit"
                             },
                         @{
                             @"name": NSLocalizedString(@"Tinder", nil),
                             @"bundleId": @"com.cardify.tinder"
                             },
                         @{
                             @"name": NSLocalizedString(@"Tumblr", nil),
                             @"bundleId": @"com.tumblr.tumblr"
                             },
                         @{
                             @"name": NSLocalizedString(@"Pokemon Go", nil),
                             @"bundleId": @"com.nianticlabs.pokemongo"
                             },
                         ];
    
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier: SCBlockableAppCellIdentifier];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];

    self.title = NSLocalizedString(@"Add App to Block List", nil);
}

// returns just the apps that are available to add to the block, *not* including the ones that are already being blocked
- (NSArray*)availableApps {
    NSArray<SCBlockRule*>* existingAppRules = [[SCBlockManager sharedManager] appBlockRules];
    NSMutableArray<NSString*>* blockedBundleIds = [NSMutableArray arrayWithCapacity: existingAppRules.count];
    [existingAppRules enumerateObjectsUsingBlock:^(SCBlockRule* rule, NSUInteger idx, BOOL * _Nonnull stop) {
        [blockedBundleIds addObject: rule.appDict[@"bundleId"]];
    }];

    return [SCBlockableApps filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSDictionary* appDict, NSDictionary<NSString *,id> * _Nullable bindings) {
        return ![blockedBundleIds containsObject: appDict[@"bundleId"]];
    }]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.availableApps.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SCBlockableAppCellIdentifier];
    cell.textLabel.textColor = self.view.tintColor;
    
    NSDictionary* appSet = [self.availableApps objectAtIndex: indexPath.row];
    cell.textLabel.text = (NSString*)[appSet objectForKey: @"name"];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary* appDict = [self.availableApps objectAtIndex: indexPath.row];
    [delegate appRuleSelected: [SCBlockRule ruleWithAppDict: appDict]];

    [self.navigationController popViewControllerAnimated: YES];
}

@end
