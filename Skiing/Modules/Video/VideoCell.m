//
//  VideoCell.m
//  Skiing
//

#import "VideoCell.h"
#import "DesignTokens.h"
#import <AVFoundation/AVFoundation.h>

@interface VideoCell ()
@property (nonatomic, strong) AVPlayer          *player;
@property (nonatomic, strong) AVPlayerLayer     *playerLayer;
@property (nonatomic, strong) id                 loopObserver;
@property (nonatomic, strong) UIView            *playerContainer;
@property (nonatomic, strong) UIView            *gradientMaskView;
@end

@implementation VideoCell

+ (NSString *)reuseIdentifier {
    return @"VideoCell";
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
        [self setupConstraints];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = UIColor.blackColor;
    self.clipsToBounds = YES;

    self.playerContainer = [[UIView alloc] init];
    self.playerContainer.backgroundColor = UIColor.blackColor;
    self.playerContainer.translatesAutoresizingMaskIntoConstraints = NO;

    UIImageView *mask = [[UIImageView alloc] init];
    mask.image = [UIImage imageNamed:@"video_gradient_mask"];
    mask.contentMode = UIViewContentModeScaleToFill;
    mask.translatesAutoresizingMaskIntoConstraints = NO;
    self.gradientMaskView = mask;

    self.profileTapArea = [[UIView alloc] init];
    self.profileTapArea.backgroundColor = UIColor.clearColor;
    self.profileTapArea.userInteractionEnabled = YES;
    self.profileTapArea.translatesAutoresizingMaskIntoConstraints = NO;

    self.avatarView = [[UIImageView alloc] init];
    self.avatarView.contentMode = UIViewContentModeScaleAspectFill;
    self.avatarView.clipsToBounds = YES;
    self.avatarView.layer.cornerRadius = 26.0;
    self.avatarView.layer.borderWidth = 2.0;
    self.avatarView.layer.borderColor = UIColor.whiteColor.CGColor;
    self.avatarView.translatesAutoresizingMaskIntoConstraints = NO;

    self.usernameLabel = [[UILabel alloc] init];
    self.usernameLabel.font = [DesignFonts semibold:15];
    self.usernameLabel.textColor = UIColor.whiteColor;
    self.usernameLabel.translatesAutoresizingMaskIntoConstraints = NO;

    self.handleLabel = [[UILabel alloc] init];
    self.handleLabel.font = [DesignFonts regular:12];
    self.handleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    self.handleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    self.descLabel = [[UILabel alloc] init];
    self.descLabel.font = [DesignFonts regular:13];
    self.descLabel.textColor = UIColor.whiteColor;
    self.descLabel.numberOfLines = 2;
    self.descLabel.translatesAutoresizingMaskIntoConstraints = NO;

    self.messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.messageButton setImage:[UIImage imageNamed:@"btn_message"] forState:UIControlStateNormal];
    self.messageButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.messageButton.translatesAutoresizingMaskIntoConstraints = NO;

    self.likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.likeButton setImage:[UIImage imageNamed:@"ic_like_normal"] forState:UIControlStateNormal];
    [self.likeButton setImage:[UIImage imageNamed:@"ic_like_selected"] forState:UIControlStateSelected];
    self.likeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.likeButton.translatesAutoresizingMaskIntoConstraints = NO;

    self.likeCountLabel = [self makeCountLabel];

    self.commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.commentButton setImage:[UIImage imageNamed:@"ic_comment_normal"] forState:UIControlStateNormal];
    self.commentButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.commentButton.translatesAutoresizingMaskIntoConstraints = NO;

    self.commentCountLabel = [self makeCountLabel];

    self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.shareButton setImage:[UIImage imageNamed:@"ic_like_more"] forState:UIControlStateNormal];
    self.shareButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.shareButton.translatesAutoresizingMaskIntoConstraints = NO;

    [self.contentView addSubview:self.playerContainer];
    [self.contentView addSubview:self.gradientMaskView];
    [self.contentView addSubview:self.profileTapArea];
    [self.contentView addSubview:self.avatarView];
    [self.contentView addSubview:self.usernameLabel];
    [self.contentView addSubview:self.handleLabel];
    [self.contentView addSubview:self.descLabel];
    [self.contentView addSubview:self.messageButton];
    [self.contentView addSubview:self.likeButton];
    [self.contentView addSubview:self.likeCountLabel];
    [self.contentView addSubview:self.commentButton];
    [self.contentView addSubview:self.commentCountLabel];
    [self.contentView addSubview:self.shareButton];
}

- (UILabel *)makeCountLabel {
    UILabel *label = [[UILabel alloc] init];
    label.font = [DesignFonts regular:11];
    label.textColor = UIColor.whiteColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    return label;
}

- (void)setupConstraints {
    CGFloat rightPad  = 12.0;
    CGFloat iconSize  = 36.0;
    CGFloat bottomPad = 164.0;

    [NSLayoutConstraint activateConstraints:@[
        [self.playerContainer.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
        [self.playerContainer.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [self.playerContainer.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        [self.playerContainer.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],

        [self.gradientMaskView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [self.gradientMaskView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        [self.gradientMaskView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
        [self.gradientMaskView.heightAnchor constraintEqualToAnchor:self.contentView.heightAnchor multiplier:0.5],

        // avatarView: 52×52，垂直居中对齐 usernameLabel+handleLabel 组合区域
        [self.avatarView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [self.avatarView.widthAnchor constraintEqualToConstant:52],
        [self.avatarView.heightAnchor constraintEqualToConstant:52],
        [self.avatarView.bottomAnchor constraintEqualToAnchor:self.descLabel.topAnchor constant:-8],

        [self.profileTapArea.leadingAnchor constraintEqualToAnchor:self.avatarView.leadingAnchor],
        [self.profileTapArea.topAnchor constraintEqualToAnchor:self.avatarView.topAnchor],
        [self.profileTapArea.widthAnchor constraintEqualToConstant:230],
        [self.profileTapArea.heightAnchor constraintEqualToAnchor:self.avatarView.heightAnchor],

        [self.descLabel.leadingAnchor constraintEqualToAnchor:self.avatarView.leadingAnchor],
        [self.descLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-64],
        [self.descLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-bottomPad],

        [self.handleLabel.leadingAnchor constraintEqualToAnchor:self.avatarView.trailingAnchor constant:10],
        [self.handleLabel.bottomAnchor constraintEqualToAnchor:self.avatarView.bottomAnchor],

        [self.usernameLabel.leadingAnchor constraintEqualToAnchor:self.avatarView.trailingAnchor constant:10],
        [self.usernameLabel.bottomAnchor constraintEqualToAnchor:self.handleLabel.topAnchor constant:-2],

        [self.messageButton.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [self.messageButton.topAnchor constraintEqualToAnchor:self.descLabel.bottomAnchor constant:12],
        [self.messageButton.heightAnchor constraintEqualToConstant:44],

        [self.likeButton.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-rightPad],
        [self.likeButton.widthAnchor constraintEqualToConstant:iconSize],
        [self.likeButton.heightAnchor constraintEqualToConstant:iconSize],
        [self.likeButton.bottomAnchor constraintEqualToAnchor:self.likeCountLabel.topAnchor constant:-2],

        [self.likeCountLabel.centerXAnchor constraintEqualToAnchor:self.likeButton.centerXAnchor],
        [self.likeCountLabel.bottomAnchor constraintEqualToAnchor:self.commentButton.topAnchor constant:-12],

        [self.commentButton.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-rightPad],
        [self.commentButton.widthAnchor constraintEqualToConstant:iconSize],
        [self.commentButton.heightAnchor constraintEqualToConstant:iconSize],
        [self.commentButton.bottomAnchor constraintEqualToAnchor:self.commentCountLabel.topAnchor constant:-2],

        [self.commentCountLabel.centerXAnchor constraintEqualToAnchor:self.commentButton.centerXAnchor],
        [self.commentCountLabel.bottomAnchor constraintEqualToAnchor:self.shareButton.topAnchor constant:-12],

        [self.shareButton.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-rightPad],
        [self.shareButton.widthAnchor constraintEqualToConstant:iconSize],
        [self.shareButton.heightAnchor constraintEqualToConstant:iconSize],
        [self.shareButton.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-bottomPad + 44],

    ]];
}

#pragma mark - Player Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    self.playerLayer.frame = self.playerContainer.bounds;
}

#pragma mark - Playback

- (void)playWithURL:(NSURL *)url {
    [self stop];

    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    self.player = [AVPlayer playerWithPlayerItem:item];
    self.player.volume = 1.0;

    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.playerLayer.frame = self.playerContainer.bounds;
    [self.playerContainer.layer addSublayer:self.playerLayer];

    __weak typeof(self) weakSelf = self;
    self.loopObserver = [[NSNotificationCenter defaultCenter]
        addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
                    object:item
                     queue:NSOperationQueue.mainQueue
                usingBlock:^(NSNotification *note) {
                    [weakSelf.player seekToTime:kCMTimeZero];
                    [weakSelf.player play];
                }];

    [self.player play];
}

- (void)pause {
    [self.player pause];
}

- (void)resume {
    [self.player play];
}

- (void)stop {
    [self.player pause];
    if (self.loopObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.loopObserver];
        self.loopObserver = nil;
    }
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
    self.player = nil;
}

#pragma mark - Reuse

- (void)prepareForReuse {
    [super prepareForReuse];
    [self stop];
    self.likeButton.selected = NO;
    self.avatarView.image = nil;
    self.usernameLabel.text = nil;
    self.handleLabel.text = nil;
    self.descLabel.text = nil;
    self.likeCountLabel.text = nil;
    self.commentCountLabel.text = nil;
}

@end
