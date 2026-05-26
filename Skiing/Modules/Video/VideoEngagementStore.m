//
//  VideoEngagementStore.m
//  Skiing
//

#import "VideoEngagementStore.h"

static NSString * const kVideoEngagementLikeCountPrefix = @"VideoEngagement.likeCount.";
static NSString * const kVideoEngagementLikedPrefix = @"VideoEngagement.liked.";
static NSString * const kVideoEngagementCommentsPrefix = @"VideoEngagement.comments.";
static NSString * const kVideoEngagementHiddenCommentKeysPrefix = @"VideoEngagement.hiddenCommentKeys.";

@implementation VideoComment

- (instancetype)initWithUsername:(NSString *)username
                         content:(NSString *)content
                      avatarName:(NSString *)avatarName {
    self = [super init];
    if (self) {
        _username = [username copy] ?: @"";
        _content = [content copy] ?: @"";
        _avatarName = [avatarName copy] ?: @"avatar_placeholder";
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary<NSString *, NSString *> *)dictionary {
    return [self initWithUsername:dictionary[@"username"]
                          content:dictionary[@"content"]
                       avatarName:dictionary[@"avatarName"]];
}

- (NSDictionary<NSString *, NSString *> *)dictionaryRepresentation {
    return @{
        @"username": self.username ?: @"",
        @"content": self.content ?: @"",
        @"avatarName": self.avatarName ?: @"avatar_placeholder"
    };
}

@end

@implementation VideoEngagementStore

+ (instancetype)sharedStore {
    static VideoEngagementStore *store;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [[VideoEngagementStore alloc] init];
    });
    return store;
}

- (void)registerVideoWithIdentifier:(NSString *)identifier
                       baseLikeCount:(NSInteger)baseLikeCount
                        seedComments:(NSArray<VideoComment *> *)seedComments {
    if (identifier.length == 0) return;

    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    BOOL shouldSynchronize = NO;
    if (![defaults objectForKey:[self likeCountKeyForIdentifier:identifier]]) {
        [defaults setInteger:MAX(baseLikeCount, 0) forKey:[self likeCountKeyForIdentifier:identifier]];
        shouldSynchronize = YES;
    }

    if (![defaults objectForKey:[self likedKeyForIdentifier:identifier]]) {
        [defaults setBool:NO forKey:[self likedKeyForIdentifier:identifier]];
        shouldSynchronize = YES;
    }

    NSString *commentsKey = [self commentsKeyForIdentifier:identifier];
    NSArray<NSDictionary<NSString *, NSString *> *> *storedComments = [defaults arrayForKey:commentsKey];
    NSMutableArray<NSDictionary<NSString *, NSString *> *> *comments = [NSMutableArray array];
    for (NSDictionary<NSString *, NSString *> *dictionary in storedComments) {
        if (![dictionary isKindOfClass:NSDictionary.class]) continue;
        if ([self isUserCommentDictionary:dictionary]) {
            [comments addObject:dictionary];
        }
    }

    NSSet<NSString *> *hiddenCommentKeys = [self hiddenCommentKeysForIdentifier:identifier];
    for (VideoComment *comment in seedComments) {
        NSDictionary<NSString *, NSString *> *dictionary = [comment dictionaryRepresentation];
        NSString *commentKey = [self commentKeyForDictionary:dictionary];
        if ([hiddenCommentKeys containsObject:commentKey]) {
            continue;
        }
        [comments addObject:dictionary];
    }

    if (!storedComments || ![storedComments isEqualToArray:comments]) {
        [defaults setObject:comments forKey:commentsKey];
        shouldSynchronize = YES;
    }

    if (shouldSynchronize) {
        [defaults synchronize];
    }
}

- (BOOL)isVideoLikedWithIdentifier:(NSString *)identifier {
    return [NSUserDefaults.standardUserDefaults boolForKey:[self likedKeyForIdentifier:identifier]];
}

- (NSInteger)likeCountForVideoIdentifier:(NSString *)identifier {
    return [NSUserDefaults.standardUserDefaults integerForKey:[self likeCountKeyForIdentifier:identifier]];
}

- (NSInteger)toggleLikeForVideoIdentifier:(NSString *)identifier {
    if (identifier.length == 0) return 0;

    BOOL isLiked = [self isVideoLikedWithIdentifier:identifier];
    NSInteger likeCount = [self likeCountForVideoIdentifier:identifier];
    isLiked = !isLiked;
    likeCount += isLiked ? 1 : -1;
    likeCount = MAX(likeCount, 0);

    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    [defaults setBool:isLiked forKey:[self likedKeyForIdentifier:identifier]];
    [defaults setInteger:likeCount forKey:[self likeCountKeyForIdentifier:identifier]];
    [defaults synchronize];

    return likeCount;
}

- (NSArray<VideoComment *> *)commentsForVideoIdentifier:(NSString *)identifier {
    NSArray<NSDictionary<NSString *, NSString *> *> *storedComments =
        [NSUserDefaults.standardUserDefaults arrayForKey:[self commentsKeyForIdentifier:identifier]];

    NSMutableArray<VideoComment *> *comments = [NSMutableArray array];
    for (NSDictionary<NSString *, NSString *> *dictionary in storedComments) {
        if (![dictionary isKindOfClass:NSDictionary.class]) continue;
        [comments addObject:[[VideoComment alloc] initWithDictionary:dictionary]];
    }
    return comments;
}

- (NSInteger)commentCountForVideoIdentifier:(NSString *)identifier {
    return [self commentsForVideoIdentifier:identifier].count;
}

- (VideoComment *)addCommentText:(NSString *)text
                         username:(NSString *)username
                       avatarName:(NSString *)avatarName
               forVideoIdentifier:(NSString *)identifier {
    VideoComment *comment = [[VideoComment alloc] initWithUsername:username
                                                           content:text
                                                        avatarName:avatarName];
    NSMutableArray<NSDictionary<NSString *, NSString *> *> *storedComments =
        [[NSUserDefaults.standardUserDefaults arrayForKey:[self commentsKeyForIdentifier:identifier]] mutableCopy] ?: [NSMutableArray array];
    [storedComments insertObject:[comment dictionaryRepresentation] atIndex:0];
    [NSUserDefaults.standardUserDefaults setObject:storedComments forKey:[self commentsKeyForIdentifier:identifier]];
    [NSUserDefaults.standardUserDefaults synchronize];
    return comment;
}

- (NSInteger)removeCommentAtIndex:(NSInteger)index
                forVideoIdentifier:(NSString *)identifier {
    return [self removeCommentAtIndex:index forVideoIdentifier:identifier recordsHiddenComment:NO];
}

- (NSInteger)reportCommentAtIndex:(NSInteger)index
                forVideoIdentifier:(NSString *)identifier {
    return [self removeCommentAtIndex:index forVideoIdentifier:identifier recordsHiddenComment:YES];
}

- (NSInteger)removeCommentAtIndex:(NSInteger)index
                forVideoIdentifier:(NSString *)identifier
              recordsHiddenComment:(BOOL)recordsHiddenComment {
    if (identifier.length == 0) return [self commentCountForVideoIdentifier:identifier];

    NSMutableArray<NSDictionary<NSString *, NSString *> *> *storedComments =
        [[NSUserDefaults.standardUserDefaults arrayForKey:[self commentsKeyForIdentifier:identifier]] mutableCopy] ?: [NSMutableArray array];
    if (index < 0 || index >= (NSInteger)storedComments.count) {
        return storedComments.count;
    }

    NSDictionary<NSString *, NSString *> *removedComment = storedComments[index];
    if (recordsHiddenComment) {
        [self recordHiddenCommentDictionary:removedComment forIdentifier:identifier];
    }
    [storedComments removeObjectAtIndex:index];
    [NSUserDefaults.standardUserDefaults setObject:storedComments forKey:[self commentsKeyForIdentifier:identifier]];
    [NSUserDefaults.standardUserDefaults synchronize];
    return storedComments.count;
}

- (NSString *)likeCountKeyForIdentifier:(NSString *)identifier {
    return [kVideoEngagementLikeCountPrefix stringByAppendingString:identifier ?: @""];
}

- (NSString *)likedKeyForIdentifier:(NSString *)identifier {
    return [kVideoEngagementLikedPrefix stringByAppendingString:identifier ?: @""];
}

- (NSString *)commentsKeyForIdentifier:(NSString *)identifier {
    return [kVideoEngagementCommentsPrefix stringByAppendingString:identifier ?: @""];
}

- (NSString *)hiddenCommentKeysKeyForIdentifier:(NSString *)identifier {
    return [kVideoEngagementHiddenCommentKeysPrefix stringByAppendingString:identifier ?: @""];
}

- (BOOL)isUserCommentDictionary:(NSDictionary<NSString *, NSString *> *)dictionary {
    NSString *username = dictionary[@"username"];
    return [username isKindOfClass:NSString.class] && [username isEqualToString:@"Me"];
}

- (NSSet<NSString *> *)hiddenCommentKeysForIdentifier:(NSString *)identifier {
    NSArray<NSString *> *storedKeys =
        [NSUserDefaults.standardUserDefaults arrayForKey:[self hiddenCommentKeysKeyForIdentifier:identifier]];
    NSMutableSet<NSString *> *keys = [NSMutableSet set];
    for (NSString *key in storedKeys) {
        if ([key isKindOfClass:NSString.class] && key.length > 0) {
            [keys addObject:key];
        }
    }
    return keys.copy;
}

- (void)recordHiddenCommentDictionary:(NSDictionary<NSString *, NSString *> *)dictionary
                         forIdentifier:(NSString *)identifier {
    NSString *commentKey = [self commentKeyForDictionary:dictionary];
    if (identifier.length == 0 || commentKey.length == 0) return;

    NSString *defaultsKey = [self hiddenCommentKeysKeyForIdentifier:identifier];
    NSMutableArray<NSString *> *storedKeys =
        [[NSUserDefaults.standardUserDefaults arrayForKey:defaultsKey] mutableCopy] ?: [NSMutableArray array];
    if (![storedKeys containsObject:commentKey]) {
        [storedKeys addObject:commentKey];
        [NSUserDefaults.standardUserDefaults setObject:storedKeys.copy forKey:defaultsKey];
    }
}

- (NSString *)commentKeyForDictionary:(NSDictionary<NSString *, NSString *> *)dictionary {
    NSString *username = [self safeCommentString:dictionary[@"username"]];
    NSString *content = [self safeCommentString:dictionary[@"content"]];
    NSString *avatarName = [self safeCommentString:dictionary[@"avatarName"]];
    return [NSString stringWithFormat:@"%@|%@|%@", username, content, avatarName];
}

- (NSString *)safeCommentString:(id)value {
    return [value isKindOfClass:NSString.class] ? value : @"";
}

@end
