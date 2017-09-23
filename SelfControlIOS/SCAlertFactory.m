//
//  SCAlertFactory.m
//  SelfControlIOS
//
//  Created by Charles Stigler on 01/07/2017.
//  Copyright © 2017 SelfControl. All rights reserved.
//

#import "SCAlertFactory.h"

@implementation SCAlertFactory

+ (void)showAlertWithTitle:(NSString*)title
               description:(NSString*)description
            viewController:(UIViewController*)vc {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle: title
                                                                   message: description
                                                            preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    [alert addAction: defaultAction];
    [vc presentViewController: alert animated: YES completion: nil];
}

+ (void)showAlertWithError:(NSError*)err
                     title:(NSString*)title
            viewController:(UIViewController*)vc {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle: title
                                                                   message: [err localizedDescription]
                                                            preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    [alert addAction: defaultAction];
    [vc presentViewController: alert animated: YES completion: nil];
}

+ (void)showConfirmationDialogWithTitle:(NSString*)title
                            description:(NSString*)description
                          confirmAction:(void(^)())handler
                         viewController: (UIViewController*)vc {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle: title
                                                                   message: description
                                                            preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action) {}];
    [alert addAction: cancelAction];
    
    UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [handler invoke];
                                                         }];
    [alert addAction: confirmAction];
    
    [vc presentViewController: alert animated: YES completion: nil];
}

@end
