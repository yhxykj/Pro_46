//
//  ChatViewController.m
//  Skiing
//

#import "ChatViewController.h"
#import "DesignTokens.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

static CGFloat const kChatSidePadding = 18.0;
static NSString * const kChatMessageCellIdentifier = @"ChatMessageCell";
static NSString * const kChatRoomMessagesDefaultsPrefix = @"kChatRoomMessagesDefaultsPrefix.";

@interface ChatMessageCell : UITableViewCell
@property (nonatomic, strong) UIButton *reportButton;
- (void)configureWithText:(NSString *)text incoming:(BOOL)incoming avatarName:(NSString *)avatarName;
@end

@interface ChatMessageCell ()
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIView *bubbleView;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) NSLayoutConstraint *bubbleWidthConstraint;
@property (nonatomic, copy) NSArray<NSLayoutConstraint *> *incomingConstraints;
@property (nonatomic, copy) NSArray<NSLayoutConstraint *> *outgoingConstraints;
@end

@implementation ChatMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColor.clearColor;
        self.contentView.backgroundColor = UIColor.clearColor;

        self.avatarImageView = [[UIImageView alloc] init];
        self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.avatarImageView.clipsToBounds = YES;
        self.avatarImageView.layer.cornerRadius = 17;
        self.avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;

        self.bubbleView = [[UIView alloc] init];
        self.bubbleView.layer.cornerRadius = 16;
        self.bubbleView.translatesAutoresizingMaskIntoConstraints = NO;

        self.messageLabel = [[UILabel alloc] init];
        self.messageLabel.font = [DesignFonts regular:15];
        self.messageLabel.textColor = [UIColor colorWithRed:0.22 green:0.22 blue:0.27 alpha:1.0];
        self.messageLabel.numberOfLines = 0;
        self.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.messageLabel.translatesAutoresizingMaskIntoConstraints = NO;

        self.timeLabel = [[UILabel alloc] init];
        self.timeLabel.text = @"09:15AM";
        self.timeLabel.font = [DesignFonts regular:12];
        self.timeLabel.textColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.35 alpha:1.0];
        self.timeLabel.translatesAutoresizingMaskIntoConstraints = NO;

        self.reportButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.reportButton.titleLabel.font = [DesignFonts semibold:12];
        [self.reportButton setTitle:@"Report" forState:UIControlStateNormal];
        [self.reportButton setTitleColor:[UIColor colorWithRed:0.18 green:0.36 blue:0.82 alpha:1.0] forState:UIControlStateNormal];
        self.reportButton.translatesAutoresizingMaskIntoConstraints = NO;

        [self.contentView addSubview:self.avatarImageView];
        [self.contentView addSubview:self.bubbleView];
        [self.bubbleView addSubview:self.messageLabel];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.reportButton];

        self.bubbleWidthConstraint = [self.bubbleView.widthAnchor constraintEqualToConstant:242.0];
        self.incomingConstraints = @[
            [self.avatarImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16.0],
            [self.bubbleView.leadingAnchor constraintEqualToAnchor:self.avatarImageView.trailingAnchor constant:10.0],
            [self.timeLabel.leadingAnchor constraintEqualToAnchor:self.bubbleView.leadingAnchor],
            [self.reportButton.leadingAnchor constraintEqualToAnchor:self.timeLabel.trailingAnchor constant:12.0],
            [self.reportButton.trailingAnchor constraintLessThanOrEqualToAnchor:self.contentView.trailingAnchor constant:-16.0],
        ];
        self.outgoingConstraints = @[
            [self.avatarImageView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16.0],
            [self.bubbleView.trailingAnchor constraintEqualToAnchor:self.avatarImageView.leadingAnchor constant:-12.0],
            [self.reportButton.trailingAnchor constraintEqualToAnchor:self.bubbleView.trailingAnchor],
            [self.timeLabel.trailingAnchor constraintEqualToAnchor:self.reportButton.leadingAnchor constant:-12.0],
        ];

        [NSLayoutConstraint activateConstraints:@[
            [self.avatarImageView.widthAnchor constraintEqualToConstant:34.0],
            [self.avatarImageView.heightAnchor constraintEqualToConstant:34.0],
            [self.avatarImageView.centerYAnchor constraintEqualToAnchor:self.bubbleView.centerYAnchor],

            [self.bubbleView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:8.0],
            self.bubbleWidthConstraint,
            [self.bubbleView.heightAnchor constraintGreaterThanOrEqualToConstant:76.0],

            [self.messageLabel.leadingAnchor constraintEqualToAnchor:self.bubbleView.leadingAnchor constant:18.0],
            [self.messageLabel.trailingAnchor constraintEqualToAnchor:self.bubbleView.trailingAnchor constant:-16.0],
            [self.messageLabel.topAnchor constraintEqualToAnchor:self.bubbleView.topAnchor constant:16.0],
            [self.messageLabel.bottomAnchor constraintEqualToAnchor:self.bubbleView.bottomAnchor constant:-16.0],

            [self.timeLabel.topAnchor constraintEqualToAnchor:self.bubbleView.bottomAnchor constant:8.0],
            [self.reportButton.centerYAnchor constraintEqualToAnchor:self.timeLabel.centerYAnchor],
            [self.reportButton.heightAnchor constraintEqualToConstant:28.0],
            [self.timeLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-18.0],
        ]];
        [NSLayoutConstraint activateConstraints:self.incomingConstraints];
    }
    return self;
}

- (void)configureWithText:(NSString *)text incoming:(BOOL)incoming avatarName:(NSString *)avatarName {
    self.messageLabel.text = text;
    self.avatarImageView.image = [UIImage imageNamed:avatarName];
    self.bubbleView.backgroundColor = incoming ? UIColor.whiteColor : [UIColor colorWithRed:0.59 green:0.90 blue:0.68 alpha:1.0];
    self.bubbleWidthConstraint.constant = incoming ? 242.0 : 252.0;
    [NSLayoutConstraint deactivateConstraints:incoming ? self.outgoingConstraints : self.incomingConstraints];
    [NSLayoutConstraint activateConstraints:incoming ? self.incomingConstraints : self.outgoingConstraints];
}

@end

@interface ChatViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) CAGradientLayer *backgroundGradient;
@property (nonatomic, strong) UIImage *roomImage;
@property (nonatomic, strong) UIView *roomCard;
@property (nonatomic, strong) UIView *communityReminderView;
@property (nonatomic, strong) UIView *inputBar;
@property (nonatomic, strong) UITextField *messageInputField;
@property (nonatomic, strong) UITableView *messageTableView;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *messages;
@property (nonatomic, strong) NSLayoutConstraint *inputBarBottomConstraint;
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.76 green:0.78 blue:1.00 alpha:1.0];
    self.roomImage = [self thumbnailForVideoNamed:@"video_ski_01"] ?: [UIImage imageNamed:@"explore_mountain_header"];
    [self setupBackground];
    [self setupHeaderButtons];
    [self setupRoomCard];
    [self setupCommunityReminder];
    [self setupInputBar];
    [self setupMessages];
    [self setupKeyboardHandling];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.backgroundGradient.frame = self.view.bounds;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDarkContent;
}

#pragma mark - Setup

- (void)setupBackground {
    self.backgroundGradient = [CAGradientLayer layer];
    self.backgroundGradient.colors = @[
        (__bridge id)[UIColor colorWithRed:0.57 green:0.61 blue:0.92 alpha:1.0].CGColor,
        (__bridge id)[UIColor colorWithRed:0.80 green:0.82 blue:1.00 alpha:1.0].CGColor
    ];
    self.backgroundGradient.startPoint = CGPointMake(0.5, 0.0);
    self.backgroundGradient.endPoint = CGPointMake(0.5, 1.0);
    [self.view.layer insertSublayer:self.backgroundGradient atIndex:0];
}

- (void)setupHeaderButtons {
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
    backButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [backButton addTarget:self action:@selector(didTapBackButton) forControlEvents:UIControlEventTouchUpInside];

    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setImage:[UIImage imageNamed:@"chat_more_button"] forState:UIControlStateNormal];
    moreButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    moreButton.translatesAutoresizingMaskIntoConstraints = NO;
    [moreButton addTarget:self action:@selector(didTapMoreButton:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:backButton];
    [self.view addSubview:moreButton];

    [NSLayoutConstraint activateConstraints:@[
        [backButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kChatSidePadding],
        [backButton.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:12],
        [backButton.widthAnchor constraintEqualToConstant:44],
        [backButton.heightAnchor constraintEqualToConstant:44],

        [moreButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-kChatSidePadding],
        [moreButton.centerYAnchor constraintEqualToAnchor:backButton.centerYAnchor],
        [moreButton.widthAnchor constraintEqualToConstant:44],
        [moreButton.heightAnchor constraintEqualToConstant:44],
    ]];
}

- (void)setupRoomCard {
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.56];
    card.layer.cornerRadius = 17;
    card.translatesAutoresizingMaskIntoConstraints = NO;
    self.roomCard = card;

    UIImageView *thumbnail = [[UIImageView alloc] initWithImage:self.roomImage];
    thumbnail.contentMode = UIViewContentModeScaleAspectFill;
    thumbnail.clipsToBounds = YES;
    thumbnail.layer.cornerRadius = 10;
    thumbnail.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *title = [self labelWithText:[self resolvedRoomName]
                                    font:[DesignFonts regular:16]
                                   color:[UIColor colorWithRed:0.18 green:0.18 blue:0.22 alpha:1.0]];

    UIImageView *groupIcon = [self imageViewWithName:@"explore_icon_group"];
    UILabel *onlineLabel = [self labelWithText:[self resolvedRoomOnlineText]
                                          font:[DesignFonts regular:12]
                                         color:[UIColor colorWithRed:0.14 green:0.70 blue:0.36 alpha:1.0]];

    UILabel *descriptionLabel = [self labelWithText:[self resolvedRoomDescription]
                                               font:[DesignFonts regular:12]
                                              color:[UIColor colorWithRed:0.24 green:0.24 blue:0.31 alpha:1.0]];
    descriptionLabel.numberOfLines = 2;

    [self.view addSubview:card];
    [card addSubview:thumbnail];
    [card addSubview:title];
    [card addSubview:groupIcon];
    [card addSubview:onlineLabel];
    [card addSubview:descriptionLabel];

    [NSLayoutConstraint activateConstraints:@[
        [card.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kChatSidePadding],
        [card.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-kChatSidePadding],
        [card.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:72],
        [card.heightAnchor constraintEqualToConstant:114],

        [thumbnail.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:12],
        [thumbnail.centerYAnchor constraintEqualToAnchor:card.centerYAnchor],
        [thumbnail.widthAnchor constraintEqualToConstant:92],
        [thumbnail.heightAnchor constraintEqualToConstant:92],

        [title.leadingAnchor constraintEqualToAnchor:thumbnail.trailingAnchor constant:12],
        [title.topAnchor constraintEqualToAnchor:card.topAnchor constant:24],
        [title.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-18],

        [groupIcon.leadingAnchor constraintEqualToAnchor:title.leadingAnchor],
        [groupIcon.topAnchor constraintEqualToAnchor:title.bottomAnchor constant:7],
        [groupIcon.widthAnchor constraintEqualToConstant:12],
        [groupIcon.heightAnchor constraintEqualToConstant:12],

        [onlineLabel.leadingAnchor constraintEqualToAnchor:groupIcon.trailingAnchor constant:4],
        [onlineLabel.centerYAnchor constraintEqualToAnchor:groupIcon.centerYAnchor],
        [onlineLabel.trailingAnchor constraintLessThanOrEqualToAnchor:card.trailingAnchor constant:-18],

        [descriptionLabel.leadingAnchor constraintEqualToAnchor:title.leadingAnchor],
        [descriptionLabel.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-18],
        [descriptionLabel.topAnchor constraintEqualToAnchor:onlineLabel.bottomAnchor constant:14],
    ]];
}

- (void)setupCommunityReminder {
    UIView *reminderView = [[UIView alloc] init];
    reminderView.backgroundColor = [UIColor colorWithRed:0.91 green:0.95 blue:1.0 alpha:0.78];
    reminderView.layer.cornerRadius = 14.0;
    reminderView.translatesAutoresizingMaskIntoConstraints = NO;
    self.communityReminderView = reminderView;

    UIImage *iconImage = [[UIImage systemImageNamed:@"shield.lefthalf.filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *iconView = [[UIImageView alloc] initWithImage:iconImage];
    iconView.tintColor = [UIColor colorWithRed:0.12 green:0.45 blue:0.88 alpha:1.0];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *titleLabel = [self labelWithText:@"Community Reminder"
                                         font:[DesignFonts semibold:13]
                                        color:[UIColor colorWithRed:0.10 green:0.24 blue:0.42 alpha:1.0]];

    UILabel *messageLabel = [self labelWithText:@"Keep chats kind and ski-focused. Do not share private info, and report anything unsafe."
                                           font:[DesignFonts regular:12]
                                          color:[UIColor colorWithRed:0.25 green:0.30 blue:0.40 alpha:1.0]];
    messageLabel.numberOfLines = 0;

    [self.view addSubview:reminderView];
    [reminderView addSubview:iconView];
    [reminderView addSubview:titleLabel];
    [reminderView addSubview:messageLabel];

    [NSLayoutConstraint activateConstraints:@[
        [reminderView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kChatSidePadding],
        [reminderView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-kChatSidePadding],
        [reminderView.topAnchor constraintEqualToAnchor:self.roomCard.bottomAnchor constant:12],

        [iconView.leadingAnchor constraintEqualToAnchor:reminderView.leadingAnchor constant:14],
        [iconView.topAnchor constraintEqualToAnchor:reminderView.topAnchor constant:15],
        [iconView.widthAnchor constraintEqualToConstant:18],
        [iconView.heightAnchor constraintEqualToConstant:18],

        [titleLabel.leadingAnchor constraintEqualToAnchor:iconView.trailingAnchor constant:9],
        [titleLabel.topAnchor constraintEqualToAnchor:reminderView.topAnchor constant:12],
        [titleLabel.trailingAnchor constraintEqualToAnchor:reminderView.trailingAnchor constant:-14],

        [messageLabel.leadingAnchor constraintEqualToAnchor:titleLabel.leadingAnchor],
        [messageLabel.trailingAnchor constraintEqualToAnchor:titleLabel.trailingAnchor],
        [messageLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:3],
        [messageLabel.bottomAnchor constraintEqualToAnchor:reminderView.bottomAnchor constant:-12],
    ]];
}

- (void)setupMessages {
    self.messages = [[self loadMessagesForCurrentRoom] mutableCopy];

    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.backgroundColor = UIColor.clearColor;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 130.0;
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [tableView registerClass:ChatMessageCell.class forCellReuseIdentifier:kChatMessageCellIdentifier];
    [self.view addSubview:tableView];
    self.messageTableView = tableView;

    [NSLayoutConstraint activateConstraints:@[
        [tableView.topAnchor constraintEqualToAnchor:self.communityReminderView.bottomAnchor constant:14],
        [tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [tableView.bottomAnchor constraintEqualToAnchor:self.inputBar.topAnchor constant:-18],
    ]];
}

- (void)setupInputBar {
    UIView *inputBar = [[UIView alloc] init];
    inputBar.backgroundColor = UIColor.whiteColor;
    inputBar.layer.cornerRadius = 27.5;
    inputBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.inputBar = inputBar;

    UITextField *textField = [[UITextField alloc] init];
    textField.backgroundColor = UIColor.clearColor;
    textField.font = [DesignFonts regular:15];
    textField.textColor = [UIColor colorWithRed:0.18 green:0.18 blue:0.22 alpha:1.0];
    textField.returnKeyType = UIReturnKeySend;
    textField.delegate = self;
    textField.placeholder = @"Please enter…";
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    self.messageInputField = textField;

    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.backgroundColor = [UIColor colorWithRed:0.57 green:0.89 blue:0.67 alpha:1.0];
    sendButton.layer.cornerRadius = 24;
    UIImage *sendImage = [[UIImage systemImageNamed:@"paperplane.fill"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [sendButton setImage:sendImage forState:UIControlStateNormal];
    sendButton.tintColor = [UIColor colorWithRed:0.17 green:0.24 blue:0.22 alpha:1.0];
    sendButton.translatesAutoresizingMaskIntoConstraints = NO;
    [sendButton addTarget:self action:@selector(sendCurrentMessage) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:inputBar];
    [inputBar addSubview:textField];
    [inputBar addSubview:sendButton];

    self.inputBarBottomConstraint = [inputBar.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-10];
    [NSLayoutConstraint activateConstraints:@[
        [inputBar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kChatSidePadding],
        [inputBar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-kChatSidePadding],
        self.inputBarBottomConstraint,
        [inputBar.heightAnchor constraintEqualToConstant:55],

        [sendButton.trailingAnchor constraintEqualToAnchor:inputBar.trailingAnchor constant:-4],
        [sendButton.centerYAnchor constraintEqualToAnchor:inputBar.centerYAnchor],
        [sendButton.widthAnchor constraintEqualToConstant:48],
        [sendButton.heightAnchor constraintEqualToConstant:48],

        [textField.leadingAnchor constraintEqualToAnchor:inputBar.leadingAnchor constant:18],
        [textField.trailingAnchor constraintEqualToAnchor:sendButton.leadingAnchor constant:-8],
        [textField.topAnchor constraintEqualToAnchor:inputBar.topAnchor],
        [textField.bottomAnchor constraintEqualToAnchor:inputBar.bottomAnchor],
    ]];
}

- (void)setupKeyboardHandling {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.messageTableView addGestureRecognizer:tap];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardFrameInView = [self.view convertRect:keyboardFrame fromView:nil];
    CGFloat safeAreaBottomY = CGRectGetMaxY(self.view.safeAreaLayoutGuide.layoutFrame);
    CGFloat keyboardOverlap = MAX(0.0, safeAreaBottomY - CGRectGetMinY(keyboardFrameInView));
    self.inputBarBottomConstraint.constant = keyboardOverlap > 0.0 ? -(keyboardOverlap + 8.0) : -10.0;

    [self animateKeyboardLayoutWithNotification:notification completion:^{
        [self scrollToLatestMessageIfNeededAnimated:NO];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.inputBarBottomConstraint.constant = -10.0;
    [self animateKeyboardLayoutWithNotification:notification completion:nil];
}

- (void)animateKeyboardLayoutWithNotification:(NSNotification *)notification completion:(void (^)(void))completion {
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = ([notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16);
    [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (completion) completion();
    }];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:kChatMessageCellIdentifier forIndexPath:indexPath];
    NSDictionary *message = self.messages[indexPath.row];
    BOOL incoming = [message[@"incoming"] boolValue];
    NSString *avatarName = [self avatarNameForMessage:message incoming:incoming index:indexPath.row];
    [cell configureWithText:message[@"text"] incoming:incoming avatarName:avatarName];
    cell.reportButton.tag = indexPath.row;
    [cell.reportButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    [cell.reportButton addTarget:self action:@selector(didTapReportMessageButton:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 130.0;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self sendCurrentMessage];
    return NO;
}

#pragma mark - Actions

- (void)sendCurrentMessage {
    NSString *text = [self.messageInputField.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (text.length == 0) return;

    [self.messages addObject:@{@"text": text, @"incoming": @NO, @"avatar": @"avatar_user_12"}];
    [self persistMessagesForCurrentRoom];
    self.messageInputField.text = nil;

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
    [self.messageTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    [self.messageTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)didTapMoreButton:(UIButton *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"Report" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self showReportSubmittedAlert];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

    alert.popoverPresentationController.sourceView = sender;
    alert.popoverPresentationController.sourceRect = sender.bounds;
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didTapReportMessageButton:(UIButton *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Report message?"
                                                                   message:@"This message will be sent to the team for review."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Report" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self showReportSubmittedAlert];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showReportSubmittedAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Report submitted"
                                                                   message:@"Thanks for helping keep the community safe."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didTapBackButton {
    if (self.navigationController && self.navigationController.viewControllers.firstObject != self) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    if (self.navigationController.presentingViewController) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return;
    }

    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }

    self.tabBarController.selectedIndex = 1;
}

#pragma mark - Components

- (UIImageView *)imageViewWithName:(NSString *)name {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    return imageView;
}

- (UILabel *)labelWithText:(NSString *)text font:(UIFont *)font color:(UIColor *)color {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = font;
    label.textColor = color;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    return label;
}

- (NSString *)resolvedRoomName {
    return self.roomName.length > 0 ? self.roomName : @"Powder Pals";
}

- (NSString *)resolvedRoomOnlineText {
    return self.roomOnlineText.length > 0 ? self.roomOnlineText : @"12 online";
}

- (NSString *)resolvedRoomDescription {
    return self.roomDescription.length > 0 ? self.roomDescription : @"Share slope plans and mountain updates.";
}

- (NSArray<NSDictionary *> *)defaultMessages {
    NSString *roomName = [self resolvedRoomName];
    return @[
        @{@"text": [NSString stringWithFormat:@"Welcome to %@. Share mountain updates, plans, and helpful tips.", roomName], @"incoming": @YES, @"avatar": @"avatar_user_11"},
        @{@"text": @"Anyone on the slopes today? Drop snow conditions, lift lines, or meetup plans here.", @"incoming": @YES, @"avatar": @"avatar_user_13"},
    ];
}

- (NSArray<NSDictionary *> *)loadMessagesForCurrentRoom {
    NSArray *storedMessages = [NSUserDefaults.standardUserDefaults objectForKey:[self messagesDefaultsKey]];
    NSArray<NSDictionary *> *validatedMessages = [self validatedMessagesFromArray:storedMessages];
    if (validatedMessages.count > 0) {
        NSArray<NSDictionary *> *visibleMessages = [self messagesByRemovingLegacyDefaultOutgoingMessages:validatedMessages];
        if (visibleMessages.count != validatedMessages.count) {
            [NSUserDefaults.standardUserDefaults setObject:visibleMessages forKey:[self messagesDefaultsKey]];
            [NSUserDefaults.standardUserDefaults synchronize];
        }
        if (visibleMessages.count > 0) {
            return visibleMessages;
        }
    }

    NSArray<NSDictionary *> *messages = [self defaultMessages];
    [NSUserDefaults.standardUserDefaults setObject:messages forKey:[self messagesDefaultsKey]];
    [NSUserDefaults.standardUserDefaults synchronize];
    return messages;
}

- (void)persistMessagesForCurrentRoom {
    [NSUserDefaults.standardUserDefaults setObject:self.messages forKey:[self messagesDefaultsKey]];
    [NSUserDefaults.standardUserDefaults synchronize];
}

- (NSArray<NSDictionary *> *)validatedMessagesFromArray:(NSArray *)array {
    if (![array isKindOfClass:NSArray.class]) {
        return @[];
    }

    NSMutableArray<NSDictionary *> *messages = [NSMutableArray arrayWithCapacity:array.count];
    for (id item in array) {
        if (![item isKindOfClass:NSDictionary.class]) {
            continue;
        }

        NSDictionary *message = (NSDictionary *)item;
        NSString *text = message[@"text"];
        id incomingValue = message[@"incoming"];
        NSString *avatar = message[@"avatar"];
        if (![text isKindOfClass:NSString.class] || text.length == 0 ||
            ![incomingValue respondsToSelector:@selector(boolValue)]) {
            continue;
        }

        NSMutableDictionary *validatedMessage = [@{@"text": text, @"incoming": @([incomingValue boolValue])} mutableCopy];
        if ([avatar isKindOfClass:NSString.class] && avatar.length > 0) {
            validatedMessage[@"avatar"] = avatar;
        }
        [messages addObject:validatedMessage.copy];
    }

    return messages.copy;
}

- (NSArray<NSDictionary *> *)messagesByRemovingLegacyDefaultOutgoingMessages:(NSArray<NSDictionary *> *)messages {
    NSMutableArray<NSDictionary *> *visibleMessages = [NSMutableArray arrayWithCapacity:messages.count];
    for (NSDictionary *message in messages) {
        NSString *text = message[@"text"];
        BOOL incoming = [message[@"incoming"] boolValue];
        BOOL isLegacyDefaultOutgoing = !incoming && [text isEqualToString:@"Hello, may I invite you to have\ndinner together?"];
        if (!isLegacyDefaultOutgoing) {
            [visibleMessages addObject:message];
        }
    }
    return visibleMessages.copy;
}

- (NSString *)avatarNameForMessage:(NSDictionary *)message incoming:(BOOL)incoming index:(NSInteger)index {
    NSString *avatar = message[@"avatar"];
    if (!incoming) {
        return @"avatar_user_12";
    }

    if ([avatar isKindOfClass:NSString.class] && avatar.length > 0) {
        return avatar;
    }

    NSArray<NSString *> *incomingAvatars = @[@"avatar_user_11", @"avatar_user_12", @"avatar_user_13"];
    return incomingAvatars[index % incomingAvatars.count];
}

- (NSString *)messagesDefaultsKey {
    NSString *roomKey = [self resolvedRoomName];
    return [kChatRoomMessagesDefaultsPrefix stringByAppendingString:roomKey];
}

- (UIImage *)thumbnailForVideoNamed:(NSString *)videoName {
    NSString *path = [[NSBundle mainBundle] pathForResource:videoName ofType:@"mp4"];
    if (!path) return nil;

    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:path] options:nil];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    generator.maximumSize = CGSizeMake(360, 360);

    NSError *error = nil;
    CGImageRef imageRef = [generator copyCGImageAtTime:CMTimeMakeWithSeconds(0.8, 600)
                                            actualTime:nil
                                                 error:&error];
    if (!imageRef || error) return nil;

    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return image;
}

- (void)scrollToLatestMessageIfNeededAnimated:(BOOL)animated {
    if (self.messages.count == 0 || !self.messageTableView) {
        return;
    }

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
    [self.messageTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
}

@end
