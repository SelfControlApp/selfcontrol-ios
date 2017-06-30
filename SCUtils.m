//
//  SCUtils.m
//  
//
//  Created by Charles Stigler on 08/05/2017.
//
//

#import "SCUtils.h"

@implementation SCUtils

- (NSString*)stringWithoutRegexSpecialChars:(NSString*)input {
    return [input stringByReplacingOccurrencesOfString: @"[\\\\\\^\\$\\.\\|\\?\\*\\+\\(\\)\\[\\{]"
                                            withString: @"\\\\$0"
                                               options: NSRegularExpressionSearch
                                                 range: (NSRange){0, [input length]}];
    //    return [input stringByR  (of: "[\\\\\\^\\$\\.\\|\\?\\*\\+\\(\\)\\[\\{]",
    //                                               with: "\\\\$0",
    //                                               options: .regularExpression)
}

@end
