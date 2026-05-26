//
//  UserModerationStore.h
//  Skiing
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const UserModerationStoreBlockedUsersDidChangeNotification;

@interface UserModerationStore : NSObject

+ (NSArray<NSDictionary *> *)blockedUsers;
+ (NSSet<NSString *> *)blockedUserIDs;
+ (BOOL)isUserBlockedWithName:(nullable NSString *)name
                       handle:(nullable NSString *)handle
                       avatar:(nullable NSString *)avatar;
+ (void)blockUserWithName:(NSString *)name
                   handle:(NSString *)handle
                   avatar:(NSString *)avatar;
+ (void)removeBlockedUserWithID:(NSString *)userID;
+ (NSString *)userIDForName:(nullable NSString *)name
                     handle:(nullable NSString *)handle
                     avatar:(nullable NSString *)avatar;

@end

NS_ASSUME_NONNULL_END
