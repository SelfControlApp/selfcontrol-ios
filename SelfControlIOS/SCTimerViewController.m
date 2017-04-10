//
//  SCTimerViewController.m
//  SelfControlIOS
//
//  Created by Charles Stigler on 25/02/2017.
//  Copyright © 2017 SelfControl. All rights reserved.
//

#import "SCTimerViewController.h"
#import "SCMainViewController.h"
#import "SCBlockManager.h"
#import <Masonry/Masonry.h>

@interface SCTimerViewController ()

@property (nonatomic, weak) UILabel* timerLabel;
@property (nonatomic, weak) UILabel* sitesBlockedLabel;
@property (nonatomic, strong) NSTimer* updateLabelTimer;

@end

@implementation SCTimerViewController

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

    UILabel* timerLabel = [UILabel new];
    timerLabel.font = [UIFont systemFontOfSize: 36.0];
    [self.view addSubview: timerLabel];
    [timerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
    }];
    self.timerLabel = timerLabel;
    
    UILabel* sitesBlockedLabel = [UILabel new];
    sitesBlockedLabel.font = [UIFont systemFontOfSize: 18.0];
    [self.view addSubview: sitesBlockedLabel];
    [sitesBlockedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(timerLabel.mas_bottom).with.offset(40);
    }];
    self.sitesBlockedLabel = sitesBlockedLabel;
    
    UIButton* extendBlockButton = [UIButton buttonWithType: UIButtonTypeSystem];
    extendBlockButton.titleLabel.font = [UIFont systemFontOfSize: 24.0];
    [extendBlockButton setTitle: @"Extend Block Time" forState: UIControlStateNormal];
    extendBlockButton.backgroundColor = [UIColor blueColor];
    //    [extendBlockButton addTarget: self action: @selector(extendBlock) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview: extendBlockButton];
    [extendBlockButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.equalTo(@60);
    }];

    UIButton* addSiteButton = [UIButton buttonWithType: UIButtonTypeSystem];
    addSiteButton.titleLabel.font = [UIFont systemFontOfSize: 24.0];
    [addSiteButton setTitle: @"Add Site to Block List" forState: UIControlStateNormal];
    addSiteButton.backgroundColor = [UIColor blueColor];
//    [addSiteButton addTarget: self action: @selector(addSite) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview: addSiteButton];
    [addSiteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(extendBlockButton.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.equalTo(@60);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateSitesBlockedLabel];
    [self updateTimerLabel];
    
    _updateLabelTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                         target: self
                                                       selector: @selector(timerUpdate)
                                                       userInfo: nil
                                                        repeats: YES];
}
- (void)viewWillDisappear:(BOOL)animated {
    [_updateLabelTimer invalidate];
    _updateLabelTimer = nil;
}

- (void)updateSitesBlockedLabel {
    self.sitesBlockedLabel.text = [NSString stringWithFormat: @"Blocking %lu sites", (unsigned long)[SCBlockManager sharedManager].blockRules.count];
}

- (void)updateTimerLabel {
    self.timerLabel.text = [self timeRemainingString];
}

- (void)reloadRootViewIfBlockNotRunning {
    if (![SCBlockManager sharedManager].blockIsRunning) {
        [(SCMainViewController*)self.navigationController reloadViewControllers];
    }
}

- (void)timerUpdate {
    [self updateTimerLabel];
    [self reloadRootViewIfBlockNotRunning];
}

- (NSString*)timeRemainingString {
    NSUInteger secondsRemaining = [SCBlockManager sharedManager].blockEndDate.timeIntervalSinceNow;
    NSUInteger hoursRemaining;
    NSUInteger minutesRemaining;
    
    // convert seconds into hours/minutes
    hoursRemaining = (secondsRemaining / 3600);
    secondsRemaining %= 3600;
    minutesRemaining = (secondsRemaining / 60);
    secondsRemaining %= 60;
    
    return [NSString stringWithFormat: @"%0.2lu:%0.2lu:%0.2lu",
            (unsigned long)hoursRemaining,
            (unsigned long)minutesRemaining,
            (unsigned long)secondsRemaining];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
