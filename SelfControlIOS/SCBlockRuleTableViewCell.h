//
//  SCBlockRuleTableViewCell.h
//  SelfControlIOS
//
//  Created by Charles Stigler on 25/02/2017.
//  Copyright © 2017 SelfControl. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SCBlockRuleTableViewCellDelegate;

@interface SCBlockRuleTableViewCell : UITableViewCell

@property (nonatomic, weak) id<SCBlockRuleTableViewCellDelegate> delegate;
@property (nonatomic, weak, readonly) UITextField *textField;

@end

@protocol SCBlockRuleTableViewCellDelegate

- (void)blockRuleCellDidChange:(SCBlockRuleTableViewCell *)cell;

@end

