//
//  VideoEngagementStore.h
//  Skiing
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoComment : NSObject

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *avatarName;

- (instancetype)initWithUsername:(NSString *)username
                         content:(NSString *)content
                      avatarName:(NSString *)avatarName;

@end

@interface VideoEngagementStore : NSObject

+ (instancetype)sharedStore;

- (void)registerVideoWithIdentifier:(NSString *)identifier
                       baseLikeCount:(NSInteger)baseLikeCount
                        seedComments:(NSArray<VideoComment *> *)seedComments;

- (BOOL)isVideoLikedWithIdentifier:(NSString *)identifier;
- (NSInteger)likeCountForVideoIdentifier:(NSString *)identifier;
- (NSInteger)toggleLikeForVideoIdentifier:(NSString *)identifier;

- (NSArray<VideoComment *> *)commentsForVideoIdentifier:(NSString *)identifier;
- (NSInteger)commentCountForVideoIdentifier:(NSString *)identifier;
- (VideoComment *)addCommentText:(NSString *)text
                         username:(NSString *)username
                       avatarName:(NSString *)avatarName
               forVideoIdentifier:(NSString *)identifier;
- (NSInteger)removeCommentAtIndex:(NSInteger)index
                forVideoIdentifier:(NSString *)identifier;
- (NSInteger)reportCommentAtIndex:(NSInteger)index
                forVideoIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
