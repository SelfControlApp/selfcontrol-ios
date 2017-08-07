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
                             @"name": @"Facebook",
                             @"bundleId": @"com.facebook.Facebook"
                             },
                         @{
                             @"name": @"Facebook Messenger",
                             @"bundleId": @"Messenger"
                             },
                         @{
                             @"name": @"Safari",
                             @"bundleId": @"com.apple.mobilesafari"
                             },
                         @{
                             @"name": @"Chrome",
                             @"bundleId": @"com.google.chrome.ios"
                             },
                         @{
                             @"name": @"Twitter",
                             @"bundleId": @"com.atebits.Tweetie2"
                             },
                         @{
                             @"name": @"Instagram",
                             @"bundleId": @"com.burbn.instagram"
                             },
                         @{
                             @"name": @"Snapchat",
                             @"bundleId": @"com.toyopagroup.picaboo"
                             },
                         @{
                             @"name": @"YouTube",
                             @"bundleId": @"com.youtube.ios.youtube"
                             },
                         @{
                             @"name": @"Netflix",
                             @"bundleId": @"com.netflix.Netflix"
                             },
                         @{
                             @"name": @"Spotify",
                             @"bundleId": @"com.spotify.client"
                             },
                         @{
                             @"name": @"Flappy Bird",
                             @"bundleId": @"com.dotgears.flap"
                             },
                         @{
                             @"name": @"9GAG",
                             @"bundleId": @"com.9gag.ios.mobile"
                             },
                         @{
                             @"name": @"Gmail",
                             @"bundleId": @"com.google.Gmail"
                             },
                         @{
                             @"name": @"Google Inbox",
                             @"bundleId": @"com.google.inbox"
                             },
                         @{
                             @"name": @"Medium",
                             @"bundleId": @"com.medium.reader"
                             },
                         @{
                             @"name": @"Reddit",
                             @"bundleId": @"com.tyanya.reddit"
                             },
                         @{
                             @"name": @"Tinder",
                             @"bundleId": @"com.cardify.tinder"
                             },
                         @{
                             @"name": @"Tumblr",
                             @"bundleId": @"com.tumblr.tumblr"
                             },
                         @{
                             @"name": @"Pokemon Go",
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
    NSLog(@"Did select row at index path %@", indexPath);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary* appDict = [SCBlockableApps objectAtIndex: indexPath.row];
    
    NSLog(@"should add app: %@", appDict);
    
    SCBlockRule* rule = [SCBlockRule ruleWithAppDict: appDict];

    [blockListViewController addRulesToList: @[rule]];

    [self.navigationController popViewControllerAnimated: YES];
}

@end
