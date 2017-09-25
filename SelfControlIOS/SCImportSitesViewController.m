//
//  SCImportSitesViewController.m
//  SelfControlIOS
//
//  Created by Charles Stigler on 04/07/2017.
//  Copyright © 2017 SelfControl. All rights reserved.
//

#import "SCImportSitesViewController.h"
#import "SCBlockRule.h"
#import "SCUtils.h"

@interface SCImportSitesViewController ()

@end

static NSString * const SCImportSetCellIdentifier = @"ImportSet";

static NSArray* SCBlockImportSets = nil;

@implementation SCImportSitesViewController

@synthesize blockListViewController;

- (instancetype)init {
    SCBlockImportSets = @[
                         @{
                             @"name": NSLocalizedString(@"Common Distractions", nil),
                             @"hosts": @[
                                     @"facebook.com",
                                     @"twitter.com",
                                     @"reddit.com",
                                     @"tumblr.com",
                                     @"youtube.com",
                                     @"9gag.com",
                                     @"netflix.com",
                                     @"hulu.com",
                                     @"buzzfeed.com",
                                     @"dailymotion.com",
                                     @"collegehumor.com",
                                     @"funnyordie.com",
                                     @"vine.co",
                                     @"pinterest.com",
                                     @"stumbleupon.com"
                                     ],
                             @"apps": @[
                                     [SCUtils appDictForBundleId: @"com.facebook.Facebook"],
                                     [SCUtils appDictForBundleId: @"com.atebits.Tweetie2"],
                                     [SCUtils appDictForBundleId: @"com.burbn.instagram"],
                                     [SCUtils appDictForBundleId: @"com.youtube.ios.youtube"],
                                     [SCUtils appDictForBundleId: @"com.9gag.ios.mobile"],
                                     [SCUtils appDictForBundleId: @"com.tyanya.reddit"]
                                     ]
                             },
                         @{
                             @"name": NSLocalizedString(@"News & Publications", nil),
                             @"hosts": @[
                                     @"cnn.com",
                                     @"huffingtonpost.com",
                                     @"foxnews.com",
                                     @"nytimes.com",
                                     @"bbc.com",
                                     @"bbc.co.uk",
                                     @"telegraph.co.uk",
                                     @"news.google.com",
                                     @"buzzfeed.com",
                                     @"vice.com",
                                     @"gawker.com",
                                     @"tumblr.com",
                                     @"forbes.com",
                                     @"gothamist.com",
                                     @"jezebel.com",
                                     @"usatoday.com",
                                     @"theonion.com",
                                     @"news.yahoo.com",
                                     @"washingtonpost.com",
                                     @"wsj.com",
                                     @"theguardian.com",
                                     @"latimes.com",
                                     @"nydailynews.com",
                                     @"salon.com",
                                     @"msnbc.com",
                                     @"rt.com",
                                     @"bloomberg.com",
                                     @"aol.com",
                                     @"drudgereport.com",
                                     @"nationalgeographic.com",
                                     @"vice.com",
                                     @"nypost.com",
                                     @"chicagotribune.com",
                                     @"msn.com",
                                     @"usnews.com"
                                     ]
                             }
                         ];

    return [super initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier: SCImportSetCellIdentifier];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    self.title = NSLocalizedString(@"Import Common Sites", nil);
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return SCBlockImportSets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SCImportSetCellIdentifier];
    cell.textLabel.textColor = self.view.tintColor;

    NSDictionary* siteSet = [SCBlockImportSets objectAtIndex: indexPath.row];
    cell.textLabel.text = (NSString*)[siteSet objectForKey: @"name"];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray* sites = [[SCBlockImportSets objectAtIndex: indexPath.row] objectForKey: @"hosts"];
    NSMutableArray* siteRules = [NSMutableArray array];
    for (unsigned long i = 0; i < sites.count; i++) {
        [siteRules addObject: [SCBlockRule ruleWithHostname: sites[i]]];
    }
    [blockListViewController addRulesToList: siteRules type: SCBlockTypeHost];
    
    NSArray* apps = [[SCBlockImportSets objectAtIndex: indexPath.row] objectForKey: @"apps"];
    NSMutableArray* appRules = [NSMutableArray array];
    for (unsigned long i = 0; i < apps.count; i++) {
        [appRules addObject: [SCBlockRule ruleWithAppDict: apps[i]]];
    }
    [blockListViewController addRulesToList: appRules type: SCBlockTypeApp];
    
    [self.navigationController popViewControllerAnimated: YES];
}

@end
