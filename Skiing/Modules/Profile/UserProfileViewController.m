//
//  UserProfileViewController.m
//  Skiing
//

#import "UserProfileViewController.h"
#import "FriendChatViewController.h"
#import "CommonMoreActionSheetView.h"
#import "ProfileRelationshipListViewController.h"
#import "EmptyStateView.h"
#import "DesignTokens.h"
#import "UserModerationStore.h"
#import "FriendRequestStore.h"
#import "UserSession.h"
#import <AVFoundation/AVFoundation.h>

static CGFloat const kUserProfileSidePadding = 16.0;
static NSString * const kUserProfileFollowedUsersDefaultsKey = @"kUserProfileFollowedUsersDefaultsKey";
static NSString * const kUserProfileFollowStoreFileName = @"followed_users.json";
static NSString * const kUserProfileBlockedUsersDefaultsKey = @"kUserProfileBlockedUsersDefaultsKey";
static NSString * const kUserProfileBlockStoreFileName = @"blocked_users.json";

@interface UserProfileViewController ()
@property (nonatomic, strong) UIImage *postImage;
@property (nonatomic, copy) NSArray<UIImage *> *postImages;
@property (nonatomic, strong) EmptyStateView *postsEmptyStateView;
@property (nonatomic, strong) UIButton *followButton;
@property (nonatomic, strong) CommonMoreActionSheetView *moreActionSheetView;
@property (nonatomic, strong) UIView *friendPromptOverlayView;
@property (nonatomic, strong) UIView *friendPromptDialogView;
@property (nonatomic, assign, getter=isFollowing) BOOL following;
@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.75 green:0.77 blue:1.0 alpha:1.0];
    self.postImages = [self buildPostImages];
    self.postImage = self.postImages.firstObject;
    self.following = [self isCurrentProfileFollowed];
    [self setupContent];
    [self setupMessageButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDarkContent;
}

#pragma mark - Setup

- (void)setupContent {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.backgroundColor = self.view.backgroundColor;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;

    UIView *contentView = [[UIView alloc] init];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:scrollView];
    [scrollView addSubview:contentView];

    UIButton *backButton = [self imageButtonWithName:@"btn_back"];
    [backButton addTarget:self action:@selector(didTapBackButton) forControlEvents:UIControlEventTouchUpInside];

    self.followButton = [self imageButtonWithName:@"user_profile_follow_button"];
    [self.followButton setImage:[UIImage imageNamed:[self followButtonImageName]] forState:UIControlStateNormal];
    [self.followButton addTarget:self action:@selector(didTapFollowButton) forControlEvents:UIControlEventTouchUpInside];
    UIButton *moreButton = [self imageButtonWithName:@"chat_more_button"];
    [moreButton addTarget:self action:@selector(didTapMoreButton) forControlEvents:UIControlEventTouchUpInside];

    UIView *profileCard = [[UIView alloc] init];
    profileCard.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.46];
    profileCard.layer.cornerRadius = 20;
    profileCard.translatesAutoresizingMaskIntoConstraints = NO;

    UIImageView *avatarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self resolvedProfileAvatarName]]];
    avatarView.contentMode = UIViewContentModeScaleAspectFill;
    avatarView.clipsToBounds = YES;
    avatarView.layer.cornerRadius = 44;
    avatarView.layer.borderWidth = 2;
    avatarView.layer.borderColor = UIColor.whiteColor.CGColor;
    avatarView.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *nameLabel = [self labelWithText:[self resolvedProfileName]
                                        font:[DesignFonts semibold:20]
                                       color:[UIColor colorWithRed:0.18 green:0.18 blue:0.23 alpha:1.0]];
    UILabel *handleLabel = [self labelWithText:[self resolvedProfileHandle]
                                          font:[DesignFonts regular:14]
                                         color:[UIColor colorWithRed:0.39 green:0.39 blue:0.50 alpha:1.0]];

    UIStackView *statsStack = [[UIStackView alloc] init];
    statsStack.axis = UILayoutConstraintAxisHorizontal;
    statsStack.distribution = UIStackViewDistributionEqualSpacing;
    statsStack.translatesAutoresizingMaskIntoConstraints = NO;
    UIControl *followingStatView = [self statViewWithValue:[self profileStatValueWithBase:1800 spread:340] title:@"Following"];
    UIControl *followersStatView = [self statViewWithValue:[self profileStatValueWithBase:260 spread:180] title:@"Followers"];
    UIControl *friendsStatView = [self statViewWithValue:[self profileStatValueWithBase:180 spread:160] title:@"Friends"];
    [statsStack addArrangedSubview:followingStatView];
    [statsStack addArrangedSubview:followersStatView];
    [statsStack addArrangedSubview:friendsStatView];

    NSInteger displayedPostCount = [self resolvedProfilePostCount];
    UILabel *postLabel = [self labelWithText:[NSString stringWithFormat:@"Post(%ld)", (long)displayedPostCount]
                                        font:[DesignFonts semibold:16]
                                       color:[UIColor colorWithRed:0.16 green:0.16 blue:0.22 alpha:1.0]];

    UIView *gridView = [[UIView alloc] init];
    gridView.translatesAutoresizingMaskIntoConstraints = NO;

    [contentView addSubview:backButton];
    [contentView addSubview:self.followButton];
    [contentView addSubview:moreButton];
    [contentView addSubview:profileCard];
    [profileCard addSubview:avatarView];
    [profileCard addSubview:nameLabel];
    [profileCard addSubview:handleLabel];
    [profileCard addSubview:statsStack];
    [contentView addSubview:postLabel];
    [contentView addSubview:gridView];

    NSMutableArray<UIView *> *postTiles = [NSMutableArray array];
    NSInteger visiblePostCount = MIN(self.postImages.count, 4);
    for (NSInteger index = 0; index < visiblePostCount; index++) {
        UIImageView *tile = [[UIImageView alloc] initWithImage:self.postImages[index]];
        tile.contentMode = UIViewContentModeScaleAspectFill;
        tile.clipsToBounds = YES;
        tile.layer.cornerRadius = 16;
        tile.translatesAutoresizingMaskIntoConstraints = NO;
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

        [backButton.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:kUserProfileSidePadding],
        [backButton.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:12],
        [backButton.widthAnchor constraintEqualToConstant:44],
        [backButton.heightAnchor constraintEqualToConstant:44],

        [moreButton.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-kUserProfileSidePadding],
        [moreButton.centerYAnchor constraintEqualToAnchor:backButton.centerYAnchor],
        [moreButton.widthAnchor constraintEqualToConstant:44],
        [moreButton.heightAnchor constraintEqualToConstant:44],

        [self.followButton.trailingAnchor constraintEqualToAnchor:moreButton.leadingAnchor constant:-18],
        [self.followButton.centerYAnchor constraintEqualToAnchor:backButton.centerYAnchor],
        [self.followButton.widthAnchor constraintEqualToConstant:94],
        [self.followButton.heightAnchor constraintEqualToConstant:36],

        [profileCard.topAnchor constraintEqualToAnchor:backButton.bottomAnchor constant:32],
        [profileCard.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:kUserProfileSidePadding],
        [profileCard.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-kUserProfileSidePadding],
        [profileCard.heightAnchor constraintEqualToConstant:174],

        [avatarView.leadingAnchor constraintEqualToAnchor:profileCard.leadingAnchor constant:16],
        [avatarView.topAnchor constraintEqualToAnchor:profileCard.topAnchor constant:14],
        [avatarView.widthAnchor constraintEqualToConstant:88],
        [avatarView.heightAnchor constraintEqualToConstant:88],

        [nameLabel.leadingAnchor constraintEqualToAnchor:avatarView.trailingAnchor constant:12],
        [nameLabel.topAnchor constraintEqualToAnchor:profileCard.topAnchor constant:36],
        [nameLabel.trailingAnchor constraintLessThanOrEqualToAnchor:profileCard.trailingAnchor constant:-16],

        [handleLabel.leadingAnchor constraintEqualToAnchor:nameLabel.leadingAnchor],
        [handleLabel.topAnchor constraintEqualToAnchor:nameLabel.bottomAnchor constant:8],
        [handleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:profileCard.trailingAnchor constant:-16],

        [statsStack.leadingAnchor constraintEqualToAnchor:profileCard.leadingAnchor constant:13],
        [statsStack.trailingAnchor constraintEqualToAnchor:profileCard.trailingAnchor constant:-36],
        [statsStack.bottomAnchor constraintEqualToAnchor:profileCard.bottomAnchor constant:-18],
        [statsStack.heightAnchor constraintEqualToConstant:42],

        [postLabel.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:kUserProfileSidePadding],
        [postLabel.topAnchor constraintEqualToAnchor:profileCard.bottomAnchor constant:28],

        [gridView.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:kUserProfileSidePadding],
        [gridView.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-kUserProfileSidePadding],
        [gridView.topAnchor constraintEqualToAnchor:postLabel.bottomAnchor constant:17],
        [gridView.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-112],
        [gridView.heightAnchor constraintGreaterThanOrEqualToConstant:360],

        [self.postsEmptyStateView.leadingAnchor constraintEqualToAnchor:gridView.leadingAnchor],
        [self.postsEmptyStateView.trailingAnchor constraintEqualToAnchor:gridView.trailingAnchor],
        [self.postsEmptyStateView.topAnchor constraintEqualToAnchor:gridView.topAnchor],
        [self.postsEmptyStateView.bottomAnchor constraintEqualToAnchor:gridView.bottomAnchor],
    ]];

    [self layoutPostTiles:postTiles inGridView:gridView tileSpacing:tileSpacing rowSpacing:16.0];
}

- (void)setupMessageButton {
    UIButton *messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [messageButton setImage:[UIImage imageNamed:@"user_profile_message_button"] forState:UIControlStateNormal];
    messageButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    messageButton.translatesAutoresizingMaskIntoConstraints = NO;
    [messageButton addTarget:self action:@selector(didTapMessageButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:messageButton];

    [NSLayoutConstraint activateConstraints:@[
        [messageButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:36],
        [messageButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-36],
        [messageButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-26],
        [messageButton.heightAnchor constraintEqualToConstant:60],
    ]];
}

#pragma mark - Actions

- (void)didTapBackButton {
    if (self.navigationController && self.navigationController.viewControllers.firstObject != self) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didTapMessageButton {
    if (![self hasSentFriendRequestForCurrentProfile]) {
        [self showFriendPromptDialog];
        return;
    }

    [self openChatViewController];
}

- (void)openChatViewController {
    FriendChatViewController *chatViewController = [[FriendChatViewController alloc] init];
    chatViewController.chatTitle = [self resolvedProfileName];
    chatViewController.peerHandle = [self resolvedProfileHandle];
    chatViewController.peerAvatarName = [self resolvedProfileAvatarName];
    chatViewController.hidesBottomBarWhenPushed = YES;
    if (self.navigationController) {
        [self.navigationController pushViewController:chatViewController animated:YES];
        return;
    }

    chatViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:chatViewController animated:YES completion:nil];
}

- (void)didTapFollowButton {
    self.following = !self.isFollowing;
    [self persistCurrentProfileFollowState];
    [self.followButton setImage:[UIImage imageNamed:[self followButtonImageName]] forState:UIControlStateNormal];
}

- (void)didTapMoreButton {
    if (!self.moreActionSheetView) {
        self.moreActionSheetView = [[CommonMoreActionSheetView alloc] init];
    }

    __weak typeof(self) weakSelf = self;
    self.moreActionSheetView.blockHandler = ^{
        [weakSelf showBlockConfirmation];
    };
    self.moreActionSheetView.reportHandler = ^{
        [weakSelf showReportConfirmation];
    };
    [self.moreActionSheetView showInView:self.view];
}

- (void)showBlockConfirmation {
    NSString *message = [NSString stringWithFormat:@"Block %@? You will not see this user's content in your lists.", [self resolvedProfileName]];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Block user"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Block" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [UserModerationStore blockUserWithName:[self resolvedProfileName]
                                        handle:[self resolvedProfileHandle]
                                        avatar:[self resolvedProfileAvatarName]];
        self.following = NO;
        [self persistCurrentProfileFollowState];
        [self.followButton setImage:[UIImage imageNamed:[self followButtonImageName]] forState:UIControlStateNormal];
        [self showSimpleAlertWithTitle:@"User blocked" message:@"This user has been added to your blacklist." completion:^{
            [self returnToSourceAfterBlocking];
        }];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showReportConfirmation {
    NSString *message = [NSString stringWithFormat:@"Report %@ for inappropriate content?", [self resolvedProfileName]];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Report user"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Report" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self showSimpleAlertWithTitle:@"Report submitted" message:@"Thanks for helping keep the community safe."];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showSimpleAlertWithTitle:(NSString *)title message:(NSString *)message {
    [self showSimpleAlertWithTitle:title message:message completion:nil];
}

- (void)showSimpleAlertWithTitle:(NSString *)title message:(NSString *)message completion:(void (^)(void))completion {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (completion) completion();
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)returnToSourceAfterBlocking {
    if (self.navigationController && self.navigationController.viewControllers.firstObject != self) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    [self dismissViewControllerAnimated:YES completion:nil];
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

- (void)showFriendPromptDialog {
    if (self.friendPromptOverlayView.superview) return;

    UIView *overlay = [[UIView alloc] initWithFrame:self.view.bounds];
    overlay.backgroundColor = [[UIColor colorWithRed:0.22 green:0.24 blue:0.43 alpha:1.0] colorWithAlphaComponent:0.68];
    overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:overlay];
    self.friendPromptOverlayView = overlay;

    CGFloat dialogWidth = 296.0;
    CGFloat dialogHeight = 258.0;
    UIView *dialog = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.bounds) - dialogWidth) / 2.0,
                                                              (CGRectGetHeight(self.view.bounds) - dialogHeight) / 2.0 - 8.0,
                                                              dialogWidth,
                                                              dialogHeight)];
    dialog.backgroundColor = [UIColor colorWithRed:0.56 green:0.62 blue:0.95 alpha:1.0];
    dialog.layer.cornerRadius = 22.0;
    dialog.layer.masksToBounds = YES;
    dialog.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                              UIViewAutoresizingFlexibleRightMargin |
                              UIViewAutoresizingFlexibleTopMargin |
                              UIViewAutoresizingFlexibleBottomMargin;
    [overlay addSubview:dialog];
    self.friendPromptDialogView = dialog;

    CGFloat whiteInset = 16.0;
    CGFloat whiteHeight = 166.0;
    UIView *whitePanel = [[UIView alloc] initWithFrame:CGRectMake(whiteInset, whiteInset, dialogWidth - whiteInset * 2.0, whiteHeight)];
    whitePanel.backgroundColor = UIColor.clearColor;
    [dialog addSubview:whitePanel];

    CAShapeLayer *whiteLayer = [CAShapeLayer layer];
    whiteLayer.fillColor = UIColor.whiteColor.CGColor;
    whiteLayer.path = [self friendPromptWhitePanelPathForSize:whitePanel.bounds.size].CGPath;
    [whitePanel.layer addSublayer:whiteLayer];

    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    messageLabel.text = @"You need to add the other\nperson as a friend before you\ncan chat. Add now?";
    messageLabel.font = [DesignFonts semibold:15];
    messageLabel.textColor = [UIColor colorWithRed:0.20 green:0.20 blue:0.24 alpha:1.0];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.numberOfLines = 3;
    messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [whitePanel addSubview:messageLabel];

    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setImage:[UIImage imageNamed:@"user_profile_friend_prompt_cancel_button"] forState:UIControlStateNormal];
    cancelButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    [cancelButton addTarget:self action:@selector(didTapFriendPromptCancel) forControlEvents:UIControlEventTouchUpInside];
    [dialog addSubview:cancelButton];

    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setImage:[UIImage imageNamed:@"user_profile_friend_prompt_add_button"] forState:UIControlStateNormal];
    addButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    addButton.translatesAutoresizingMaskIntoConstraints = NO;
    [addButton addTarget:self action:@selector(didTapFriendPromptAdd) forControlEvents:UIControlEventTouchUpInside];
    [dialog addSubview:addButton];

    [NSLayoutConstraint activateConstraints:@[
        [messageLabel.centerXAnchor constraintEqualToAnchor:whitePanel.centerXAnchor],
        [messageLabel.centerYAnchor constraintEqualToAnchor:whitePanel.centerYAnchor constant:-8],
        [messageLabel.leadingAnchor constraintEqualToAnchor:whitePanel.leadingAnchor constant:24],
        [messageLabel.trailingAnchor constraintEqualToAnchor:whitePanel.trailingAnchor constant:-24],

        [cancelButton.leadingAnchor constraintEqualToAnchor:dialog.leadingAnchor constant:24],
        [cancelButton.bottomAnchor constraintEqualToAnchor:dialog.bottomAnchor constant:-20],
        [cancelButton.widthAnchor constraintEqualToConstant:107],
        [cancelButton.heightAnchor constraintEqualToConstant:42],

        [addButton.trailingAnchor constraintEqualToAnchor:dialog.trailingAnchor constant:-24],
        [addButton.bottomAnchor constraintEqualToAnchor:dialog.bottomAnchor constant:-20],
        [addButton.widthAnchor constraintEqualToConstant:107],
        [addButton.heightAnchor constraintEqualToConstant:42],
    ]];

    dialog.transform = CGAffineTransformMakeScale(0.92, 0.92);
    overlay.alpha = 0;
    [UIView animateWithDuration:0.22
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        overlay.alpha = 1;
        dialog.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (UIBezierPath *)friendPromptWhitePanelPathForSize:(CGSize)size {
    CGFloat radius = 18.0;
    CGFloat notchHeight = 22.0;
    CGFloat bottomY = size.height - notchHeight;
    CGFloat midX = size.width / 2.0;

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(radius, 0)];
    [path addLineToPoint:CGPointMake(size.width - radius, 0)];
    [path addQuadCurveToPoint:CGPointMake(size.width, radius) controlPoint:CGPointMake(size.width, 0)];
    [path addLineToPoint:CGPointMake(size.width, bottomY)];
    [path addLineToPoint:CGPointMake(midX, size.height)];
    [path addLineToPoint:CGPointMake(0, bottomY)];
    [path addLineToPoint:CGPointMake(0, radius)];
    [path addQuadCurveToPoint:CGPointMake(radius, 0) controlPoint:CGPointMake(0, 0)];
    [path closePath];
    return path;
}

- (void)didTapFriendPromptCancel {
    [self dismissFriendPromptDialogWithCompletion:nil];
}

- (void)didTapFriendPromptAdd {
    [FriendRequestStore markFriendRequestSentToName:[self resolvedProfileName]
                                             handle:[self resolvedProfileHandle]
                                             avatar:[self resolvedProfileAvatarName]];
    [self dismissFriendPromptDialogWithCompletion:^{
        [self showFriendRequestSentAlert];
    }];
}

- (void)dismissFriendPromptDialogWithCompletion:(void (^)(void))completion {
    [UIView animateWithDuration:0.18 animations:^{
        self.friendPromptOverlayView.alpha = 0;
        self.friendPromptDialogView.transform = CGAffineTransformMakeScale(0.94, 0.94);
    } completion:^(BOOL finished) {
        [self.friendPromptOverlayView removeFromSuperview];
        self.friendPromptOverlayView = nil;
        self.friendPromptDialogView = nil;
        if (completion) completion();
    }];
}

- (BOOL)hasSentFriendRequestForCurrentProfile {
    return [FriendRequestStore hasSentFriendRequestToName:[self resolvedProfileName]
                                                   handle:[self resolvedProfileHandle]
                                                   avatar:[self resolvedProfileAvatarName]];
}

- (void)showFriendRequestSentAlert {
    NSString *message = [NSString stringWithFormat:@"Your request to %@ has been sent. Tap Message again to start chatting.", [self resolvedProfileName]];
    [self showSimpleAlertWithTitle:@"Friend request sent" message:message];
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
    [constraints addObject:[postTiles[lastRowFirstIndex].bottomAnchor constraintEqualToAnchor:gridView.bottomAnchor]];
    [NSLayoutConstraint activateConstraints:constraints];
}

#pragma mark - Helpers

- (NSString *)resolvedProfileName {
    return self.profileName.length > 0 ? self.profileName : @"Gaston";
}

- (NSString *)resolvedProfileHandle {
    return self.profileHandle.length > 0 ? self.profileHandle : @"@279jsof895";
}

- (NSString *)resolvedProfileAvatarName {
    return self.profileAvatarName.length > 0 ? self.profileAvatarName : @"avatar_user_01";
}

- (NSInteger)resolvedProfilePostCount {
    if (self.profilePostCount > 0) {
        return self.profilePostCount;
    }

    if (self.profilePostVideoFileNames.count > 0) {
        return self.profilePostVideoFileNames.count;
    }

    return self.postImages.count == 0 ? 0 : 56;
}

- (NSString *)followButtonImageName {
    return self.isFollowing ? @"user_profile_following_button" : @"user_profile_follow_button";
}

- (BOOL)isCurrentProfileFollowed {
    NSString *identity = [self followIdentityForName:[self resolvedProfileName]
                                             handle:[self resolvedProfileHandle]
                                             avatar:[self resolvedProfileAvatarName]];
    for (NSDictionary *user in [self followedUsers]) {
        if ([self user:user matchesIdentity:identity]) {
            return YES;
        }
    }
    return NO;
}

- (void)persistCurrentProfileFollowState {
    NSMutableArray<NSDictionary *> *users = [[self followedUsers] mutableCopy];
    NSString *name = [self resolvedProfileName];
    NSString *handle = [self resolvedProfileHandle];
    NSString *avatar = [self resolvedProfileAvatarName];
    NSString *identity = [self followIdentityForName:name handle:handle avatar:avatar];
    NSIndexSet *matchingIndexes = [users indexesOfObjectsPassingTest:^BOOL(NSDictionary *user, NSUInteger idx, BOOL *stop) {
        return [self user:user matchesIdentity:identity];
    }];
    if (matchingIndexes.count > 0) {
        [users removeObjectsAtIndexes:matchingIndexes];
    }

    if (self.isFollowing) {
        [users addObject:@{@"id": identity,
                           @"name": name,
                           @"handle": handle,
                           @"avatar": avatar}];
    }

    [NSUserDefaults.standardUserDefaults setObject:users forKey:[self followedUsersDefaultsKey]];
    [NSUserDefaults.standardUserDefaults synchronize];
    [self writeFollowedUsersToDisk:users];
}

- (NSArray<NSDictionary *> *)followedUsers {
    NSArray *storedUsers = [NSUserDefaults.standardUserDefaults objectForKey:[self followedUsersDefaultsKey]];
    NSArray<NSDictionary *> *users = [self sanitizedFollowedUsersFromObject:storedUsers];
    if (users.count > 0) {
        [NSUserDefaults.standardUserDefaults setObject:users forKey:[self followedUsersDefaultsKey]];
        [NSUserDefaults.standardUserDefaults synchronize];
        [self writeFollowedUsersToDisk:users];
    } else {
        users = [self readFollowedUsersFromDisk];
        if (users.count > 0) {
            [NSUserDefaults.standardUserDefaults setObject:users forKey:[self followedUsersDefaultsKey]];
            [NSUserDefaults.standardUserDefaults synchronize];
        }
    }

    return users;
}

- (NSArray<NSDictionary *> *)sanitizedFollowedUsersFromObject:(id)object {
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
        NSString *identity = user[@"id"];
        if ([name isKindOfClass:NSString.class] && name.length > 0 &&
            [handle isKindOfClass:NSString.class] && handle.length > 0 &&
            [avatar isKindOfClass:NSString.class] && avatar.length > 0) {
            if (![identity isKindOfClass:NSString.class] || identity.length == 0) {
                identity = [self followIdentityForName:name handle:handle avatar:avatar];
            }
            [users addObject:@{@"id": identity, @"name": name, @"handle": handle, @"avatar": avatar}];
        }
    }
    return users.copy;
}

- (BOOL)user:(NSDictionary *)user matchesIdentity:(NSString *)identity {
    NSString *storedIdentity = user[@"id"];
    if ([storedIdentity isKindOfClass:NSString.class] && [storedIdentity isEqualToString:identity]) {
        return YES;
    }

    NSString *fallbackIdentity = [self followIdentityForName:user[@"name"]
                                                     handle:user[@"handle"]
                                                     avatar:user[@"avatar"]];
    return [fallbackIdentity isEqualToString:identity];
}

- (NSString *)followIdentityForName:(NSString *)name handle:(NSString *)handle avatar:(NSString *)avatar {
    NSString *cleanHandle = [self normalizedFollowComponent:handle];
    if (cleanHandle.length > 0) {
        return cleanHandle;
    }

    NSString *cleanName = [self normalizedFollowComponent:name];
    NSString *cleanAvatar = [self normalizedFollowComponent:avatar];
    return [NSString stringWithFormat:@"%@|%@", cleanName, cleanAvatar];
}

- (NSString *)normalizedFollowComponent:(id)value {
    if (![value isKindOfClass:NSString.class]) {
        return @"";
    }

    NSString *trimmedValue = [(NSString *)value stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    return trimmedValue.lowercaseString;
}

- (NSURL *)followStoreFileURL {
    NSURL *applicationSupportURL = [NSFileManager.defaultManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask].firstObject;
    NSURL *directoryURL = [applicationSupportURL URLByAppendingPathComponent:@"Profile" isDirectory:YES];
    [NSFileManager.defaultManager createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:nil];
    return [directoryURL URLByAppendingPathComponent:[self followStoreFileName]];
}

- (NSString *)followedUsersDefaultsKey {
    return [NSString stringWithFormat:@"%@.%@", kUserProfileFollowedUsersDefaultsKey, [self accountSuffix]];
}

- (NSString *)followStoreFileName {
    return [NSString stringWithFormat:@"%@_%@", [self accountSuffix], kUserProfileFollowStoreFileName];
}

- (NSString *)accountSuffix {
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

- (NSArray<NSDictionary *> *)readFollowedUsersFromDisk {
    NSData *data = [NSData dataWithContentsOfURL:[self followStoreFileURL]];
    if (data.length == 0) {
        return @[];
    }

    id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return [self sanitizedFollowedUsersFromObject:object];
}

- (void)writeFollowedUsersToDisk:(NSArray<NSDictionary *> *)users {
    NSData *data = [NSJSONSerialization dataWithJSONObject:users options:0 error:nil];
    if (data.length == 0) {
        return;
    }

    [data writeToURL:[self followStoreFileURL] atomically:YES];
}

- (void)persistCurrentProfileBlockedState {
    NSMutableArray<NSDictionary *> *users = [[self blockedUsers] mutableCopy];
    NSString *name = [self resolvedProfileName];
    NSString *handle = [self resolvedProfileHandle];
    NSString *avatar = [self resolvedProfileAvatarName];
    NSString *identity = [self followIdentityForName:name handle:handle avatar:avatar];
    NSIndexSet *matchingIndexes = [users indexesOfObjectsPassingTest:^BOOL(NSDictionary *user, NSUInteger idx, BOOL *stop) {
        return [self user:user matchesIdentity:identity];
    }];
    if (matchingIndexes.count > 0) {
        [users removeObjectsAtIndexes:matchingIndexes];
    }

    [users addObject:@{@"id": identity,
                       @"name": name,
                       @"handle": handle,
                       @"avatar": avatar}];

    [NSUserDefaults.standardUserDefaults setObject:users forKey:kUserProfileBlockedUsersDefaultsKey];
    [NSUserDefaults.standardUserDefaults synchronize];
    [self writeBlockedUsersToDisk:users];
}

- (NSArray<NSDictionary *> *)blockedUsers {
    NSArray *storedUsers = [NSUserDefaults.standardUserDefaults objectForKey:kUserProfileBlockedUsersDefaultsKey];
    NSArray<NSDictionary *> *users = [self sanitizedFollowedUsersFromObject:storedUsers];
    if (users.count > 0) {
        [NSUserDefaults.standardUserDefaults setObject:users forKey:kUserProfileBlockedUsersDefaultsKey];
        [NSUserDefaults.standardUserDefaults synchronize];
        [self writeBlockedUsersToDisk:users];
    } else {
        users = [self readBlockedUsersFromDisk];
        if (users.count > 0) {
            [NSUserDefaults.standardUserDefaults setObject:users forKey:kUserProfileBlockedUsersDefaultsKey];
            [NSUserDefaults.standardUserDefaults synchronize];
        }
    }

    return users;
}

- (NSURL *)blockStoreFileURL {
    NSURL *applicationSupportURL = [NSFileManager.defaultManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask].firstObject;
    NSURL *directoryURL = [applicationSupportURL URLByAppendingPathComponent:@"Profile" isDirectory:YES];
    [NSFileManager.defaultManager createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:nil];
    return [directoryURL URLByAppendingPathComponent:kUserProfileBlockStoreFileName];
}

- (NSArray<NSDictionary *> *)readBlockedUsersFromDisk {
    NSData *data = [NSData dataWithContentsOfURL:[self blockStoreFileURL]];
    if (data.length == 0) {
        return @[];
    }

    id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return [self sanitizedFollowedUsersFromObject:object];
}

- (void)writeBlockedUsersToDisk:(NSArray<NSDictionary *> *)users {
    NSData *data = [NSJSONSerialization dataWithJSONObject:users options:0 error:nil];
    if (data.length == 0) {
        return;
    }

    [data writeToURL:[self blockStoreFileURL] atomically:YES];
}

- (NSArray<UIImage *> *)buildPostImages {
    if (self.profilePostVideoFileNames.count > 0) {
        NSMutableArray<UIImage *> *images = [NSMutableArray array];
        NSInteger visibleCount = MIN(self.profilePostVideoFileNames.count, 4);
        for (NSInteger index = 0; index < visibleCount; index++) {
            UIImage *image = [self thumbnailForVideoNamed:self.profilePostVideoFileNames[index]];
            if (image) {
                [images addObject:image];
            }
        }
        return images.copy;
    }

    UIImage *defaultImage = [self thumbnailForVideoNamed:@"video_ski_01"] ?: [UIImage imageNamed:@"explore_mountain_header"];
    return defaultImage ? @[defaultImage, defaultImage, defaultImage, defaultImage] : @[];
}

- (NSString *)profileStatValueWithBase:(NSInteger)base spread:(NSInteger)spread {
    NSUInteger hash = [self resolvedProfileName].hash;
    NSInteger value = base + (NSInteger)(hash % MAX(spread, 1));
    return [NSString stringWithFormat:@"%ld", (long)value];
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
