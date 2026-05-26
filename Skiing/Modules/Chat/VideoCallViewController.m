//
//  VideoCallViewController.m
//  Skiing
//

#import "VideoCallViewController.h"
#import "DesignTokens.h"

@interface VideoCallViewController ()
@property (nonatomic, strong) UIImageView *remoteVideoView;
@property (nonatomic, strong) UIButton *micButton;
@property (nonatomic, strong) UIButton *speakerButton;
@property (nonatomic, assign, getter=isMicMuted) BOOL micMuted;
@property (nonatomic, assign, getter=isSpeakerMuted) BOOL speakerMuted;
@end

@implementation VideoCallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;
    [self setupRemoteVideo];
    [self setupHeader];
    [self setupLocalPreview];
    [self setupControls];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDarkContent;
}

#pragma mark - Setup

- (void)setupRemoteVideo {
    self.remoteVideoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatar_user_06"]];
    self.remoteVideoView.contentMode = UIViewContentModeScaleAspectFill;
    self.remoteVideoView.clipsToBounds = YES;
    self.remoteVideoView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.remoteVideoView];

    UIView *topShade = [[UIView alloc] init];
    topShade.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.18];
    topShade.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:topShade];

    [NSLayoutConstraint activateConstraints:@[
        [self.remoteVideoView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.remoteVideoView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.remoteVideoView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.remoteVideoView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [topShade.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [topShade.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [topShade.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [topShade.heightAnchor constraintEqualToConstant:142.0],
    ]];
}

- (void)setupHeader {
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
    backButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [backButton addTarget:self action:@selector(didTapEndButton) forControlEvents:UIControlEventTouchUpInside];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Raya";
    titleLabel.font = [DesignFonts semibold:18];
    titleLabel.textColor = UIColor.whiteColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setImage:[UIImage imageNamed:@"chat_more_button"] forState:UIControlStateNormal];
    moreButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    moreButton.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:backButton];
    [self.view addSubview:titleLabel];
    [self.view addSubview:moreButton];

    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [backButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:18.0],
        [backButton.topAnchor constraintEqualToAnchor:safeArea.topAnchor constant:12.0],
        [backButton.widthAnchor constraintEqualToConstant:44.0],
        [backButton.heightAnchor constraintEqualToConstant:44.0],

        [titleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [titleLabel.centerYAnchor constraintEqualToAnchor:backButton.centerYAnchor],

        [moreButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-18.0],
        [moreButton.centerYAnchor constraintEqualToAnchor:backButton.centerYAnchor],
        [moreButton.widthAnchor constraintEqualToConstant:44.0],
        [moreButton.heightAnchor constraintEqualToConstant:44.0],
    ]];
}

- (void)setupLocalPreview {
    UIImageView *preview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatar_user_13"]];
    preview.contentMode = UIViewContentModeScaleAspectFill;
    preview.clipsToBounds = YES;
    preview.layer.cornerRadius = 50.0;
    preview.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.86].CGColor;
    preview.layer.borderWidth = 1.0;
    preview.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:preview];

    [NSLayoutConstraint activateConstraints:@[
        [preview.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [preview.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:138.0],
        [preview.widthAnchor constraintEqualToConstant:100.0],
        [preview.heightAnchor constraintEqualToConstant:100.0],
    ]];
}

- (void)setupControls {
    UIView *controlPanel = [[UIView alloc] init];
    controlPanel.backgroundColor = [UIColor colorWithRed:0.60 green:0.65 blue:1.0 alpha:0.88];
    controlPanel.layer.cornerRadius = 18.0;
    controlPanel.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    controlPanel.translatesAutoresizingMaskIntoConstraints = NO;

    self.micButton = [self controlButtonWithImageName:@"video_call_mic_on_button" action:@selector(didTapMicButton)];
    UIButton *endButton = [self controlButtonWithImageName:@"video_call_end_button" action:@selector(didTapEndButton)];
    self.speakerButton = [self controlButtonWithImageName:@"video_call_speaker_on_button" action:@selector(didTapSpeakerButton)];

    UIView *homeIndicator = [[UIView alloc] init];
    homeIndicator.backgroundColor = UIColor.whiteColor;
    homeIndicator.layer.cornerRadius = 2.0;
    homeIndicator.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:controlPanel];
    [controlPanel addSubview:self.micButton];
    [controlPanel addSubview:endButton];
    [controlPanel addSubview:self.speakerButton];
    [controlPanel addSubview:homeIndicator];

    [NSLayoutConstraint activateConstraints:@[
        [controlPanel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [controlPanel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [controlPanel.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [controlPanel.heightAnchor constraintEqualToConstant:142.0],

        [endButton.centerXAnchor constraintEqualToAnchor:controlPanel.centerXAnchor],
        [endButton.topAnchor constraintEqualToAnchor:controlPanel.topAnchor constant:25.0],
        [endButton.widthAnchor constraintEqualToConstant:68.0],
        [endButton.heightAnchor constraintEqualToConstant:68.0],

        [self.micButton.centerYAnchor constraintEqualToAnchor:endButton.centerYAnchor],
        [self.micButton.trailingAnchor constraintEqualToAnchor:endButton.leadingAnchor constant:-52.0],
        [self.micButton.widthAnchor constraintEqualToConstant:68.0],
        [self.micButton.heightAnchor constraintEqualToConstant:68.0],

        [self.speakerButton.centerYAnchor constraintEqualToAnchor:endButton.centerYAnchor],
        [self.speakerButton.leadingAnchor constraintEqualToAnchor:endButton.trailingAnchor constant:52.0],
        [self.speakerButton.widthAnchor constraintEqualToConstant:68.0],
        [self.speakerButton.heightAnchor constraintEqualToConstant:68.0],

        [homeIndicator.centerXAnchor constraintEqualToAnchor:controlPanel.centerXAnchor],
        [homeIndicator.bottomAnchor constraintEqualToAnchor:controlPanel.safeAreaLayoutGuide.bottomAnchor constant:-7.0],
        [homeIndicator.widthAnchor constraintEqualToConstant:140.0],
        [homeIndicator.heightAnchor constraintEqualToConstant:4.0],
    ]];
}

- (UIButton *)controlButtonWithImageName:(NSString *)imageName action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#pragma mark - Actions

- (void)didTapMicButton {
    self.micMuted = !self.isMicMuted;
    NSString *imageName = self.isMicMuted ? @"video_call_mic_off_button" : @"video_call_mic_on_button";
    [self.micButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

- (void)didTapSpeakerButton {
    self.speakerMuted = !self.isSpeakerMuted;
    NSString *imageName = self.isSpeakerMuted ? @"video_call_speaker_off_button" : @"video_call_speaker_on_button";
    [self.speakerButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

- (void)didTapEndButton {
    if (self.navigationController && self.navigationController.viewControllers.firstObject != self) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
