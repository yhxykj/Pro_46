//
//  AIChatViewController.m
//  Skiing
//

#import "AIChatViewController.h"
#import "DesignTokens.h"
#import "CoinBalanceStore.h"

static CGFloat const kAIChatSidePadding = 18.0;
static NSInteger const kAIChatMessageCost = 19;
static NSString * const kAIChatMessageCellIdentifier = @"AIChatMessageCell";
static NSString * const kAIChatMessagesDefaultsKey = @"kAIChatMessagesDefaultsKey";

@interface AIChatMessageCell : UITableViewCell
- (void)configureWithText:(NSString *)text incoming:(BOOL)incoming;
@end

@interface AIChatMessageCell ()
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIView *bubbleView;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) NSLayoutConstraint *bubbleWidthConstraint;
@property (nonatomic, copy) NSArray<NSLayoutConstraint *> *incomingConstraints;
@property (nonatomic, copy) NSArray<NSLayoutConstraint *> *outgoingConstraints;
@end

@implementation AIChatMessageCell

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
    self.avatarImageView.layer.cornerRadius = 17.0;
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

    self.bubbleWidthConstraint = [self.bubbleView.widthAnchor constraintEqualToConstant:258.0];
    self.incomingConstraints = @[
        [self.avatarImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:kAIChatSidePadding],
        [self.bubbleView.leadingAnchor constraintEqualToAnchor:self.avatarImageView.trailingAnchor constant:16.0],
        [self.timeLabel.leadingAnchor constraintEqualToAnchor:self.bubbleView.leadingAnchor],
    ];
    self.outgoingConstraints = @[
        [self.avatarImageView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-kAIChatSidePadding],
        [self.bubbleView.trailingAnchor constraintEqualToAnchor:self.avatarImageView.leadingAnchor constant:-12.0],
        [self.timeLabel.trailingAnchor constraintEqualToAnchor:self.bubbleView.trailingAnchor],
    ];

    [NSLayoutConstraint activateConstraints:@[
        [self.avatarImageView.widthAnchor constraintEqualToConstant:34.0],
        [self.avatarImageView.heightAnchor constraintEqualToConstant:34.0],
        [self.avatarImageView.centerYAnchor constraintEqualToAnchor:self.bubbleView.centerYAnchor],

        [self.bubbleView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:8.0],
        self.bubbleWidthConstraint,
        [self.bubbleView.heightAnchor constraintGreaterThanOrEqualToConstant:72.0],

        [self.messageLabel.leadingAnchor constraintEqualToAnchor:self.bubbleView.leadingAnchor constant:20.0],
        [self.messageLabel.trailingAnchor constraintEqualToAnchor:self.bubbleView.trailingAnchor constant:-18.0],
        [self.messageLabel.topAnchor constraintEqualToAnchor:self.bubbleView.topAnchor constant:15.0],
        [self.messageLabel.bottomAnchor constraintEqualToAnchor:self.bubbleView.bottomAnchor constant:-15.0],

        [self.timeLabel.topAnchor constraintEqualToAnchor:self.bubbleView.bottomAnchor constant:8.0],
        [self.timeLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-28.0],
    ]];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [NSLayoutConstraint deactivateConstraints:self.incomingConstraints];
    [NSLayoutConstraint deactivateConstraints:self.outgoingConstraints];
}

- (void)configureWithText:(NSString *)text incoming:(BOOL)incoming {
    self.messageLabel.text = text;
    self.avatarImageView.image = [UIImage imageNamed:incoming ? @"ai_chat_avatar" : @"avatar_user_12"];
    self.bubbleView.backgroundColor = incoming ? UIColor.whiteColor : [UIColor colorWithRed:0.58 green:0.90 blue:0.67 alpha:1.0];
    self.bubbleWidthConstraint.constant = incoming ? 258.0 : 270.0;
    [NSLayoutConstraint deactivateConstraints:self.incomingConstraints];
    [NSLayoutConstraint deactivateConstraints:self.outgoingConstraints];
    [NSLayoutConstraint activateConstraints:incoming ? self.incomingConstraints : self.outgoingConstraints];
}

@end

@interface AIChatViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) CAGradientLayer *backgroundGradientLayer;
@property (nonatomic, strong) UIImageView *bannerImageView;
@property (nonatomic, strong) UITableView *messageTableView;
@property (nonatomic, strong) UIView *inputBar;
@property (nonatomic, strong) UITextField *messageInputField;
@property (nonatomic, strong) NSMutableArray<NSDictionary<NSString *, id> *> *messages;
@property (nonatomic, strong) NSLayoutConstraint *inputBarBottomConstraint;
@property (nonatomic, strong) UIView *costPromptOverlayView;
@property (nonatomic, strong) UIView *costPromptDialogView;
@property (nonatomic, copy) NSString *pendingCostPromptText;
@property (nonatomic, assign, getter=hasShownCostPrompt) BOOL shownCostPrompt;
@end

@implementation AIChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.75 green:0.78 blue:1.0 alpha:1.0];
    self.messages = [[self loadMessages] mutableCopy];

    [self setupBackground];
    [self setupBanner];
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
    self.backgroundGradientLayer.frame = self.view.bounds;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self scrollToLatestMessageIfNeededAnimated:NO];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDarkContent;
}

#pragma mark - Setup

- (void)setupBackground {
    self.backgroundGradientLayer = [CAGradientLayer layer];
    self.backgroundGradientLayer.colors = @[
        (__bridge id)[UIColor colorWithRed:0.55 green:0.59 blue:0.94 alpha:1.0].CGColor,
        (__bridge id)[UIColor colorWithRed:0.79 green:0.81 blue:1.0 alpha:1.0].CGColor
    ];
    self.backgroundGradientLayer.startPoint = CGPointMake(0.5, 0.0);
    self.backgroundGradientLayer.endPoint = CGPointMake(0.5, 1.0);
    [self.view.layer insertSublayer:self.backgroundGradientLayer atIndex:0];
}

- (void)setupBanner {
    self.bannerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ai_chat_banner"]];
    self.bannerImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.bannerImageView.clipsToBounds = YES;
    self.bannerImageView.layer.cornerRadius = 18.0;
    self.bannerImageView.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
    self.bannerImageView.translatesAutoresizingMaskIntoConstraints = NO;

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
    backButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [backButton addTarget:self action:@selector(didTapBackButton) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.bannerImageView];
    [self.view addSubview:backButton];

    [NSLayoutConstraint activateConstraints:@[
        [self.bannerImageView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.bannerImageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.bannerImageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.bannerImageView.heightAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:414.0 / 780.0],

        [backButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kAIChatSidePadding],
        [backButton.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:12],
        [backButton.widthAnchor constraintEqualToConstant:44.0],
        [backButton.heightAnchor constraintEqualToConstant:44.0],
    ]];
}

- (void)setupMessages {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.backgroundColor = UIColor.clearColor;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 132.0;
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [tableView registerClass:AIChatMessageCell.class forCellReuseIdentifier:kAIChatMessageCellIdentifier];
    [self.view addSubview:tableView];
    self.messageTableView = tableView;

    [NSLayoutConstraint activateConstraints:@[
        [tableView.topAnchor constraintEqualToAnchor:self.bannerImageView.bottomAnchor constant:24.0],
        [tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [tableView.bottomAnchor constraintEqualToAnchor:self.inputBar.topAnchor constant:-16.0],
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
    [inputBar addSubview:textField];
    [inputBar addSubview:sendButton];

    self.inputBarBottomConstraint = [inputBar.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-10.0];
    [NSLayoutConstraint activateConstraints:@[
        [inputBar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kAIChatSidePadding],
        [inputBar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-kAIChatSidePadding],
        self.inputBarBottomConstraint,
        [inputBar.heightAnchor constraintEqualToConstant:55.0],

        [sendButton.trailingAnchor constraintEqualToAnchor:inputBar.trailingAnchor constant:-4.0],
        [sendButton.centerYAnchor constraintEqualToAnchor:inputBar.centerYAnchor],
        [sendButton.widthAnchor constraintEqualToConstant:48.0],
        [sendButton.heightAnchor constraintEqualToConstant:48.0],

        [textField.leadingAnchor constraintEqualToAnchor:inputBar.leadingAnchor constant:22.0],
        [textField.trailingAnchor constraintEqualToAnchor:sendButton.leadingAnchor constant:-10.0],
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
    AIChatMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:kAIChatMessageCellIdentifier forIndexPath:indexPath];
    NSDictionary<NSString *, id> *message = self.messages[indexPath.row];
    [cell configureWithText:message[@"text"] incoming:[message[@"incoming"] boolValue]];
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

    if (!self.hasShownCostPrompt) {
        self.shownCostPrompt = YES;
        self.pendingCostPromptText = text;
        [self showCostPromptDialog];
        return;
    }

    [self sendAIChatText:text];
}

- (void)sendAIChatText:(NSString *)text {
    if (text.length == 0) {
        return;
    }

    if (![CoinBalanceStore spendCoins:kAIChatMessageCost]) {
        [self showInsufficientCoinsAlert];
        return;
    }

    [self.messages addObject:@{@"text": text, @"incoming": @NO}];
    [self persistMessages];
    self.messageInputField.text = nil;

    NSIndexPath *userIndexPath = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
    [self.messageTableView insertRowsAtIndexPaths:@[userIndexPath] withRowAnimation:UITableViewRowAnimationBottom];
    [self.messageTableView scrollToRowAtIndexPath:userIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.messages addObject:@{@"text": [self skiAssistantReplyForUserText:text], @"incoming": @YES}];
        [self persistMessages];
        NSIndexPath *replyIndexPath = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
        [self.messageTableView insertRowsAtIndexPaths:@[replyIndexPath] withRowAnimation:UITableViewRowAnimationBottom];
        [self.messageTableView scrollToRowAtIndexPath:replyIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    });
}

- (NSString *)skiAssistantReplyForUserText:(NSString *)text {
    NSString *lowercaseText = text.lowercaseString;
    if ([lowercaseText containsString:@"gear"] || [lowercaseText containsString:@"equipment"] || [lowercaseText containsString:@"boot"] || [lowercaseText containsString:@"ski"]) {
        return @"For ski gear, start with boots that fit snugly, then match skis to your level and terrain. If you're heading for powder, go wider; for groomers, keep them narrower and easier to edge.";
    }

    if ([lowercaseText containsString:@"trip"] || [lowercaseText containsString:@"resort"] || [lowercaseText containsString:@"mountain"] || [lowercaseText containsString:@"where"]) {
        return @"For a ski trip, pick the resort by your crew's level first: Snowbasin for big terrain, Deer Valley for polished groomers, Aspen for a luxury weekend, and Big Sky for wide-open runs.";
    }

    if ([lowercaseText containsString:@"beginner"] || [lowercaseText containsString:@"learn"] || [lowercaseText containsString:@"practice"] || [lowercaseText containsString:@"first"]) {
        return @"For beginner practice, stay on mellow green runs, keep your hands forward, and work on smooth S-turns before adding speed. A lesson on day one saves a lot of bruised confidence.";
    }

    if ([lowercaseText containsString:@"snow"] || [lowercaseText containsString:@"powder"] || [lowercaseText containsString:@"weather"] || [lowercaseText containsString:@"condition"]) {
        return @"For snow conditions, check overnight totals, wind, and lift status before you go. Fresh powder is best early, while groomers usually ski smoother after patrol opens the main lifts.";
    }

    return @"I can help with ski resorts, snow conditions, gear choices, beginner technique, and trip planning. Tell me your level, destination, and what kind of runs you like.";
}

- (NSArray<NSDictionary<NSString *, id> *> *)loadMessages {
    NSArray *storedMessages = [NSUserDefaults.standardUserDefaults objectForKey:kAIChatMessagesDefaultsKey];
    return [self validatedMessagesFromArray:storedMessages];
}

- (void)persistMessages {
    [NSUserDefaults.standardUserDefaults setObject:self.messages forKey:kAIChatMessagesDefaultsKey];
    [NSUserDefaults.standardUserDefaults synchronize];
}

- (NSArray<NSDictionary<NSString *, id> *> *)validatedMessagesFromArray:(NSArray *)array {
    if (![array isKindOfClass:NSArray.class]) {
        return @[];
    }

    NSMutableArray<NSDictionary<NSString *, id> *> *messages = [NSMutableArray arrayWithCapacity:array.count];
    for (id item in array) {
        if (![item isKindOfClass:NSDictionary.class]) {
            continue;
        }

        NSDictionary *message = (NSDictionary *)item;
        NSString *text = message[@"text"];
        id incomingValue = message[@"incoming"];
        if (![text isKindOfClass:NSString.class] || text.length == 0 ||
            ![incomingValue respondsToSelector:@selector(boolValue)]) {
            continue;
        }

        [messages addObject:@{@"text": text, @"incoming": @([incomingValue boolValue])}];
    }

    return messages.copy;
}

- (void)showInsufficientCoinsAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Not enough coins"
                                                                   message:@"Recharge coins to chat with AI."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showCostPromptDialog {
    if (self.costPromptOverlayView.superview) {
        return;
    }

    UIView *overlay = [[UIView alloc] initWithFrame:self.view.bounds];
    overlay.backgroundColor = [[UIColor colorWithRed:0.22 green:0.24 blue:0.43 alpha:1.0] colorWithAlphaComponent:0.68];
    overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:overlay];
    self.costPromptOverlayView = overlay;

    CGFloat dialogWidth = 296.0;
    CGFloat dialogHeight = 298.0;
    UIView *dialog = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.bounds) - dialogWidth) / 2.0,
                                                              (CGRectGetHeight(self.view.bounds) - dialogHeight) / 2.0 - 18.0,
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
    self.costPromptDialogView = dialog;

    CGFloat whiteInset = 16.0;
    CGFloat whiteHeight = 212.0;
    UIView *whitePanel = [[UIView alloc] initWithFrame:CGRectMake(whiteInset, whiteInset, dialogWidth - whiteInset * 2.0, whiteHeight)];
    whitePanel.backgroundColor = UIColor.clearColor;
    [dialog addSubview:whitePanel];

    CAShapeLayer *whiteLayer = [CAShapeLayer layer];
    whiteLayer.fillColor = UIColor.whiteColor.CGColor;
    whiteLayer.path = [self costPromptWhitePanelPathForSize:whitePanel.bounds.size].CGPath;
    [whitePanel.layer addSublayer:whiteLayer];

    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    messageLabel.text = @"No free chats left.\nFurther messages will\ncost 19 coins each.";
    messageLabel.font = [DesignFonts semibold:18];
    messageLabel.textColor = [UIColor colorWithRed:0.20 green:0.20 blue:0.24 alpha:1.0];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.numberOfLines = 3;
    messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [whitePanel addSubview:messageLabel];

    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.backgroundColor = [UIColor colorWithRed:0.18 green:0.18 blue:0.19 alpha:1.0];
    cancelButton.layer.cornerRadius = 10.0;
    cancelButton.titleLabel.font = [DesignFonts semibold:20];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    [cancelButton addTarget:self action:@selector(didTapCostPromptCancel) forControlEvents:UIControlEventTouchUpInside];
    [dialog addSubview:cancelButton];

    UIButton *okButton = [UIButton buttonWithType:UIButtonTypeCustom];
    okButton.backgroundColor = [UIColor colorWithRed:1.0 green:0.94 blue:0.48 alpha:1.0];
    okButton.layer.cornerRadius = 10.0;
    okButton.titleLabel.font = [DesignFonts semibold:20];
    [okButton setTitle:@"Ok" forState:UIControlStateNormal];
    [okButton setTitleColor:[UIColor colorWithRed:0.18 green:0.18 blue:0.23 alpha:1.0] forState:UIControlStateNormal];
    okButton.translatesAutoresizingMaskIntoConstraints = NO;
    [okButton addTarget:self action:@selector(didTapCostPromptOK) forControlEvents:UIControlEventTouchUpInside];
    [dialog addSubview:okButton];

    [NSLayoutConstraint activateConstraints:@[
        [messageLabel.centerXAnchor constraintEqualToAnchor:whitePanel.centerXAnchor],
        [messageLabel.centerYAnchor constraintEqualToAnchor:whitePanel.centerYAnchor constant:-18.0],
        [messageLabel.leadingAnchor constraintEqualToAnchor:whitePanel.leadingAnchor constant:24.0],
        [messageLabel.trailingAnchor constraintEqualToAnchor:whitePanel.trailingAnchor constant:-24.0],

        [cancelButton.leadingAnchor constraintEqualToAnchor:dialog.leadingAnchor constant:24.0],
        [cancelButton.bottomAnchor constraintEqualToAnchor:dialog.bottomAnchor constant:-28.0],
        [cancelButton.widthAnchor constraintEqualToConstant:107.0],
        [cancelButton.heightAnchor constraintEqualToConstant:42.0],

        [okButton.trailingAnchor constraintEqualToAnchor:dialog.trailingAnchor constant:-24.0],
        [okButton.bottomAnchor constraintEqualToAnchor:dialog.bottomAnchor constant:-28.0],
        [okButton.widthAnchor constraintEqualToConstant:107.0],
        [okButton.heightAnchor constraintEqualToConstant:42.0],
    ]];

    dialog.transform = CGAffineTransformMakeScale(0.92, 0.92);
    overlay.alpha = 0.0;
    [UIView animateWithDuration:0.22
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        overlay.alpha = 1.0;
        dialog.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (UIBezierPath *)costPromptWhitePanelPathForSize:(CGSize)size {
    CGFloat radius = 18.0;
    CGFloat notchHeight = 22.0;
    CGFloat bottomY = size.height - notchHeight;
    CGFloat midX = size.width / 2.0;

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(radius, 0.0)];
    [path addLineToPoint:CGPointMake(size.width - radius, 0.0)];
    [path addQuadCurveToPoint:CGPointMake(size.width, radius) controlPoint:CGPointMake(size.width, 0.0)];
    [path addLineToPoint:CGPointMake(size.width, bottomY)];
    [path addLineToPoint:CGPointMake(midX, size.height)];
    [path addLineToPoint:CGPointMake(0.0, bottomY)];
    [path addLineToPoint:CGPointMake(0.0, radius)];
    [path addQuadCurveToPoint:CGPointMake(radius, 0.0) controlPoint:CGPointMake(0.0, 0.0)];
    [path closePath];
    return path;
}

- (void)didTapCostPromptCancel {
    self.pendingCostPromptText = nil;
    [self dismissCostPromptDialogWithCompletion:nil];
}

- (void)didTapCostPromptOK {
    NSString *text = [self.pendingCostPromptText copy];
    self.pendingCostPromptText = nil;
    [self dismissCostPromptDialogWithCompletion:^{
        [self sendAIChatText:text];
    }];
}

- (void)dismissCostPromptDialogWithCompletion:(void (^)(void))completion {
    [UIView animateWithDuration:0.18 animations:^{
        self.costPromptOverlayView.alpha = 0.0;
        self.costPromptDialogView.transform = CGAffineTransformMakeScale(0.94, 0.94);
    } completion:^(BOOL finished) {
        [self.costPromptOverlayView removeFromSuperview];
        self.costPromptOverlayView = nil;
        self.costPromptDialogView = nil;
        if (completion) {
            completion();
        }
    }];
}

- (void)didTapBackButton {
    if (self.navigationController && self.navigationController.viewControllers.firstObject != self) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)scrollToLatestMessageIfNeededAnimated:(BOOL)animated {
    if (self.messages.count == 0 || !self.messageTableView) {
        return;
    }

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
    [self.messageTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
}

@end
