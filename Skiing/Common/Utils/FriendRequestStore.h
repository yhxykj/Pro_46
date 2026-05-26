//
//  FriendRequestStore.h
//  Skiing
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FriendRequestStore : NSObject

+ (BOOL)hasSentFriendRequestToName:(NSString *)name
                            handle:(NSString *)handle
                            avatar:(NSString *)avatar;

+ (void)markFriendRequestSentToName:(NSString *)name
                             handle:(NSString *)handle
                             avatar:(NSString *)avatar;

+ (NSString *)friendRequestIDForName:(NSString *)name
                              handle:(NSString *)handle
                              avatar:(NSString *)avatar;

@end

NS_ASSUME_NONNULL_END
