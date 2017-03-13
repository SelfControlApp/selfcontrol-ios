//
//  SCBlockRuleTableViewCell.m
//  SelfControlIOS
//
//  Created by Charles Stigler on 25/02/2017.
//  Copyright © 2017 SelfControl. All rights reserved.
//

#import "SCBlockRuleTableViewCell.h"

@interface SCBlockRuleTableViewCell () <UITextFieldDelegate>

@end

@implementation SCBlockRuleTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self)
        return nil;
    
    UIView *contentView = self.contentView;
    
    UITextField *textField = [UITextField new];
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    textField.keyboardType = UIKeyboardTypeURL;
    textField.returnKeyType = UIReturnKeyDone;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.delegate = self;
    textField.placeholder = @"example.com";
    [contentView addSubview:textField];
    _textField = textField;
    
    [NSLayoutConstraint activateConstraints:@[
        [NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeLeadingMargin multiplier:1.0f constant:0.0f],
        [NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTrailingMargin multiplier:1.0f constant:0.0f],
        [NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f],
        [NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f]
    ]];
    
    return self;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.delegate blockRuleCellDidChange:self];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [(UITableViewController*)self.delegate setEditing: NO animated: YES];
    return NO;
}

@end
