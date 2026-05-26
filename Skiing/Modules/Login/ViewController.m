//
//  ViewController.m
//  Skiing
//

#import "ViewController.h"
#import "DesignTokens.h"
#import "UILabel+TapRange.h"
#import "SignInViewController.h"
#import "SignUpViewController.h"
#import <SafariServices/SafariServices.h>


@interface ViewController ()
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIButton    *signUpButton;
@property (nonatomic, strong) UIButton    *signInButton;
@property (nonatomic, strong) UIStackView *buttonRowStack;
@property (nonatomic, strong) UILabel     *agreementLabel;
@property (nonatomic, assign) NSRange      agreementLinkRange;
@property (nonatomic, assign) BOOL         hasAgreedThisSession;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self setupConstraints];
    [self setupActions];
}

- (void)setupViews {
    self.backgroundImageView = [[UIImageView alloc] init];
    self.backgroundImageView.image = [UIImage imageNamed:@"login_screen_preview"];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImageView.clipsToBounds = YES;
    self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;

    self.signUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.signUpButton setImage:[UIImage imageNamed:@"btn_sign_up"] forState:UIControlStateNormal];
    self.signUpButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.signUpButton.translatesAutoresizingMaskIntoConstraints = NO;

    self.signInButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.signInButton setImage:[UIImage imageNamed:@"btn_sign_in"] forState:UIControlStateNormal];
    self.signInButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.signInButton.translatesAutoresizingMaskIntoConstraints = NO;

    self.buttonRowStack = [[UIStackView alloc] init];
    self.buttonRowStack.axis = UILayoutConstraintAxisHorizontal;
    self.buttonRowStack.spacing = 12;
    self.buttonRowStack.distribution = UIStackViewDistributionFillEqually;
    self.buttonRowStack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.buttonRowStack addArrangedSubview:self.signUpButton];
    [self.buttonRowStack addArrangedSubview:self.signInButton];

    NSString *text = @"By signing up you agree to the\nUser Agreement & Privacy Policy";
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text];
    [attr addAttributes:@{
        NSFontAttributeName: [DesignFonts regular:11],
        NSForegroundColorAttributeName: UIColor.grayColor
    } range:NSMakeRange(0, text.length)];
    self.agreementLinkRange = [attr addLinkToSubstring:@"User Agreement & Privacy Policy" color:UIColor.darkGrayColor];

    self.agreementLabel = [[UILabel alloc] init];
    self.agreementLabel.attributedText = attr;
    self.agreementLabel.textAlignment = NSTextAlignmentCenter;
    self.agreementLabel.numberOfLines = 2;
    self.agreementLabel.userInteractionEnabled = YES;
    self.agreementLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:self.backgroundImageView];
    [self.view addSubview:self.buttonRowStack];
    [self.view addSubview:self.agreementLabel];
}

- (void)setupActions {
    [self.signUpButton addTarget:self action:@selector(didTapSignUp) forControlEvents:UIControlEventTouchUpInside];
    [self.signInButton addTarget:self action:@selector(didTapSignIn) forControlEvents:UIControlEventTouchUpInside];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAgreement:)];
    [self.agreementLabel addGestureRecognizer:tap];
}

- (void)setupConstraints {
    [NSLayoutConstraint activateConstraints:@[
        [self.backgroundImageView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.backgroundImageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.backgroundImageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.backgroundImageView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [self.agreementLabel.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-12],
        [self.agreementLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kHorizontalPadding],
        [self.agreementLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-kHorizontalPadding],

        [self.buttonRowStack.bottomAnchor constraintEqualToAnchor:self.agreementLabel.topAnchor constant:-12],
        [self.buttonRowStack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kHorizontalPadding],
        [self.buttonRowStack.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-kHorizontalPadding],
        [self.buttonRowStack.heightAnchor constraintEqualToConstant:kButtonHeight],
    ]];
}

#pragma mark - Actions

- (void)didTapSignUp {
    __weak typeof(self) weakSelf = self;
    if (self.hasAgreedThisSession) {
        [self.navigationController pushViewController:[[SignUpViewController alloc] init] animated:YES];
        return;
    }
    [self showAgreementAlertWithCompletion:^{
        weakSelf.hasAgreedThisSession = YES;
        [weakSelf.navigationController pushViewController:[[SignUpViewController alloc] init] animated:YES];
    }];
}

- (void)didTapSignIn {
    __weak typeof(self) weakSelf = self;
    if (self.hasAgreedThisSession) {
        [self.navigationController pushViewController:[[SignInViewController alloc] init] animated:YES];
        return;
    }
    [self showAgreementAlertWithCompletion:^{
        weakSelf.hasAgreedThisSession = YES;
        [weakSelf.navigationController pushViewController:[[SignInViewController alloc] init] animated:YES];
    }];
}

- (void)didTapAgreement:(UITapGestureRecognizer *)gesture {
    if ([self.agreementLabel didTapRange:self.agreementLinkRange inGesture:gesture]) {
        [self openURL:@"https://www.example.com/agreement"];
    }
}

- (void)showAgreementAlertWithCompletion:(void(^)(void))completion {
    __weak typeof(self) weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Terms & Privacy"
                                                                   message:@"Please read and agree to the User Agreement and Privacy Policy before continuing."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"View Agreement" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
        [weakSelf openURL:@"https://www.example.com/agreement"];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Decline" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Agree & Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
        if (completion) completion();
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)openURL:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) return;
    SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:url];
    [self presentViewController:safari animated:YES completion:nil];
}

@end
