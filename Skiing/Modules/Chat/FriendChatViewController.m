//
//  FriendChatViewController.m
//  Skiing
//

#import "FriendChatViewController.h"
#import "VideoCallViewController.h"
#import "CommonMoreActionSheetView.h"
#import "DesignTokens.h"
#import "UserModerationStore.h"

static CGFloat const kFriendChatSidePadding = 18.0;
static NSString * const kFriendChatMessageCellIdentifier = @"FriendChatMessageCell";

@interface FriendChatMessageCell : UITableViewCell
- (void)configureWithText:(NSString *)text incoming:(BOOL)incoming avatarName:(NSString *)avatarName;
@end

@interface FriendChatMessageCell ()
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIView *bubbleView;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) NSLayoutConstraint *bubbleWidthConstraint;
@property (nonatomic, copy) NSArray<NSLayoutConstraint *> *incomingConstraints;
@property (nonatomic, copy) NSArray<NSLayoutConstraint *> *outgoingConstraints;
@end

@implementation FriendChatMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = UIColor.clearColor;
    self.contentView.backgroundColor = UIColor.clearColor;

    self.avatarImageView = [[UIImageView alloc] init];
    self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 16.0;
    self.avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;

    self.bubbleView = [[UIView alloc] init];
    self.bubbleView.layer.cornerRadius = 16.0;
    self.bubbleView.translatesAutoresizingMaskIntoConstraints = NO;

    self.messageLabel = [[UILabel alloc] init];
    self.messageLabel.font = [DesignFonts regular:15];
    self.messageLabel.textColor = [UIColor colorWithRed:0.18 green:0.18 blue:0.23 alpha:1.0];
    self.messageLabel.numberOfLines = 0;
    self.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.messageLabel.translatesAutoresizingMaskIntoConstraints = NO;

    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.text = @"09:15AM";
    self.timeLabel.font = [DesignFonts regular:12];
    self.timeLabel.textColor = [UIColor colorWithRed:0.26 green:0.26 blue:0.34 alpha:1.0];
    self.timeLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [self.contentView addSubview:self.avatarImageView];
    [self.contentView addSubview:self.bubbleView];
    [self.bubbleView addSubview:self.messageLabel];
    [self.contentView addSubview:self.timeLabel];

    self.bubbleWidthConstraint = [self.bubbleView.widthAnchor constraintEqualToConstant:225.0];
    self.incomingConstraints = @[
        [self.avatarImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16.0],
        [self.bubbleView.leadingAnchor constraintEqualToAnchor:self.avatarImageView.trailingAnchor constant:10.0],
        [self.timeLabel.leadingAnchor constraintEqualToAnchor:self.bubbleView.leadingAnchor],
    ];
    self.outgoingConstraints = @[
        [self.avatarImageView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16.0],
        [self.bubbleView.trailingAnchor constraintEqualToAnchor:self.avatarImageView.leadingAnchor constant:-12.0],
        [self.timeLabel.trailingAnchor constraintEqualToAnchor:self.bubbleView.trailingAnchor],
    ];

    [NSLayoutConstraint activateConstraints:@[
        [self.avatarImageView.widthAnchor constraintEqualToConstant:32.0],
        [self.avatarImageView.heightAnchor constraintEqualToConstant:32.0],
        [self.avatarImageView.centerYAnchor constraintEqualToAnchor:self.bubbleView.centerYAnchor],

        [self.bubbleView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:8.0],
        self.bubbleWidthConstraint,
        [self.bubbleView.heightAnchor constraintGreaterThanOrEqualToConstant:72.0],

        [self.messageLabel.leadingAnchor constraintEqualToAnchor:self.bubbleView.leadingAnchor constant:18.0],
        [self.messageLabel.trailingAnchor constraintEqualToAnchor:self.bubbleView.trailingAnchor constant:-16.0],
        [self.messageLabel.topAnchor constraintEqualToAnchor:self.bubbleView.topAnchor constant:15.0],
        [self.messageLabel.bottomAnchor constraintEqualToAnchor:self.bubbleView.bottomAnchor constant:-15.0],

        [self.timeLabel.topAnchor constraintEqualToAnchor:self.bubbleView.bottomAnchor constant:8.0],
        [self.timeLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-30.0],
    ]];
    [NSLayoutConstraint activateConstraints:self.incomingConstraints];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [NSLayoutConstraint deactivateConstraints:self.incomingConstraints];
    [NSLayoutConstraint deactivateConstraints:self.outgoingConstraints];
}

- (void)configureWithText:(NSString *)text incoming:(BOOL)incoming avatarName:(NSString *)avatarName {
    self.messageLabel.text = text;
    self.avatarImageView.image = [UIImage imageNamed:avatarName];
    self.bubbleView.backgroundColor = incoming ? UIColor.whiteColor : [UIColor colorWithRed:0.58 green:0.90 blue:0.67 alpha:1.0];
    self.bubbleWidthConstraint.constant = incoming ? 225.0 : 238.0;
    [NSLayoutConstraint deactivateConstraints:self.incomingConstraints];
    [NSLayoutConstraint deactivateConstraints:self.outgoingConstraints];
    [NSLayoutConstraint activateConstraints:incoming ? self.incomingConstraints : self.outgoingConstraints];
}

@end

@interface FriendChatViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) CAGradientLayer *backgroundGradientLayer;
@property (nonatomic, strong) UITableView *messageTableView;
@property (nonatomic, strong) UIView *inputBar;
@property (nonatomic, strong) UITextField *messageInputField;
@property (nonatomic, strong) NSMutableArray<NSDictionary<NSString *, id> *> *messages;
@property (nonatomic, strong) CommonMoreActionSheetView *moreActionSheetView;
@end

@implementation FriendChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.76 green:0.78 blue:1.0 alpha:1.0];
    self.messages = [NSMutableArray array];

    [self setupBackground];
    [self setupHeader];
    [self setupInputBar];
    [self setupVideoButton];
    [self setupMessages];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
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
        (__bridge id)[UIColor colorWithRed:0.78 green:0.80 blue:1.0 alpha:1.0].CGColor
    ];
    self.backgroundGradientLayer.startPoint = CGPointMake(0.5, 0.0);
    self.backgroundGradientLayer.endPoint = CGPointMake(0.5, 1.0);
    [self.view.layer insertSublayer:self.backgroundGradientLayer atIndex:0];
}

- (void)setupHeader {
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
    backButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [backButton addTarget:self action:@selector(didTapBackButton) forControlEvents:UIControlEventTouchUpInside];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = self.chatTitle.length > 0 ? self.chatTitle : @"Raya";
    titleLabel.font = [DesignFonts semibold:18];
    titleLabel.textColor = [UIColor colorWithRed:0.18 green:0.18 blue:0.23 alpha:1.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setImage:[UIImage imageNamed:@"chat_more_button"] forState:UIControlStateNormal];
    moreButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    moreButton.translatesAutoresizingMaskIntoConstraints = NO;
    [moreButton addTarget:self action:@selector(didTapMoreButton) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:backButton];
    [self.view addSubview:titleLabel];
    [self.view addSubview:moreButton];

    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [backButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kFriendChatSidePadding],
        [backButton.topAnchor constraintEqualToAnchor:safeArea.topAnchor constant:12.0],
        [backButton.widthAnchor constraintEqualToConstant:44.0],
        [backButton.heightAnchor constraintEqualToConstant:44.0],

        [titleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [titleLabel.centerYAnchor constraintEqualToAnchor:backButton.centerYAnchor],

        [moreButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-kFriendChatSidePadding],
        [moreButton.centerYAnchor constraintEqualToAnchor:backButton.centerYAnchor],
        [moreButton.widthAnchor constraintEqualToConstant:44.0],
        [moreButton.heightAnchor constraintEqualToConstant:44.0],
    ]];
}

- (void)setupMessages {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.backgroundColor = UIColor.clearColor;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 132.0;
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [tableView registerClass:FriendChatMessageCell.class forCellReuseIdentifier:kFriendChatMessageCellIdentifier];
    [self.view addSubview:tableView];
    self.messageTableView = tableView;

    [NSLayoutConstraint activateConstraints:@[
        [tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:135.0],
        [tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [tableView.bottomAnchor constraintEqualToAnchor:self.inputBar.topAnchor constant:-82.0],
    ]];
}

- (void)setupInputBar {
    UIView *inputBar = [[UIView alloc] init];
    inputBar.backgroundColor = UIColor.whiteColor;
    inputBar.layer.cornerRadius = 27.5;
    inputBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.inputBar = inputBar;

    UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *imageIcon = [[UIImage systemImageNamed:@"photo"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [imageButton setImage:imageIcon forState:UIControlStateNormal];
    imageButton.tintColor = [UIColor colorWithRed:0.58 green:0.58 blue:0.60 alpha:1.0];
    imageButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageButton.translatesAutoresizingMaskIntoConstraints = NO;

    UITextField *textField = [[UITextField alloc] init];
    textField.backgroundColor = UIColor.clearColor;
    textField.font = [DesignFonts regular:15];
    textField.textColor = [UIColor colorWithRed:0.18 green:0.18 blue:0.22 alpha:1.0];
    textField.returnKeyType = UIReturnKeySend;
    textField.delegate = self;
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    self.messageInputField = textField;

    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.backgroundColor = [UIColor colorWithRed:0.57 green:0.89 blue:0.67 alpha:1.0];
    sendButton.layer.cornerRadius = 24.0;
    UIImage *sendImage = [[UIImage systemImageNamed:@"paperplane.fill"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [sendButton setImage:sendImage forState:UIControlStateNormal];
    sendButton.tintColor = [UIColor colorWithRed:0.17 green:0.24 blue:0.22 alpha:1.0];
    sendButton.translatesAutoresizingMaskIntoConstraints = NO;
    [sendButton addTarget:self action:@selector(sendCurrentMessage) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:inputBar];
    [inputBar addSubview:imageButton];
    [inputBar addSubview:textField];
    [inputBar addSubview:sendButton];

    [NSLayoutConstraint activateConstraints:@[
        [inputBar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kFriendChatSidePadding],
        [inputBar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-kFriendChatSidePadding],
        [inputBar.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-42.0],
        [inputBar.heightAnchor constraintEqualToConstant:55.0],

        [imageButton.leadingAnchor constraintEqualToAnchor:inputBar.leadingAnchor constant:12.0],
        [imageButton.centerYAnchor constraintEqualToAnchor:inputBar.centerYAnchor],
        [imageButton.widthAnchor constraintEqualToConstant:24.0],
        [imageButton.heightAnchor constraintEqualToConstant:24.0],

        [sendButton.trailingAnchor constraintEqualToAnchor:inputBar.trailingAnchor constant:-4.0],
        [sendButton.centerYAnchor constraintEqualToAnchor:inputBar.centerYAnchor],
        [sendButton.widthAnchor constraintEqualToConstant:48.0],
        [sendButton.heightAnchor constraintEqualToConstant:48.0],

        [textField.leadingAnchor constraintEqualToAnchor:imageButton.trailingAnchor constant:10.0],
        [textField.trailingAnchor constraintEqualToAnchor:sendButton.leadingAnchor constant:-8.0],
        [textField.topAnchor constraintEqualToAnchor:inputBar.topAnchor],
        [textField.bottomAnchor constraintEqualToAnchor:inputBar.bottomAnchor],
    ]];
}

- (void)setupVideoButton {
    UIButton *videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [videoButton setImage:[UIImage imageNamed:@"friend_chat_video_button"] forState:UIControlStateNormal];
    videoButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    videoButton.translatesAutoresizingMaskIntoConstraints = NO;
    [videoButton addTarget:self action:@selector(didTapVideoButton) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:videoButton];

    [NSLayoutConstraint activateConstraints:@[
        [videoButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kFriendChatSidePadding],
        [videoButton.bottomAnchor constraintEqualToAnchor:self.inputBar.topAnchor constant:-38.0],
        [videoButton.widthAnchor constraintEqualToConstant:44.0],
        [videoButton.heightAnchor constraintEqualToConstant:44.0],
    ]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendChatMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:kFriendChatMessageCellIdentifier forIndexPath:indexPath];
    NSDictionary<NSString *, id> *message = self.messages[indexPath.row];
    BOOL incoming = [message[@"incoming"] boolValue];
    NSString *incomingAvatarName = self.peerAvatarName.length > 0 ? self.peerAvatarName : @"avatar_user_13";
    [cell configureWithText:message[@"text"] incoming:incoming avatarName:incoming ? incomingAvatarName : @"avatar_user_01"];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 132.0;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self sendCurrentMessage];
    return NO;
}

#pragma mark - Actions

- (void)sendCurrentMessage {
    NSString *text = [self.messageInputField.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (text.length == 0) {
        return;
    }

    [self.messages addObject:@{@"text": text, @"incoming": @NO}];
    self.messageInputField.text = nil;

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
    [self.messageTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    [self.messageTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)didTapVideoButton {
    VideoCallViewController *videoCallViewController = [[VideoCallViewController alloc] init];
    videoCallViewController.hidesBottomBarWhenPushed = YES;
    if (self.navigationController) {
        [self.navigationController pushViewController:videoCallViewController animated:YES];
        return;
    }

    videoCallViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:videoCallViewController animated:YES completion:nil];
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
    [self.moreActionSheetView showInView:[self moreActionSheetPresentationView]];
}

- (UIView *)moreActionSheetPresentationView {
    if (self.navigationController.view) {
        return self.navigationController.view;
    }

    return self.view;
}

- (void)showBlockConfirmation {
    NSString *message = [NSString stringWithFormat:@"Block %@? You will not see this user's content or chats.", [self resolvedPeerName]];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Block user"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Block" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [UserModerationStore blockUserWithName:[self resolvedPeerName]
                                        handle:self.peerHandle ?: @""
                                        avatar:[self resolvedPeerAvatarName]];
        [self showSimpleAlertWithTitle:@"User blocked"
                               message:@"This user has been added to your blacklist."
                            completion:^{
            [self returnToPreviousPageAfterBlocking];
        }];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showReportConfirmation {
    NSString *message = [NSString stringWithFormat:@"Report %@ for inappropriate behavior?", [self resolvedPeerName]];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Report user"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Report" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self showSimpleAlertWithTitle:@"Report submitted"
                               message:@"Thanks for helping keep the community safe."
                            completion:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showSimpleAlertWithTitle:(NSString *)title
                         message:(NSString *)message
                      completion:(void (^)(void))completion {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (completion) completion();
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)returnToPreviousPageAfterBlocking {
    if (self.navigationController && self.navigationController.viewControllers.firstObject != self) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didTapBackButton {
    if (self.navigationController && self.navigationController.viewControllers.firstObject != self) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)resolvedPeerName {
    return self.chatTitle.length > 0 ? self.chatTitle : @"Raya";
}

- (NSString *)resolvedPeerAvatarName {
    return self.peerAvatarName.length > 0 ? self.peerAvatarName : @"avatar_user_13";
}

@end
