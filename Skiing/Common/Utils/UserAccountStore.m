//
//  UserAccountStore.m
//  Skiing
//

#import "UserAccountStore.h"

static NSString * const kUserAccountStoreAccountsDefaultsKey = @"kUserAccountStoreAccountsDefaultsKey";
static NSString * const kSeedTestEmail = @"skiing666@gmail.com";
static NSString * const kSeedTestPassword = @"888888";

@implementation UserAccountStore

+ (BOOL)accountExistsWithEmail:(NSString *)email {
    NSString *normalizedEmail = [self normalizedEmail:email];
    if (normalizedEmail.length == 0) {
        return NO;
    }

    return [self accounts][normalizedEmail] != nil;
}

+ (BOOL)validateEmail:(NSString *)email password:(NSString *)password {
    NSString *normalizedEmail = [self normalizedEmail:email];
    if (normalizedEmail.length == 0 || password.length == 0) {
        return NO;
    }

    NSString *storedPassword = [self accounts][normalizedEmail];
    return [storedPassword isKindOfClass:NSString.class] && [storedPassword isEqualToString:password];
}

+ (BOOL)saveAccountWithEmail:(NSString *)email password:(NSString *)password errorMessage:(NSString *_Nullable *_Nullable)errorMessage {
    NSString *normalizedEmail = [self normalizedEmail:email];
    if (normalizedEmail.length == 0 || password.length == 0) {
        if (errorMessage) {
            *errorMessage = @"Invalid account information.";
        }
        return NO;
    }

    NSMutableDictionary<NSString *, NSString *> *accounts = [[self accounts] mutableCopy];
    if (accounts[normalizedEmail]) {
        if (errorMessage) {
            *errorMessage = @"This email is already registered.";
        }
        return NO;
    }

    accounts[normalizedEmail] = password;
    [self saveAccounts:accounts];
    return YES;
}

+ (NSDictionary<NSString *, NSString *> *)accounts {
    NSDictionary *storedAccounts = [NSUserDefaults.standardUserDefaults objectForKey:kUserAccountStoreAccountsDefaultsKey];
    NSMutableDictionary<NSString *, NSString *> *accounts = [NSMutableDictionary dictionary];

    if ([storedAccounts isKindOfClass:NSDictionary.class]) {
        [storedAccounts enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString *email = [self normalizedEmail:[key isKindOfClass:NSString.class] ? key : @""];
            if (email.length == 0 || ![obj isKindOfClass:NSString.class]) {
                return;
            }
            accounts[email] = (NSString *)obj;
        }];
    }

    if (!accounts[kSeedTestEmail]) {
        accounts[kSeedTestEmail] = kSeedTestPassword;
        [self saveAccounts:accounts];
    }

    return accounts.copy;
}

+ (void)saveAccounts:(NSDictionary<NSString *, NSString *> *)accounts {
    [NSUserDefaults.standardUserDefaults setObject:accounts forKey:kUserAccountStoreAccountsDefaultsKey];
    [NSUserDefaults.standardUserDefaults synchronize];
}

+ (NSString *)normalizedEmail:(NSString *)email {
    if (![email isKindOfClass:NSString.class]) {
        return @"";
    }

    NSString *trimmedEmail = [email stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    return trimmedEmail.lowercaseString;
}

@end
