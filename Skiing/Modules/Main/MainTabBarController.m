//
//  MainTabBarController.m
//  Skiing
//

#import "MainTabBarController.h"
#import "VideoViewController.h"
#import "ExploreViewController.h"
#import "FriendsChatViewController.h"
#import "ProfileViewController.h"

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTabs];
    [self setupAppearance];
}

- (void)setupTabs {
    VideoViewController   *videoVC   = [[VideoViewController alloc] init];
    ExploreViewController *exploreVC = [[ExploreViewController alloc] init];
    FriendsChatViewController *chatVC = [[FriendsChatViewController alloc] init];
    ProfileViewController *profileVC = [[ProfileViewController alloc] init];

    // videoVC 包一层 NavigationController 以支持 push 到发布页
    UINavigationController *videoNav = [[UINavigationController alloc] initWithRootViewController:videoVC];
    [videoNav setNavigationBarHidden:YES animated:NO];
    videoNav.tabBarItem  = [self tabItemWithTitle:@"Video"   normal:@"tab_video_normal"   selected:@"tab_video_selected"];

    UINavigationController *profileNav = [[UINavigationController alloc] initWithRootViewController:profileVC];
    [profileNav setNavigationBarHidden:YES animated:NO];
    profileNav.tabBarItem = [self tabItemWithTitle:@"Profile" normal:@"tab_profile_normal" selected:@"tab_profile_selected"];

    UINavigationController *chatNav = [[UINavigationController alloc] initWithRootViewController:chatVC];
    [chatNav setNavigationBarHidden:YES animated:NO];
    chatNav.tabBarItem = [self tabItemWithTitle:@"Chat" normal:@"tab_chat_normal" selected:@"tab_chat_selected"];

    exploreVC.tabBarItem = [self tabItemWithTitle:@"Explore" normal:@"tab_explore_normal" selected:@"tab_explore_selected"];

    self.viewControllers = @[videoNav, exploreVC, chatNav, profileNav];
}

- (UITabBarItem *)tabItemWithTitle:(NSString *)title
                            normal:(NSString *)normalName
                          selected:(NSString *)selectedName {
    UIImage *normalImage   = [[UIImage imageNamed:normalName]   imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *selectedImage = [[UIImage imageNamed:selectedName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:title image:normalImage selectedImage:selectedImage];

    // Title color
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:0.28 green:0.56 blue:1.0 alpha:1.0]} forState:UIControlStateSelected];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0]} forState:UIControlStateNormal];

    return item;
}

- (void)setupAppearance {
    UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
    [appearance configureWithOpaqueBackground];
    appearance.backgroundColor = UIColor.whiteColor;

    // Remove top separator line
    appearance.shadowImage = [[UIImage alloc] init];
    appearance.shadowColor = UIColor.clearColor;

    self.tabBar.standardAppearance = appearance;
    if (@available(iOS 15.0, *)) {
        self.tabBar.scrollEdgeAppearance = appearance;
    }
}

@end
