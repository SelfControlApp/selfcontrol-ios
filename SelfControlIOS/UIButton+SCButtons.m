//
//  UIButton+SCButtons.m
//  SelfControlIOS
//
//  Created by Charles Stigler on 23/09/2017.
//  Copyright © 2017 SelfControl. All rights reserved.
//

#import "UIButton+SCButtons.h"
#import <Masonry/Masonry.h>

@implementation UIButton (SCButtons)

+ (UIButton*)scActionButton; {
    UIButton* actionButton = [UIButton buttonWithType: UIButtonTypeSystem];
    actionButton.titleLabel.font = [UIFont systemFontOfSize: 24.0];
    [actionButton setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    actionButton.backgroundColor = [UIColor colorWithRed: (68.0 / 255.0) green: (108.0 / 255.0) blue: (179.0 / 255.0) alpha: 1];
    [actionButton setTitleColor: [UIColor lightGrayColor] forState: UIControlStateDisabled];
    
    // add drop shadow
    actionButton.layer.shadowRadius = 1.5f;
    actionButton.layer.shadowColor = [UIColor blackColor].CGColor;
    actionButton.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    actionButton.layer.shadowOpacity = 0.3f;
    actionButton.layer.masksToBounds = NO;
    
    [actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@60);
    }];
    
    // darken button when pressed
    [actionButton addTarget: self action: @selector(scActionButtonHighlight:) forControlEvents: UIControlEventTouchDown];
    [actionButton addTarget: self action: @selector(scActionButtonUnHighlight:) forControlEvents: UIControlEventTouchUpInside|UIControlEventTouchUpOutside|UIControlEventTouchDragExit];
    
    return actionButton;
}
+ (void)scActionButtonHighlight:(UIButton*)button {
    button.backgroundColor = [UIColor colorWithRed: (48.0 / 255.0) green: (88.0 / 255.0) blue: (159.0 / 255.0) alpha: 1];
}
+ (void)scActionButtonUnHighlight:(UIButton*)button {
    button.backgroundColor = [UIColor colorWithRed: (68.0 / 255.0) green: (108.0 / 255.0) blue: (179.0 / 255.0) alpha: 1];
}

@end
