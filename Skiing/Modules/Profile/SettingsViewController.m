//
//  SettingsViewController.m
//  Skiing
//

#import "SettingsViewController.h"
#import "ProfileRelationshipListViewController.h"
#import "UserSession.h"
#import "ViewController.h"
#import "DesignTokens.h"

static CGFloat const kSettingsSidePadding = 24.0;

@interface SettingsViewController ()
@property (nonatomic, strong) CAGradientLayer *backgroundGradientLayer;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.75 green:0.78 blue:1.0 alpha:1.0];
    [self setupBackground];
    [self setupContent];
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
    titleLabel.text = @"Settings";
    titleLabel.font = [DesignFonts semibold:22];
    titleLabel.textColor = [UIColor colorWithRed:0.17 green:0.17 blue:0.24 alpha:1.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    UIStackView *menuStackView = [[UIStackView alloc] init];
    menuStackView.axis = UILayoutConstraintAxisVertical;
    menuStackView.spacing = 16.0;
    menuStackView.translatesAutoresizingMaskIntoConstraints = NO;

    UIControl *blacklistItem = [self menuItemWithTitle:@"Blacklist"];
    [blacklistItem addTarget:self action:@selector(didTapBlacklistItem) forControlEvents:UIControlEventTouchUpInside];
    [menuStackView addArrangedSubview:blacklistItem];
    [menuStackView addArrangedSubview:[self menuItemWithTitle:@"Privacy agreement"]];
    [menuStackView addArrangedSubview:[self menuItemWithTitle:@"User agreement"]];
    [menuStackView addArrangedSubview:[self menuItemWithTitle:@"Community Guidelines"]];
    [menuStackView addArrangedSubview:[self menuItemWithTitle:@"Contact Us"]];
    [menuStackView addArrangedSubview:[self menuItemWithTitle:@"Delete of account"]];

    for (UIView *item in menuStackView.arrangedSubviews) {
        [item.heightAnchor constraintEqualToConstant:76.0].active = YES;
    }

    UIButton *logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    logoutButton.backgroundColor = [UIColor colorWithRed:1.0 green:0.94 blue:0.60 alpha:1.0];
    logoutButton.layer.cornerRadius = 14.0;
    logoutButton.titleLabel.font = [DesignFonts semibold:20];
    [logoutButton setTitle:@"Log out" forState:UIControlStateNormal];
    [logoutButton setTitleColor:[UIColor colorWithRed:0.17 green:0.17 blue:0.22 alpha:1.0] forState:UIControlStateNormal];
    logoutButton.translatesAutoresizingMaskIntoConstraints = NO;
    [logoutButton addTarget:self action:@selector(didTapLogoutButton) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:backButton];
    [self.view addSubview:titleLabel];
    [self.view addSubview:menuStackView];
    [self.view addSubview:logoutButton];

    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [backButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [backButton.topAnchor constraintEqualToAnchor:safeArea.topAnchor constant:12],
        [backButton.widthAnchor constraintEqualToConstant:44],
        [backButton.heightAnchor constraintEqualToConstant:44],

        [titleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [titleLabel.centerYAnchor constraintEqualToAnchor:backButton.centerYAnchor],

        [menuStackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kSettingsSidePadding],
        [menuStackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-kSettingsSidePadding],
        [menuStackView.topAnchor constraintEqualToAnchor:backButton.bottomAnchor constant:32],

        [logoutButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kSettingsSidePadding],
        [logoutButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-kSettingsSidePadding],
        [logoutButton.bottomAnchor constraintEqualToAnchor:safeArea.bottomAnchor constant:-40],
        [logoutButton.heightAnchor constraintEqualToConstant:60],
    ]];
}

- (UIControl *)menuItemWithTitle:(NSString *)title {
    UIControl *control = [[UIControl alloc] init];
    control.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.38];
    control.layer.cornerRadius = 14.0;

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [DesignFonts semibold:17];
    titleLabel.textColor = [UIColor colorWithRed:0.18 green:0.18 blue:0.23 alpha:1.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [control addSubview:titleLabel];
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.centerXAnchor constraintEqualToAnchor:control.centerXAnchor],
        [titleLabel.centerYAnchor constraintEqualToAnchor:control.centerYAnchor],
        [titleLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:control.leadingAnchor constant:16],
        [titleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:control.trailingAnchor constant:-16],
    ]];

    return control;
}

#pragma mark - Actions

- (void)didTapBackButton {
    if (self.navigationController && self.navigationController.viewControllers.firstObject != self) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didTapBlacklistItem {
    ProfileRelationshipListViewController *blacklistViewController = [[ProfileRelationshipListViewController alloc] initWithTitle:@"Blacklist" mode:ProfileRelationshipListModeBlacklist];
    blacklistViewController.hidesBottomBarWhenPushed = YES;

    if (self.navigationController) {
        [self.navigationController pushViewController:blacklistViewController animated:YES];
        return;
    }

    blacklistViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:blacklistViewController animated:YES completion:nil];
}

- (void)didTapLogoutButton {
    [UserSession clearLoginState];

    ViewController *loginViewController = [[ViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    [navigationController setNavigationBarHidden:YES animated:NO];

    UIWindow *window = self.view.window;
    window.rootViewController = navigationController;
    [UIView transitionWithView:window
                      duration:0.25
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:nil
                    completion:nil];
}

@end
