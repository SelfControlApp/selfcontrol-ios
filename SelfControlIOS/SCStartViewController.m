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
    blockTimeSlider.minimumValue = 1;
    blockTimeSlider.maximumValue = 1440;
    blockTimeSlider.continuous = YES;
    [self.view addSubview: blockTimeSlider];
    [blockTimeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(focusForLabel.mas_bottom).with.offset(15);
        make.left.equalTo(self.view.mas_left).with.offset(40);
        make.right.equalTo(self.view.mas_right).with.offset(-40);
    }];
    self.blockTimeSlider = blockTimeSlider;
    // pull initial value from defautls
    self.blockTimeSlider.value = [[NSUserDefaults standardUserDefaults] integerForKey:@"blockLengthMinutes"];

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
    [startBlockButton addTarget: self action: @selector(confirmStartBlock) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview: startBlockButton];
    [startBlockButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.equalTo(@60);
    }];
}

- (void)blockTimeSliderChanged:(id)sender {
    // update time label
    self.humanReadableBlockTimeLabel.text = [NSString stringWithFormat: @"%d minutes", (int)self.blockTimeSlider.value];
    
    // save to defaults
    [[NSUserDefaults standardUserDefaults] setInteger: self.blockTimeSlider.value forKey: @"blockLengthMinutes"];
}

- (void)updateSitesBlockedLabel {
    self.sitesBlockedLabel.text = [NSString stringWithFormat: @"%d sites will be blocked.", (int)[[[SCBlockManager sharedManager] blockRules] count]];
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

- (void)confirmStartBlock {
    UIAlertController* prompt = [UIAlertController alertControllerWithTitle:@"Confirm" message:@"Are you sure you want to start blocking?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self startBlock];
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {}];
    [prompt addAction:defaultAction];
    [prompt addAction:cancelAction];
    [self presentViewController:prompt animated:YES completion:nil];
}

- (void)startBlock {
    [[SCBlockManager sharedManager] startBlock:^(NSError * err) {
        if (err != nil) {
            // show error message
            // TODO: abstract into a factory cause this is way too long
            UIAlertController* alert = [UIAlertController alertControllerWithTitle: @"Couldn't Start Block"
                                                                           message: [err localizedDescription]
                                                                    preferredStyle: UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            [alert addAction: defaultAction];
            [self presentViewController: alert animated: YES completion: nil];
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
