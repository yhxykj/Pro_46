//
//  UserSession.h
//  Skiing
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserSession : NSObject

/// Returns YES if the user has logged in before and the session is still valid.
+ (BOOL)isLoggedIn;

/// Call after a successful login or registration.
+ (void)saveLoginState;

/// Call after a successful login or registration with the active account email.
+ (void)saveLoginStateWithEmail:(NSString *)email;

/// Returns the email for the current logged-in account.
+ (NSString *)currentEmail;

/// Call on logout to clear the session.
+ (void)clearLoginState;

@end

NS_ASSUME_NONNULL_END
