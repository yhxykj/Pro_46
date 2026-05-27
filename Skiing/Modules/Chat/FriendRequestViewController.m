//
//  FriendRequestViewController.m
//  Skiing
//

#import "FriendRequestViewController.h"
#import "EmptyStateView.h"
#import "DesignTokens.h"
#import "FriendshipStore.h"
#import "UserSession.h"

static CGFloat const kFriendRequestSidePadding = 16.0;
static CGFloat const kFriendRequestCardHeight = 82.0;
static CGFloat const kFriendRequestRowHeight = 97.0;
static NSString * const kFriendRequestCellIdentifier = @"FriendRequestCell";
static NSString * const kIncomingFriendRequestsDefaultsKey = @"kIncomingFriendRequestsDefaultsKey";
static NSString * const kIncomingFriendRequestsSeededDefaultsKey = @"kIncomingFriendRequestsSeededV1";
static NSString * const kFriendRequestTestAccountEmail = @"skiing666@gmail.com";

@interface FriendRequestCell : UITableViewCell
@property (nonatomic, strong) UIButton *acceptButton;
- (void)configureWithName:(NSString *)name avatarName:(NSString *)avatarName;
@end

@interface FriendRequestViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) CAGradientLayer *backgroundGradientLayer;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) EmptyStateView *emptyStateView;
@property (nonatomic, strong) NSMutableArray<NSDictionary<NSString *, NSString *> *> *requests;
@end

@implementation FriendRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.75 green:0.78 blue:1.0 alpha:1.0];
    self.requests = [[self incomingFriendRequests] mutableCopy];

    [self setupBackground];
    [self setupContent];
    [self updateEmptyState];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.requests = [[self incomingFriendRequests] mutableCopy];
    [self.tableView reloadData];
    [self updateEmptyState];
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
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
    backButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [backButton addTarget:self action:@selector(didTapBackButton) forControlEvents:UIControlEventTouchUpInside];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Friend request";
    titleLabel.font = [DesignFonts semibold:18];
    titleLabel.textColor = [UIColor colorWithRed:0.18 green:0.18 blue:0.23 alpha:1.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = UIColor.clearColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.tableView.rowHeight = kFriendRequestRowHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView registerClass:FriendRequestCell.class forCellReuseIdentifier:kFriendRequestCellIdentifier];

    self.emptyStateView = [[EmptyStateView alloc] initWithText:@"No data available"];
    self.emptyStateView.hidden = YES;

    [self.view addSubview:backButton];
    [self.view addSubview:titleLabel];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.emptyStateView];

    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [backButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kFriendRequestSidePadding],
        [backButton.topAnchor constraintEqualToAnchor:safeArea.topAnchor constant:12.0],
        [backButton.widthAnchor constraintEqualToConstant:44.0],
        [backButton.heightAnchor constraintEqualToConstant:44.0],

        [titleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [titleLabel.centerYAnchor constraintEqualToAnchor:backButton.centerYAnchor],

        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.topAnchor constraintEqualToAnchor:backButton.bottomAnchor constant:35.0],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [self.emptyStateView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.emptyStateView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.emptyStateView.topAnchor constraintEqualToAnchor:backButton.bottomAnchor],
        [self.emptyStateView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

- (void)updateEmptyState {
    BOOL isEmpty = self.requests.count == 0;
    self.emptyStateView.hidden = !isEmpty;
    self.tableView.hidden = isEmpty;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.requests.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendRequestCell *cell = [tableView dequeueReusableCellWithIdentifier:kFriendRequestCellIdentifier forIndexPath:indexPath];
    NSDictionary<NSString *, NSString *> *request = self.requests[indexPath.row];
    [cell configureWithName:request[@"name"] avatarName:request[@"avatar"]];
    [cell.acceptButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    cell.acceptButton.tag = indexPath.row;
    [cell.acceptButton addTarget:self action:@selector(didTapAcceptButton:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kFriendRequestRowHeight;
}

#pragma mark - Actions

- (void)didTapBackButton {
    if (self.navigationController && self.navigationController.viewControllers.firstObject != self) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didTapAcceptButton:(UIButton *)button {
    NSInteger row = button.tag;
    if (row < 0 || row >= self.requests.count) {
        return;
    }

    NSDictionary<NSString *, NSString *> *request = self.requests[row];
    [FriendshipStore addFriendWithName:request[@"name"] ?: @""
                                handle:request[@"handle"] ?: @""
                                avatar:request[@"avatar"] ?: @""];
    [self.requests removeObjectAtIndex:row];
    [self persistIncomingFriendRequests:self.requests];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.tableView performBatchUpdates:^{
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } completion:^(BOOL finished) {
        [self.tableView reloadData];
        [self updateEmptyState];
    }];
}

- (NSArray<NSDictionary<NSString *, NSString *> *> *)incomingFriendRequests {
    [self seedIncomingFriendRequestsIfNeeded];
    NSArray *storedRequests = [NSUserDefaults.standardUserDefaults objectForKey:[self incomingFriendRequestsDefaultsKey]];
    return [self sanitizedRequestsFromObject:storedRequests];
}

- (void)seedIncomingFriendRequestsIfNeeded {
    if (![self isTestAccount]) {
        return;
    }

    if ([NSUserDefaults.standardUserDefaults boolForKey:[self incomingFriendRequestsSeededDefaultsKey]]) {
        return;
    }

    NSArray<NSDictionary<NSString *, NSString *> *> *requests = [self presetIncomingFriendRequests];
    [NSUserDefaults.standardUserDefaults setObject:requests forKey:[self incomingFriendRequestsDefaultsKey]];
    [NSUserDefaults.standardUserDefaults setBool:YES forKey:[self incomingFriendRequestsSeededDefaultsKey]];
    [NSUserDefaults.standardUserDefaults synchronize];
}

- (NSArray<NSDictionary<NSString *, NSString *> *> *)presetIncomingFriendRequests {
    return @[
        @{@"id": @"@snowqueen", @"name": @"SnowQueen", @"handle": @"@snowqueen", @"avatar": @"avatar_user_06"}
    ];
}

- (void)persistIncomingFriendRequests:(NSArray<NSDictionary<NSString *, NSString *> *> *)requests {
    NSArray<NSDictionary<NSString *, NSString *> *> *sanitizedRequests = [self sanitizedRequestsFromObject:requests];
    [NSUserDefaults.standardUserDefaults setObject:sanitizedRequests forKey:[self incomingFriendRequestsDefaultsKey]];
    [NSUserDefaults.standardUserDefaults synchronize];
}

- (BOOL)isTestAccount {
    return [[[UserSession currentEmail] lowercaseString] isEqualToString:kFriendRequestTestAccountEmail];
}

- (NSString *)incomingFriendRequestsDefaultsKey {
    return [NSString stringWithFormat:@"%@.%@", kIncomingFriendRequestsDefaultsKey, [self accountSuffix]];
}

- (NSString *)incomingFriendRequestsSeededDefaultsKey {
    return [NSString stringWithFormat:@"%@.%@", kIncomingFriendRequestsSeededDefaultsKey, [self accountSuffix]];
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

- (NSArray<NSDictionary<NSString *, NSString *> *> *)sanitizedRequestsFromObject:(id)object {
    if (![object isKindOfClass:NSArray.class]) {
        return @[];
    }

    NSMutableArray<NSDictionary<NSString *, NSString *> *> *requests = [NSMutableArray array];
    for (id item in (NSArray *)object) {
        if (![item isKindOfClass:NSDictionary.class]) {
            continue;
        }

        NSDictionary *request = (NSDictionary *)item;
        NSString *name = request[@"name"];
        NSString *handle = request[@"handle"];
        NSString *avatar = request[@"avatar"];
        if (![name isKindOfClass:NSString.class] || name.length == 0 ||
            ![avatar isKindOfClass:NSString.class] || avatar.length == 0) {
            continue;
        }

        NSString *cleanHandle = [handle isKindOfClass:NSString.class] ? handle : @"";
        NSString *requestID = request[@"id"];
        if (![requestID isKindOfClass:NSString.class] || requestID.length == 0) {
            requestID = cleanHandle.length > 0 ? cleanHandle : [NSString stringWithFormat:@"%@|%@", name.lowercaseString, avatar.lowercaseString];
        }

        [requests addObject:@{@"id": requestID,
                              @"name": name,
                              @"handle": cleanHandle,
                              @"avatar": avatar}];
    }

    return requests.copy;
}

@end

@interface FriendRequestCell ()
@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@end

@implementation FriendRequestCell

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
    self.cardView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.40];
    self.cardView.layer.cornerRadius = 14.0;
    self.cardView.translatesAutoresizingMaskIntoConstraints = NO;

    self.avatarView = [[UIImageView alloc] init];
    self.avatarView.contentMode = UIViewContentModeScaleAspectFill;
    self.avatarView.clipsToBounds = YES;
    self.avatarView.layer.cornerRadius = 23.0;
    self.avatarView.translatesAutoresizingMaskIntoConstraints = NO;

    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = [DesignFonts semibold:13];
    self.nameLabel.textColor = [UIColor colorWithRed:0.16 green:0.16 blue:0.21 alpha:1.0];
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;

    self.acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.acceptButton.backgroundColor = [UIColor colorWithRed:1.0 green:0.93 blue:0.42 alpha:1.0];
    self.acceptButton.layer.cornerRadius = 25.0;
    self.acceptButton.titleLabel.font = [DesignFonts semibold:13];
    [self.acceptButton setTitle:@"Accept" forState:UIControlStateNormal];
    [self.acceptButton setTitleColor:[UIColor colorWithRed:0.18 green:0.18 blue:0.23 alpha:1.0] forState:UIControlStateNormal];
    self.acceptButton.translatesAutoresizingMaskIntoConstraints = NO;

    [self.contentView addSubview:self.cardView];
    [self.cardView addSubview:self.avatarView];
    [self.cardView addSubview:self.nameLabel];
    [self.cardView addSubview:self.acceptButton];

    [NSLayoutConstraint activateConstraints:@[
        [self.cardView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:kFriendRequestSidePadding],
        [self.cardView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-kFriendRequestSidePadding],
        [self.cardView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
        [self.cardView.heightAnchor constraintEqualToConstant:kFriendRequestCardHeight],

        [self.avatarView.leadingAnchor constraintEqualToAnchor:self.cardView.leadingAnchor constant:16.0],
        [self.avatarView.centerYAnchor constraintEqualToAnchor:self.cardView.centerYAnchor],
        [self.avatarView.widthAnchor constraintEqualToConstant:46.0],
        [self.avatarView.heightAnchor constraintEqualToConstant:46.0],

        [self.nameLabel.leadingAnchor constraintEqualToAnchor:self.avatarView.trailingAnchor constant:12.0],
        [self.nameLabel.centerYAnchor constraintEqualToAnchor:self.cardView.centerYAnchor],
        [self.nameLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.acceptButton.leadingAnchor constant:-12.0],

        [self.acceptButton.trailingAnchor constraintEqualToAnchor:self.cardView.trailingAnchor constant:-10.0],
        [self.acceptButton.centerYAnchor constraintEqualToAnchor:self.cardView.centerYAnchor],
        [self.acceptButton.widthAnchor constraintEqualToConstant:116.0],
        [self.acceptButton.heightAnchor constraintEqualToConstant:50.0],
    ]];
}

- (void)configureWithName:(NSString *)name avatarName:(NSString *)avatarName {
    self.nameLabel.text = name;
    self.avatarView.image = [UIImage imageNamed:avatarName];
}

@end
