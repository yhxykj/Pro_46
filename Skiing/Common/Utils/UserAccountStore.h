//
//  UserAccountStore.h
//  Skiing
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserAccountStore : NSObject

+ (BOOL)accountExistsWithEmail:(NSString *)email;
+ (BOOL)validateEmail:(NSString *)email password:(NSString *)password;
+ (BOOL)saveAccountWithEmail:(NSString *)email password:(NSString *)password errorMessage:(NSString *_Nullable *_Nullable)errorMessage;

@end

NS_ASSUME_NONNULL_END
