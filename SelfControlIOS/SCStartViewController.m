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
#import <Masonry/Masonry.h>

@interface SCStartViewController ()

@property (nonatomic, weak) UISlider* blockTimeSlider;
@property (nonatomic, weak) UILabel* humanReadableBlockTimeLabel;
@property (nonatomic, weak) UILabel* sitesBlockedLabel;

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
    focusForLabel.text = @"I want to focus for...";
    [self.view addSubview: focusForLabel];
    [focusForLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(logoView.mas_bottom).with.offset(15);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    UISlider* blockTimeSlider = [UISlider new];
    blockTimeSlider.minimumValue = 60; // 1 minute
    blockTimeSlider.maximumValue = 86400; // 1 day
    blockTimeSlider.continuous = YES;
    [self.view addSubview: blockTimeSlider];
    [blockTimeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(focusForLabel.mas_bottom).with.offset(15);
        make.left.equalTo(self.view.mas_left).with.offset(40);
        make.right.equalTo(self.view.mas_right).with.offset(-40);
    }];
    self.blockTimeSlider = blockTimeSlider;
    // pull initial value from defaults
    self.blockTimeSlider.value = [[NSUserDefaults standardUserDefaults] integerForKey:@"blockLengthSeconds"];

    // Todo: actually convert this label into proper units
    UILabel* humanReadableBlockTimeLabel = [UILabel new];
    [self.view addSubview: humanReadableBlockTimeLabel];
    [humanReadableBlockTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(blockTimeSlider).with.offset(35);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [blockTimeSlider addTarget: self action: @selector(blockTimeSliderChanged:) forControlEvents: UIControlEventValueChanged];
    self.humanReadableBlockTimeLabel = humanReadableBlockTimeLabel;
    // initialize time label
    [self blockTimeSliderChanged: blockTimeSlider];
    
    UILabel* sitesBlockedLabel = [UILabel new];
    [self.view addSubview: sitesBlockedLabel];
    [sitesBlockedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(humanReadableBlockTimeLabel).with.offset(60);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    self.sitesBlockedLabel = sitesBlockedLabel;
    // initialize sites blocked label
    [self updateSitesBlockedLabel];
    
    UIButton *editBlockListButton = [UIButton buttonWithType: UIButtonTypeSystem];
    [editBlockListButton setTitle: @"Edit Block List" forState: UIControlStateNormal];
    [editBlockListButton addTarget: self action: @selector(editBlockList) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview: editBlockListButton];
    [editBlockListButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(sitesBlockedLabel.mas_bottom).with.offset(20);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    UIButton* startBlockButton = [UIButton buttonWithType: UIButtonTypeSystem];
    startBlockButton.titleLabel.font = [UIFont systemFontOfSize: 24.0];
    [startBlockButton setTitle: @"Start Block" forState: UIControlStateNormal];
    startBlockButton.backgroundColor = [UIColor blueColor];
    [startBlockButton addTarget: self action: @selector(startBlockButtonPressed) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview: startBlockButton];
    [startBlockButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.equalTo(@60);
    }];
}

- (NSString*)humanReadableBlockTime {
    // make a formatter if we don't have one
    static SCTimeIntervalFormatter* formatter = nil;
    if (formatter == nil) {
        formatter = [[SCTimeIntervalFormatter alloc] init];
    }

    return [formatter stringForObjectValue:@(self.blockTimeSlider.value)];
}

- (void)blockTimeSliderChanged:(id)sender {
    // update time label
    self.humanReadableBlockTimeLabel.text = [self humanReadableBlockTime];
    
    // save to defaults
    [[NSUserDefaults standardUserDefaults] setInteger: self.blockTimeSlider.value forKey: @"blockLengthSeconds"];
}

- (void)updateSitesBlockedLabel {
    self.sitesBlockedLabel.text = [NSString stringWithFormat: @"%lu sites will be blocked.", (unsigned long)[[SCBlockManager sharedManager] blockRules].count];
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
    NSString* confirmText = [NSString stringWithFormat: @"Are you sure you want to start the block? %lu sites will be blocked for %@.", (unsigned long)[[SCBlockManager sharedManager] blockRules].count, self.humanReadableBlockTime];
    
    [SCAlertFactory showConfirmationDialogWithTitle: @"Confirm Block"
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
                                         title: @"Couldn't Start Block"
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
