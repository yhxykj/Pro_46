//
//  VideoCell.h
//  Skiing
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoCell : UICollectionViewCell

@property (nonatomic, strong) UIView *profileTapArea;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel  *usernameLabel;
@property (nonatomic, strong) UILabel  *handleLabel;
@property (nonatomic, strong) UILabel  *descLabel;
@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UILabel  *likeCountLabel;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UILabel  *commentCountLabel;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIButton *messageButton;

+ (NSString *)reuseIdentifier;

- (void)playWithURL:(NSURL *)url;
- (void)resume;
- (void)pause;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
