//
//  SCTimerViewController.m
//  SelfControlIOS
//
//  Created by Charles Stigler on 25/02/2017.
//  Copyright © 2017 SelfControl. All rights reserved.
//

#import "SCTimerViewController.h"
#import "SCTimeIntervalFormatter.h"
#import "SCMainViewController.h"
#import "SCAppSelectorViewController.h"
#import "SCBlockManager.h"
#import "SCBlockRule.h"
#import "SCUtils.h"
#import "SCUtils+SCViewUtils.h"
#import "SCAlertFactory.h"
#import "UIButton+SCButtons.h"
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
    
    UIButton* extendBlockButton = [UIButton scActionButton];
    [extendBlockButton setTitle: NSLocalizedString(@"Extend Block Duration", nil) forState: UIControlStateNormal];
    [extendBlockButton addTarget: self action: @selector(showExtendBlockDialog) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview: extendBlockButton];
    [extendBlockButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
    }];

    UIButton* addSiteButton = [UIButton scActionButton];
    [addSiteButton setTitle: NSLocalizedString(@"Add Site to Block List", nil) forState: UIControlStateNormal];
    [addSiteButton addTarget: self action: @selector(showAddSiteDialog) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview: addSiteButton];
    [addSiteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(extendBlockButton.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
    }];
    
    UIButton* addAppButton = [UIButton scActionButton];
    [addAppButton setTitle: NSLocalizedString(@"Add App to Block List", nil) forState: UIControlStateNormal];
    [addAppButton addTarget: self action: @selector(showAddAppDialog) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview: addAppButton];
    [addAppButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(addSiteButton.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
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
    
    [self.navigationController setNavigationBarHidden: YES animated: YES];
}
- (void)viewWillDisappear:(BOOL)animated {
    [_updateLabelTimer invalidate];
    _updateLabelTimer = nil;
}

- (void)updateSitesBlockedLabel {
    self.sitesBlockedLabel.text = [NSString localizedStringWithFormat: NSLocalizedString(@"Blocking %@", nil), [SCUtils blockListSummaryString]];
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

- (void) showAddSiteDialog {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle: NSLocalizedString(@"Add Site to Blocklist", nil)
                                                                   message: NSLocalizedString(@"The new site will be inaccessible for the remainder of the current block.", nil)
                                                            preferredStyle: UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeURL;
        textField.returnKeyType = UIReturnKeyDone;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.placeholder = @"example.com";
        textField.adjustsFontSizeToFitWidth = YES;
        
        [textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@25);
        }];
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle: NSLocalizedString(@"Cancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {}];
    [alert addAction: cancelAction];
    
    UIAlertAction* addAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Add", nil) style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              UITextField* textField = alert.textFields[0];
                                                              [[SCBlockManager sharedManager] addBlockRule: [SCBlockRule ruleWithHostname: textField.text] type: SCBlockTypeHost];
                                                              [self updateSitesBlockedLabel];
                                                          }];
    [alert addAction: addAction];
    
    [self presentViewController: alert animated: YES completion: nil];
}

- (void)showAddAppDialog {
    SCAppSelectorViewController* addAppVC = [SCAppSelectorViewController new];
    addAppVC.delegate = self;
    [self.navigationController pushViewController: addAppVC animated: YES];
    [self.navigationController setNavigationBarHidden: NO animated: YES];
}

- (void)showExtendBlockDialog {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle: NSLocalizedString(@"Extend Block Duration", nil)
                                                                   message: NSLocalizedString(@"The chosen amount of time will be added on to your current block.", nil)
                                                            preferredStyle: UIAlertControllerStyleActionSheet];
    
    static SCTimeIntervalFormatter* formatter = nil;
    if (formatter == nil) {
        formatter = [[SCTimeIntervalFormatter alloc] init];
    }

    NSArray<NSNumber*>* blockExtensionOptionsSeconds = @[
                                       @300,
                                       @900,
                                       @1800,
                                       @3600,
                                       @7200,
                                       @21600
                                       ];
    
    for (int i = 0; i < blockExtensionOptionsSeconds.count; i++) {
        NSString* optionText = [NSString localizedStringWithFormat: NSLocalizedString(@"Extend block by %@", nil), [formatter stringForObjectValue: blockExtensionOptionsSeconds[i]]];
        UIAlertAction* extendAction = [UIAlertAction actionWithTitle: optionText
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   NSInteger extendSecs = blockExtensionOptionsSeconds[i].integerValue;
                                   if ([SCBlockManager sharedManager].blockEndDate.timeIntervalSinceNow + extendSecs > 604800) {
                                       [SCAlertFactory showAlertWithTitle: @"Can't Extend Block"
                                                              description: @"Sorry, we don't let you extend your block for longer than a week. It's for your own good."
                                                           viewController: self];
                                       return;
                                   }
   
                                   [[SCBlockManager sharedManager] extendBlockDuration: extendSecs];
                                   [self updateTimerLabel];
                               }];
        [alert addAction: extendAction];
    }
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle: NSLocalizedString(@"Cancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {}];
    [alert addAction: cancelAction];

    [self presentViewController: alert animated: YES completion: nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SCAppSelectorDelegate

- (void)appRuleSelected:(SCBlockRule*)appRule {
    [[SCBlockManager sharedManager] addBlockRule: appRule type: SCBlockTypeApp];
    [self updateSitesBlockedLabel];
    [self.navigationController setNavigationBarHidden: YES animated: YES];
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
