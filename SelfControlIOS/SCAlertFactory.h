//
//  SCAlertFactory.h
//  SelfControlIOS
//
//  Created by Charles Stigler on 01/07/2017.
//  Copyright © 2017 SelfControl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SCAlertFactory : NSObject

+ (void)showAlertWithError:(NSError*)err
                     title:(NSString*)title
            viewController:(UIViewController*)vc;

+ (void)showConfirmationDialogWithTitle:(NSString*)title
                            description:(NSString*)description
                          confirmAction:(void(^)())handler
                         viewController: (UIViewController*)vc;

@end
