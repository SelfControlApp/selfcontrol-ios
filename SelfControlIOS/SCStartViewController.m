//
//  SCStartViewController.m
//  SelfControlIOS
//
//  Created by Charles Stigler on 25/02/2017.
//  Copyright © 2017 SelfControl. All rights reserved.
//

#import "SCStartViewController.h"
#import "SCBlockListViewController.h"

@interface SCStartViewController ()

@end

@implementation SCStartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *editBlockListButton = [UIButton buttonWithType: UIButtonTypeSystem];
    editBlockListButton.translatesAutoresizingMaskIntoConstraints = NO;
    [editBlockListButton setTitle: @"Edit Block List" forState: UIControlStateNormal];
    [editBlockListButton addTarget: self action: @selector(editBlockList) forControlEvents: UIControlEventTouchUpInside];
    
    [self.view addSubview: editBlockListButton];
    
    NSMutableArray<NSLayoutConstraint *> *constraints = [NSMutableArray new];
    NSDictionary *views = NSDictionaryOfVariableBindings(editBlockListButton);
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-100-[editBlockListButton]" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[editBlockListButton]|" options:0 metrics:nil views:views]];
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [self.navigationController setNavigationBarHidden: YES animated: YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)editBlockList {
    [self.navigationController pushViewController: [SCBlockListViewController new] animated: YES];
    [self.navigationController setNavigationBarHidden: NO animated: YES];
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
