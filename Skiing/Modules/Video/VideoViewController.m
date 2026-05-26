//
//  VideoViewController.m
//  Skiing
//

#import "VideoViewController.h"
#import "VideoCell.h"
#import "DesignTokens.h"
#import "CommentPanelView.h"
#import "VideoEngagementStore.h"
#import "PublishViewController.h"
#import "UserProfileViewController.h"
#import "FriendChatViewController.h"
#import "UnlockDialogView.h"
#import "CoinBalanceStore.h"
#import "CommonMoreActionSheetView.h"
#import "UserModerationStore.h"
#import "FriendRequestStore.h"

static NSString * const kPostingUnlockedDefaultsKey = @"kPostingUnlockedDefaultsKey";
static NSInteger const kPostingUnlockCost = 19;

@interface VideoItem : NSObject
@property (nonatomic, copy) NSString *videoFileName; // filename without extension in Videoes/
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *handle;
@property (nonatomic, copy) NSString *avatarName;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *likeCount;
@property (nonatomic, copy) NSString *commentCount;
@property (nonatomic, copy) NSString *coinCount;
@end
@implementation VideoItem
@end

// ─────────────────────────────────────────────

@interface VideoViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView      *collectionView;
@property (nonatomic, strong) UILabel               *appNameLabel;
@property (nonatomic, strong) UIButton              *backButton;
@property (nonatomic, strong) UIButton              *starButton;
@property (nonatomic, strong) NSArray<VideoItem *>  *items;
@property (nonatomic, assign) NSInteger              currentPlayingIndex;
@property (nonatomic, strong) CommentPanelView      *commentPanel;
@property (nonatomic, strong) UnlockDialogView      *unlockDialogView;
@property (nonatomic, strong) CommonMoreActionSheetView *moreActionSheetView;
@property (nonatomic, strong) UIView                *friendPromptOverlayView;
@property (nonatomic, strong) UIView                *friendPromptDialogView;
@property (nonatomic, strong) VideoItem             *pendingFriendRequestItem;
@property (nonatomic, assign) BOOL                   didApplyInitialVideoPosition;
@property (nonatomic, assign) BOOL                   needsBlockedUsersRefresh;
@end

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentPlayingIndex = -1;
    [self buildData];
    [self setupCollectionView];
    [self setupTopBar];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(handleBlockedUsersDidChange)
                                               name:UserModerationStoreBlockedUsersDidChangeNotification
                                             object:nil];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    if (self.needsBlockedUsersRefresh) {
        [self refreshVideosAfterBlockedUsersChanged];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.didApplyInitialVideoPosition) {
        self.didApplyInitialVideoPosition = YES;
        NSInteger initialIndex = [self indexForVideoFileName:self.initialVideoFileName];
        if (initialIndex > 0) {
            [self scrollToAndPlayVideoAtIndex:initialIndex];
            return;
        }
    }

    if (self.currentPlayingIndex >= 0) {
        [self resumeCurrentCell];
    } else {
        [self playVideoAtIndex:0];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self pauseCurrentCell];
}

#pragma mark - Data

- (void)buildData {
    NSArray *videos = @[
        @{@"file": @"video_ski_01",       @"user": @"IndieAnna",     @"handle": @"@indieanna",   @"avatar": @"avatar_user_01", @"desc": @"I have been learning the guitar for two years. Let's see how it goes", @"like": @"38",  @"comment": @"3", @"coin": @"12"},
        @{@"file": @"video_ski_02",       @"user": @"SkiPro99",      @"handle": @"@skipro99",    @"avatar": @"avatar_user_02", @"desc": @"First run of the season — absolutely incredible conditions today!",    @"like": @"124", @"comment": @"2", @"coin": @"45"},
        @{@"file": @"video_ski_03",       @"user": @"MountainGirl",  @"handle": @"@mtngirl",     @"avatar": @"avatar_user_03", @"desc": @"Nothing beats fresh powder in the morning",                            @"like": @"87",  @"comment": @"3", @"coin": @"22"},
        @{@"file": @"video_ski_04",       @"user": @"FreeRider",     @"handle": @"@freerider",   @"avatar": @"avatar_user_04", @"desc": @"Off-piste all day long. Who's joining me tomorrow?",                   @"like": @"203", @"comment": @"2", @"coin": @"67"},
        @{@"file": @"video_ski_05",       @"user": @"AlpineKing",    @"handle": @"@alpineking",  @"avatar": @"avatar_user_05", @"desc": @"Black diamond run at sunrise. Absolutely worth it.",                   @"like": @"310", @"comment": @"3", @"coin": @"88"},
        @{@"file": @"video_ski_06",       @"user": @"SnowQueen",     @"handle": @"@snowqueen",   @"avatar": @"avatar_user_06", @"desc": @"Carving through fresh powder like butter",                             @"like": @"155", @"comment": @"2", @"coin": @"30"},
        @{@"file": @"video_ski_07",       @"user": @"PowderHunter",  @"handle": @"@powderhunt",  @"avatar": @"avatar_user_07", @"desc": @"Storm day means powder day. See you on the mountain!",                 @"like": @"290", @"comment": @"3", @"coin": @"55"},
        @{@"file": @"video_lifestyle_01", @"user": @"TravelVibes",   @"handle": @"@travelvibes", @"avatar": @"avatar_user_08", @"desc": @"Fresh travel bucket list ideas for your next adventure",              @"like": @"412", @"comment": @"2", @"coin": @"76"},
        @{@"file": @"video_lifestyle_02", @"user": @"BreakfastClub", @"handle": @"@bfclub",      @"avatar": @"avatar_user_09", @"desc": @"Healthy breakfast ideas that make everyday moments beautiful",           @"like": @"278", @"comment": @"3", @"coin": @"44"},
        @{@"file": @"video_lifestyle_03", @"user": @"GemFinder",     @"handle": @"@gemfinder",   @"avatar": @"avatar_user_10", @"desc": @"Hidden gem tips that feel luxe without breaking the bank",               @"like": @"199", @"comment": @"2", @"coin": @"33"},
        @{@"file": @"video_lifestyle_04", @"user": @"BrandVibes",    @"handle": @"@brandvibes",  @"avatar": @"avatar_user_11", @"desc": @"Easy brand identity tips that make everything look polished",            @"like": @"347", @"comment": @"3", @"coin": @"61"},
    ];

    NSArray *sourceVideos = [self filteredVideoDictionariesFromVideos:[self videosByFilteringBlockedUsers:videos]];

    NSMutableArray *arr = [NSMutableArray array];
    for (NSDictionary *d in sourceVideos) {
        VideoItem *item    = [[VideoItem alloc] init];
        item.videoFileName = d[@"file"];
        item.username      = d[@"user"];
        item.handle        = d[@"handle"];
        item.avatarName    = d[@"avatar"];
        item.desc          = d[@"desc"];
        item.likeCount     = d[@"like"];
        item.commentCount  = d[@"comment"];
        item.coinCount     = d[@"coin"];
        [[VideoEngagementStore sharedStore] registerVideoWithIdentifier:item.videoFileName
                                                           baseLikeCount:[self integerFromString:item.likeCount]
                                                            seedComments:[self seedCommentsWithCount:[self integerFromString:item.commentCount]]];
        [arr addObject:item];
    }
    self.items = arr;
}

- (NSArray<NSDictionary *> *)filteredVideoDictionariesFromVideos:(NSArray<NSDictionary *> *)videos {
    if (self.videoFileNames.count == 0) {
        return videos;
    }

    NSMutableArray<NSDictionary *> *filteredVideos = [NSMutableArray array];
    for (NSString *fileName in self.videoFileNames) {
        for (NSDictionary *video in videos) {
            if ([video[@"file"] isEqualToString:fileName]) {
                [filteredVideos addObject:video];
                break;
            }
        }
    }

    return filteredVideos.copy;
}

- (NSArray<NSDictionary *> *)videosByFilteringBlockedUsers:(NSArray<NSDictionary *> *)videos {
    NSMutableArray<NSDictionary *> *visibleVideos = [NSMutableArray array];
    for (NSDictionary *video in videos) {
        if ([UserModerationStore isUserBlockedWithName:video[@"user"]
                                                handle:video[@"handle"]
                                                avatar:video[@"avatar"]]) {
            continue;
        }
        [visibleVideos addObject:video];
    }
    return visibleVideos.copy;
}

- (void)handleBlockedUsersDidChange {
    self.needsBlockedUsersRefresh = YES;
    if (self.isViewLoaded && self.view.window) {
        [self refreshVideosAfterBlockedUsersChanged];
    }
}

- (void)refreshVideosAfterBlockedUsersChanged {
    self.needsBlockedUsersRefresh = NO;
    NSString *previousVideoFileName = nil;
    NSInteger previousIndex = MAX(self.currentPlayingIndex, 0);
    if (self.currentPlayingIndex >= 0 && self.currentPlayingIndex < (NSInteger)self.items.count) {
        previousVideoFileName = self.items[self.currentPlayingIndex].videoFileName;
    }

    [self pauseCurrentCell];
    [self buildData];
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];
    self.currentPlayingIndex = -1;

    if (self.items.count == 0) {
        return;
    }

    NSInteger targetIndex = previousVideoFileName.length > 0 ? [self indexForVideoFileName:previousVideoFileName] : previousIndex;
    if (previousVideoFileName.length > 0 && ![self.items[targetIndex].videoFileName isEqualToString:previousVideoFileName]) {
        targetIndex = MIN(previousIndex, (NSInteger)self.items.count - 1);
    }
    [self scrollToAndPlayVideoAtIndex:targetIndex];
}

- (NSArray<VideoComment *> *)seedCommentsWithCount:(NSInteger)count {
    NSArray<NSDictionary<NSString *, NSString *> *> *templates = @[
        @{@"user": @"Kevin",  @"avatar": @"avatar_user_01", @"text": @"You sang so beautifully. I'll learn from you."},
        @{@"user": @"Sarah",  @"avatar": @"avatar_user_02", @"text": @"This is absolutely amazing!"},
        @{@"user": @"Mike",   @"avatar": @"avatar_user_03", @"text": @"Keep going, you're doing great!"},
        @{@"user": @"Emma",   @"avatar": @"avatar_user_05", @"text": @"Love this so much."},
        @{@"user": @"James",  @"avatar": @"avatar_user_07", @"text": @"Incredible skills on the slopes!"},
        @{@"user": @"Olivia", @"avatar": @"avatar_user_06", @"text": @"Can't wait to try this myself."},
        @{@"user": @"Liam",   @"avatar": @"avatar_user_09", @"text": @"Best run I've seen all season."},
        @{@"user": @"Sophia", @"avatar": @"avatar_user_11", @"text": @"The conditions look perfect today!"}
    ];

    NSMutableArray<VideoComment *> *comments = [NSMutableArray array];
    for (NSInteger index = 0; index < count; index++) {
        NSDictionary<NSString *, NSString *> *template = templates[index % templates.count];
        VideoComment *comment = [[VideoComment alloc] initWithUsername:template[@"user"]
                                                                content:template[@"text"]
                                                             avatarName:template[@"avatar"]];
        [comments addObject:comment];
    }
    return comments;
}

- (NSInteger)integerFromString:(NSString *)string {
    return MAX((NSInteger)string.integerValue, 0);
}

- (NSString *)displayTextForCount:(NSInteger)count {
    return [NSString stringWithFormat:@"%ld", (long)MAX(count, 0)];
}

- (NSInteger)indexForVideoFileName:(NSString *)videoFileName {
    if (videoFileName.length == 0) return 0;

    for (NSInteger index = 0; index < (NSInteger)self.items.count; index++) {
        VideoItem *item = self.items[index];
        if ([item.videoFileName isEqualToString:videoFileName]) {
            return index;
        }
    }

    return 0;
}

#pragma mark - Setup

- (void)setupCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection         = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing      = 0;
    layout.minimumInteritemSpacing = 0;

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.backgroundColor    = UIColor.blackColor;
    self.collectionView.dataSource         = self;
    self.collectionView.delegate           = self;
    self.collectionView.pagingEnabled      = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.collectionView registerClass:[VideoCell class]
            forCellWithReuseIdentifier:[VideoCell reuseIdentifier]];
    [self.view addSubview:self.collectionView];

    [NSLayoutConstraint activateConstraints:@[
        [self.collectionView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.collectionView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.collectionView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.collectionView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

- (void)setupTopBar {
    self.appNameLabel = [[UILabel alloc] init];
    self.appNameLabel.text      = @"APPNAME";
    self.appNameLabel.font      = [DesignFonts semibold:22];
    self.appNameLabel.textColor = UIColor.whiteColor;
    self.appNameLabel.hidden    = self.showsBackButton;
    self.appNameLabel.translatesAutoresizingMaskIntoConstraints = NO;

    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
    self.backButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.backButton.hidden = !self.showsBackButton;
    self.backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backButton addTarget:self action:@selector(didTapBackButton) forControlEvents:UIControlEventTouchUpInside];

    self.starButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.starButton setImage:[UIImage imageNamed:@"btn_publish"] forState:UIControlStateNormal];
    self.starButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.starButton.hidden = self.showsBackButton;
    self.starButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.starButton addTarget:self action:@selector(didTapStarButton) forControlEvents:UIControlEventTouchUpInside];

    UIImageView *coinsImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_coin"]];
    coinsImageView.hidden = self.showsBackButton;
    coinsImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.appNameLabel];
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.starButton];
    [self.view addSubview:coinsImageView];

    [NSLayoutConstraint activateConstraints:@[
        [self.appNameLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:12],
        [self.appNameLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],

        [self.backButton.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:12],
        [self.backButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [self.backButton.widthAnchor constraintEqualToConstant:44],
        [self.backButton.heightAnchor constraintEqualToConstant:44],

        [self.starButton.centerYAnchor constraintEqualToAnchor:self.appNameLabel.centerYAnchor],
        [self.starButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],
        [self.starButton.widthAnchor constraintEqualToConstant:44],
        [self.starButton.heightAnchor constraintEqualToConstant:44],
        
        [coinsImageView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:0],
        [coinsImageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-14],
        [coinsImageView.widthAnchor constraintEqualToConstant:20],
        [coinsImageView.heightAnchor constraintEqualToConstant:20],
        
    ]];
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

    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Playback Control

- (NSURL *)videoURLForItem:(VideoItem *)item {
    // Look for the file in the Videoes folder bundled in the app
    NSString *path = [[NSBundle mainBundle] pathForResource:item.videoFileName ofType:@"mp4"];
    if (path) return [NSURL fileURLWithPath:path];
    return nil;
}

- (void)playVideoAtIndex:(NSInteger)index {
    if (index < 0 || index >= (NSInteger)self.items.count) return;
    if (index == self.currentPlayingIndex) {
        [self resumeCurrentCell];
        return;
    }

    // Stop previous
    if (self.currentPlayingIndex >= 0) {
        NSIndexPath *prevPath = [NSIndexPath indexPathForItem:self.currentPlayingIndex inSection:0];
        VideoCell *prevCell = (VideoCell *)[self.collectionView cellForItemAtIndexPath:prevPath];
        [prevCell stop];
    }

    self.currentPlayingIndex = index;
    NSIndexPath *path = [NSIndexPath indexPathForItem:index inSection:0];
    VideoCell *cell = (VideoCell *)[self.collectionView cellForItemAtIndexPath:path];

    NSURL *url = [self videoURLForItem:self.items[index]];
    if (cell && url) {
        [cell playWithURL:url];
    }
}

- (void)scrollToAndPlayVideoAtIndex:(NSInteger)index {
    if (index < 0 || index >= (NSInteger)self.items.count) return;

    NSIndexPath *path = [NSIndexPath indexPathForItem:index inSection:0];
    [self.collectionView layoutIfNeeded];
    [self.collectionView scrollToItemAtIndexPath:path
                                atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                        animated:NO];
    [self.collectionView layoutIfNeeded];
    [self playVideoAtIndex:index];
}

- (void)resumeCurrentCell {
    if (self.currentPlayingIndex < 0 || self.currentPlayingIndex >= (NSInteger)self.items.count) {
        [self playVideoAtIndex:0];
        return;
    }

    NSIndexPath *path = [NSIndexPath indexPathForItem:self.currentPlayingIndex inSection:0];
    VideoCell *cell = (VideoCell *)[self.collectionView cellForItemAtIndexPath:path];
    if (cell) {
        [cell resume];
        return;
    }

    [self.collectionView scrollToItemAtIndexPath:path
                                atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                        animated:NO];
    [self.collectionView layoutIfNeeded];

    cell = (VideoCell *)[self.collectionView cellForItemAtIndexPath:path];
    NSURL *url = [self videoURLForItem:self.items[self.currentPlayingIndex]];
    if (cell && url) {
        [cell playWithURL:url];
    }
}

- (void)pauseCurrentCell {
    if (self.currentPlayingIndex < 0) return;
    NSIndexPath *path = [NSIndexPath indexPathForItem:self.currentPlayingIndex inSection:0];
    VideoCell *cell = (VideoCell *)[self.collectionView cellForItemAtIndexPath:path];
    [cell pause];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[VideoCell reuseIdentifier]
                                                                forIndexPath:indexPath];
    VideoItem *item = self.items[indexPath.item];
    UIImage *avatarImage = [UIImage imageNamed:item.avatarName];
    cell.usernameLabel.text     = item.username;
    cell.handleLabel.text       = item.handle;
    cell.avatarView.image       = avatarImage ?: [UIImage imageNamed:@"avatar_placeholder"];
    cell.descLabel.text         = item.desc;
    cell.likeButton.selected    = [[VideoEngagementStore sharedStore] isVideoLikedWithIdentifier:item.videoFileName];
    cell.likeCountLabel.text    = [self displayTextForCount:[[VideoEngagementStore sharedStore] likeCountForVideoIdentifier:item.videoFileName]];
    cell.commentCountLabel.text = [self displayTextForCount:[[VideoEngagementStore sharedStore] commentCountForVideoIdentifier:item.videoFileName]];
    [self configureProfileEntryForCell:cell index:indexPath.item];

    [cell.likeButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    cell.likeButton.tag = indexPath.item;
    [cell.likeButton addTarget:self action:@selector(didTapLikeButton:) forControlEvents:UIControlEventTouchUpInside];

    [cell.commentButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    cell.commentButton.tag = indexPath.item;
    [cell.commentButton addTarget:self action:@selector(didTapCommentButton:) forControlEvents:UIControlEventTouchUpInside];

    [cell.shareButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    cell.shareButton.tag = indexPath.item;
    [cell.shareButton addTarget:self action:@selector(didTapShareButton:) forControlEvents:UIControlEventTouchUpInside];

    [cell.messageButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    cell.messageButton.tag = indexPath.item;
    [cell.messageButton addTarget:self action:@selector(didTapMessageButton:) forControlEvents:UIControlEventTouchUpInside];

    // If this cell is the current playing one, start immediately
    if (indexPath.item == self.currentPlayingIndex) {
        NSURL *url = [self videoURLForItem:item];
        if (url) [cell playWithURL:url];
    }

    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.bounds.size;
}

#pragma mark - UIScrollViewDelegate (paging)

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageHeight = scrollView.bounds.size.height;
    NSInteger page = (NSInteger)round(scrollView.contentOffset.y / pageHeight);
    [self playVideoAtIndex:page];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    CGFloat pageHeight = scrollView.bounds.size.height;
    NSInteger page = (NSInteger)round(scrollView.contentOffset.y / pageHeight);
    [self playVideoAtIndex:page];
}

#pragma mark - Comment Panel

- (void)didTapCommentButton:(UIButton *)button {
    NSInteger index = button.tag;
    if (index < 0 || index >= (NSInteger)self.items.count) {
        return;
    }

    VideoItem *item = self.items[index];
    self.commentPanel = [[CommentPanelView alloc] initWithVideoIdentifier:item.videoFileName];
    __weak typeof(self) weakSelf = self;
    self.commentPanel.commentsDidChange = ^(NSInteger commentCount) {
        [weakSelf updateCommentCount:commentCount forVideoAtIndex:index];
    };
    [self.commentPanel showInView:self.view];
}

#pragma mark - Engagement

- (void)didTapLikeButton:(UIButton *)button {
    NSInteger index = button.tag;
    if (index < 0 || index >= (NSInteger)self.items.count) {
        return;
    }

    VideoItem *item = self.items[index];
    NSInteger likeCount = [[VideoEngagementStore sharedStore] toggleLikeForVideoIdentifier:item.videoFileName];
    BOOL isLiked = [[VideoEngagementStore sharedStore] isVideoLikedWithIdentifier:item.videoFileName];
    item.likeCount = [self displayTextForCount:likeCount];

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    VideoCell *cell = (VideoCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    cell.likeButton.selected = isLiked;
    cell.likeCountLabel.text = item.likeCount;
}

- (void)updateCommentCount:(NSInteger)commentCount forVideoAtIndex:(NSInteger)index {
    if (index < 0 || index >= (NSInteger)self.items.count) {
        return;
    }

    VideoItem *item = self.items[index];
    item.commentCount = [self displayTextForCount:commentCount];

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    VideoCell *cell = (VideoCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    cell.commentCountLabel.text = item.commentCount;
}

#pragma mark - Friend Message

- (void)didTapMessageButton:(UIButton *)button {
    NSInteger index = button.tag;
    if (index < 0 || index >= (NSInteger)self.items.count) {
        return;
    }

    VideoItem *item = self.items[index];
    if ([self hasSentFriendRequestForVideoItem:item]) {
        [self openFriendChatForVideoItem:item];
        return;
    }

    self.pendingFriendRequestItem = item;
    [self showFriendPromptDialog];
}

- (BOOL)hasSentFriendRequestForVideoItem:(VideoItem *)item {
    return [FriendRequestStore hasSentFriendRequestToName:item.username
                                                   handle:item.handle
                                                   avatar:item.avatarName];
}

- (void)openFriendChatForVideoItem:(VideoItem *)item {
    FriendChatViewController *chatViewController = [[FriendChatViewController alloc] init];
    chatViewController.chatTitle = item.username;
    chatViewController.peerHandle = item.handle;
    chatViewController.peerAvatarName = item.avatarName;
    chatViewController.hidesBottomBarWhenPushed = YES;
    if (self.navigationController) {
        [self.navigationController pushViewController:chatViewController animated:YES];
        return;
    }

    chatViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:chatViewController animated:YES completion:nil];
}

- (void)showFriendPromptDialog {
    if (self.friendPromptOverlayView.superview) return;

    UIView *parentView = [self friendPromptPresentationView];
    UIView *overlay = [[UIView alloc] initWithFrame:parentView.bounds];
    overlay.backgroundColor = [[UIColor colorWithRed:0.22 green:0.24 blue:0.43 alpha:1.0] colorWithAlphaComponent:0.68];
    overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [parentView addSubview:overlay];
    self.friendPromptOverlayView = overlay;

    CGFloat dialogWidth = 296.0;
    CGFloat dialogHeight = 258.0;
    UIView *dialog = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(parentView.bounds) - dialogWidth) / 2.0,
                                                              (CGRectGetHeight(parentView.bounds) - dialogHeight) / 2.0 - 8.0,
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

- (UIView *)friendPromptPresentationView {
    if (self.tabBarController.view) {
        return self.tabBarController.view;
    }

    if (self.navigationController.view) {
        return self.navigationController.view;
    }

    return self.view;
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
    self.pendingFriendRequestItem = nil;
    [self dismissFriendPromptDialogWithCompletion:nil];
}

- (void)didTapFriendPromptAdd {
    VideoItem *item = self.pendingFriendRequestItem;
    if (!item) {
        [self dismissFriendPromptDialogWithCompletion:nil];
        return;
    }

    [FriendRequestStore markFriendRequestSentToName:item.username
                                             handle:item.handle
                                             avatar:item.avatarName];
    self.pendingFriendRequestItem = nil;
    [self dismissFriendPromptDialogWithCompletion:^{
        NSString *message = [NSString stringWithFormat:@"Your request to %@ has been sent. Tap Message again to start chatting.", item.username ?: @"this user"];
        [self showSimpleAlertWithTitle:@"Friend request sent" message:message];
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

#pragma mark - More Actions

- (void)didTapShareButton:(UIButton *)button {
    NSInteger index = button.tag;
    if (index < 0 || index >= (NSInteger)self.items.count) {
        return;
    }

    VideoItem *item = self.items[index];
    if (!self.moreActionSheetView) {
        self.moreActionSheetView = [[CommonMoreActionSheetView alloc] init];
    }

    __weak typeof(self) weakSelf = self;
    self.moreActionSheetView.blockHandler = ^{
        [weakSelf showBlockConfirmationForVideoItem:item];
    };
    self.moreActionSheetView.reportHandler = ^{
        [weakSelf showReportConfirmationForVideoItem:item];
    };
    [self.moreActionSheetView showInView:[self moreActionSheetPresentationView]];
}

- (UIView *)moreActionSheetPresentationView {
    if (self.tabBarController.view) {
        return self.tabBarController.view;
    }

    if (self.navigationController.view) {
        return self.navigationController.view;
    }

    return self.view;
}

- (void)showBlockConfirmationForVideoItem:(VideoItem *)item {
    NSString *message = [NSString stringWithFormat:@"Block %@ and stop seeing their videos?", item.username ?: @"this user"];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Block user"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Block" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [UserModerationStore blockUserWithName:item.username handle:item.handle avatar:item.avatarName];
        [self showSimpleAlertWithTitle:@"User blocked" message:@"You will see fewer videos from this user." completion:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showReportConfirmationForVideoItem:(VideoItem *)item {
    NSString *message = [NSString stringWithFormat:@"Report %@'s video?", item.username ?: @"this"];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Report video"
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

#pragma mark - User Profile

- (void)configureProfileEntryForCell:(VideoCell *)cell index:(NSInteger)index {
    cell.profileTapArea.tag = index;
    [self addUserProfileTapIfNeededToView:cell.profileTapArea];
}

- (void)addUserProfileTapIfNeededToView:(UIView *)view {
    if (view.gestureRecognizers.count > 0) return;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openUserProfileFromTap:)];
    [view addGestureRecognizer:tap];
}

- (void)openUserProfileFromTap:(UITapGestureRecognizer *)gesture {
    NSInteger index = gesture.view.tag;
    if (index < 0 || index >= (NSInteger)self.items.count) {
        return;
    }

    VideoItem *item = self.items[index];
    UserProfileViewController *profileViewController = [[UserProfileViewController alloc] init];
    profileViewController.profileName = item.username;
    profileViewController.profileHandle = item.handle;
    profileViewController.profileAvatarName = item.avatarName;
    profileViewController.profilePostVideoFileNames = [self videoFileNamesForUser:item.username];
    profileViewController.profilePostCount = profileViewController.profilePostVideoFileNames.count;
    profileViewController.hidesBottomBarWhenPushed = YES;
    if (self.navigationController) {
        [self.navigationController pushViewController:profileViewController animated:YES];
        return;
    }

    profileViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:profileViewController animated:YES completion:nil];
}

- (NSArray<NSString *> *)videoFileNamesForUser:(NSString *)username {
    NSMutableArray<NSString *> *fileNames = [NSMutableArray array];
    for (VideoItem *item in self.items) {
        if ([item.username isEqualToString:username] && item.videoFileName.length > 0) {
            [fileNames addObject:item.videoFileName];
        }
    }

    return fileNames.copy;
}

#pragma mark - Unlock Dialog

- (void)didTapStarButton {
    if ([self isPostingUnlocked]) {
        [self openPublishPage];
        return;
    }

    [self showPostingUnlockDialog];
}

- (BOOL)isPostingUnlocked {
    return [NSUserDefaults.standardUserDefaults boolForKey:kPostingUnlockedDefaultsKey];
}

- (void)showPostingUnlockDialog {
    if (self.unlockDialogView.superview) {
        return;
    }

    UnlockDialogView *dialogView = [[UnlockDialogView alloc] init];
    __weak typeof(self) weakSelf = self;
    dialogView.confirmHandler = ^{
        [weakSelf unlockPostingAndOpenPublishPage];
    };
    self.unlockDialogView = dialogView;
    [dialogView show];
}

- (void)unlockPostingAndOpenPublishPage {
    self.unlockDialogView = nil;

    if (![CoinBalanceStore spendCoins:kPostingUnlockCost]) {
        [self showInsufficientCoinsAlert];
        return;
    }

    [NSUserDefaults.standardUserDefaults setBool:YES forKey:kPostingUnlockedDefaultsKey];
    [NSUserDefaults.standardUserDefaults synchronize];
    [self openPublishPage];
}

- (void)showInsufficientCoinsAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Not enough coins"
                                                                   message:@"Recharge coins to unlock posting."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)openPublishPage {
    PublishViewController *publishVC = [[PublishViewController alloc] init];
    publishVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:publishVC animated:YES];
}

@end
