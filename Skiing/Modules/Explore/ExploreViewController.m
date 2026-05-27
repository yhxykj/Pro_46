//
//  ExploreViewController.m
//  Skiing
//

#import "ExploreViewController.h"
#import "ChatViewController.h"
#import "VideoViewController.h"
#import "DesignTokens.h"
#import "UserModerationStore.h"
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>

static CGFloat const kExploreSidePadding = 18.0;
static NSString * const kExploreChatRoomsDefaultsKey = @"kExploreChatRoomsDefaultsKey";
static char kExploreRoomAssociationKey;

@interface ExploreViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImage *skiThumbnail;
@property (nonatomic, strong) NSArray<NSString *> *topVideoFileNames;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, id> *> *chatRooms;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, NSString *> *> *resorts;
@property (nonatomic, strong) NSArray<UIView *> *resortPins;
@property (nonatomic, strong) UIButton *featuredButton;
@property (nonatomic, strong) UIButton *chatButton;
@property (nonatomic, strong) UIView *chatRoomsContainer;
@property (nonatomic, strong) NSLayoutConstraint *featuredContentBottomConstraint;
@property (nonatomic, strong) UILabel *resortTitleLabel;
@property (nonatomic, strong) UILabel *resortLocationLabel;
@property (nonatomic, strong) UILabel *resortTagLabel;
@property (nonatomic, strong) UILabel *resortSummaryLabel;
@property (nonatomic, assign) NSInteger selectedResortIndex;
@property (nonatomic, assign) BOOL showingChatRooms;
@end

@implementation ExploreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.79 green:0.80 blue:1.00 alpha:1.0];
    self.topVideoFileNames = [self visibleTopVideoFileNames];
    self.chatRooms = [self loadChatRooms];
    self.resorts = [self makeResorts];
    self.selectedResortIndex = 0;
    self.skiThumbnail = [self thumbnailForVideoNamed:@"video_ski_01"] ?: [UIImage imageNamed:@"explore_mountain_header"];
    [self setupScrollView];
    [self setupContent];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshTopVideosIfNeeded];
}

#pragma mark - Data

- (NSArray<NSDictionary<NSString *, id> *> *)makeChatRooms {
    NSArray<NSDictionary<NSString *, NSString *> *> *templates = @[
        @{@"name": @"Powder Pups",
          @"desc": @"New to snow? Ask anything and meet other beginners finding their snow legs.",
          @"icon": @"chat_room_powder_pups"},
        @{@"name": @"Après Lounge",
          @"desc": @"Chill after a long day on the mountain. Drinks, stories, and good vibes.",
          @"icon": @"chat_room_apres_lounge"},
        @{@"name": @"Park Rats",
          @"desc": @"Features, spins, and stoke from the terrain park. Share your progress.",
          @"icon": @"chat_room_park_rats"},
        @{@"name": @"Carve Talk",
          @"desc": @"Obsessed with carving technique and gear? This is your space.",
          @"icon": @"chat_room_carve_talk"},
        @{@"name": @"Snow Sisters",
          @"desc": @"A friendly space for women who ride. Share tips and plan trips.",
          @"icon": @"chat_room_snow_sisters"},
        @{@"name": @"The Stomp Pad",
          @"desc": @"Park rats unite. Rails, kickers, and butters for the one-plank crew.",
          @"icon": @"chat_room_stomp_pad"},
        @{@"name": @"Pole Plant",
          @"desc": @"Twin tips, telemark, or cruising. Skiers of all kinds are welcome.",
          @"icon": @"chat_room_pole_plant"},
        @{@"name": @"Snow Report - Live",
          @"desc": @"Real-time snow conditions, lift lines, and powder alerts. Share what you see.",
          @"icon": @"chat_room_snow_report_live"},
        @{@"name": @"First Chair",
          @"desc": @"Early birds and dawn patrol chasing untouched fresh tracks.",
          @"icon": @"chat_room_first_chair"},
    ];

    NSMutableArray<NSDictionary<NSString *, id> *> *rooms = [NSMutableArray arrayWithCapacity:templates.count];
    for (NSDictionary<NSString *, NSString *> *template in templates) {
        NSInteger onlineCount = 7 + arc4random_uniform(18);
        [rooms addObject:@{@"name": template[@"name"],
                           @"desc": template[@"desc"],
                           @"icon": template[@"icon"],
                           @"online": @(onlineCount)}];
    }

    return rooms;
}

- (NSArray<NSDictionary<NSString *, id> *> *)loadChatRooms {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    NSArray *storedRooms = [defaults objectForKey:kExploreChatRoomsDefaultsKey];
    NSArray<NSDictionary<NSString *, id> *> *validatedRooms = [self validatedChatRoomsFromArray:storedRooms];
    if (validatedRooms.count == 9) {
        return validatedRooms;
    }

    NSArray<NSDictionary<NSString *, id> *> *rooms = [self makeChatRooms];
    [self persistChatRooms:rooms];
    return rooms;
}

- (void)persistChatRooms:(NSArray<NSDictionary<NSString *, id> *> *)rooms {
    [NSUserDefaults.standardUserDefaults setObject:rooms forKey:kExploreChatRoomsDefaultsKey];
    [NSUserDefaults.standardUserDefaults synchronize];
}

- (NSArray<NSDictionary<NSString *, id> *> *)validatedChatRoomsFromArray:(NSArray *)array {
    if (![array isKindOfClass:NSArray.class]) {
        return @[];
    }

    NSMutableArray<NSDictionary<NSString *, id> *> *rooms = [NSMutableArray arrayWithCapacity:array.count];
    for (id item in array) {
        if (![item isKindOfClass:NSDictionary.class]) {
            continue;
        }

        NSDictionary *room = (NSDictionary *)item;
        NSString *name = room[@"name"];
        NSString *description = room[@"desc"];
        NSString *icon = room[@"icon"];
        id onlineValue = room[@"online"];
        if (![name isKindOfClass:NSString.class] || name.length == 0 ||
            ![description isKindOfClass:NSString.class] || description.length == 0 ||
            ![icon isKindOfClass:NSString.class] || icon.length == 0 ||
            ![onlineValue respondsToSelector:@selector(integerValue)]) {
            continue;
        }

        NSInteger onlineCount = MAX(1, [onlineValue integerValue]);
        [rooms addObject:@{@"name": name,
                           @"desc": description,
                           @"icon": icon,
                           @"online": @(onlineCount)}];
    }

    return rooms.count == 9 ? rooms.copy : @[];
}

- (NSArray<NSDictionary<NSString *, NSString *> *> *)topVideoCandidates {
    return @[
        @{@"file": @"video_ski_01",       @"user": @"IndieAnna",     @"handle": @"@indieanna",   @"avatar": @"avatar_user_01"},
        @{@"file": @"video_ski_02",       @"user": @"SkiPro99",      @"handle": @"@skipro99",    @"avatar": @"avatar_user_02"},
        @{@"file": @"video_ski_03",       @"user": @"MountainGirl",  @"handle": @"@mtngirl",     @"avatar": @"avatar_user_03"},
        @{@"file": @"video_ski_04",       @"user": @"FreeRider",     @"handle": @"@freerider",   @"avatar": @"avatar_user_04"},
        @{@"file": @"video_ski_05",       @"user": @"AlpineKing",    @"handle": @"@alpineking",  @"avatar": @"avatar_user_05"},
        @{@"file": @"video_ski_06",       @"user": @"SnowQueen",     @"handle": @"@snowqueen",   @"avatar": @"avatar_user_06"},
        @{@"file": @"video_ski_07",       @"user": @"PowderHunter",  @"handle": @"@powderhunt",  @"avatar": @"avatar_user_07"},
    ];
}

- (NSArray<NSString *> *)visibleTopVideoFileNames {
    NSMutableArray<NSString *> *fileNames = [NSMutableArray array];
    for (NSDictionary<NSString *, NSString *> *video in [self topVideoCandidates]) {
        if ([UserModerationStore isUserBlockedWithName:video[@"user"]
                                                handle:video[@"handle"]
                                                avatar:video[@"avatar"]]) {
            continue;
        }
        [fileNames addObject:video[@"file"]];
        if (fileNames.count == 3) {
            break;
        }
    }
    return fileNames.copy;
}

- (void)refreshTopVideosIfNeeded {
    NSArray<NSString *> *visibleFileNames = [self visibleTopVideoFileNames];
    if ([visibleFileNames isEqualToArray:self.topVideoFileNames]) {
        return;
    }

    self.topVideoFileNames = visibleFileNames;
    [self rebuildContent];
}

- (void)rebuildContent {
    for (UIView *subview in self.view.subviews) {
        [subview removeFromSuperview];
    }
    self.scrollView = nil;
    self.contentView = nil;
    self.chatRoomsContainer = nil;
    self.featuredContentBottomConstraint = nil;
    self.resortPins = nil;
    self.resortTitleLabel = nil;
    self.resortLocationLabel = nil;
    self.resortTagLabel = nil;
    self.resortSummaryLabel = nil;
    self.showingChatRooms = NO;
    [self setupScrollView];
    [self setupContent];
}

- (NSArray<NSDictionary<NSString *, NSString *> *> *)makeResorts {
    return @[
        @{@"pin": @"Snowbasin",
          @"title": @"Snowbasin Resort",
          @"location": @"Huntsville, Utah",
          @"tag": @"#1 in the U.S. (2025 USA Today Readers' Choice)",
          @"summary": @"Consecutive winner with deep powder, Olympic-grade facilities, 3,000+ acres, and minimal lift lines."},
        @{@"pin": @"Big S...",
          @"title": @"Big Sky Resort",
          @"location": @"Big Sky, Montana",
          @"tag": @"\"The Biggest Skiing in America\"",
          @"summary": @"5,850 acres, uncrowded slopes, endless wide-open terrain."},
        @{@"pin": @"Aspen",
          @"title": @"Aspen Snowmass",
          @"location": @"Aspen, Colorado",
          @"tag": @"Ultimate luxury resort",
          @"summary": @"Four connected mountains, world-class dining, high-end shopping, and host of X Games."},
        @{@"pin": @"Deer",
          @"title": @"Deer Valley Resort",
          @"location": @"Park City, Utah",
          @"tag": @"5-star service, skiers-only",
          @"summary": @"Top-rated grooming, premium service, and no snowboarders."},
        @{@"pin": @"Palisades",
          @"title": @"Palisades Tahoe",
          @"location": @"Olympic Valley, California",
          @"tag": @"Olympic history & stunning views",
          @"summary": @"1960 Winter Olympics host, legendary KT-22 run, and Lake Tahoe scenery."},
    ];
}

#pragma mark - Setup

- (void)setupScrollView {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.backgroundColor = [UIColor colorWithRed:0.79 green:0.80 blue:1.00 alpha:1.0];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;

    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = self.scrollView.backgroundColor;
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.contentView];

    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [self.contentView.topAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.topAnchor],
        [self.contentView.leadingAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.leadingAnchor],
        [self.contentView.trailingAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.trailingAnchor],
        [self.contentView.bottomAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.bottomAnchor],
        [self.contentView.widthAnchor constraintEqualToAnchor:self.scrollView.frameLayoutGuide.widthAnchor],
    ]];
}

- (void)setupContent {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor colorWithRed:0.58 green:0.62 blue:0.93 alpha:1.0];
    headerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:headerView];

    UIImageView *titleImageView = [self imageViewWithName:@"explore_title"];
    [headerView addSubview:titleImageView];

    self.featuredButton = [self pillButtonWithTitle:@"Featured"
                                    backgroundColor:[UIColor colorWithRed:0.18 green:0.51 blue:1.00 alpha:1.0]
                                          textAlpha:1.0];
    self.chatButton = [self pillButtonWithTitle:@"Chat Rooms"
                                backgroundColor:[UIColor colorWithWhite:1.0 alpha:0.28]
                                      textAlpha:0.95];
    [self.featuredButton addTarget:self action:@selector(didTapFeaturedButton) forControlEvents:UIControlEventTouchUpInside];
    [self.chatButton addTarget:self action:@selector(didTapChatButton) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:self.featuredButton];
    [headerView addSubview:self.chatButton];

    UIView *mapView = [[UIView alloc] init];
    mapView.clipsToBounds = NO;
    mapView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:mapView];

    UIImageView *mapImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"explore_mountain_header"]];
    mapImageView.contentMode = UIViewContentModeScaleAspectFill;
    mapImageView.clipsToBounds = YES;
    mapImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [mapView addSubview:mapImageView];

    UIView *snowbasinPin = [self mapPinWithTitle:self.resorts[0][@"pin"] highlighted:YES];
    UIView *bigSkyPin = [self mapPinWithTitle:self.resorts[1][@"pin"] highlighted:NO];
    UIView *aspenPin = [self mapPinWithTitle:self.resorts[2][@"pin"] highlighted:NO];
    UIView *deerPin = [self mapPinWithTitle:self.resorts[3][@"pin"] highlighted:NO];
    UIView *palisadesPin = [self mapPinWithTitle:self.resorts[4][@"pin"] highlighted:NO];
    self.resortPins = @[snowbasinPin, bigSkyPin, aspenPin, deerPin, palisadesPin];
    for (NSInteger index = 0; index < (NSInteger)self.resortPins.count; index++) {
        UIView *pin = self.resortPins[index];
        pin.tag = index;
        pin.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapResortPin:)];
        [pin addGestureRecognizer:tap];
    }
    [mapView addSubview:snowbasinPin];
    [mapView addSubview:bigSkyPin];
    [mapView addSubview:aspenPin];
    [mapView addSubview:deerPin];
    [mapView addSubview:palisadesPin];

    UIView *resortCard = [self makeResortCard];
    [self.contentView addSubview:resortCard];

    UIView *chatHeader = [self sectionHeaderWithTitle:@"Active Chat Rooms"];
    [self.contentView addSubview:chatHeader];

    UIView *roomOne = [self chatRoomCardWithRoom:self.chatRooms[0]];
    UIView *roomTwo = [self chatRoomCardWithRoom:self.chatRooms[1]];
    UIView *roomThree = [self chatRoomCardWithRoom:self.chatRooms[2]];
    [self.contentView addSubview:roomOne];
    [self.contentView addSubview:roomTwo];
    [self.contentView addSubview:roomThree];

    UIView *videosHeader = [self sectionHeaderWithTitle:@"Top Videos"];
    [self.contentView addSubview:videosHeader];

    UIScrollView *videoScrollView = [[UIScrollView alloc] init];
    videoScrollView.showsHorizontalScrollIndicator = NO;
    videoScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:videoScrollView];

    UIStackView *videoStack = [[UIStackView alloc] init];
    videoStack.axis = UILayoutConstraintAxisHorizontal;
    videoStack.spacing = 14;
    videoStack.translatesAutoresizingMaskIntoConstraints = NO;
    [videoScrollView addSubview:videoStack];
    for (NSInteger i = 0; i < (NSInteger)self.topVideoFileNames.count; i++) {
        [videoStack addArrangedSubview:[self videoTileWithVideoName:self.topVideoFileNames[i] index:i]];
    }

    self.featuredContentBottomConstraint = [videoScrollView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-110];

    [NSLayoutConstraint activateConstraints:@[
        [headerView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [headerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [headerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [headerView.heightAnchor constraintEqualToConstant:194],

        [titleImageView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:14],
        [titleImageView.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor constant:18],
        [titleImageView.widthAnchor constraintEqualToConstant:115],
        [titleImageView.heightAnchor constraintEqualToConstant:34],

        [self.featuredButton.topAnchor constraintEqualToAnchor:titleImageView.bottomAnchor constant:20],
        [self.featuredButton.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor constant:18],
        [self.featuredButton.widthAnchor constraintEqualToConstant:97],
        [self.featuredButton.heightAnchor constraintEqualToConstant:39],

        [self.chatButton.centerYAnchor constraintEqualToAnchor:self.featuredButton.centerYAnchor],
        [self.chatButton.leadingAnchor constraintEqualToAnchor:self.featuredButton.trailingAnchor constant:28],
        [self.chatButton.widthAnchor constraintEqualToConstant:97],
        [self.chatButton.heightAnchor constraintEqualToConstant:39],

        [mapView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:194],
        [mapView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [mapView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        [mapView.heightAnchor constraintEqualToConstant:270],

        [mapImageView.topAnchor constraintEqualToAnchor:mapView.topAnchor],
        [mapImageView.leadingAnchor constraintEqualToAnchor:mapView.leadingAnchor],
        [mapImageView.trailingAnchor constraintEqualToAnchor:mapView.trailingAnchor],
        [mapImageView.bottomAnchor constraintEqualToAnchor:mapView.bottomAnchor],

        [snowbasinPin.topAnchor constraintEqualToAnchor:mapView.topAnchor constant:28],
        [snowbasinPin.leadingAnchor constraintEqualToAnchor:mapView.leadingAnchor constant:30],
        [snowbasinPin.widthAnchor constraintEqualToConstant:116],
        [snowbasinPin.heightAnchor constraintEqualToConstant:52],

        [bigSkyPin.topAnchor constraintEqualToAnchor:mapView.topAnchor constant:48],
        [bigSkyPin.trailingAnchor constraintEqualToAnchor:mapView.trailingAnchor constant:-74],
        [bigSkyPin.widthAnchor constraintEqualToConstant:86],
        [bigSkyPin.heightAnchor constraintEqualToConstant:38],

        [aspenPin.topAnchor constraintEqualToAnchor:mapView.topAnchor constant:118],
        [aspenPin.centerXAnchor constraintEqualToAnchor:mapView.centerXAnchor constant:10],
        [aspenPin.widthAnchor constraintEqualToConstant:88],
        [aspenPin.heightAnchor constraintEqualToConstant:38],

        [deerPin.topAnchor constraintEqualToAnchor:mapView.topAnchor constant:162],
        [deerPin.leadingAnchor constraintEqualToAnchor:mapView.leadingAnchor constant:93],
        [deerPin.widthAnchor constraintEqualToConstant:72],
        [deerPin.heightAnchor constraintEqualToConstant:38],

        [palisadesPin.topAnchor constraintEqualToAnchor:mapView.topAnchor constant:162],
        [palisadesPin.trailingAnchor constraintEqualToAnchor:mapView.trailingAnchor constant:-60],
        [palisadesPin.widthAnchor constraintEqualToConstant:102],
        [palisadesPin.heightAnchor constraintEqualToConstant:38],

        [resortCard.topAnchor constraintEqualToAnchor:mapView.topAnchor constant:255],
        [resortCard.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:kExploreSidePadding],
        [resortCard.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-kExploreSidePadding],
        [resortCard.heightAnchor constraintEqualToConstant:214],

        [chatHeader.topAnchor constraintEqualToAnchor:resortCard.bottomAnchor constant:28],
        [chatHeader.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:kExploreSidePadding],
        [chatHeader.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-kExploreSidePadding],
        [chatHeader.heightAnchor constraintEqualToConstant:28],

        [roomOne.topAnchor constraintEqualToAnchor:chatHeader.bottomAnchor constant:17],
        [roomOne.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:kExploreSidePadding],
        [roomOne.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-kExploreSidePadding],
        [roomOne.heightAnchor constraintEqualToConstant:82],

        [roomTwo.topAnchor constraintEqualToAnchor:roomOne.bottomAnchor constant:14],
        [roomTwo.leadingAnchor constraintEqualToAnchor:roomOne.leadingAnchor],
        [roomTwo.trailingAnchor constraintEqualToAnchor:roomOne.trailingAnchor],
        [roomTwo.heightAnchor constraintEqualToAnchor:roomOne.heightAnchor],

        [roomThree.topAnchor constraintEqualToAnchor:roomTwo.bottomAnchor constant:14],
        [roomThree.leadingAnchor constraintEqualToAnchor:roomOne.leadingAnchor],
        [roomThree.trailingAnchor constraintEqualToAnchor:roomOne.trailingAnchor],
        [roomThree.heightAnchor constraintEqualToAnchor:roomOne.heightAnchor],

        [videosHeader.topAnchor constraintEqualToAnchor:roomThree.bottomAnchor constant:26],
        [videosHeader.leadingAnchor constraintEqualToAnchor:chatHeader.leadingAnchor],
        [videosHeader.trailingAnchor constraintEqualToAnchor:chatHeader.trailingAnchor],
        [videosHeader.heightAnchor constraintEqualToConstant:28],

        [videoScrollView.topAnchor constraintEqualToAnchor:videosHeader.bottomAnchor constant:14],
        [videoScrollView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:kExploreSidePadding],
        [videoScrollView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        [videoScrollView.heightAnchor constraintEqualToConstant:156],
        self.featuredContentBottomConstraint,

        [videoStack.topAnchor constraintEqualToAnchor:videoScrollView.contentLayoutGuide.topAnchor],
        [videoStack.leadingAnchor constraintEqualToAnchor:videoScrollView.contentLayoutGuide.leadingAnchor],
        [videoStack.trailingAnchor constraintEqualToAnchor:videoScrollView.contentLayoutGuide.trailingAnchor constant:-18],
        [videoStack.bottomAnchor constraintEqualToAnchor:videoScrollView.contentLayoutGuide.bottomAnchor],
        [videoStack.heightAnchor constraintEqualToAnchor:videoScrollView.frameLayoutGuide.heightAnchor],
    ]];
}

#pragma mark - Components

- (void)didTapFeaturedButton {
    if (!self.showingChatRooms) return;

    self.showingChatRooms = NO;
    [self updateSegmentButtons];
    [self.chatRoomsContainer removeFromSuperview];
    self.chatRoomsContainer = nil;
    self.featuredContentBottomConstraint.active = YES;

    for (UIView *subview in self.contentView.subviews) {
        subview.hidden = NO;
    }
    [self.scrollView setContentOffset:CGPointZero animated:NO];
}

- (void)didTapChatButton {
    if (self.showingChatRooms) return;

    self.showingChatRooms = YES;
    [self updateSegmentButtons];
    self.featuredContentBottomConstraint.active = NO;
    for (UIView *subview in self.contentView.subviews) {
        subview.hidden = YES;
    }
    [self buildChatRoomsContent];
    [self.scrollView setContentOffset:CGPointZero animated:NO];
}

- (void)updateSegmentButtons {
    UIColor *activeColor = [UIColor colorWithRed:0.18 green:0.51 blue:1.00 alpha:1.0];
    UIColor *inactiveColor = [UIColor colorWithWhite:1.0 alpha:0.28];

    self.featuredButton.backgroundColor = self.showingChatRooms ? inactiveColor : activeColor;
    self.chatButton.backgroundColor = self.showingChatRooms ? activeColor : inactiveColor;
    [self.featuredButton setTitleColor:[UIColor colorWithWhite:1 alpha:self.showingChatRooms ? 0.95 : 1.0] forState:UIControlStateNormal];
    [self.chatButton setTitleColor:[UIColor colorWithWhite:1 alpha:self.showingChatRooms ? 1.0 : 0.95] forState:UIControlStateNormal];
}

- (void)didTapResortPin:(UITapGestureRecognizer *)gesture {
    NSInteger index = gesture.view.tag;
    if (index < 0 || index >= (NSInteger)self.resorts.count || index == self.selectedResortIndex) {
        return;
    }

    self.selectedResortIndex = index;
    [self updateResortCard];
    [self updateResortPins];
}

- (void)updateResortCard {
    NSDictionary<NSString *, NSString *> *resort = [self selectedResort];
    self.resortTitleLabel.text = resort[@"title"];
    self.resortLocationLabel.text = resort[@"location"];
    self.resortTagLabel.text = resort[@"tag"];
    self.resortSummaryLabel.text = resort[@"summary"];
}

- (void)updateResortPins {
    for (NSInteger index = 0; index < (NSInteger)self.resortPins.count; index++) {
        [self configureMapPin:self.resortPins[index] highlighted:index == self.selectedResortIndex];
    }
}

- (NSDictionary<NSString *, NSString *> *)selectedResort {
    if (self.selectedResortIndex < 0 || self.selectedResortIndex >= (NSInteger)self.resorts.count) {
        return self.resorts.firstObject;
    }

    return self.resorts[self.selectedResortIndex];
}

- (void)buildChatRoomsContent {
    [self.chatRoomsContainer removeFromSuperview];

    UIView *container = [[UIView alloc] init];
    container.backgroundColor = self.contentView.backgroundColor;
    container.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:container];
    self.chatRoomsContainer = container;

    NSMutableArray<UIView *> *cards = [NSMutableArray array];
    for (NSDictionary<NSString *, id> *room in self.chatRooms) {
        UIView *card = [self chatRoomsModeCardWithRoom:room];
        [container addSubview:card];
        [cards addObject:card];
    }

    NSMutableArray<NSLayoutConstraint *> *constraints = [NSMutableArray arrayWithArray:@[
        [container.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
        [container.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [container.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        [container.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
    ]];

    UIView *previousCard = nil;
    for (UIView *card in cards) {
        [constraints addObjectsFromArray:@[
            [card.leadingAnchor constraintEqualToAnchor:container.leadingAnchor constant:kExploreSidePadding],
            [card.trailingAnchor constraintEqualToAnchor:container.trailingAnchor constant:-kExploreSidePadding],
            [card.heightAnchor constraintEqualToConstant:128],
        ]];
        if (previousCard) {
            [constraints addObject:[card.topAnchor constraintEqualToAnchor:previousCard.bottomAnchor constant:20]];
        } else {
            [constraints addObject:[card.topAnchor constraintEqualToAnchor:container.topAnchor constant:216]];
        }
        previousCard = card;
    }

    [constraints addObject:[previousCard.bottomAnchor constraintEqualToAnchor:container.bottomAnchor constant:-110]];

    [NSLayoutConstraint activateConstraints:constraints];
}

- (UIView *)chatRoomsModeCardWithRoom:(NSDictionary<NSString *, id> *)room {
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.64];
    card.layer.cornerRadius = 17;
    card.translatesAutoresizingMaskIntoConstraints = NO;
    [self attachOpenChatGestureToView:card room:room];

    UIImageView *thumbnail = [[UIImageView alloc] initWithImage:[self roomIconForRoom:room]];
    thumbnail.contentMode = UIViewContentModeScaleAspectFill;
    thumbnail.clipsToBounds = YES;
    thumbnail.layer.cornerRadius = 10;
    thumbnail.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *title = [self labelWithText:[self roomNameForRoom:room]
                                    font:[DesignFonts regular:16]
                                   color:[UIColor colorWithRed:0.19 green:0.19 blue:0.22 alpha:1.0]];

    UIImageView *groupIcon = [self imageViewWithName:@"explore_icon_group"];
    UILabel *onlineLabel = [self labelWithText:[self roomOnlineTextForRoom:room]
                                          font:[DesignFonts regular:12]
                                         color:[UIColor colorWithRed:0.14 green:0.70 blue:0.36 alpha:1.0]];

    UILabel *descriptionLabel = [self labelWithText:[self roomDescriptionForRoom:room]
                                               font:[DesignFonts regular:12]
                                              color:[UIColor colorWithRed:0.24 green:0.24 blue:0.31 alpha:1.0]];
    descriptionLabel.numberOfLines = 2;

    UIButton *joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [joinButton setImage:[UIImage imageNamed:@"btn_explore_join"] forState:UIControlStateNormal];
    joinButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    joinButton.userInteractionEnabled = NO;
    joinButton.translatesAutoresizingMaskIntoConstraints = NO;

    [card addSubview:thumbnail];
    [card addSubview:title];
    [card addSubview:groupIcon];
    [card addSubview:onlineLabel];
    [card addSubview:descriptionLabel];
    [card addSubview:joinButton];

    [NSLayoutConstraint activateConstraints:@[
        [thumbnail.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:12],
        [thumbnail.centerYAnchor constraintEqualToAnchor:card.centerYAnchor],
        [thumbnail.widthAnchor constraintEqualToConstant:104],
        [thumbnail.heightAnchor constraintEqualToConstant:104],

        [title.leadingAnchor constraintEqualToAnchor:thumbnail.trailingAnchor constant:12],
        [title.topAnchor constraintEqualToAnchor:card.topAnchor constant:24],
        [title.trailingAnchor constraintLessThanOrEqualToAnchor:joinButton.leadingAnchor constant:-10],

        [groupIcon.leadingAnchor constraintEqualToAnchor:title.leadingAnchor],
        [groupIcon.topAnchor constraintEqualToAnchor:title.bottomAnchor constant:7],
        [groupIcon.widthAnchor constraintEqualToConstant:12],
        [groupIcon.heightAnchor constraintEqualToConstant:12],

        [onlineLabel.leadingAnchor constraintEqualToAnchor:groupIcon.trailingAnchor constant:4],
        [onlineLabel.centerYAnchor constraintEqualToAnchor:groupIcon.centerYAnchor],
        [onlineLabel.trailingAnchor constraintLessThanOrEqualToAnchor:joinButton.leadingAnchor constant:-10],

        [descriptionLabel.leadingAnchor constraintEqualToAnchor:title.leadingAnchor],
        [descriptionLabel.topAnchor constraintEqualToAnchor:onlineLabel.bottomAnchor constant:12],
        [descriptionLabel.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-20],

        [joinButton.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-12],
        [joinButton.topAnchor constraintEqualToAnchor:card.topAnchor constant:24],
        [joinButton.widthAnchor constraintEqualToConstant:64],
        [joinButton.heightAnchor constraintEqualToConstant:28],
    ]];

    return card;
}

- (UIButton *)pillButtonWithTitle:(NSString *)title backgroundColor:(UIColor *)backgroundColor textAlpha:(CGFloat)textAlpha {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = backgroundColor;
    button.layer.cornerRadius = 20;
    button.titleLabel.font = [DesignFonts semibold:14];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithWhite:1 alpha:textAlpha] forState:UIControlStateNormal];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    return button;
}

- (UIView *)mapPinWithTitle:(NSString *)title highlighted:(BOOL)highlighted {
    UIView *container = [[UIView alloc] init];
    container.layer.shadowColor = [UIColor colorWithRed:0.25 green:0.36 blue:0.55 alpha:1.0].CGColor;
    container.layer.shadowOpacity = 0.10;
    container.layer.shadowRadius = 8;
    container.layer.shadowOffset = CGSizeMake(0, 4);
    container.translatesAutoresizingMaskIntoConstraints = NO;

    UIImageView *icon = [self imageViewWithName:@"explore_icon_snowflake"];
    UILabel *label = [self labelWithText:title
                                    font:[DesignFonts semibold:11]
                                   color:[UIColor colorWithRed:0.22 green:0.23 blue:0.28 alpha:1.0]];
    [container addSubview:icon];
    [container addSubview:label];

    CGFloat iconSize = highlighted ? 28.0 : 22.0;
    [NSLayoutConstraint activateConstraints:@[
        [icon.leadingAnchor constraintEqualToAnchor:container.leadingAnchor constant:highlighted ? 12 : 10],
        [icon.centerYAnchor constraintEqualToAnchor:container.centerYAnchor],
        [icon.widthAnchor constraintEqualToConstant:iconSize],
        [icon.heightAnchor constraintEqualToConstant:iconSize],

        [label.leadingAnchor constraintEqualToAnchor:icon.trailingAnchor constant:highlighted ? 4 : 5],
        [label.centerYAnchor constraintEqualToAnchor:container.centerYAnchor],
        [label.trailingAnchor constraintLessThanOrEqualToAnchor:container.trailingAnchor constant:-9],
    ]];

    [self configureMapPin:container highlighted:highlighted];
    return container;
}

- (void)configureMapPin:(UIView *)pin highlighted:(BOOL)highlighted {
    pin.backgroundColor = UIColor.whiteColor;
    CGFloat highlightedRadius = CGRectGetHeight(pin.bounds) > 0.0 ? CGRectGetHeight(pin.bounds) / 2.0 : 26.0;
    pin.layer.cornerRadius = highlighted ? highlightedRadius : 19.0;
    pin.layer.borderWidth = highlighted ? 5.0 : 0.0;
    pin.layer.borderColor = highlighted ? [UIColor colorWithRed:1.00 green:0.93 blue:0.48 alpha:1.0].CGColor : UIColor.clearColor.CGColor;
}

- (UIView *)makeResortCard {
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = UIColor.whiteColor;
    card.layer.cornerRadius = 20;
    card.layer.shadowColor = [UIColor colorWithRed:0.24 green:0.27 blue:0.45 alpha:1.0].CGColor;
    card.layer.shadowOpacity = 0.08;
    card.layer.shadowRadius = 14;
    card.layer.shadowOffset = CGSizeMake(0, 6);
    card.translatesAutoresizingMaskIntoConstraints = NO;

    NSDictionary<NSString *, NSString *> *resort = [self selectedResort];

    UILabel *title = [self labelWithText:resort[@"title"]
                                    font:[DesignFonts semibold:20]
                                   color:[UIColor colorWithRed:0.18 green:0.18 blue:0.21 alpha:1.0]];
    title.adjustsFontSizeToFitWidth = YES;
    title.minimumScaleFactor = 0.82;
    self.resortTitleLabel = title;

    UIImageView *locationImage = [self imageViewWithName:@"explore_badge_location"];
    UILabel *locationLabel = [self labelWithText:resort[@"location"]
                                            font:[DesignFonts regular:12]
                                           color:[UIColor colorWithRed:0.24 green:0.24 blue:0.28 alpha:1.0]];
    locationLabel.adjustsFontSizeToFitWidth = YES;
    locationLabel.minimumScaleFactor = 0.86;
    self.resortLocationLabel = locationLabel;

    UIImageView *tagImage = [self imageViewWithName:@"explore_badge_tag"];
    UILabel *tagLabel = [self labelWithText:resort[@"tag"]
                                       font:[DesignFonts regular:12]
                                      color:[UIColor colorWithRed:0.24 green:0.24 blue:0.28 alpha:1.0]];
    tagLabel.numberOfLines = 2;
    tagLabel.adjustsFontSizeToFitWidth = YES;
    tagLabel.minimumScaleFactor = 0.86;
    self.resortTagLabel = tagLabel;

    UIView *summaryBox = [[UIView alloc] init];
    summaryBox.backgroundColor = [UIColor colorWithRed:0.91 green:0.95 blue:1.00 alpha:1.0];
    summaryBox.layer.cornerRadius = 14;
    summaryBox.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *summary = [self labelWithText:resort[@"summary"]
                                      font:[DesignFonts regular:13]
                                     color:[UIColor colorWithRed:0.03 green:0.24 blue:0.52 alpha:1.0]];
    summary.numberOfLines = 4;
    self.resortSummaryLabel = summary;

    UIImageView *skiImage = [self imageViewWithName:@"explore_ski_equipment"];
    skiImage.transform = CGAffineTransformMakeRotation(0.13);

    [card addSubview:title];
    [card addSubview:locationImage];
    [card addSubview:locationLabel];
    [card addSubview:tagImage];
    [card addSubview:tagLabel];
    [card addSubview:summaryBox];
    [summaryBox addSubview:summary];
    [card addSubview:skiImage];

    [NSLayoutConstraint activateConstraints:@[
        [title.topAnchor constraintEqualToAnchor:card.topAnchor constant:16],
        [title.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:16],
        [title.trailingAnchor constraintLessThanOrEqualToAnchor:skiImage.leadingAnchor constant:-6],

        [locationImage.leadingAnchor constraintEqualToAnchor:title.leadingAnchor],
        [locationImage.topAnchor constraintEqualToAnchor:title.bottomAnchor constant:10],
        [locationImage.widthAnchor constraintEqualToConstant:68],
        [locationImage.heightAnchor constraintEqualToConstant:12],

        [locationLabel.leadingAnchor constraintEqualToAnchor:locationImage.trailingAnchor constant:5],
        [locationLabel.centerYAnchor constraintEqualToAnchor:locationImage.centerYAnchor],
        [locationLabel.trailingAnchor constraintLessThanOrEqualToAnchor:card.trailingAnchor constant:-16],

        [tagImage.leadingAnchor constraintEqualToAnchor:title.leadingAnchor],
        [tagImage.topAnchor constraintEqualToAnchor:locationImage.bottomAnchor constant:10],
        [tagImage.widthAnchor constraintEqualToConstant:43],
        [tagImage.heightAnchor constraintEqualToConstant:15],

        [tagLabel.leadingAnchor constraintEqualToAnchor:tagImage.trailingAnchor constant:5],
        [tagLabel.topAnchor constraintEqualToAnchor:tagImage.topAnchor constant:-1],
        [tagLabel.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-14],

        [summaryBox.leadingAnchor constraintEqualToAnchor:title.leadingAnchor],
        [summaryBox.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-16],
        [summaryBox.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-16],
        [summaryBox.heightAnchor constraintEqualToConstant:86],

        [summary.leadingAnchor constraintEqualToAnchor:summaryBox.leadingAnchor constant:15],
        [summary.trailingAnchor constraintEqualToAnchor:summaryBox.trailingAnchor constant:-15],
        [summary.centerYAnchor constraintEqualToAnchor:summaryBox.centerYAnchor],

        [skiImage.topAnchor constraintEqualToAnchor:card.topAnchor constant:-34],
        [skiImage.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-4],
        [skiImage.widthAnchor constraintEqualToConstant:91],
        [skiImage.heightAnchor constraintEqualToConstant:91],
    ]];

    return card;
}

- (UIView *)sectionHeaderWithTitle:(NSString *)title {
    UIView *header = [[UIView alloc] init];
    header.translatesAutoresizingMaskIntoConstraints = NO;

    UIImageView *icon = [self imageViewWithName:@"explore_icon_flame"];
    UILabel *label = [self labelWithText:title
                                    font:[DesignFonts semibold:18]
                                   color:[UIColor colorWithRed:0.20 green:0.20 blue:0.25 alpha:1.0]];
    [header addSubview:icon];
    [header addSubview:label];

    [NSLayoutConstraint activateConstraints:@[
        [icon.leadingAnchor constraintEqualToAnchor:header.leadingAnchor],
        [icon.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],
        [icon.widthAnchor constraintEqualToConstant:20],
        [icon.heightAnchor constraintEqualToConstant:20],

        [label.leadingAnchor constraintEqualToAnchor:icon.trailingAnchor constant:6],
        [label.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],
        [label.trailingAnchor constraintLessThanOrEqualToAnchor:header.trailingAnchor],
    ]];

    return header;
}

- (UIView *)chatRoomCardWithRoom:(NSDictionary<NSString *, id> *)room {
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.74];
    card.layer.cornerRadius = 17;
    card.translatesAutoresizingMaskIntoConstraints = NO;
    [self attachOpenChatGestureToView:card room:room];

    UIImageView *thumbnail = [[UIImageView alloc] initWithImage:[self roomIconForRoom:room]];
    thumbnail.contentMode = UIViewContentModeScaleAspectFill;
    thumbnail.clipsToBounds = YES;
    thumbnail.layer.cornerRadius = 10;
    thumbnail.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *title = [self labelWithText:[self roomNameForRoom:room]
                                    font:[DesignFonts regular:16]
                                   color:[UIColor colorWithRed:0.19 green:0.19 blue:0.22 alpha:1.0]];

    UIImageView *groupIcon = [self imageViewWithName:@"explore_icon_group"];
    UILabel *onlineLabel = [self labelWithText:[self roomOnlineTextForRoom:room]
                                          font:[DesignFonts regular:12]
                                         color:[UIColor colorWithRed:0.14 green:0.70 blue:0.36 alpha:1.0]];

    UIButton *joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [joinButton setImage:[UIImage imageNamed:@"btn_explore_join"] forState:UIControlStateNormal];
    joinButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    joinButton.userInteractionEnabled = NO;
    joinButton.translatesAutoresizingMaskIntoConstraints = NO;

    [card addSubview:thumbnail];
    [card addSubview:title];
    [card addSubview:groupIcon];
    [card addSubview:onlineLabel];
    [card addSubview:joinButton];

    [NSLayoutConstraint activateConstraints:@[
        [thumbnail.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:8],
        [thumbnail.centerYAnchor constraintEqualToAnchor:card.centerYAnchor],
        [thumbnail.widthAnchor constraintEqualToConstant:68],
        [thumbnail.heightAnchor constraintEqualToConstant:68],

        [title.leadingAnchor constraintEqualToAnchor:thumbnail.trailingAnchor constant:11],
        [title.topAnchor constraintEqualToAnchor:card.topAnchor constant:19],
        [title.trailingAnchor constraintLessThanOrEqualToAnchor:joinButton.leadingAnchor constant:-8],

        [groupIcon.leadingAnchor constraintEqualToAnchor:title.leadingAnchor],
        [groupIcon.topAnchor constraintEqualToAnchor:title.bottomAnchor constant:7],
        [groupIcon.widthAnchor constraintEqualToConstant:12],
        [groupIcon.heightAnchor constraintEqualToConstant:12],

        [onlineLabel.leadingAnchor constraintEqualToAnchor:groupIcon.trailingAnchor constant:4],
        [onlineLabel.centerYAnchor constraintEqualToAnchor:groupIcon.centerYAnchor],

        [joinButton.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-11],
        [joinButton.centerYAnchor constraintEqualToAnchor:card.centerYAnchor],
        [joinButton.widthAnchor constraintEqualToConstant:64],
        [joinButton.heightAnchor constraintEqualToConstant:28],
    ]];

    return card;
}

- (UIView *)videoTileWithVideoName:(NSString *)videoName index:(NSInteger)index {
    UIView *tile = [[UIView alloc] init];
    tile.layer.cornerRadius = 17;
    tile.clipsToBounds = YES;
    tile.tag = index;
    tile.userInteractionEnabled = YES;
    tile.translatesAutoresizingMaskIntoConstraints = NO;

    UIImage *thumbnailImage = [self thumbnailForVideoNamed:videoName] ?: self.skiThumbnail ?: [UIImage imageNamed:@"explore_mountain_header"];
    UIImageView *thumbnail = [[UIImageView alloc] initWithImage:thumbnailImage];
    thumbnail.contentMode = UIViewContentModeScaleAspectFill;
    thumbnail.clipsToBounds = YES;
    thumbnail.translatesAutoresizingMaskIntoConstraints = NO;

    UIView *dim = [[UIView alloc] init];
    dim.backgroundColor = [UIColor colorWithWhite:0 alpha:0.08];
    dim.translatesAutoresizingMaskIntoConstraints = NO;

    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [playButton setImage:[UIImage imageNamed:@"explore_icon_play"] forState:UIControlStateNormal];
    playButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    playButton.translatesAutoresizingMaskIntoConstraints = NO;

    [tile addSubview:thumbnail];
    [tile addSubview:dim];
    [tile addSubview:playButton];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapTopVideoTile:)];
    [tile addGestureRecognizer:tapGesture];

    [NSLayoutConstraint activateConstraints:@[
        [tile.widthAnchor constraintEqualToConstant:122],

        [thumbnail.topAnchor constraintEqualToAnchor:tile.topAnchor],
        [thumbnail.leadingAnchor constraintEqualToAnchor:tile.leadingAnchor],
        [thumbnail.trailingAnchor constraintEqualToAnchor:tile.trailingAnchor],
        [thumbnail.bottomAnchor constraintEqualToAnchor:tile.bottomAnchor],

        [dim.topAnchor constraintEqualToAnchor:tile.topAnchor],
        [dim.leadingAnchor constraintEqualToAnchor:tile.leadingAnchor],
        [dim.trailingAnchor constraintEqualToAnchor:tile.trailingAnchor],
        [dim.bottomAnchor constraintEqualToAnchor:tile.bottomAnchor],

        [playButton.centerXAnchor constraintEqualToAnchor:tile.centerXAnchor],
        [playButton.centerYAnchor constraintEqualToAnchor:tile.centerYAnchor],
        [playButton.widthAnchor constraintEqualToConstant:40],
        [playButton.heightAnchor constraintEqualToConstant:40],
    ]];

    return tile;
}

#pragma mark - Navigation

- (void)openChatRoom {
    [self openChatRoomWithRoom:self.chatRooms.firstObject];
}

- (void)openChatRoomFromGesture:(UITapGestureRecognizer *)gesture {
    NSDictionary<NSString *, id> *room = objc_getAssociatedObject(gesture.view, &kExploreRoomAssociationKey);
    [self openChatRoomWithRoom:room];
}

- (void)openChatRoomWithRoom:(NSDictionary<NSString *, id> *)room {
    ChatViewController *chatViewController = [[ChatViewController alloc] init];
    chatViewController.roomName = [self roomNameForRoom:room];
    chatViewController.roomOnlineText = [self roomOnlineTextForRoom:room];
    chatViewController.roomDescription = [self roomDescriptionForRoom:room];

    if (self.navigationController) {
        chatViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:chatViewController animated:YES];
        return;
    }

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:chatViewController];
    navigationController.navigationBarHidden = YES;
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)didTapTopVideoTile:(UITapGestureRecognizer *)gesture {
    NSInteger index = gesture.view.tag;
    if (index < 0 || index >= (NSInteger)self.topVideoFileNames.count) {
        return;
    }

    [self openTopVideoWithFileName:self.topVideoFileNames[index]];
}

- (void)openTopVideoWithFileName:(NSString *)videoFileName {
    self.topVideoFileNames = [self visibleTopVideoFileNames];
    if (![self.topVideoFileNames containsObject:videoFileName]) {
        videoFileName = self.topVideoFileNames.firstObject;
    }
    if (videoFileName.length == 0) {
        return;
    }

    VideoViewController *videoViewController = [[VideoViewController alloc] init];
    videoViewController.videoFileNames = self.topVideoFileNames;
    videoViewController.initialVideoFileName = videoFileName;
    videoViewController.showsBackButton = YES;

    if (self.navigationController) {
        videoViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:videoViewController animated:YES];
        return;
    }

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:videoViewController];
    navigationController.navigationBarHidden = YES;
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Helpers

- (void)attachOpenChatGestureToView:(UIView *)view room:(NSDictionary<NSString *, id> *)room {
    view.userInteractionEnabled = YES;
    objc_setAssociatedObject(view, &kExploreRoomAssociationKey, room, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openChatRoomFromGesture:)];
    tapGesture.cancelsTouchesInView = NO;
    [view addGestureRecognizer:tapGesture];
}

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

- (NSString *)roomNameForRoom:(NSDictionary<NSString *, id> *)room {
    NSString *name = room[@"name"];
    return [name isKindOfClass:NSString.class] && name.length > 0 ? name : @"Snow Chat";
}

- (NSString *)roomOnlineTextForRoom:(NSDictionary<NSString *, id> *)room {
    NSNumber *online = room[@"online"];
    NSInteger count = [online respondsToSelector:@selector(integerValue)] ? online.integerValue : 0;
    return [NSString stringWithFormat:@"%ld online", (long)MAX(count, 1)];
}

- (NSString *)roomDescriptionForRoom:(NSDictionary<NSString *, id> *)room {
    NSString *description = room[@"desc"];
    return [description isKindOfClass:NSString.class] && description.length > 0 ? description : @"Share slope plans and mountain updates.";
}

- (UIImage *)roomIconForRoom:(NSDictionary<NSString *, id> *)room {
    NSString *iconName = room[@"icon"];
    UIImage *icon = [iconName isKindOfClass:NSString.class] && iconName.length > 0 ? [UIImage imageNamed:iconName] : nil;
    return icon ?: self.skiThumbnail ?: [UIImage imageNamed:@"explore_mountain_header"];
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

@end
