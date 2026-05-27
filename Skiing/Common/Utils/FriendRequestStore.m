//
//  FriendRequestStore.m
//  Skiing
//

#import "FriendRequestStore.h"
#import "UserSession.h"

static NSString * const kFriendRequestSentUsersDefaultsKey = @"kFriendRequestSentUsersDefaultsKey";
static NSString * const kFriendRequestStoreFileName = @"friend_requests.json";

@implementation FriendRequestStore

+ (BOOL)hasSentFriendRequestToName:(NSString *)name
                            handle:(NSString *)handle
                            avatar:(NSString *)avatar {
    NSString *userID = [self friendRequestIDForName:name handle:handle avatar:avatar];
    for (NSDictionary *user in [self sentUsers]) {
        if ([self user:user matchesID:userID]) {
            return YES;
        }
    }
    return NO;
}

+ (void)markFriendRequestSentToName:(NSString *)name
                             handle:(NSString *)handle
                             avatar:(NSString *)avatar {
    NSString *cleanName = [self cleanString:name fallback:@"Unknown"];
    NSString *cleanHandle = [self cleanString:handle fallback:@""];
    NSString *cleanAvatar = [self cleanString:avatar fallback:@"avatar_placeholder"];
    NSString *userID = [self friendRequestIDForName:cleanName handle:cleanHandle avatar:cleanAvatar];

    NSMutableArray<NSDictionary *> *users = [[self sentUsers] mutableCopy];
    NSIndexSet *matchingIndexes = [users indexesOfObjectsPassingTest:^BOOL(NSDictionary *user, NSUInteger idx, BOOL *stop) {
        return [self user:user matchesID:userID];
    }];
    if (matchingIndexes.count > 0) {
        [users removeObjectsAtIndexes:matchingIndexes];
    }

    [users addObject:@{@"id": userID,
                       @"name": cleanName,
                       @"handle": cleanHandle,
                       @"avatar": cleanAvatar}];
    [self persistSentUsers:users];
}

+ (NSString *)friendRequestIDForName:(NSString *)name
                              handle:(NSString *)handle
                              avatar:(NSString *)avatar {
    NSString *cleanHandle = [self normalizedComponent:handle];
    if (cleanHandle.length > 0) {
        return cleanHandle;
    }

    NSString *cleanName = [self normalizedComponent:name];
    NSString *cleanAvatar = [self normalizedComponent:avatar];
    return [NSString stringWithFormat:@"%@|%@", cleanName, cleanAvatar];
}

+ (NSArray<NSDictionary *> *)sentUsers {
    NSArray *storedUsers = [NSUserDefaults.standardUserDefaults objectForKey:[self sentUsersDefaultsKey]];
    NSArray<NSDictionary *> *users = [self sanitizedUsersFromObject:storedUsers];
    if (users.count > 0) {
        [self persistSentUsers:users];
        return users;
    }

    users = [self readSentUsersFromDisk];
    if (users.count > 0) {
        [NSUserDefaults.standardUserDefaults setObject:users forKey:[self sentUsersDefaultsKey]];
        [NSUserDefaults.standardUserDefaults synchronize];
    }
    return users;
}

+ (void)persistSentUsers:(NSArray<NSDictionary *> *)users {
    NSArray<NSDictionary *> *sanitizedUsers = [self sanitizedUsersFromObject:users];
    [NSUserDefaults.standardUserDefaults setObject:sanitizedUsers forKey:[self sentUsersDefaultsKey]];
    [NSUserDefaults.standardUserDefaults synchronize];
    [self writeSentUsersToDisk:sanitizedUsers];
}

+ (NSArray<NSDictionary *> *)sanitizedUsersFromObject:(id)object {
    if (![object isKindOfClass:NSArray.class]) {
        return @[];
    }

    NSMutableArray<NSDictionary *> *users = [NSMutableArray array];
    for (id item in (NSArray *)object) {
        if (![item isKindOfClass:NSDictionary.class]) {
            continue;
        }

        NSDictionary *user = (NSDictionary *)item;
        NSString *name = user[@"name"];
        NSString *handle = user[@"handle"];
        NSString *avatar = user[@"avatar"];
        if (![name isKindOfClass:NSString.class] || name.length == 0 ||
            ![avatar isKindOfClass:NSString.class] || avatar.length == 0) {
            continue;
        }

        NSString *cleanHandle = [handle isKindOfClass:NSString.class] ? handle : @"";
        NSString *userID = user[@"id"];
        if (![userID isKindOfClass:NSString.class] || userID.length == 0) {
            userID = [self friendRequestIDForName:name handle:cleanHandle avatar:avatar];
        }
        [users addObject:@{@"id": userID,
                           @"name": name,
                           @"handle": cleanHandle,
                           @"avatar": avatar}];
    }
    return users.copy;
}

+ (BOOL)user:(NSDictionary *)user matchesID:(NSString *)userID {
    NSString *storedID = user[@"id"];
    if ([storedID isKindOfClass:NSString.class] && [storedID isEqualToString:userID]) {
        return YES;
    }

    NSString *fallbackID = [self friendRequestIDForName:user[@"name"]
                                                handle:user[@"handle"]
                                                avatar:user[@"avatar"]];
    return [fallbackID isEqualToString:userID];
}

+ (NSString *)cleanString:(id)value fallback:(NSString *)fallback {
    if (![value isKindOfClass:NSString.class]) {
        return fallback;
    }

    NSString *trimmedValue = [(NSString *)value stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    return trimmedValue.length > 0 ? trimmedValue : fallback;
}

+ (NSString *)normalizedComponent:(id)value {
    if (![value isKindOfClass:NSString.class]) {
        return @"";
    }

    NSString *trimmedValue = [(NSString *)value stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    return trimmedValue.lowercaseString;
}

+ (NSURL *)storeFileURL {
    NSURL *applicationSupportURL = [NSFileManager.defaultManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask].firstObject;
    NSURL *directoryURL = [applicationSupportURL URLByAppendingPathComponent:@"Profile" isDirectory:YES];
    [NSFileManager.defaultManager createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:nil];
    return [directoryURL URLByAppendingPathComponent:[self storeFileName]];
}

+ (NSString *)sentUsersDefaultsKey {
    return [NSString stringWithFormat:@"%@.%@", kFriendRequestSentUsersDefaultsKey, [self accountSuffix]];
}

+ (NSString *)storeFileName {
    return [NSString stringWithFormat:@"%@_%@", [self accountSuffix], kFriendRequestStoreFileName];
}

+ (NSString *)accountSuffix {
    NSString *email = [[UserSession currentEmail] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet].lowercaseString;
    if (email.length == 0) {
        return @"anonymous";
    }

    NSMutableString *suffix = [NSMutableString string];
    NSCharacterSet *allowedCharacters = NSCharacterSet.alphanumericCharacterSet;
    for (NSUInteger index = 0; index < email.length; index++) {
        unichar character = [email characterAtIndex:index];
        [suffix appendString:[allowedCharacters characterIsMember:character] ? [NSString stringWithFormat:@"%C", character] : @"_"];
    }
    return suffix.length > 0 ? suffix : @"anonymous";
}

+ (NSArray<NSDictionary *> *)readSentUsersFromDisk {
    NSData *data = [NSData dataWithContentsOfURL:[self storeFileURL]];
    if (data.length == 0) {
        return @[];
    }

    id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return [self sanitizedUsersFromObject:object];
}

+ (void)writeSentUsersToDisk:(NSArray<NSDictionary *> *)users {
    NSData *data = [NSJSONSerialization dataWithJSONObject:users options:0 error:nil];
    if (data.length == 0) {
        return;
    }

    [data writeToURL:[self storeFileURL] atomically:YES];
}

@end
