//
//  UserSession.m
//  Skiing
//

#import "UserSession.h"

static NSString * const kIsLoggedIn = @"kIsLoggedIn";

@implementation UserSession

+ (BOOL)isLoggedIn {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kIsLoggedIn];
}

+ (void)saveLoginState {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsLoggedIn];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)clearLoginState {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kIsLoggedIn];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
