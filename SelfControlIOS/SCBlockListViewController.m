//
//  SCBlockListViewController.m
//  SelfControlIOS
//
//  Created by Charles Stigler on 25/02/2017.
//  Copyright © 2017 SelfControl. All rights reserved.
//

#import "SCBlockListViewController.h"
#import "SCBlockManager.h"
#import "SCBlockRuleTableViewCell.h"
#import "SCImportSitesViewController.h"
#import "SCAddAppViewController.h"

typedef NS_ENUM(NSInteger, SCBlockListSection) {
    SCBlockListSectionButtons = 0,
    SCBlockListSectionSites = 1
};

@interface SCBlockListViewController () <SCBlockRuleTableViewCellDelegate>

@end

static NSString * const SCBlockListButtonCellIdentifier = @"ButtonCell";
static NSString * const SCBlockListSiteCellIdentifier = @"SiteCell";

@implementation SCBlockListViewController

- (instancetype)init {
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.allowsSelectionDuringEditing = YES;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.tableView.estimatedRowHeight = 0;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:SCBlockListButtonCellIdentifier];
    [self.tableView registerClass:[SCBlockRuleTableViewCell class] forCellReuseIdentifier:SCBlockListSiteCellIdentifier];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == SCBlockListSectionButtons) {
        return 3;
    } else if (section == SCBlockListSectionSites) {
        return [[SCBlockManager sharedManager] blockRules].count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SCBlockListSection section = indexPath.section;
    if (section == SCBlockListSectionButtons) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SCBlockListButtonCellIdentifier];
        cell.textLabel.textColor = self.view.tintColor;

        if (indexPath.row == 0) {
            cell.textLabel.text = @"Add New Website";
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Add New App";
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"Import Common Sites";
        }
        return cell;
        
    } else if (section == SCBlockListSectionSites) {
        SCBlockRuleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SCBlockListSiteCellIdentifier];
        SCBlockRule *rule = [[[SCBlockManager sharedManager] blockRules] objectAtIndex:indexPath.row];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSLog(@"creating cell for rule %@ with appDict %@", rule, rule.appDict);
        if ([rule.type isEqualToString: @"hostname"]) {
            cell.textField.text = rule.hostname;
            cell.textField.textColor = UIColor.blackColor;
            cell.textField.userInteractionEnabled = YES;
        } else if ([rule.type isEqualToString: @"app"]) {
            cell.textField.text = rule.appDict[@"name"];
            NSLog(@"setting text to %@", rule.appDict[@"name"]);
            cell.textField.textColor = self.view.tintColor;
            cell.textField.userInteractionEnabled = NO;
        }

        return cell;
    }
    
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section == SCBlockListSectionSites);
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SCBlockListSectionButtons)
        return UITableViewCellEditingStyleNone;

    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SCBlockListSectionButtons)
        return;
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[SCBlockManager sharedManager] removeBlockRuleAtIndex: indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Did select row at index path %@", indexPath);
    if (indexPath.section != SCBlockListSectionButtons)
        return;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        // "Add New Website" button
        [[SCBlockManager sharedManager] addBlockRule: [SCBlockRule ruleWithHostname: @""]];
        
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:([SCBlockManager sharedManager].blockRules.count - 1) inSection:SCBlockListSectionSites];
        [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            SCBlockRuleTableViewCell *cell = [tableView cellForRowAtIndexPath:newIndexPath];
            [cell.textField becomeFirstResponder];
        });
        
    } else if (indexPath.row == 1) {
        // add app
        SCAddAppViewController* addAppVC = [SCAddAppViewController new];
        addAppVC.blockListViewController = self;
        [self.navigationController pushViewController: addAppVC animated: YES];
    } else if (indexPath.row == 2) {
        // import common sites
        SCImportSitesViewController* importSitesVC = [SCImportSitesViewController new];
        importSitesVC.blockListViewController = self;
        [self.navigationController pushViewController: importSitesVC animated: YES];
    }
}

#pragma mark - SCBlockRuleTableViewCellDelegate

- (void)blockRuleCellDidChange:(SCBlockRuleTableViewCell *)cell {
    // delete empty cells when editing completes
    NSString* trimmedText = [cell.textField.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimmedText length] < 1) {
        NSIndexPath* indexPath = [self.tableView indexPathForCell: cell];
        [[SCBlockManager sharedManager] removeBlockRuleAtIndex: indexPath.row];

        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    }
    
    SCBlockRule *newRule = [SCBlockRule ruleWithHostname:cell.textField.text];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSMutableArray<SCBlockRule *> *blockRules = [[[SCBlockManager sharedManager] blockRules] mutableCopy];
    [blockRules replaceObjectAtIndex:indexPath.row withObject:newRule];
    [SCBlockManager sharedManager].blockRules = blockRules;
}

# pragma mark - Other methods

- (void)addRulesToList:(NSArray<SCBlockRule*>*)newBlockRules {
    [[SCBlockManager sharedManager] addBlockRules: newBlockRules];
    NSArray<SCBlockRule *> *blockRules = [SCBlockManager sharedManager].blockRules;

    NSMutableArray* indexPaths = [NSMutableArray array];
    for (unsigned long i = blockRules.count - newBlockRules.count; i < blockRules.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow: i inSection: SCBlockListSectionSites];
        [indexPaths addObject: indexPath];
    }
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
