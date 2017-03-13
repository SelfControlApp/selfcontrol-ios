//
//  SCMainViewController.m
//  SelfControlIOS
//
//  Created by Charles Stigler on 25/02/2017.
//  Copyright © 2017 SelfControl. All rights reserved.
//

#import "SCMainViewController.h"
#import "SCStartViewController.h"
#import "SCTimerViewController.h"

@interface SCMainViewController ()

@property (nonatomic, strong) SCStartViewController* startViewController;
@property (nonatomic, strong) SCTimerViewController* timerViewController;

@end

@implementation SCMainViewController

- (instancetype)init {
    self = [super init];
    if (!self)
        return nil;
    
    _startViewController = [SCStartViewController new];
    _timerViewController = [SCTimerViewController new];
    
    [self reloadViewControllers];

    return self;
}
        
- (void)reloadViewControllers {
    // if block running, root view controller = timer, otherwise = start
    self.viewControllers = @[self.startViewController];
    
    self.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
