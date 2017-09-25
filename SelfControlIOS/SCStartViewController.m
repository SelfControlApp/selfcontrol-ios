//
//  SCStartViewController.m
//  SelfControlIOS
//
//  Created by Charles Stigler on 25/02/2017.
//  Copyright © 2017 SelfControl. All rights reserved.
//

#import "SCBlockManager.h"
#import "SCMainViewController.h"
#import "SCStartViewController.h"
#import "SCBlockListViewController.h"
#import "SCTimeIntervalFormatter.h"
#import "SCAlertFactory.h"
#import "UIButton+SCButtons.h"
#import "SCUtils.h"
#import "SCUtils+SCViewUtils.h"
#import <Masonry/Masonry.h>

@interface SCStartViewController ()

@property (nonatomic, weak) UIDatePicker* blockTimePicker;
@property (nonatomic, weak) UILabel* sitesBlockedLabel;
@property (nonatomic, weak) UIButton* startBlockButton;

@end

@implementation SCStartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // SC logo
    UIImageView* logoView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"logo"]];
    [self.view addSubview: logoView];
    [logoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@90);
        make.width.equalTo(@90);
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view.mas_top).with.offset(30);
    }];

    UILabel* focusForLabel = [UILabel new];
    focusForLabel.text = NSLocalizedString(@"I want to focus for...", nil);
    [self.view addSubview: focusForLabel];
    [focusForLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(logoView.mas_bottom).with.offset(15);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    UIDatePicker* blockTimePicker = [UIDatePicker new];
    blockTimePicker.datePickerMode = UIDatePickerModeCountDownTimer;
    blockTimePicker.minuteInterval = 1;
    [self.view addSubview: blockTimePicker];
    [blockTimePicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(focusForLabel.mas_bottom).with.offset(15);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
    }];
    self.blockTimePicker = blockTimePicker;
    // pull initial value from defaults
    self.blockTimePicker.countDownDuration = [[NSUserDefaults standardUserDefaults] integerForKey:@"blockLengthSeconds"];
    [blockTimePicker addTarget: self action: @selector(blockTimePickerChanged:) forControlEvents: UIControlEventValueChanged];
    
    UILabel* sitesBlockedLabel = [UILabel new];
    [self.view addSubview: sitesBlockedLabel];
    [sitesBlockedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(blockTimePicker.mas_bottom).with.offset(30);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    self.sitesBlockedLabel = sitesBlockedLabel;
    // initialize sites blocked label
    [self updateSitesBlockedLabel];
    
    UIButton *editBlockListButton = [UIButton buttonWithType: UIButtonTypeSystem];
    [editBlockListButton setTitle: NSLocalizedString(@"Edit Block List", nil) forState: UIControlStateNormal];
    [editBlockListButton addTarget: self action: @selector(editBlockList) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview: editBlockListButton];
    [editBlockListButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(sitesBlockedLabel.mas_bottom).with.offset(20);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    UIButton* startBlockButton = [UIButton scActionButton];
    [startBlockButton setTitle: NSLocalizedString(@"Start Block", nil) forState: UIControlStateNormal];
    [startBlockButton addTarget: self action: @selector(startBlockButtonPressed) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview: startBlockButton];
    [startBlockButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
    }];
    self.startBlockButton = startBlockButton;
}

- (NSString*)humanReadableBlockTime {
    // make a formatter if we don't have one
    static SCTimeIntervalFormatter* formatter = nil;
    if (formatter == nil) {
        formatter = [[SCTimeIntervalFormatter alloc] init];
    }

    return [formatter stringForObjectValue:@(self.blockTimePicker.countDownDuration)];
}

- (void)blockTimePickerChanged:(id)sender {
    // save to defaults
    [[NSUserDefaults standardUserDefaults] setInteger: self.blockTimePicker.countDownDuration forKey: @"blockLengthSeconds"];
}

- (void)updateSitesBlockedLabel {
    NSInteger appsBlocked = [SCBlockManager sharedManager].appBlockRules.count;
    NSInteger sitesBlocked = [SCBlockManager sharedManager].hostBlockRules.count;
    
    if (!appsBlocked && !sitesBlocked) {
        self.sitesBlockedLabel.text = NSLocalizedString(@"Your block list is empty.", nil);
        self.startBlockButton.enabled = NO;
    } else {
        self.sitesBlockedLabel.text = [NSString stringWithFormat: NSLocalizedString(@"%@ will be blocked.", @"{blocked items} will be blocked."), [SCUtils blockListSummaryString]];
        self.startBlockButton.enabled = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [self.navigationController setNavigationBarHidden: YES animated: YES];
    [self updateSitesBlockedLabel];
    
    // make sure that we're supposed to be showing this screen and not the timer view controller
    [(SCMainViewController*)self.navigationController reloadViewControllers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)editBlockList {
    [self.navigationController pushViewController: [SCBlockListViewController new] animated: YES];
    [self.navigationController setNavigationBarHidden: NO animated: YES];
}

- (void)startBlockButtonPressed {
    if ([SCBlockManager sharedManager].appBlockRules.count == 0 && [SCBlockManager sharedManager].hostBlockRules.count == 0) {
        // we aren't going to run a block with nothing in the blocklist! that's just silly
        [SCAlertFactory showAlertWithTitle: NSLocalizedString(@"No rules in block list", nil)
                               description: NSLocalizedString(@"Your block list is currently empty. To start a block, first add some apps or sites into your block list.", nil)
                            viewController: self];
        return;
    }

    NSString* confirmText = [NSString localizedStringWithFormat: NSLocalizedString(@"Are you sure you want to start the block? %@ will be blocked for %@.", @"Are you sure you want to start the block? {blocked things} will be blocked for {block duration}"), [SCUtils blockListSummaryString], self.humanReadableBlockTime];
    
    [SCAlertFactory showConfirmationDialogWithTitle: NSLocalizedString(@"Confirm Block", nil)
                                        description: confirmText
                                      confirmAction:^{
                                          [self startBlock];
                                      }
                                     viewController: self];
}

- (void)startBlock {
    [[SCBlockManager sharedManager] startBlock:^(NSError * err) {
        if (err != nil) {
            // show error message
            [SCAlertFactory showAlertWithError: err
                                         title: NSLocalizedString(@"Couldn't Start Block", nil)
                                viewController: self];
        }
        
        // reload the root view controller to show the timer
        [(SCMainViewController*)self.navigationController reloadViewControllers];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
