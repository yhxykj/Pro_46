//
//  FriendsChatViewController.m
//  Skiing
//

#import "FriendsChatViewController.h"
#import "AIChatViewController.h"
#import "FriendChatViewController.h"
#import "FriendRequestViewController.h"
#import "EmptyStateView.h"
#import "DesignTokens.h"
#import "FriendshipStore.h"

static CGFloat const kFriendsChatSidePadding = 22.0;
static NSString * const kFriendsChatCellIdentifier = @"FriendsChatCell";
static NSString * const kFriendChatMessagesDefaultsPrefix = @"kFriendChatMessagesDefaultsPrefix.";

@interface FriendsChatCell : UITableViewCell
- (void)configureWithName:(NSString *)name message:(NSString *)message time:(NSString *)time avatarName:(NSString *)avatarName;
@end

@interface FriendsChatCell ()
@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *badgeLabel;
@property (nonatomic, strong) UIImageView *avatarImageView;
@end

@implementation FriendsChatCell

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

    self.cardView = [[UIView alloc] init];
    self.cardView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.42];
    self.cardView.layer.cornerRadius = 16.0;
    self.cardView.translatesAutoresizingMaskIntoConstraints = NO;

    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = [DesignFonts semibold:16];
    self.nameLabel.textColor = [UIColor colorWithRed:0.18 green:0.18 blue:0.23 alpha:1.0];
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;

    self.messageLabel = [[UILabel alloc] init];
    self.messageLabel.font = [DesignFonts regular:15];
    self.messageLabel.textColor = [UIColor colorWithRed:0.22 green:0.22 blue:0.28 alpha:1.0];
    self.messageLabel.translatesAutoresizingMaskIntoConstraints = NO;

    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.font = [DesignFonts regular:13];
    self.timeLabel.textColor = [UIColor colorWithRed:0.49 green:0.49 blue:0.56 alpha:1.0];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    self.timeLabel.translatesAutoresizingMaskIntoConstraints = NO;

    self.badgeLabel = [[UILabel alloc] init];
    self.badgeLabel.text = @"1";
    self.badgeLabel.font = [DesignFonts semibold:12];
    self.badgeLabel.textColor = UIColor.whiteColor;
    self.badgeLabel.textAlignment = NSTextAlignmentCenter;
    self.badgeLabel.backgroundColor = [UIColor colorWithRed:1.0 green:0.16 blue:0.17 alpha:1.0];
    self.badgeLabel.layer.cornerRadius = 10.0;
    self.badgeLabel.clipsToBounds = YES;
    self.badgeLabel.translatesAutoresizingMaskIntoConstraints = NO;

    self.avatarImageView = [[UIImageView alloc] init];
    self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 31.0;
    self.avatarImageView.layer.borderWidth = 2.0;
    self.avatarImageView.layer.borderColor = UIColor.whiteColor.CGColor;
    self.avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.contentView addSubview:self.cardView];
    [self.cardView addSubview:self.nameLabel];
    [self.cardView addSubview:self.messageLabel];
    [self.cardView addSubview:self.timeLabel];
    [self.cardView addSubview:self.badgeLabel];
    [self.contentView addSubview:self.avatarImageView];

    [NSLayoutConstraint activateConstraints:@[
        [self.avatarImageView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-22.0],
        [self.avatarImageView.centerYAnchor constraintEqualToAnchor:self.cardView.centerYAnchor],
        [self.avatarImageView.widthAnchor constraintEqualToConstant:62.0],
        [self.avatarImageView.heightAnchor constraintEqualToConstant:62.0],

        [self.cardView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:kFriendsChatSidePadding],
        [self.cardView.trailingAnchor constraintEqualToAnchor:self.avatarImageView.leadingAnchor constant:-16.0],
        [self.cardView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
        [self.cardView.heightAnchor constraintEqualToConstant:92.0],
        [self.cardView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-22.0],

        [self.nameLabel.leadingAnchor constraintEqualToAnchor:self.cardView.leadingAnchor constant:20.0],
        [self.nameLabel.topAnchor constraintEqualToAnchor:self.cardView.topAnchor constant:20.0],
        [self.nameLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.timeLabel.leadingAnchor constant:-10.0],

        [self.timeLabel.trailingAnchor constraintEqualToAnchor:self.cardView.trailingAnchor constant:-38.0],
        [self.timeLabel.centerYAnchor constraintEqualToAnchor:self.nameLabel.centerYAnchor],
        [self.timeLabel.widthAnchor constraintEqualToConstant:58.0],

        [self.messageLabel.leadingAnchor constraintEqualToAnchor:self.nameLabel.leadingAnchor],
        [self.messageLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.badgeLabel.leadingAnchor constant:-12.0],
        [self.messageLabel.topAnchor constraintEqualToAnchor:self.nameLabel.bottomAnchor constant:17.0],

        [self.badgeLabel.trailingAnchor constraintEqualToAnchor:self.cardView.trailingAnchor constant:-18.0],
        [self.badgeLabel.centerYAnchor constraintEqualToAnchor:self.messageLabel.centerYAnchor],
        [self.badgeLabel.widthAnchor constraintEqualToConstant:20.0],
        [self.badgeLabel.heightAnchor constraintEqualToConstant:20.0],
    ]];
}

- (void)configureWithName:(NSString *)name message:(NSString *)message time:(NSString *)time avatarName:(NSString *)avatarName {
    self.nameLabel.text = name;
    self.messageLabel.text = message;
    self.timeLabel.text = time;
    self.avatarImageView.image = [UIImage imageNamed:avatarName];
}

@end

@interface FriendsChatViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) CAGradientLayer *backgroundGradientLayer;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) EmptyStateView *emptyStateView;
@property (nonatomic, copy) NSArray<NSDictionary<NSString *, NSString *> *> *items;
@end

@implementation FriendsChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.75 green:0.78 blue:1.0 alpha:1.0];
    self.items = @[];
    [self setupBackground];
    [self setupContent];
    [self updateEmptyState];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self reloadFriendChatItems];
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
        (__bridge id)[UIColor colorWithRed:0.77 green:0.79 blue:1.0 alpha:1.0].CGColor
    ];
    self.backgroundGradientLayer.startPoint = CGPointMake(0.5, 0.0);
    self.backgroundGradientLayer.endPoint = CGPointMake(0.5, 1.0);
    [self.view.layer insertSublayer:self.backgroundGradientLayer atIndex:0];
}

- (void)setupContent {
    UIImageView *titleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"message_friends_chat_title"]];
    titleImageView.contentMode = UIViewContentModeScaleAspectFit;
    titleImageView.translatesAutoresizingMaskIntoConstraints = NO;

    UIButton *addFriendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addFriendButton setImage:[UIImage imageNamed:@"message_add_friend_icon"] forState:UIControlStateNormal];
    addFriendButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    addFriendButton.translatesAutoresizingMaskIntoConstraints = NO;
    [addFriendButton addTarget:self action:@selector(didTapAddFriendButton) forControlEvents:UIControlEventTouchUpInside];

    UIView *dotView = [[UIView alloc] init];
    dotView.backgroundColor = [UIColor colorWithRed:1.0 green:0.16 blue:0.43 alpha:1.0];
    dotView.layer.cornerRadius = 5.0;
    dotView.translatesAutoresizingMaskIntoConstraints = NO;
    dotView.userInteractionEnabled = NO;

    UIImageView *bannerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"message_skigpt_banner"]];
    bannerImageView.contentMode = UIViewContentModeScaleAspectFill;
    bannerImageView.clipsToBounds = YES;
    bannerImageView.layer.cornerRadius = 20.0;
    bannerImageView.userInteractionEnabled = YES;
    bannerImageView.translatesAutoresizingMaskIntoConstraints = NO;
    UITapGestureRecognizer *bannerTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAIChatBanner)];
    [bannerImageView addGestureRecognizer:bannerTapGesture];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = UIColor.clearColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 114.0;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView registerClass:FriendsChatCell.class forCellReuseIdentifier:kFriendsChatCellIdentifier];

    self.emptyStateView = [[EmptyStateView alloc] initWithText:@"No data available"];
    self.emptyStateView.hidden = YES;

    [self.view addSubview:titleImageView];
    [self.view addSubview:addFriendButton];
    [addFriendButton addSubview:dotView];
    [self.view addSubview:bannerImageView];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.emptyStateView];

    [NSLayoutConstraint activateConstraints:@[
        [titleImageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kFriendsChatSidePadding],
        [titleImageView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:12],
        [titleImageView.widthAnchor constraintEqualToConstant:192.0],
        [titleImageView.heightAnchor constraintEqualToConstant:29.0],

        [addFriendButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-24.0],
        [addFriendButton.centerYAnchor constraintEqualToAnchor:titleImageView.centerYAnchor],
        [addFriendButton.widthAnchor constraintEqualToConstant:32.0],
        [addFriendButton.heightAnchor constraintEqualToConstant:32.0],

        [dotView.trailingAnchor constraintEqualToAnchor:addFriendButton.trailingAnchor constant:0.0],
        [dotView.topAnchor constraintEqualToAnchor:addFriendButton.topAnchor constant:0.0],
        [dotView.widthAnchor constraintEqualToConstant:10.0],
        [dotView.heightAnchor constraintEqualToConstant:10.0],

        [bannerImageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kFriendsChatSidePadding],
        [bannerImageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-kFriendsChatSidePadding],
        [bannerImageView.topAnchor constraintEqualToAnchor:titleImageView.bottomAnchor constant:28.0],
        [bannerImageView.heightAnchor constraintEqualToAnchor:bannerImageView.widthAnchor multiplier:113.0 / 358.0],

        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.topAnchor constraintEqualToAnchor:bannerImageView.bottomAnchor constant:32.0],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],

        [self.emptyStateView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.emptyStateView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.emptyStateView.topAnchor constraintEqualToAnchor:bannerImageView.bottomAnchor],
        [self.emptyStateView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
    ]];
}

- (void)updateEmptyState {
    BOOL isEmpty = self.items.count == 0;
    self.emptyStateView.hidden = !isEmpty;
    self.tableView.hidden = isEmpty;
}

- (void)reloadFriendChatItems {
    NSMutableArray<NSDictionary<NSString *, NSString *> *> *items = [NSMutableArray array];
    for (NSDictionary *friend in [FriendshipStore friends]) {
        NSDictionary<NSString *, NSString *> *item = [self chatListItemForFriend:friend];
        if (item) {
            [items addObject:item];
        }
    }

    [items sortUsingComparator:^NSComparisonResult(NSDictionary<NSString *,NSString *> *first, NSDictionary<NSString *,NSString *> *second) {
        NSTimeInterval firstTime = [first[@"timestamp"] doubleValue];
        NSTimeInterval secondTime = [second[@"timestamp"] doubleValue];
        if (firstTime > secondTime) return NSOrderedAscending;
        if (firstTime < secondTime) return NSOrderedDescending;
        return NSOrderedSame;
    }];

    self.items = items.copy;
    [self.tableView reloadData];
    [self updateEmptyState];
}

- (NSDictionary<NSString *, NSString *> *)chatListItemForFriend:(NSDictionary *)friend {
    NSString *name = [self cleanString:friend[@"name"] fallback:@"Unknown"];
    NSString *handle = [self cleanString:friend[@"handle"] fallback:@""];
    NSString *avatar = [self cleanString:friend[@"avatar"] fallback:@"avatar_placeholder"];
    NSArray<NSDictionary<NSString *, id> *> *messages = [self messagesForFriendName:name handle:handle avatar:avatar];
    NSDictionary<NSString *, id> *lastMessage = messages.lastObject;
    NSString *messageText = lastMessage[@"text"];
    if (![messageText isKindOfClass:NSString.class] || messageText.length == 0) {
        return nil;
    }

    NSNumber *timestamp = lastMessage[@"timestamp"];
    NSTimeInterval timestampValue = [timestamp respondsToSelector:@selector(doubleValue)] ? timestamp.doubleValue : NSDate.date.timeIntervalSince1970;
    return @{@"name": name,
             @"handle": handle,
             @"avatar": avatar,
             @"message": messageText,
             @"time": [self displayTimeForTimestamp:timestampValue],
             @"timestamp": [NSString stringWithFormat:@"%.0f", timestampValue]};
}

- (NSArray<NSDictionary<NSString *, id> *> *)messagesForFriendName:(NSString *)name handle:(NSString *)handle avatar:(NSString *)avatar {
    NSArray *storedMessages = [NSUserDefaults.standardUserDefaults objectForKey:[self messagesDefaultsKeyForName:name handle:handle avatar:avatar]];
    if (![storedMessages isKindOfClass:NSArray.class]) {
        return @[];
    }

    NSMutableArray<NSDictionary<NSString *, id> *> *messages = [NSMutableArray arrayWithCapacity:storedMessages.count];
    for (id item in storedMessages) {
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

        NSMutableDictionary<NSString *, id> *cleanMessage = [@{@"text": text,
                                                               @"incoming": @([incomingValue boolValue])} mutableCopy];
        id timestamp = message[@"timestamp"];
        if ([timestamp respondsToSelector:@selector(doubleValue)]) {
            cleanMessage[@"timestamp"] = @([timestamp doubleValue]);
        }
        [messages addObject:cleanMessage.copy];
    }

    return messages.copy;
}

- (NSString *)messagesDefaultsKeyForName:(NSString *)name handle:(NSString *)handle avatar:(NSString *)avatar {
    NSString *identity = handle.length > 0 ? handle : [NSString stringWithFormat:@"%@.%@", name, avatar];
    return [kFriendChatMessagesDefaultsPrefix stringByAppendingString:[self normalizedDefaultsKeyComponentFromString:identity]];
}

- (NSString *)normalizedDefaultsKeyComponentFromString:(NSString *)string {
    NSCharacterSet *allowedCharacters = NSCharacterSet.alphanumericCharacterSet;
    NSMutableString *normalizedString = [NSMutableString string];
    for (NSUInteger index = 0; index < string.length; index++) {
        unichar character = [string characterAtIndex:index];
        if ([allowedCharacters characterIsMember:character]) {
            [normalizedString appendFormat:@"%C", character];
        } else {
            [normalizedString appendString:@"_"];
        }
    }

    return normalizedString.length > 0 ? normalizedString : @"default";
}

- (NSString *)cleanString:(id)value fallback:(NSString *)fallback {
    if (![value isKindOfClass:NSString.class]) {
        return fallback;
    }

    NSString *trimmedValue = [(NSString *)value stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    return trimmedValue.length > 0 ? trimmedValue : fallback;
}

- (NSString *)displayTimeForTimestamp:(NSTimeInterval)timestamp {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale currentLocale];
    formatter.dateFormat = [NSCalendar.currentCalendar isDateInToday:date] ? @"HH:mm" : @"MM/dd";
    return [formatter stringFromDate:date];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendsChatCell *cell = [tableView dequeueReusableCellWithIdentifier:kFriendsChatCellIdentifier forIndexPath:indexPath];
    NSDictionary<NSString *, NSString *> *item = self.items[indexPath.row];
    [cell configureWithName:item[@"name"]
                    message:item[@"message"]
                       time:item[@"time"]
                 avatarName:item[@"avatar"]];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary<NSString *, NSString *> *item = self.items[indexPath.row];
    FriendChatViewController *chatViewController = [[FriendChatViewController alloc] init];
    chatViewController.chatTitle = item[@"name"];
    chatViewController.peerHandle = item[@"handle"];
    chatViewController.peerAvatarName = item[@"avatar"];
    chatViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatViewController animated:YES];
}

- (void)didTapAddFriendButton {
    FriendRequestViewController *friendRequestViewController = [[FriendRequestViewController alloc] init];
    friendRequestViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:friendRequestViewController animated:YES];
}

- (void)didTapAIChatBanner {
    AIChatViewController *aiChatViewController = [[AIChatViewController alloc] init];
    aiChatViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:aiChatViewController animated:YES];
}

@end
