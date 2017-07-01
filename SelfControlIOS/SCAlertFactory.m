//
//  SCAlertFactory.m
//  SelfControlIOS
//
//  Created by Charles Stigler on 01/07/2017.
//  Copyright © 2017 SelfControl. All rights reserved.
//

#import "SCAlertFactory.h"

@implementation SCAlertFactory

+ (void)showAlertWithError:(NSError*)err
                     title:(NSString*)title
            viewController:(UIViewController*)vc {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle: title
                                                                   message: [err localizedDescription]
                                                            preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    [alert addAction: defaultAction];
    [vc presentViewController: alert animated: YES completion: nil];
}

@end
