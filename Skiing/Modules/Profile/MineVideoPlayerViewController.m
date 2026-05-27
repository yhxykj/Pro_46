//
//  MineVideoPlayerViewController.m
//  Skiing
//

#import "MineVideoPlayerViewController.h"
#import "DesignTokens.h"
#import <AVFoundation/AVFoundation.h>

@interface MineVideoPlayerViewController ()
@property (nonatomic, strong) UIView *playerContainerView;
@property (nonatomic, strong) UIImageView *posterImageView;
@property (nonatomic, strong) UIView *bottomGradientView;
@property (nonatomic, strong) CAGradientLayer *bottomGradientLayer;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) id loopObserver;
@end

@implementation MineVideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    [self setupViews];
    [self setupPlayer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.player play];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.player pause];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.playerLayer.frame = self.playerContainerView.bounds;
    self.bottomGradientLayer.frame = self.bottomGradientView.bounds;
}

- (void)dealloc {
    if (self.loopObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.loopObserver];
        self.loopObserver = nil;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDarkContent;
}

#pragma mark - Setup

- (void)setupViews {
    NSString *videoName = [self resolvedVideoFileName];
    UIView *bottomPanel = [[UIView alloc] init];
    bottomPanel.backgroundColor = UIColor.whiteColor;
    bottomPanel.translatesAutoresizingMaskIntoConstraints = NO;

    self.playerContainerView = [[UIView alloc] init];
    self.playerContainerView.backgroundColor = UIColor.blackColor;
    self.playerContainerView.clipsToBounds = YES;
    self.playerContainerView.translatesAutoresizingMaskIntoConstraints = NO;

    self.posterImageView = [[UIImageView alloc] initWithImage:[self thumbnailForVideoNamed:videoName]];
    self.posterImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.posterImageView.translatesAutoresizingMaskIntoConstraints = NO;

    self.bottomGradientView = [[UIView alloc] init];
    self.bottomGradientView.translatesAutoresizingMaskIntoConstraints = NO;
    self.bottomGradientView.userInteractionEnabled = NO;
    self.bottomGradientLayer = [CAGradientLayer layer];
    self.bottomGradientLayer.colors = @[
        (__bridge id)[UIColor colorWithWhite:0 alpha:0.0].CGColor,
        (__bridge id)[UIColor colorWithWhite:0 alpha:0.62].CGColor
    ];
    self.bottomGradientLayer.startPoint = CGPointMake(0.5, 0.0);
    self.bottomGradientLayer.endPoint = CGPointMake(0.5, 1.0);
    [self.bottomGradientView.layer addSublayer:self.bottomGradientLayer];

    UIImageView *avatarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self resolvedAvatarName]]];
    avatarView.contentMode = UIViewContentModeScaleAspectFill;
    avatarView.clipsToBounds = YES;
    avatarView.layer.cornerRadius = 26.0;
    avatarView.layer.borderWidth = 2.0;
    avatarView.layer.borderColor = UIColor.whiteColor.CGColor;
    avatarView.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *nameLabel = [self labelWithText:[self resolvedUsername]
                                        font:[DesignFonts semibold:20]
                                       color:UIColor.whiteColor];
    UILabel *timeLabel = [self labelWithText:@"9:00pm"
                                        font:[DesignFonts regular:15]
                                       color:[UIColor colorWithWhite:1.0 alpha:0.86]];
    UILabel *descLabel = [self labelWithText:[self resolvedDescription]
                                        font:[DesignFonts regular:17]
                                       color:UIColor.whiteColor];
    descLabel.numberOfLines = 2;

    UIView *likeStack = [self actionStackWithImageName:@"ic_like_normal" count:[self resolvedLikeCount]];
    UIView *commentStack = [self actionStackWithImageName:@"ic_comment_normal" count:[self resolvedCommentCount]];

    UIImageView *viewsIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mine_video_views_icon"]];
    viewsIconView.contentMode = UIViewContentModeScaleAspectFit;
    viewsIconView.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *viewsLabel = [self labelWithText:[self resolvedViewCount]
                                         font:[DesignFonts regular:15]
                                        color:[UIColor colorWithWhite:0.64 alpha:1.0]];

    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setImage:[UIImage imageNamed:@"mine_video_delete_button"] forState:UIControlStateNormal];
    deleteButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    deleteButton.translatesAutoresizingMaskIntoConstraints = NO;

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
    backButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [backButton addTarget:self action:@selector(didTapBackButton) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.playerContainerView];
    [self.view addSubview:bottomPanel];
    [self.playerContainerView addSubview:self.posterImageView];
    [self.playerContainerView addSubview:self.bottomGradientView];
    [self.playerContainerView addSubview:backButton];
    [self.playerContainerView addSubview:avatarView];
    [self.playerContainerView addSubview:nameLabel];
    [self.playerContainerView addSubview:timeLabel];
    [self.playerContainerView addSubview:descLabel];
    [self.playerContainerView addSubview:likeStack];
    [self.playerContainerView addSubview:commentStack];
    [bottomPanel addSubview:viewsIconView];
    [bottomPanel addSubview:viewsLabel];
    [bottomPanel addSubview:deleteButton];

    [NSLayoutConstraint activateConstraints:@[
        [bottomPanel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [bottomPanel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [bottomPanel.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [bottomPanel.heightAnchor constraintEqualToConstant:118],

        [self.playerContainerView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.playerContainerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.playerContainerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.playerContainerView.bottomAnchor constraintEqualToAnchor:bottomPanel.topAnchor],

        [self.posterImageView.topAnchor constraintEqualToAnchor:self.playerContainerView.topAnchor],
        [self.posterImageView.leadingAnchor constraintEqualToAnchor:self.playerContainerView.leadingAnchor],
        [self.posterImageView.trailingAnchor constraintEqualToAnchor:self.playerContainerView.trailingAnchor],
        [self.posterImageView.bottomAnchor constraintEqualToAnchor:self.playerContainerView.bottomAnchor],

        [self.bottomGradientView.leadingAnchor constraintEqualToAnchor:self.playerContainerView.leadingAnchor],
        [self.bottomGradientView.trailingAnchor constraintEqualToAnchor:self.playerContainerView.trailingAnchor],
        [self.bottomGradientView.bottomAnchor constraintEqualToAnchor:self.playerContainerView.bottomAnchor],
        [self.bottomGradientView.heightAnchor constraintEqualToAnchor:self.playerContainerView.heightAnchor multiplier:0.42],

        [backButton.leadingAnchor constraintEqualToAnchor:self.playerContainerView.leadingAnchor constant:16],
        [backButton.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:12],
        [backButton.widthAnchor constraintEqualToConstant:44],
        [backButton.heightAnchor constraintEqualToConstant:44],

        [likeStack.leadingAnchor constraintEqualToAnchor:self.playerContainerView.leadingAnchor constant:18],
        [likeStack.bottomAnchor constraintEqualToAnchor:self.playerContainerView.bottomAnchor constant:-18],
        [likeStack.widthAnchor constraintEqualToConstant:42],
        [likeStack.heightAnchor constraintEqualToConstant:62],

        [commentStack.leadingAnchor constraintEqualToAnchor:likeStack.trailingAnchor constant:34],
        [commentStack.centerYAnchor constraintEqualToAnchor:likeStack.centerYAnchor],
        [commentStack.widthAnchor constraintEqualToConstant:42],
        [commentStack.heightAnchor constraintEqualToConstant:62],

        [descLabel.leadingAnchor constraintEqualToAnchor:self.playerContainerView.leadingAnchor constant:18],
        [descLabel.trailingAnchor constraintEqualToAnchor:self.playerContainerView.trailingAnchor constant:-18],
        [descLabel.bottomAnchor constraintEqualToAnchor:likeStack.topAnchor constant:-22],

        [avatarView.leadingAnchor constraintEqualToAnchor:self.playerContainerView.leadingAnchor constant:18],
        [avatarView.bottomAnchor constraintEqualToAnchor:descLabel.topAnchor constant:-28],
        [avatarView.widthAnchor constraintEqualToConstant:52],
        [avatarView.heightAnchor constraintEqualToConstant:52],

        [nameLabel.leadingAnchor constraintEqualToAnchor:avatarView.trailingAnchor constant:10],
        [nameLabel.topAnchor constraintEqualToAnchor:avatarView.topAnchor constant:4],
        [nameLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.playerContainerView.trailingAnchor constant:-18],

        [timeLabel.leadingAnchor constraintEqualToAnchor:nameLabel.leadingAnchor],
        [timeLabel.topAnchor constraintEqualToAnchor:nameLabel.bottomAnchor constant:4],
        [timeLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.playerContainerView.trailingAnchor constant:-18],

        [viewsIconView.leadingAnchor constraintEqualToAnchor:bottomPanel.leadingAnchor constant:22],
        [viewsIconView.topAnchor constraintEqualToAnchor:bottomPanel.topAnchor constant:25],
        [viewsIconView.widthAnchor constraintEqualToConstant:20],
        [viewsIconView.heightAnchor constraintEqualToConstant:20],

        [viewsLabel.leadingAnchor constraintEqualToAnchor:viewsIconView.trailingAnchor constant:10],
        [viewsLabel.centerYAnchor constraintEqualToAnchor:viewsIconView.centerYAnchor],

        [deleteButton.trailingAnchor constraintEqualToAnchor:bottomPanel.trailingAnchor constant:-24],
        [deleteButton.centerYAnchor constraintEqualToAnchor:viewsIconView.centerYAnchor],
        [deleteButton.widthAnchor constraintEqualToConstant:28],
        [deleteButton.heightAnchor constraintEqualToConstant:28],
    ]];
}

- (void)didTapBackButton {
    if (self.navigationController && self.navigationController.viewControllers.firstObject != self) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupPlayer {
    NSString *path = [[NSBundle mainBundle] pathForResource:[self resolvedVideoFileName] ofType:@"mp4"];
    if (!path) return;

    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:path]];
    self.player = [AVPlayer playerWithPlayerItem:item];
    self.player.volume = 1.0;

    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.playerContainerView.layer insertSublayer:self.playerLayer above:self.posterImageView.layer];

    __weak typeof(self) weakSelf = self;
    self.loopObserver = [[NSNotificationCenter defaultCenter]
        addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
                    object:item
                     queue:NSOperationQueue.mainQueue
                usingBlock:^(NSNotification *note) {
                    [weakSelf.player seekToTime:kCMTimeZero];
                    [weakSelf.player play];
                }];
}

#pragma mark - Components

- (NSString *)resolvedVideoFileName {
    return self.videoFileName.length > 0 ? self.videoFileName : @"video_lifestyle_05";
}

- (NSString *)resolvedUsername {
    return self.username.length > 0 ? self.username : @"GardenDream";
}

- (NSString *)resolvedAvatarName {
    return self.avatarName.length > 0 ? self.avatarName : @"avatar_user_12";
}

- (NSString *)resolvedDescription {
    return self.desc.length > 0 ? self.desc : @"Dreamy garden wedding inspiration for your next board";
}

- (NSString *)resolvedLikeCount {
    return self.likeCount.length > 0 ? self.likeCount : @"521";
}

- (NSString *)resolvedCommentCount {
    return self.commentCount.length > 0 ? self.commentCount : @"2";
}

- (NSString *)resolvedViewCount {
    return self.viewCount.length > 0 ? self.viewCount : @"3399";
}

- (UILabel *)labelWithText:(NSString *)text font:(UIFont *)font color:(UIColor *)color {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = font;
    label.textColor = color;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    return label;
}

- (UIView *)actionStackWithImageName:(NSString *)imageName count:(NSString *)count {
    UIView *view = [[UIView alloc] init];
    view.translatesAutoresizingMaskIntoConstraints = NO;

    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *countLabel = [self labelWithText:count
                                         font:[DesignFonts regular:13]
                                        color:UIColor.whiteColor];
    countLabel.textAlignment = NSTextAlignmentCenter;

    [view addSubview:iconView];
    [view addSubview:countLabel];

    [NSLayoutConstraint activateConstraints:@[
        [iconView.topAnchor constraintEqualToAnchor:view.topAnchor],
        [iconView.centerXAnchor constraintEqualToAnchor:view.centerXAnchor],
        [iconView.widthAnchor constraintEqualToConstant:36],
        [iconView.heightAnchor constraintEqualToConstant:36],

        [countLabel.topAnchor constraintEqualToAnchor:iconView.bottomAnchor constant:5],
        [countLabel.centerXAnchor constraintEqualToAnchor:view.centerXAnchor],
        [countLabel.leadingAnchor constraintEqualToAnchor:view.leadingAnchor],
        [countLabel.trailingAnchor constraintEqualToAnchor:view.trailingAnchor],
    ]];

    return view;
}

#pragma mark - Helpers

- (UIImage *)thumbnailForVideoNamed:(NSString *)videoName {
    NSString *path = [[NSBundle mainBundle] pathForResource:videoName ofType:@"mp4"];
    if (!path) return nil;

    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:path] options:nil];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    generator.maximumSize = CGSizeMake(640, 960);

    NSError *error = nil;
    CGImageRef imageRef = [generator copyCGImageAtTime:CMTimeMakeWithSeconds(0.8, 600)
                                            actualTime:nil
                                                 error:&error];
    if (!imageRef || error) return nil;

    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return image;
}

@end
