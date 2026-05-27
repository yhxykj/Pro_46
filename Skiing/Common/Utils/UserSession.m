//
//  UserSession.m
//  Skiing
//

#import "UserSession.h"

static NSString * const kIsLoggedIn = @"kIsLoggedIn";
static NSString * const kCurrentUserEmail = @"kCurrentUserEmail";

@implementation UserSession

+ (BOOL)isLoggedIn {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kIsLoggedIn];
}

+ (void)saveLoginState {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsLoggedIn];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)saveLoginStateWithEmail:(NSString *)email {
    NSString *trimmedEmail = [email stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:kIsLoggedIn];
    if (trimmedEmail.length > 0) {
        [defaults setObject:trimmedEmail.lowercaseString forKey:kCurrentUserEmail];
    }
    [defaults synchronize];
}

+ (NSString *)currentEmail {
    NSString *email = [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentUserEmail];
    return [email isKindOfClass:NSString.class] ? email : @"";
}

+ (void)clearLoginState {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kIsLoggedIn];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCurrentUserEmail];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
