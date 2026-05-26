//
//  ProfileRelationshipListViewController.m
//  Skiing
//

#import "ProfileRelationshipListViewController.h"
#import "FriendChatViewController.h"
#import "EmptyStateView.h"
#import "DesignTokens.h"
#import "UserModerationStore.h"

static CGFloat const kRelationshipCellCardHeight = 68.0;
static CGFloat const kRelationshipCellRowHeight = 80.0;
static NSString * const kProfileRelationshipFollowedUsersDefaultsKey = @"kUserProfileFollowedUsersDefaultsKey";
static NSString * const kProfileRelationshipFollowStoreFileName = @"followed_users.json";
static NSString * const kProfileRelationshipBlockedUsersDefaultsKey = @"kUserProfileBlockedUsersDefaultsKey";
static NSString * const kProfileRelationshipBlockStoreFileName = @"blocked_users.json";
static NSString * const kProfileRelationshipPresetSeededDefaultsKey = @"kProfileRelationshipPresetSeededV1";

@interface ProfileRelationshipListCell : UITableViewCell
@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) NSLayoutConstraint *actionButtonWidthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *actionButtonHeightConstraint;
- (void)configureWithName:(NSString *)name avatarName:(NSString *)avatarName mode:(ProfileRelationshipListMode)mode;
@end

@interface ProfileRelationshipListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, copy) NSString *relationshipTitle;
@property (nonatomic, assign) ProfileRelationshipListMode mode;
@property (nonatomic, strong) CAGradientLayer *backgroundGradientLayer;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) EmptyStateView *emptyStateView;
@property (nonatomic, strong) NSMutableArray<NSString *> *itemIDs;
@property (nonatomic, strong) NSMutableArray<NSString *> *names;
@property (nonatomic, strong) NSMutableArray<NSString *> *avatarNames;
@end

@implementation ProfileRelationshipListViewController

+ (NSInteger)relationshipItemCountForTitle:(NSString *)title mode:(ProfileRelationshipListMode)mode {
    return [self relationshipItemsForTitle:title mode:mode].count;
}

- (instancetype)initWithTitle:(NSString *)title mode:(ProfileRelationshipListMode)mode {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _relationshipTitle = [title copy];
        _mode = mode;
        _itemIDs = [NSMutableArray array];
        _names = [NSMutableArray array];
        _avatarNames = [NSMutableArray array];
        [self loadRelationshipItems];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.75 green:0.78 blue:1.0 alpha:1.0];
    [self setupBackground];
    [self setupContent];
    [self updateEmptyState];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self loadRelationshipItems];
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
    titleLabel.text = self.relationshipTitle;
    titleLabel.font = [DesignFonts semibold:18];
    titleLabel.textColor = [UIColor colorWithRed:0.18 green:0.18 blue:0.23 alpha:1.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = UIColor.clearColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.tableView.rowHeight = kRelationshipCellRowHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView registerClass:ProfileRelationshipListCell.class forCellReuseIdentifier:@"ProfileRelationshipListCell"];

    self.emptyStateView = [[EmptyStateView alloc] initWithText:@"No data available"];
    self.emptyStateView.hidden = YES;

    [self.view addSubview:backButton];
    [self.view addSubview:titleLabel];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.emptyStateView];

    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [backButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [backButton.topAnchor constraintEqualToAnchor:safeArea.topAnchor constant:12],
        [backButton.widthAnchor constraintEqualToConstant:44],
        [backButton.heightAnchor constraintEqualToConstant:44],

        [titleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [titleLabel.centerYAnchor constraintEqualToAnchor:backButton.centerYAnchor],

        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.topAnchor constraintEqualToAnchor:backButton.bottomAnchor constant:32],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [self.emptyStateView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.emptyStateView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.emptyStateView.topAnchor constraintEqualToAnchor:backButton.bottomAnchor],
        [self.emptyStateView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

- (void)updateEmptyState {
    BOOL isEmpty = self.names.count == 0;
    self.emptyStateView.hidden = !isEmpty;
    self.tableView.hidden = isEmpty;
}

- (void)loadRelationshipItems {
    [self.itemIDs removeAllObjects];
    [self.names removeAllObjects];
    [self.avatarNames removeAllObjects];

    NSArray<NSDictionary *> *items = [self relationshipItems];
    for (NSDictionary *item in items) {
        NSString *identity = item[@"id"];
        NSString *name = item[@"name"];
        NSString *avatar = item[@"avatar"];
        if (![name isKindOfClass:NSString.class] || name.length == 0 ||
            ![avatar isKindOfClass:NSString.class] || avatar.length == 0) {
            continue;
        }
        if (![identity isKindOfClass:NSString.class] || identity.length == 0) {
            identity = [self followIdentityForName:name handle:item[@"handle"] avatar:avatar];
        }
        [self.itemIDs addObject:identity];
        [self.names addObject:name];
        [self.avatarNames addObject:avatar];
    }
}

- (NSArray<NSDictionary *> *)relationshipItems {
    return [ProfileRelationshipListViewController relationshipItemsForTitle:self.relationshipTitle mode:self.mode];
}

+ (NSArray<NSDictionary *> *)relationshipItemsForTitle:(NSString *)title mode:(ProfileRelationshipListMode)mode {
    if (mode == ProfileRelationshipListModeBlacklist) {
        return [UserModerationStore blockedUsers];
    }

    if (mode != ProfileRelationshipListModeMessage) {
        return @[];
    }

    if ([title isEqualToString:@"Following"]) {
        return [self followedUserItemsForCount];
    }
    if ([title isEqualToString:@"Followers"]) {
        return [self presetFollowerItems];
    }
    if ([title isEqualToString:@"Friends"]) {
        return [self presetFriendItems];
    }

    return @[];
}

+ (NSArray<NSDictionary *> *)defaultRelationshipItemsForCount {
    return [self presetFollowerItems];
}

+ (NSArray<NSDictionary *> *)presetFollowingItems {
    return @[
        @{@"id": @"@skipro99", @"name": @"SkiPro99", @"handle": @"@skipro99", @"avatar": @"avatar_user_02"}
    ];
}

+ (NSArray<NSDictionary *> *)presetFollowerItems {
    return @[
        @{@"id": @"@raya", @"name": @"Raya", @"handle": @"@raya", @"avatar": @"avatar_user_13"},
        @{@"id": @"@janiz", @"name": @"Janiz", @"handle": @"@janiz", @"avatar": @"avatar_user_06"}
    ];
}

+ (NSArray<NSDictionary *> *)presetFriendItems {
    return @[
        @{@"id": @"@mila", @"name": @"Mila", @"handle": @"@mila", @"avatar": @"avatar_user_03"},
        @{@"id": @"@kevin", @"name": @"Kevin", @"handle": @"@kevin", @"avatar": @"avatar_user_04"}
    ];
}

+ (void)seedRelationshipPresetsIfNeeded {
    if ([NSUserDefaults.standardUserDefaults boolForKey:kProfileRelationshipPresetSeededDefaultsKey]) {
        return;
    }

    NSArray<NSDictionary *> *followingItems = [self presetFollowingItems];
    [NSUserDefaults.standardUserDefaults setObject:followingItems forKey:kProfileRelationshipFollowedUsersDefaultsKey];
    [NSUserDefaults.standardUserDefaults setBool:YES forKey:kProfileRelationshipPresetSeededDefaultsKey];
    [NSUserDefaults.standardUserDefaults synchronize];
    [self writeFollowedUsersForCountToDisk:followingItems];
}

+ (NSArray<NSDictionary *> *)followedUserItemsForCount {
    [self seedRelationshipPresetsIfNeeded];

    NSArray *storedUsers = [NSUserDefaults.standardUserDefaults objectForKey:kProfileRelationshipFollowedUsersDefaultsKey];
    NSArray<NSDictionary *> *users = [self sanitizedFollowedUsersForCountFromObject:storedUsers];
    if (users.count > 0) {
        [NSUserDefaults.standardUserDefaults setObject:users forKey:kProfileRelationshipFollowedUsersDefaultsKey];
        [NSUserDefaults.standardUserDefaults synchronize];
        return users;
    }

    users = [self readFollowedUsersForCountFromDisk];
    if (users.count > 0) {
        [NSUserDefaults.standardUserDefaults setObject:users forKey:kProfileRelationshipFollowedUsersDefaultsKey];
        [NSUserDefaults.standardUserDefaults synchronize];
    }
    return users;
}

+ (NSArray<NSDictionary *> *)sanitizedFollowedUsersForCountFromObject:(id)object {
    if (![object isKindOfClass:NSArray.class]) {
        return @[];
    }

    NSMutableArray<NSDictionary *> *users = [NSMutableArray array];
    for (id item in (NSArray *)object) {
        if (![item isKindOfClass:NSDictionary.class]) {
            continue;
        }
        NSDictionary *user = item;
        NSString *identity = user[@"id"];
        NSString *name = user[@"name"];
        NSString *handle = user[@"handle"];
        NSString *avatar = user[@"avatar"];
        if ([name isKindOfClass:NSString.class] && name.length > 0 &&
            [avatar isKindOfClass:NSString.class] && avatar.length > 0) {
            if (![handle isKindOfClass:NSString.class]) {
                handle = @"";
            }
            if (![identity isKindOfClass:NSString.class] || identity.length == 0) {
                identity = [self followIdentityForCountName:name handle:handle avatar:avatar];
            }
            [users addObject:@{@"id": identity, @"name": name, @"handle": handle, @"avatar": avatar}];
        }
    }
    return users.copy;
}

+ (NSString *)followIdentityForCountName:(NSString *)name handle:(NSString *)handle avatar:(NSString *)avatar {
    NSString *cleanHandle = [self normalizedFollowCountComponent:handle];
    if (cleanHandle.length > 0) {
        return cleanHandle;
    }

    NSString *cleanName = [self normalizedFollowCountComponent:name];
    NSString *cleanAvatar = [self normalizedFollowCountComponent:avatar];
    return [NSString stringWithFormat:@"%@|%@", cleanName, cleanAvatar];
}

+ (NSString *)normalizedFollowCountComponent:(id)value {
    if (![value isKindOfClass:NSString.class]) {
        return @"";
    }

    NSString *trimmedValue = [(NSString *)value stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    return trimmedValue.lowercaseString;
}

+ (NSURL *)followStoreFileURLForCount {
    NSURL *applicationSupportURL = [NSFileManager.defaultManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask].firstObject;
    NSURL *directoryURL = [applicationSupportURL URLByAppendingPathComponent:@"Profile" isDirectory:YES];
    [NSFileManager.defaultManager createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:nil];
    return [directoryURL URLByAppendingPathComponent:kProfileRelationshipFollowStoreFileName];
}

+ (NSArray<NSDictionary *> *)readFollowedUsersForCountFromDisk {
    NSData *data = [NSData dataWithContentsOfURL:[self followStoreFileURLForCount]];
    if (data.length == 0) {
        return @[];
    }

    id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return [self sanitizedFollowedUsersForCountFromObject:object];
}

+ (void)writeFollowedUsersForCountToDisk:(NSArray<NSDictionary *> *)users {
    NSData *data = [NSJSONSerialization dataWithJSONObject:users options:0 error:nil];
    if (data.length == 0) {
        return;
    }

    [data writeToURL:[self followStoreFileURLForCount] atomically:YES];
}

- (BOOL)shouldUseFollowedUsers {
    return self.mode == ProfileRelationshipListModeMessage && [self.relationshipTitle isEqualToString:@"Following"];
}

- (BOOL)shouldUseBlockedUsers {
    return self.mode == ProfileRelationshipListModeBlacklist;
}

- (NSArray<NSDictionary *> *)defaultRelationshipItems {
    return @[
        @{@"name": @"Janiz", @"avatar": @"avatar_user_06"},
        @{@"name": @"Janiz", @"avatar": @"avatar_user_06"},
        @{@"name": @"Janiz", @"avatar": @"avatar_user_06"},
        @{@"name": @"Janiz", @"avatar": @"avatar_user_06"},
        @{@"name": @"Janiz", @"avatar": @"avatar_user_06"},
    ];
}

- (NSArray<NSDictionary *> *)followedUserItems {
    NSArray *storedUsers = [NSUserDefaults.standardUserDefaults objectForKey:kProfileRelationshipFollowedUsersDefaultsKey];
    NSArray<NSDictionary *> *users = [self sanitizedFollowedUsersFromObject:storedUsers];
    if (users.count > 0) {
        [NSUserDefaults.standardUserDefaults setObject:users forKey:kProfileRelationshipFollowedUsersDefaultsKey];
        [NSUserDefaults.standardUserDefaults synchronize];
    } else {
        users = [self readFollowedUsersFromDisk];
        if (users.count > 0) {
            [NSUserDefaults.standardUserDefaults setObject:users forKey:kProfileRelationshipFollowedUsersDefaultsKey];
            [NSUserDefaults.standardUserDefaults synchronize];
        }
    }

    return users;
}

- (NSArray<NSDictionary *> *)blockedUserItems {
    return [UserModerationStore blockedUsers];
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
        NSString *identity = user[@"id"];
        NSString *name = user[@"name"];
        NSString *handle = user[@"handle"];
        NSString *avatar = user[@"avatar"];
        if ([name isKindOfClass:NSString.class] && name.length > 0 &&
            [avatar isKindOfClass:NSString.class] && avatar.length > 0) {
            if (![handle isKindOfClass:NSString.class]) {
                handle = @"";
            }
            if (![identity isKindOfClass:NSString.class] || identity.length == 0) {
                identity = [self followIdentityForName:name handle:handle avatar:avatar];
            }
            [users addObject:@{@"id": identity, @"name": name, @"handle": handle, @"avatar": avatar}];
        }
    }
    return users.copy;
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
    return [directoryURL URLByAppendingPathComponent:kProfileRelationshipFollowStoreFileName];
}

- (NSArray<NSDictionary *> *)readFollowedUsersFromDisk {
    NSData *data = [NSData dataWithContentsOfURL:[self followStoreFileURL]];
    if (data.length == 0) {
        return @[];
    }

    id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return [self sanitizedFollowedUsersFromObject:object];
}

- (NSURL *)blockStoreFileURL {
    NSURL *applicationSupportURL = [NSFileManager.defaultManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask].firstObject;
    NSURL *directoryURL = [applicationSupportURL URLByAppendingPathComponent:@"Profile" isDirectory:YES];
    [NSFileManager.defaultManager createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:nil];
    return [directoryURL URLByAppendingPathComponent:kProfileRelationshipBlockStoreFileName];
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

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.names.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProfileRelationshipListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileRelationshipListCell" forIndexPath:indexPath];
    [cell configureWithName:self.names[indexPath.row]
                 avatarName:self.avatarNames[indexPath.row]
                       mode:self.mode];
    [cell.actionButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    if (self.mode == ProfileRelationshipListModeMessage) {
        [cell.actionButton addTarget:self action:@selector(didTapMessageButton) forControlEvents:UIControlEventTouchUpInside];
    } else if (self.mode == ProfileRelationshipListModeBlacklist) {
        cell.actionButton.tag = indexPath.row;
        [cell.actionButton addTarget:self action:@selector(didTapRemoveButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
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
    FriendChatViewController *chatViewController = [[FriendChatViewController alloc] init];
    chatViewController.hidesBottomBarWhenPushed = YES;

    if (self.navigationController) {
        [self.navigationController pushViewController:chatViewController animated:YES];
        return;
    }

    chatViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:chatViewController animated:YES completion:nil];
}

- (void)didTapRemoveButton:(UIButton *)button {
    NSInteger row = button.tag;
    if (row < 0 || row >= self.itemIDs.count || row >= self.names.count || row >= self.avatarNames.count) {
        return;
    }

    NSString *itemID = self.itemIDs[row];
    if ([self shouldUseBlockedUsers]) {
        [self removeBlockedUserWithID:itemID];
    }

    [self.itemIDs removeObjectAtIndex:row];
    [self.names removeObjectAtIndex:row];
    [self.avatarNames removeObjectAtIndex:row];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.tableView performBatchUpdates:^{
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } completion:^(BOOL finished) {
        [self.tableView reloadData];
        [self updateEmptyState];
    }];
}

- (void)removeBlockedUserWithID:(NSString *)itemID {
    [UserModerationStore removeBlockedUserWithID:itemID];
}

@end

@implementation ProfileRelationshipListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = UIColor.clearColor;
    self.contentView.backgroundColor = UIColor.clearColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    self.cardView = [[UIView alloc] init];
    self.cardView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.40];
    self.cardView.layer.cornerRadius = 12.0;
    self.cardView.translatesAutoresizingMaskIntoConstraints = NO;

    self.avatarView = [[UIImageView alloc] init];
    self.avatarView.contentMode = UIViewContentModeScaleAspectFill;
    self.avatarView.clipsToBounds = YES;
    self.avatarView.layer.cornerRadius = 21.0;
    self.avatarView.translatesAutoresizingMaskIntoConstraints = NO;

    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = [DesignFonts semibold:13];
    self.nameLabel.textColor = [UIColor colorWithRed:0.16 green:0.16 blue:0.21 alpha:1.0];
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;

    self.actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.actionButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.actionButton.translatesAutoresizingMaskIntoConstraints = NO;

    [self.contentView addSubview:self.cardView];
    [self.cardView addSubview:self.avatarView];
    [self.cardView addSubview:self.nameLabel];
    [self.cardView addSubview:self.actionButton];

    self.actionButtonWidthConstraint = [self.actionButton.widthAnchor constraintEqualToConstant:102.0];
    self.actionButtonHeightConstraint = [self.actionButton.heightAnchor constraintEqualToConstant:44.0];

    [NSLayoutConstraint activateConstraints:@[
        [self.cardView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:14],
        [self.cardView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-14],
        [self.cardView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
        [self.cardView.heightAnchor constraintEqualToConstant:kRelationshipCellCardHeight],

        [self.avatarView.leadingAnchor constraintEqualToAnchor:self.cardView.leadingAnchor constant:14],
        [self.avatarView.centerYAnchor constraintEqualToAnchor:self.cardView.centerYAnchor],
        [self.avatarView.widthAnchor constraintEqualToConstant:42],
        [self.avatarView.heightAnchor constraintEqualToConstant:42],

        [self.nameLabel.leadingAnchor constraintEqualToAnchor:self.avatarView.trailingAnchor constant:14],
        [self.nameLabel.centerYAnchor constraintEqualToAnchor:self.cardView.centerYAnchor],
        [self.nameLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.actionButton.leadingAnchor constant:-8],

        [self.actionButton.trailingAnchor constraintEqualToAnchor:self.cardView.trailingAnchor constant:-8],
        [self.actionButton.centerYAnchor constraintEqualToAnchor:self.cardView.centerYAnchor],
        self.actionButtonWidthConstraint,
        self.actionButtonHeightConstraint,
    ]];
}

- (void)configureWithName:(NSString *)name avatarName:(NSString *)avatarName mode:(ProfileRelationshipListMode)mode {
    self.nameLabel.text = name;
    self.avatarView.image = [UIImage imageNamed:avatarName];

    if (mode == ProfileRelationshipListModeBlacklist) {
        [self.actionButton setImage:[UIImage imageNamed:@"mine_relationship_remove_button"] forState:UIControlStateNormal];
        self.actionButtonWidthConstraint.constant = 32.0;
        self.actionButtonHeightConstraint.constant = 32.0;
        return;
    }

    [self.actionButton setImage:[UIImage imageNamed:@"mine_relationship_message_button"] forState:UIControlStateNormal];
    self.actionButtonWidthConstraint.constant = 102.0;
    self.actionButtonHeightConstraint.constant = 44.0;
}

@end
