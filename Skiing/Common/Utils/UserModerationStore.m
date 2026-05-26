//
//  UserModerationStore.m
//  Skiing
//

#import "UserModerationStore.h"

NSString * const UserModerationStoreBlockedUsersDidChangeNotification = @"UserModerationStoreBlockedUsersDidChangeNotification";

static NSString * const kUserModerationBlockedUsersDefaultsKey = @"kUserProfileBlockedUsersDefaultsKey";
static NSString * const kUserModerationBlockStoreFileName = @"blocked_users.json";

@implementation UserModerationStore

+ (NSArray<NSDictionary *> *)blockedUsers {
    NSArray *storedUsers = [NSUserDefaults.standardUserDefaults objectForKey:kUserModerationBlockedUsersDefaultsKey];
    NSArray<NSDictionary *> *users = [self sanitizedUsersFromObject:storedUsers];
    if (users.count > 0) {
        [self persistBlockedUsers:users notify:NO];
        return users;
    }

    users = [self readBlockedUsersFromDisk];
    if (users.count > 0) {
        [self persistBlockedUsers:users notify:NO];
    }
    return users;
}

+ (NSSet<NSString *> *)blockedUserIDs {
    NSMutableSet<NSString *> *userIDs = [NSMutableSet set];
    for (NSDictionary *user in [self blockedUsers]) {
        NSString *userID = user[@"id"];
        if ([userID isKindOfClass:NSString.class] && userID.length > 0) {
            [userIDs addObject:userID];
        }
    }
    return userIDs.copy;
}

+ (BOOL)isUserBlockedWithName:(NSString *)name handle:(NSString *)handle avatar:(NSString *)avatar {
    NSString *userID = [self userIDForName:name handle:handle avatar:avatar];
    return [[self blockedUserIDs] containsObject:userID];
}

+ (void)blockUserWithName:(NSString *)name handle:(NSString *)handle avatar:(NSString *)avatar {
    NSString *safeName = [name isKindOfClass:NSString.class] && name.length > 0 ? name : @"Unknown";
    NSString *safeHandle = [handle isKindOfClass:NSString.class] ? handle : @"";
    NSString *safeAvatar = [avatar isKindOfClass:NSString.class] && avatar.length > 0 ? avatar : @"avatar_user_01";
    NSString *userID = [self userIDForName:safeName handle:safeHandle avatar:safeAvatar];

    NSMutableArray<NSDictionary *> *users = [[self blockedUsers] mutableCopy];
    NSIndexSet *matchingIndexes = [users indexesOfObjectsPassingTest:^BOOL(NSDictionary *user, NSUInteger idx, BOOL *stop) {
        return [user[@"id"] isEqualToString:userID];
    }];
    if (matchingIndexes.count > 0) {
        [users removeObjectsAtIndexes:matchingIndexes];
    }

    [users addObject:@{@"id": userID,
                       @"name": safeName,
                       @"handle": safeHandle,
                       @"avatar": safeAvatar}];
    [self persistBlockedUsers:users notify:YES];
}

+ (void)removeBlockedUserWithID:(NSString *)userID {
    if (![userID isKindOfClass:NSString.class] || userID.length == 0) {
        return;
    }

    NSMutableArray<NSDictionary *> *users = [[self blockedUsers] mutableCopy];
    NSIndexSet *matchingIndexes = [users indexesOfObjectsPassingTest:^BOOL(NSDictionary *user, NSUInteger idx, BOOL *stop) {
        return [user[@"id"] isEqualToString:userID];
    }];
    if (matchingIndexes.count == 0) {
        return;
    }

    [users removeObjectsAtIndexes:matchingIndexes];
    [self persistBlockedUsers:users notify:YES];
}

+ (NSString *)userIDForName:(NSString *)name handle:(NSString *)handle avatar:(NSString *)avatar {
    NSString *cleanHandle = [self normalizedComponent:handle];
    if (cleanHandle.length > 0) {
        return cleanHandle;
    }

    NSString *cleanName = [self normalizedComponent:name];
    NSString *cleanAvatar = [self normalizedComponent:avatar];
    return [NSString stringWithFormat:@"%@|%@", cleanName, cleanAvatar];
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

        NSDictionary *user = item;
        NSString *name = user[@"name"];
        NSString *handle = user[@"handle"];
        NSString *avatar = user[@"avatar"];
        NSString *userID = user[@"id"];
        if (![name isKindOfClass:NSString.class] || name.length == 0 ||
            ![avatar isKindOfClass:NSString.class] || avatar.length == 0) {
            continue;
        }
        if (![handle isKindOfClass:NSString.class]) {
            handle = @"";
        }
        if (![userID isKindOfClass:NSString.class] || userID.length == 0) {
            userID = [self userIDForName:name handle:handle avatar:avatar];
        }

        [users addObject:@{@"id": userID,
                           @"name": name,
                           @"handle": handle,
                           @"avatar": avatar}];
    }
    return users.copy;
}

+ (void)persistBlockedUsers:(NSArray<NSDictionary *> *)users notify:(BOOL)notify {
    NSArray<NSDictionary *> *sanitizedUsers = [self sanitizedUsersFromObject:users];
    [NSUserDefaults.standardUserDefaults setObject:sanitizedUsers forKey:kUserModerationBlockedUsersDefaultsKey];
    [NSUserDefaults.standardUserDefaults synchronize];
    [self writeBlockedUsersToDisk:sanitizedUsers];

    if (notify) {
        [NSNotificationCenter.defaultCenter postNotificationName:UserModerationStoreBlockedUsersDidChangeNotification object:nil];
    }
}

+ (NSURL *)blockStoreFileURL {
    NSURL *applicationSupportURL = [NSFileManager.defaultManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask].firstObject;
    NSURL *directoryURL = [applicationSupportURL URLByAppendingPathComponent:@"Profile" isDirectory:YES];
    [NSFileManager.defaultManager createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:nil];
    return [directoryURL URLByAppendingPathComponent:kUserModerationBlockStoreFileName];
}

+ (NSArray<NSDictionary *> *)readBlockedUsersFromDisk {
    NSData *data = [NSData dataWithContentsOfURL:[self blockStoreFileURL]];
    if (data.length == 0) {
        return @[];
    }

    id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return [self sanitizedUsersFromObject:object];
}

+ (void)writeBlockedUsersToDisk:(NSArray<NSDictionary *> *)users {
    NSData *data = [NSJSONSerialization dataWithJSONObject:users options:0 error:nil];
    if (data.length == 0) {
        return;
    }

    [data writeToURL:[self blockStoreFileURL] atomically:YES];
}

+ (NSString *)normalizedComponent:(id)value {
    if (![value isKindOfClass:NSString.class]) {
        return @"";
    }

    NSString *trimmedValue = [(NSString *)value stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    return trimmedValue.lowercaseString;
}

@end
