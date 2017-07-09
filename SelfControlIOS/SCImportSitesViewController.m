//
//  SCImportSitesViewController.m
//  SelfControlIOS
//
//  Created by Charles Stigler on 04/07/2017.
//  Copyright © 2017 SelfControl. All rights reserved.
//

#import "SCImportSitesViewController.h"
#import "SCBlockRule.h"

@interface SCImportSitesViewController ()

@end

static NSString * const SCImportSetCellIdentifier = @"ImportSet";

static NSArray* SCSiteImportSets = nil;

@implementation SCImportSitesViewController

@synthesize blockListViewController;

- (instancetype)init {
    SCSiteImportSets = @[
                         @{
                             @"name": @"Common Distracting Sites",
                             @"items": @[
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
                                     ]
                             },
                         @{
                             @"name": @"News & Publications",
                             @"items": @[
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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return SCSiteImportSets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SCImportSetCellIdentifier];
    cell.textLabel.textColor = self.view.tintColor;

    NSDictionary* siteSet = [SCSiteImportSets objectAtIndex: indexPath.row];
    cell.textLabel.text = (NSString*)[siteSet objectForKey: @"name"];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Did select row at index path %@", indexPath);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray* sites = [[SCSiteImportSets objectAtIndex: indexPath.row] objectForKey: @"items"];
    
    NSLog(@"should add sites: %@", sites);
    
    NSMutableArray* rules = [NSMutableArray array];
    for (unsigned long i = 0; i < sites.count; i++) {
        [rules addObject: [SCBlockRule ruleWithHostname: sites[i]]];
    }
    
    [blockListViewController addSitesToList: rules];
    
    [self.navigationController popViewControllerAnimated: YES];
}

@end
