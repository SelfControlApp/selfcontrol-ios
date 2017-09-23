//
//  SCAddAppViewController.m
//  SelfControlIOS
//
//  Created by Charles Stigler on 06/08/2017.
//  Copyright © 2017 SelfControl. All rights reserved.
//

#import "SCAddAppViewController.h"
#import "SCBlockRule.h"

@interface SCAddAppViewController ()

@end

static NSString * const SCBlockableAppCellIdentifier = @"BlockableApp";

static NSArray* SCBlockableApps = nil;

@implementation SCAddAppViewController

@synthesize blockListViewController;

- (instancetype)init {
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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return SCBlockableApps.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SCBlockableAppCellIdentifier];
    cell.textLabel.textColor = self.view.tintColor;
    
    NSDictionary* appSet = [SCBlockableApps objectAtIndex: indexPath.row];
    cell.textLabel.text = (NSString*)[appSet objectForKey: @"name"];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary* appDict = [SCBlockableApps objectAtIndex: indexPath.row];
    
    SCBlockRule* rule = [SCBlockRule ruleWithAppDict: appDict];

    [blockListViewController addRulesToList: @[rule] type: SCBlockTypeApp];

    [self.navigationController popViewControllerAnimated: YES];
}

@end
