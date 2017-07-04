//
//  SCTimeIntervalFormatter.m
//  SelfControl
//
//  Created by Sam Stigler on 10/14/14.
//
//

#import <FormatterKit/TTTTimeIntervalFormatter.h>
#import "SCTimeIntervalFormatter.h"

@implementation SCTimeIntervalFormatter

- (NSString *)stringForObjectValue:(id)obj {
    NSString* string = @"";
    if ([obj isKindOfClass:[NSNumber class]]) {
        string = [self formatSeconds:[obj doubleValue]];
    }

    return string;
}

- (NSString *)formatSeconds:(NSTimeInterval)seconds {
    static TTTTimeIntervalFormatter* timeIntervalFormatter = nil;
    if (timeIntervalFormatter == nil) {
        timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        timeIntervalFormatter.pastDeicticExpression = @"";
        timeIntervalFormatter.presentDeicticExpression = @"";
        timeIntervalFormatter.futureDeicticExpression = @"";
        timeIntervalFormatter.significantUnits = (NSCalendarUnitYear |
                                                  NSCalendarUnitMonth |
                                                  NSCalendarUnitDay |
                                                  NSCalendarUnitHour |
                                                  NSCalendarUnitMinute);
        timeIntervalFormatter.numberOfSignificantUnits = 0;
        timeIntervalFormatter.leastSignificantUnit = NSCalendarUnitMinute;
    }
    
    NSString* formatted = [timeIntervalFormatter stringForTimeInterval:seconds];
    if ([formatted length] == 0) {
        formatted = [self stringIndicatingZeroMinutes];
    }
    
    return formatted;
}

- (NSString *)stringIndicatingZeroMinutes {
    NSString* disabledString = [NSString stringWithFormat: @"0 %@ (%@)",
                                NSLocalizedString(@"minutes", @"Plural minutes time string"),
                                NSLocalizedString(@"disabled", "Shows that SelfControl is disabled")];
    return disabledString;
}

@end
