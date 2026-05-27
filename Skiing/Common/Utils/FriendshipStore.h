//
//  FriendshipStore.h
//  Skiing
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FriendshipStore : NSObject

+ (NSArray<NSDictionary *> *)friends;
+ (BOOL)isFriendWithName:(NSString *)name
                  handle:(NSString *)handle
                  avatar:(NSString *)avatar;
+ (void)addFriendWithName:(NSString *)name
                   handle:(NSString *)handle
                   avatar:(NSString *)avatar;

@end

NS_ASSUME_NONNULL_END
