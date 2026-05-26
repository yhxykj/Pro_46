//
//  ProfileViewController.m
//  Skiing
//

#import "ProfileViewController.h"
#import "EditProfileViewController.h"
#import "MineVideoPlayerViewController.h"
#import "ProfileRelationshipListViewController.h"
#import "RechargeViewController.h"
#import "SettingsViewController.h"
#import "CoinBalanceStore.h"
#import "EmptyStateView.h"
#import "DesignTokens.h"
#import <AVFoundation/AVFoundation.h>

static CGFloat const kMineSidePadding = 16.0;
static NSString * const kTestAccountPostVideoFileName = @"video_lifestyle_05";
static NSString * const kTestAccountPostDescription = @"Dreamy garden wedding inspiration for your next board";
static NSString * const kTestAccountPostLikeCount = @"521";
static NSString * const kTestAccountPostCommentCount = @"2";
static NSString * const kTestAccountPostViewCount = @"3399";

@interface ProfileViewController ()
@property (nonatomic, strong) CAGradientLayer *backgroundGradientLayer;
@property (nonatomic, strong) UIImage *postImage;
@property (nonatomic, copy) NSArray<UIImage *> *postImages;
@property (nonatomic, strong) EmptyStateView *postsEmptyStateView;
@property (nonatomic, strong) UILabel *coinsValueLabel;
@property (nonatomic, strong) UILabel *followingValueLabel;
@property (nonatomic, strong) UILabel *followersValueLabel;
@property (nonatomic, strong) UILabel *friendsValueLabel;
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.74 green:0.77 blue:1.0 alpha:1.0];
    self.postImage = [self thumbnailForVideoNamed:kTestAccountPostVideoFileName] ?: [UIImage imageNamed:@"explore_mountain_header"];
    self.postImages = self.postImage ? @[self.postImage] : @[];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(updateCoinBalance)
                                               name:CoinBalanceStoreDidChangeNotification
                                             object:nil];
    [self setupBackground];
    [self setupContent];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self updateCoinBalance];
    [self updateRelationshipCounts];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.backgroundGradientLayer.frame = self.view.bounds;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDarkContent;
}

#pragma mark - Setup

- (void)setupBackground {
    self.backgroundGradientLayer = [CAGradientLayer layer];
    self.backgroundGradientLayer.colors = @[
        (__bridge id)[UIColor colorWithRed:0.55 green:0.59 blue:0.94 alpha:1.0].CGColor,
        (__bridge id)[UIColor colorWithRed:0.76 green:0.78 blue:1.0 alpha:1.0].CGColor
    ];
    self.backgroundGradientLayer.startPoint = CGPointMake(0.5, 0.0);
    self.backgroundGradientLayer.endPoint = CGPointMake(0.5, 1.0);
    [self.view.layer insertSublayer:self.backgroundGradientLayer atIndex:0];
}

- (void)setupContent {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.backgroundColor = UIColor.clearColor;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;

    UIView *contentView = [[UIView alloc] init];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:scrollView];
    [scrollView addSubview:contentView];

    UIImageView *titleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mine_profile_title"]];
    titleImageView.contentMode = UIViewContentModeScaleAspectFit;
    titleImageView.translatesAutoresizingMaskIntoConstraints = NO;

    UIButton *editButton = [self imageButtonWithName:@"mine_edit_profile_button"];
    [editButton addTarget:self action:@selector(didTapEditProfile) forControlEvents:UIControlEventTouchUpInside];
    UIButton *settingsButton = [self imageButtonWithName:@"mine_settings_button"];
    [settingsButton addTarget:self action:@selector(didTapSettingsButton) forControlEvents:UIControlEventTouchUpInside];

    UIView *profileCard = [[UIView alloc] init];
    profileCard.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.42];
    profileCard.layer.cornerRadius = 20.0;
    profileCard.translatesAutoresizingMaskIntoConstraints = NO;

    UIImageView *avatarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatar_user_01"]];
    avatarView.contentMode = UIViewContentModeScaleAspectFill;
    avatarView.clipsToBounds = YES;
    avatarView.layer.cornerRadius = 44.0;
    avatarView.layer.borderWidth = 2.0;
    avatarView.layer.borderColor = UIColor.whiteColor.CGColor;
    avatarView.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *nameLabel = [self labelWithText:@"Gaston"
                                        font:[DesignFonts semibold:21]
                                       color:[UIColor colorWithRed:0.18 green:0.18 blue:0.23 alpha:1.0]];
    UILabel *handleLabel = [self labelWithText:@"@279jsof895"
                                          font:[DesignFonts regular:15]
                                         color:[UIColor colorWithRed:0.39 green:0.39 blue:0.50 alpha:1.0]];

    UIStackView *statsStack = [[UIStackView alloc] init];
    statsStack.axis = UILayoutConstraintAxisHorizontal;
    statsStack.distribution = UIStackViewDistributionEqualSpacing;
    statsStack.translatesAutoresizingMaskIntoConstraints = NO;
    UIControl *followingStatView = [self statViewWithValue:[self relationshipCountTextForTitle:@"Following"] title:@"Following"];
    [followingStatView addTarget:self action:@selector(didTapFollowingStat) forControlEvents:UIControlEventTouchUpInside];
    UIControl *followersStatView = [self statViewWithValue:[self relationshipCountTextForTitle:@"Followers"] title:@"Followers"];
    [followersStatView addTarget:self action:@selector(didTapFollowersStat) forControlEvents:UIControlEventTouchUpInside];
    UIControl *friendsStatView = [self statViewWithValue:[self relationshipCountTextForTitle:@"Friends"] title:@"Friends"];
    [friendsStatView addTarget:self action:@selector(didTapFriendsStat) forControlEvents:UIControlEventTouchUpInside];
    [statsStack addArrangedSubview:followingStatView];
    [statsStack addArrangedSubview:followersStatView];
    [statsStack addArrangedSubview:friendsStatView];

    UIImageView *coinCardImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mine_coin_card"]];
    coinCardImageView.contentMode = UIViewContentModeScaleToFill;
    coinCardImageView.userInteractionEnabled = YES;
    coinCardImageView.translatesAutoresizingMaskIntoConstraints = NO;
    UITapGestureRecognizer *coinCardTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapCoinCard)];
    [coinCardImageView addGestureRecognizer:coinCardTapGesture];

    UILabel *coinsTitleLabel = [self labelWithText:@"My coins"
                                              font:[DesignFonts regular:17]
                                             color:[UIColor colorWithRed:0.23 green:0.23 blue:0.27 alpha:1.0]];
    self.coinsValueLabel = [self labelWithText:[NSString stringWithFormat:@"%ld", (long)[CoinBalanceStore currentBalance]]
                                          font:[DesignFonts semibold:20]
                                         color:[UIColor colorWithRed:0.19 green:0.19 blue:0.22 alpha:1.0]];

    NSInteger displayedPostCount = self.postImages.count;
    UILabel *postLabel = [self labelWithText:[NSString stringWithFormat:@"My post(%ld)", (long)displayedPostCount]
                                        font:[DesignFonts semibold:17]
                                       color:[UIColor colorWithRed:0.16 green:0.16 blue:0.22 alpha:1.0]];

    UIView *gridView = [[UIView alloc] init];
    gridView.translatesAutoresizingMaskIntoConstraints = NO;

    [contentView addSubview:titleImageView];
    [contentView addSubview:editButton];
    [contentView addSubview:settingsButton];
    [contentView addSubview:profileCard];
    [profileCard addSubview:avatarView];
    [profileCard addSubview:nameLabel];
    [profileCard addSubview:handleLabel];
    [profileCard addSubview:statsStack];
    [contentView addSubview:coinCardImageView];
    [coinCardImageView addSubview:coinsTitleLabel];
    [coinCardImageView addSubview:self.coinsValueLabel];
    [contentView addSubview:postLabel];
    [contentView addSubview:gridView];

    NSMutableArray<UIView *> *postTiles = [NSMutableArray array];
    NSInteger visiblePostCount = MIN(self.postImages.count, 4);
    for (NSInteger index = 0; index < visiblePostCount; index++) {
        UIView *tile = [self postTileView];
        [gridView addSubview:tile];
        [postTiles addObject:tile];
    }
    self.postsEmptyStateView = [[EmptyStateView alloc] initWithText:@"No data available"];
    self.postsEmptyStateView.contentCenterYOffset = -4.0;
    self.postsEmptyStateView.hidden = visiblePostCount > 0;
    [gridView addSubview:self.postsEmptyStateView];

    CGFloat tileSpacing = 16.0;

    [NSLayoutConstraint activateConstraints:@[
        [scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [contentView.topAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.topAnchor],
        [contentView.leadingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.leadingAnchor],
        [contentView.trailingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.trailingAnchor],
        [contentView.bottomAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.bottomAnchor],
        [contentView.widthAnchor constraintEqualToAnchor:scrollView.frameLayoutGuide.widthAnchor],

        [titleImageView.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:kMineSidePadding],
        [titleImageView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:12],
        [titleImageView.widthAnchor constraintEqualToConstant:101],
        [titleImageView.heightAnchor constraintEqualToConstant:18],

        [settingsButton.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-kMineSidePadding],
        [settingsButton.centerYAnchor constraintEqualToAnchor:titleImageView.centerYAnchor],
        [settingsButton.widthAnchor constraintEqualToConstant:32],
        [settingsButton.heightAnchor constraintEqualToConstant:32],

        [editButton.trailingAnchor constraintEqualToAnchor:settingsButton.leadingAnchor constant:-14],
        [editButton.centerYAnchor constraintEqualToAnchor:settingsButton.centerYAnchor],
        [editButton.widthAnchor constraintEqualToConstant:77],
        [editButton.heightAnchor constraintEqualToConstant:32],

        [profileCard.topAnchor constraintEqualToAnchor:titleImageView.bottomAnchor constant:30],
        [profileCard.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:kMineSidePadding],
        [profileCard.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-kMineSidePadding],
        [profileCard.heightAnchor constraintEqualToConstant:171],

        [avatarView.leadingAnchor constraintEqualToAnchor:profileCard.leadingAnchor constant:16],
        [avatarView.topAnchor constraintEqualToAnchor:profileCard.topAnchor constant:16],
        [avatarView.widthAnchor constraintEqualToConstant:88],
        [avatarView.heightAnchor constraintEqualToConstant:88],

        [nameLabel.leadingAnchor constraintEqualToAnchor:avatarView.trailingAnchor constant:12],
        [nameLabel.topAnchor constraintEqualToAnchor:profileCard.topAnchor constant:36],
        [nameLabel.trailingAnchor constraintLessThanOrEqualToAnchor:profileCard.trailingAnchor constant:-16],

        [handleLabel.leadingAnchor constraintEqualToAnchor:nameLabel.leadingAnchor],
        [handleLabel.topAnchor constraintEqualToAnchor:nameLabel.bottomAnchor constant:8],
        [handleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:profileCard.trailingAnchor constant:-16],

        [statsStack.leadingAnchor constraintEqualToAnchor:profileCard.leadingAnchor constant:13],
        [statsStack.trailingAnchor constraintEqualToAnchor:profileCard.trailingAnchor constant:-42],
        [statsStack.bottomAnchor constraintEqualToAnchor:profileCard.bottomAnchor constant:-20],
        [statsStack.heightAnchor constraintEqualToConstant:42],

        [coinCardImageView.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:kMineSidePadding],
        [coinCardImageView.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-kMineSidePadding],
        [coinCardImageView.topAnchor constraintEqualToAnchor:profileCard.bottomAnchor constant:20],
        [coinCardImageView.heightAnchor constraintEqualToConstant:98],

        [coinsTitleLabel.leadingAnchor constraintEqualToAnchor:coinCardImageView.leadingAnchor constant:24],
        [coinsTitleLabel.topAnchor constraintEqualToAnchor:coinCardImageView.topAnchor constant:23],
        [coinsTitleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:coinCardImageView.trailingAnchor constant:-150],

        [self.coinsValueLabel.leadingAnchor constraintEqualToAnchor:coinsTitleLabel.leadingAnchor],
        [self.coinsValueLabel.topAnchor constraintEqualToAnchor:coinsTitleLabel.bottomAnchor constant:8],

        [postLabel.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:kMineSidePadding],
        [postLabel.topAnchor constraintEqualToAnchor:coinCardImageView.bottomAnchor constant:30],

        [gridView.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:kMineSidePadding],
        [gridView.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-kMineSidePadding],
        [gridView.topAnchor constraintEqualToAnchor:postLabel.bottomAnchor constant:22],
        [gridView.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-24],
        [gridView.heightAnchor constraintGreaterThanOrEqualToConstant:360],

        [self.postsEmptyStateView.leadingAnchor constraintEqualToAnchor:gridView.leadingAnchor],
        [self.postsEmptyStateView.trailingAnchor constraintEqualToAnchor:gridView.trailingAnchor],
        [self.postsEmptyStateView.topAnchor constraintEqualToAnchor:gridView.topAnchor],
        [self.postsEmptyStateView.bottomAnchor constraintEqualToAnchor:gridView.bottomAnchor],
    ]];

    [self layoutPostTiles:postTiles inGridView:gridView tileSpacing:tileSpacing rowSpacing:20.0];
}

#pragma mark - Components

- (UIButton *)imageButtonWithName:(NSString *)imageName {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    button.translatesAutoresizingMaskIntoConstraints = NO;
    return button;
}

- (UILabel *)labelWithText:(NSString *)text font:(UIFont *)font color:(UIColor *)color {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = font;
    label.textColor = color;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    return label;
}

- (UIControl *)statViewWithValue:(NSString *)value title:(NSString *)title {
    UIControl *view = [[UIControl alloc] init];

    UILabel *valueLabel = [self labelWithText:value
                                         font:[DesignFonts regular:14]
                                        color:[UIColor colorWithRed:0.15 green:0.15 blue:0.22 alpha:1.0]];
    if ([title isEqualToString:@"Following"]) {
        self.followingValueLabel = valueLabel;
    } else if ([title isEqualToString:@"Followers"]) {
        self.followersValueLabel = valueLabel;
    } else if ([title isEqualToString:@"Friends"]) {
        self.friendsValueLabel = valueLabel;
    }
    UILabel *titleLabel = [self labelWithText:title
                                         font:[DesignFonts regular:14]
                                        color:[UIColor colorWithRed:0.42 green:0.42 blue:0.50 alpha:1.0]];

    [view addSubview:valueLabel];
    [view addSubview:titleLabel];

    [NSLayoutConstraint activateConstraints:@[
        [valueLabel.leadingAnchor constraintEqualToAnchor:view.leadingAnchor],
        [valueLabel.topAnchor constraintEqualToAnchor:view.topAnchor],
        [valueLabel.trailingAnchor constraintEqualToAnchor:view.trailingAnchor],

        [titleLabel.leadingAnchor constraintEqualToAnchor:view.leadingAnchor],
        [titleLabel.topAnchor constraintEqualToAnchor:valueLabel.bottomAnchor constant:7],
        [titleLabel.trailingAnchor constraintEqualToAnchor:view.trailingAnchor],
        [titleLabel.bottomAnchor constraintEqualToAnchor:view.bottomAnchor],
    ]];

    return view;
}

- (UIView *)postTileView {
    UIControl *container = [[UIControl alloc] init];
    container.clipsToBounds = YES;
    container.layer.cornerRadius = 16.0;
    container.translatesAutoresizingMaskIntoConstraints = NO;
    [container addTarget:self action:@selector(didTapPostTile) forControlEvents:UIControlEventTouchUpInside];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.postImage];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [container addSubview:imageView];

    UIImageView *playIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"explore_icon_play"]];
    playIconView.contentMode = UIViewContentModeScaleAspectFit;
    playIconView.translatesAutoresizingMaskIntoConstraints = NO;
    [container addSubview:playIconView];

    [NSLayoutConstraint activateConstraints:@[
        [imageView.topAnchor constraintEqualToAnchor:container.topAnchor],
        [imageView.leadingAnchor constraintEqualToAnchor:container.leadingAnchor],
        [imageView.trailingAnchor constraintEqualToAnchor:container.trailingAnchor],
        [imageView.bottomAnchor constraintEqualToAnchor:container.bottomAnchor],

        [playIconView.centerXAnchor constraintEqualToAnchor:container.centerXAnchor],
        [playIconView.centerYAnchor constraintEqualToAnchor:container.centerYAnchor],
        [playIconView.widthAnchor constraintEqualToConstant:36],
        [playIconView.heightAnchor constraintEqualToConstant:36],
    ]];

    return container;
}

- (void)layoutPostTiles:(NSArray<UIView *> *)postTiles
             inGridView:(UIView *)gridView
            tileSpacing:(CGFloat)tileSpacing
             rowSpacing:(CGFloat)rowSpacing {
    if (postTiles.count == 0) {
        return;
    }

    NSMutableArray<NSLayoutConstraint *> *constraints = [NSMutableArray array];
    for (NSInteger index = 0; index < postTiles.count; index++) {
        UIView *tile = postTiles[index];
        BOOL isLeftColumn = index % 2 == 0;
        NSLayoutDimension *widthAnchor = tile.widthAnchor;

        if (isLeftColumn) {
            [constraints addObject:[tile.leadingAnchor constraintEqualToAnchor:gridView.leadingAnchor]];
            [constraints addObject:[widthAnchor constraintEqualToAnchor:gridView.widthAnchor multiplier:0.5 constant:-(tileSpacing / 2.0)]];
            if (index < 2) {
                [constraints addObject:[tile.topAnchor constraintEqualToAnchor:gridView.topAnchor]];
            } else {
                UIView *previousRowTile = postTiles[index - 2];
                [constraints addObject:[tile.topAnchor constraintEqualToAnchor:previousRowTile.bottomAnchor constant:rowSpacing]];
            }
        } else {
            UIView *leftTile = postTiles[index - 1];
            [constraints addObject:[tile.leadingAnchor constraintEqualToAnchor:leftTile.trailingAnchor constant:tileSpacing]];
            [constraints addObject:[tile.trailingAnchor constraintEqualToAnchor:gridView.trailingAnchor]];
            [constraints addObject:[tile.topAnchor constraintEqualToAnchor:leftTile.topAnchor]];
            [constraints addObject:[widthAnchor constraintEqualToAnchor:leftTile.widthAnchor]];
        }

        [constraints addObject:[tile.heightAnchor constraintEqualToAnchor:tile.widthAnchor multiplier:1.22]];
    }

    NSInteger lastRowFirstIndex = ((NSInteger)postTiles.count - 1) / 2 * 2;
    [constraints addObject:[postTiles[lastRowFirstIndex].bottomAnchor constraintLessThanOrEqualToAnchor:gridView.bottomAnchor]];
    [NSLayoutConstraint activateConstraints:constraints];
}

#pragma mark - Actions

- (void)didTapPostTile {
    if (self.postImages.count == 0) {
        return;
    }

    MineVideoPlayerViewController *playerViewController = [[MineVideoPlayerViewController alloc] init];
    playerViewController.videoFileName = kTestAccountPostVideoFileName;
    playerViewController.username = @"Gaston";
    playerViewController.avatarName = @"avatar_user_01";
    playerViewController.desc = kTestAccountPostDescription;
    playerViewController.likeCount = kTestAccountPostLikeCount;
    playerViewController.commentCount = kTestAccountPostCommentCount;
    playerViewController.viewCount = kTestAccountPostViewCount;
    playerViewController.hidesBottomBarWhenPushed = YES;

    if (self.navigationController) {
        [self.navigationController pushViewController:playerViewController animated:YES];
        return;
    }

    playerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:playerViewController animated:YES completion:nil];
}

- (void)didTapEditProfile {
    EditProfileViewController *editProfileViewController = [[EditProfileViewController alloc] init];
    editProfileViewController.hidesBottomBarWhenPushed = YES;

    if (self.navigationController) {
        [self.navigationController pushViewController:editProfileViewController animated:YES];
        return;
    }

    editProfileViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:editProfileViewController animated:YES completion:nil];
}

- (void)didTapCoinCard {
    RechargeViewController *rechargeViewController = [[RechargeViewController alloc] init];
    rechargeViewController.hidesBottomBarWhenPushed = YES;

    if (self.navigationController) {
        [self.navigationController pushViewController:rechargeViewController animated:YES];
        return;
    }

    rechargeViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:rechargeViewController animated:YES completion:nil];
}

- (void)didTapSettingsButton {
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] init];
    settingsViewController.hidesBottomBarWhenPushed = YES;

    if (self.navigationController) {
        [self.navigationController pushViewController:settingsViewController animated:YES];
        return;
    }

    settingsViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:settingsViewController animated:YES completion:nil];
}

- (void)didTapFollowingStat {
    [self openRelationshipListWithTitle:@"Following" mode:ProfileRelationshipListModeMessage];
}

- (void)didTapFollowersStat {
    [self openRelationshipListWithTitle:@"Followers" mode:ProfileRelationshipListModeMessage];
}

- (void)didTapFriendsStat {
    [self openRelationshipListWithTitle:@"Friends" mode:ProfileRelationshipListModeMessage];
}

- (void)openRelationshipListWithTitle:(NSString *)title mode:(ProfileRelationshipListMode)mode {
    ProfileRelationshipListViewController *listViewController = [[ProfileRelationshipListViewController alloc] initWithTitle:title mode:mode];
    listViewController.hidesBottomBarWhenPushed = YES;

    if (self.navigationController) {
        [self.navigationController pushViewController:listViewController animated:YES];
        return;
    }

    listViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:listViewController animated:YES completion:nil];
}

#pragma mark - Helpers

- (void)updateCoinBalance {
    self.coinsValueLabel.text = [NSString stringWithFormat:@"%ld", (long)[CoinBalanceStore currentBalance]];
}

- (void)updateRelationshipCounts {
    self.followingValueLabel.text = [self relationshipCountTextForTitle:@"Following"];
    self.followersValueLabel.text = [self relationshipCountTextForTitle:@"Followers"];
    self.friendsValueLabel.text = [self relationshipCountTextForTitle:@"Friends"];
}

- (NSString *)relationshipCountTextForTitle:(NSString *)title {
    NSInteger count = [ProfileRelationshipListViewController relationshipItemCountForTitle:title
                                                                                      mode:ProfileRelationshipListModeMessage];
    return [NSString stringWithFormat:@"%ld", (long)MAX(count, 0)];
}

- (UIImage *)thumbnailForVideoNamed:(NSString *)videoName {
    NSString *path = [[NSBundle mainBundle] pathForResource:videoName ofType:@"mp4"];
    if (!path) return nil;

    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:path] options:nil];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    generator.maximumSize = CGSizeMake(640, 640);

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
