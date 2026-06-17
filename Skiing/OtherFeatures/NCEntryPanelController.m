#import "NCEntryPanelController.h"

#import "NCSlopeFeatureContext.h"
#import "NCSlopeGatewayInternal.h"

@interface NCEntryPanelController ()
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIButton *entryButton;
@end

@implementation NCEntryPanelController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;
    [self buildEntryInterface];
}

- (void)buildEntryInterface {
    self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:NCSlopeRouteLoginImage]];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImageView.clipsToBounds = YES;
    self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.backgroundImageView];

    self.entryButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.entryButton setTitle:@"Log In" forState:UIControlStateNormal];
    [self.entryButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.entryButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    self.entryButton.backgroundColor = [UIColor colorWithRed:150.0 / 255.0 green:52.0 / 255.0 blue:253.0 / 255.0 alpha:1];
    self.entryButton.layer.cornerRadius = 29;
    self.entryButton.clipsToBounds = YES;
    self.entryButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.entryButton addTarget:self action:@selector(entryButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.entryButton];

    [NSLayoutConstraint activateConstraints:@[
        [self.backgroundImageView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.backgroundImageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.backgroundImageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.backgroundImageView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [self.entryButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:32],
        [self.entryButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-32],
        [self.entryButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-56],
        [self.entryButton.heightAnchor constraintEqualToConstant:58]
    ]];
}

- (void)entryButtonTapped {
    if (!NCSlopeTapLocked) {
        [[NCSlopeGateway sharedGateway] performFastEntry];
    }
    NCSlopeTapLocked = YES;
}

@end
