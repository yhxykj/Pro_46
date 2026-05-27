//
//  SettingsViewController.m
//  Skiing
//

#import "SettingsViewController.h"
#import "ProfileRelationshipListViewController.h"
#import "UserSession.h"
#import "ViewController.h"
#import "DesignTokens.h"
#import <SafariServices/SafariServices.h>

static CGFloat const kSettingsSidePadding = 24.0;
static NSString * const kSettingsPrivacyAgreementURL = @"https://www.example.com/privacy";
static NSString * const kSettingsUserAgreementURL = @"https://www.example.com/agreement";
static NSString * const kSettingsCommunityGuidelinesURL = @"https://www.example.com/community-guidelines";

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

    UIControl *privacyItem = [self menuItemWithTitle:@"Privacy agreement"];
    [privacyItem addTarget:self action:@selector(didTapPrivacyAgreementItem) forControlEvents:UIControlEventTouchUpInside];
    [menuStackView addArrangedSubview:privacyItem];

    UIControl *userAgreementItem = [self menuItemWithTitle:@"User agreement"];
    [userAgreementItem addTarget:self action:@selector(didTapUserAgreementItem) forControlEvents:UIControlEventTouchUpInside];
    [menuStackView addArrangedSubview:userAgreementItem];

    UIControl *communityGuidelinesItem = [self menuItemWithTitle:@"Community Guidelines"];
    [communityGuidelinesItem addTarget:self action:@selector(didTapCommunityGuidelinesItem) forControlEvents:UIControlEventTouchUpInside];
    [menuStackView addArrangedSubview:communityGuidelinesItem];

    UIControl *contactItem = [self menuItemWithTitle:@"Contact Us"];
    [contactItem addTarget:self action:@selector(didTapContactUsItem) forControlEvents:UIControlEventTouchUpInside];
    [menuStackView addArrangedSubview:contactItem];

    UIControl *deleteAccountItem = [self menuItemWithTitle:@"Delete of account"];
    [deleteAccountItem addTarget:self action:@selector(didTapDeleteAccountItem) forControlEvents:UIControlEventTouchUpInside];
    [menuStackView addArrangedSubview:deleteAccountItem];

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

- (void)didTapPrivacyAgreementItem {
    [self openURL:kSettingsPrivacyAgreementURL];
}

- (void)didTapUserAgreementItem {
    [self openURL:kSettingsUserAgreementURL];
}

- (void)didTapCommunityGuidelinesItem {
    [self openURL:kSettingsCommunityGuidelinesURL];
}

- (void)didTapContactUsItem {
    [self showSettingsInfoWithTitle:@"Contact Us"
                             message:@"Need help? Contact the Skiing support team at support@skiingapp.com. We usually review messages within 2 business days."];
}

- (void)didTapDeleteAccountItem {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete account?"
                                                                   message:@"Your request will be submitted for review. Account deletion may remove your profile, posts, chats, and saved activity."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Submit request" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self showSettingsInfoWithTitle:@"Request submitted"
                                message:@"Your account deletion request has been submitted for review."];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showSettingsInfoWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)openURL:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) return;

    SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:url];
    [self presentViewController:safari animated:YES completion:nil];
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
