//
//  FriendshipStore.m
//  Skiing
//

#import "FriendshipStore.h"
#import "UserSession.h"

static NSString * const kFriendshipStoreFriendsDefaultsKey = @"kFriendshipStoreFriendsDefaultsKey";
static NSString * const kFriendshipStoreSeededDefaultsKey = @"kFriendshipStoreSeededV1";
static NSString * const kFriendshipStoreFileName = @"friends.json";
static NSString * const kFriendshipStoreTestAccountEmail = @"skiing666@gmail.com";

@implementation FriendshipStore

+ (NSArray<NSDictionary *> *)friends {
    [self seedFriendsIfNeeded];

    NSArray *storedFriends = [NSUserDefaults.standardUserDefaults objectForKey:[self friendsDefaultsKey]];
    NSArray<NSDictionary *> *friends = [self sanitizedFriendsFromObject:storedFriends];
    if (friends.count > 0) {
        [self persistFriends:friends];
        return friends;
    }

    friends = [self readFriendsFromDisk];
    if (friends.count > 0) {
        [NSUserDefaults.standardUserDefaults setObject:friends forKey:[self friendsDefaultsKey]];
        [NSUserDefaults.standardUserDefaults synchronize];
    }
    return friends;
}

+ (BOOL)isFriendWithName:(NSString *)name
                  handle:(NSString *)handle
                  avatar:(NSString *)avatar {
    NSString *friendID = [self friendIDForName:name handle:handle avatar:avatar];
    for (NSDictionary *friend in [self friends]) {
        if ([self friend:friend matchesID:friendID]) {
            return YES;
        }
    }
    return NO;
}

+ (void)addFriendWithName:(NSString *)name
                   handle:(NSString *)handle
                   avatar:(NSString *)avatar {
    NSString *cleanName = [self cleanString:name fallback:@"Unknown"];
    NSString *cleanHandle = [self cleanString:handle fallback:@""];
    NSString *cleanAvatar = [self cleanString:avatar fallback:@"avatar_placeholder"];
    NSString *friendID = [self friendIDForName:cleanName handle:cleanHandle avatar:cleanAvatar];

    NSMutableArray<NSDictionary *> *friends = [[self friends] mutableCopy];
    NSIndexSet *matchingIndexes = [friends indexesOfObjectsPassingTest:^BOOL(NSDictionary *friend, NSUInteger idx, BOOL *stop) {
        return [self friend:friend matchesID:friendID];
    }];
    if (matchingIndexes.count > 0) {
        [friends removeObjectsAtIndexes:matchingIndexes];
    }

    [friends addObject:@{@"id": friendID,
                         @"name": cleanName,
                         @"handle": cleanHandle,
                         @"avatar": cleanAvatar}];
    [self persistFriends:friends];
}

+ (NSArray<NSDictionary *> *)presetFriends {
    return @[
        @{@"id": @"@mila", @"name": @"Mila", @"handle": @"@mila", @"avatar": @"avatar_user_03"},
        @{@"id": @"@kevin", @"name": @"Kevin", @"handle": @"@kevin", @"avatar": @"avatar_user_04"}
    ];
}

+ (void)seedFriendsIfNeeded {
    if (![self isTestAccount]) {
        return;
    }

    if ([NSUserDefaults.standardUserDefaults boolForKey:[self seededDefaultsKey]]) {
        return;
    }

    NSArray<NSDictionary *> *friends = [self presetFriends];
    [NSUserDefaults.standardUserDefaults setObject:friends forKey:[self friendsDefaultsKey]];
    [NSUserDefaults.standardUserDefaults setBool:YES forKey:[self seededDefaultsKey]];
    [NSUserDefaults.standardUserDefaults synchronize];
    [self writeFriendsToDisk:friends];
}

+ (void)persistFriends:(NSArray<NSDictionary *> *)friends {
    NSArray<NSDictionary *> *sanitizedFriends = [self sanitizedFriendsFromObject:friends];
    [NSUserDefaults.standardUserDefaults setObject:sanitizedFriends forKey:[self friendsDefaultsKey]];
    [NSUserDefaults.standardUserDefaults synchronize];
    [self writeFriendsToDisk:sanitizedFriends];
}

+ (NSArray<NSDictionary *> *)sanitizedFriendsFromObject:(id)object {
    if (![object isKindOfClass:NSArray.class]) {
        return @[];
    }

    NSMutableArray<NSDictionary *> *friends = [NSMutableArray array];
    for (id item in (NSArray *)object) {
        if (![item isKindOfClass:NSDictionary.class]) {
            continue;
        }

        NSDictionary *friend = (NSDictionary *)item;
        NSString *name = friend[@"name"];
        NSString *handle = friend[@"handle"];
        NSString *avatar = friend[@"avatar"];
        if (![name isKindOfClass:NSString.class] || name.length == 0 ||
            ![avatar isKindOfClass:NSString.class] || avatar.length == 0) {
            continue;
        }

        NSString *cleanHandle = [handle isKindOfClass:NSString.class] ? handle : @"";
        NSString *friendID = friend[@"id"];
        if (![friendID isKindOfClass:NSString.class] || friendID.length == 0) {
            friendID = [self friendIDForName:name handle:cleanHandle avatar:avatar];
        }

        [friends addObject:@{@"id": friendID,
                             @"name": name,
                             @"handle": cleanHandle,
                             @"avatar": avatar}];
    }

    return friends.copy;
}

+ (BOOL)friend:(NSDictionary *)friend matchesID:(NSString *)friendID {
    NSString *storedID = friend[@"id"];
    if ([storedID isKindOfClass:NSString.class] && [storedID isEqualToString:friendID]) {
        return YES;
    }

    NSString *fallbackID = [self friendIDForName:friend[@"name"]
                                         handle:friend[@"handle"]
                                         avatar:friend[@"avatar"]];
    return [fallbackID isEqualToString:friendID];
}

+ (NSString *)friendIDForName:(NSString *)name
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

+ (BOOL)isTestAccount {
    return [[[UserSession currentEmail] lowercaseString] isEqualToString:kFriendshipStoreTestAccountEmail];
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

+ (NSString *)friendsDefaultsKey {
    return [NSString stringWithFormat:@"%@.%@", kFriendshipStoreFriendsDefaultsKey, [self accountSuffix]];
}

+ (NSString *)seededDefaultsKey {
    return [NSString stringWithFormat:@"%@.%@", kFriendshipStoreSeededDefaultsKey, [self accountSuffix]];
}

+ (NSString *)storeFileName {
    return [NSString stringWithFormat:@"%@_%@", [self accountSuffix], kFriendshipStoreFileName];
}

+ (NSArray<NSDictionary *> *)readFriendsFromDisk {
    NSData *data = [NSData dataWithContentsOfURL:[self storeFileURL]];
    if (data.length == 0) {
        return @[];
    }

    id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return [self sanitizedFriendsFromObject:object];
}

+ (void)writeFriendsToDisk:(NSArray<NSDictionary *> *)friends {
    NSData *data = [NSJSONSerialization dataWithJSONObject:friends options:0 error:nil];
    if (data.length == 0) {
        return;
    }

    [data writeToURL:[self storeFileURL] atomically:YES];
}

@end
