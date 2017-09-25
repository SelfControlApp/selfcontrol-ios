//
//  SCUtils.h
//  
//
//  Created by Charles Stigler on 08/05/2017.
//
//

#import <Foundation/Foundation.h>

@interface SCUtils : NSObject

+ (NSString*)stringWithoutRegexSpecialChars:(NSString*)input;
+ (NSDictionary<NSString*, NSString*>*)appDictForBundleId:(NSString*)bundleId;

@end
