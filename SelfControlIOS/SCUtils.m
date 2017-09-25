//
//  SCUtils.m
//  
//
//  Created by Charles Stigler on 08/05/2017.
//
//

#import "SCUtils.h"

@implementation SCUtils

+ (NSString*)stringWithoutRegexSpecialChars:(NSString*)input {
    return [input stringByReplacingOccurrencesOfString: @"[\\\\\\^\\$\\.\\|\\?\\*\\+\\(\\)\\[\\{]"
                                            withString: @"\\\\$0"
                                               options: NSRegularExpressionSearch
                                                 range: (NSRange){0, [input length]}];
    //    return [input stringByR  (of: "[\\\\\\^\\$\\.\\|\\?\\*\\+\\(\\)\\[\\{]",
    //                                               with: "\\\\$0",
    //                                               options: .regularExpression)
}

+ (NSDictionary<NSString*, NSString*>*)appNameDict {
    return @{
        @"com.facebook.Facebook": NSLocalizedString(@"Facebook", nil),
        @"com.facebook.Messenger": NSLocalizedString(@"Facebook Messenger", nil),
        @"com.apple.mobilesafari": NSLocalizedString(@"Safari", nil),
        @"com.google.chrome.ios": NSLocalizedString(@"Chrome", nil),
        @"com.atebits.Tweetie2": NSLocalizedString(@"Twitter", nil),
        @"com.burbn.instagram": NSLocalizedString(@"Instagram", nil),
        @"com.toyopagroup.picaboo": NSLocalizedString(@"Snapchat", nil),
        @"com.youtube.ios.youtube": NSLocalizedString(@"YouTube", nil),
        @"com.netflix.Netflix": NSLocalizedString(@"Netflix", nil),
        @"com.spotify.client": NSLocalizedString(@"Spotify", nil),
        @"com.dotgears.flap": NSLocalizedString(@"Flappy Bird", nil),
        @"com.9gag.ios.mobile": NSLocalizedString(@"9GAG", nil),
        @"com.google.Gmail": NSLocalizedString(@"Gmail", nil),
        @"com.google.inbox": NSLocalizedString(@"Google Inbox", nil),
        @"com.medium.reader": NSLocalizedString(@"Medium", nil),
        @"com.tyanya.reddit": NSLocalizedString(@"Reddit", nil),
        @"com.cardify.tinder": NSLocalizedString(@"Tinder", nil),
        @"com.tumblr.tumblr": NSLocalizedString(@"Tumblr", nil),
        @"com.nianticlabs.pokemongo": NSLocalizedString(@"Pokemon Go", nil)
    };
}

+ (NSDictionary<NSString*, NSString*>*)appDictForBundleId:(NSString*)bundleId {
    return @{
             @"name": bundleId,
             @"bundleId": [[SCUtils appNameDict] objectForKey: bundleId]
             };
}

@end
