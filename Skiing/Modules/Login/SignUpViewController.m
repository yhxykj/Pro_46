//
//  SignUpViewController.m
//  Skiing
//

#import "SignUpViewController.h"
#import "DesignTokens.h"
#import "InputFieldView.h"
#import "UILabel+TapRange.h"
#import "CreateAccountViewController.h"
#import "UserAccountStore.h"

@interface SignUpViewController ()
@property (nonatomic, strong) UIImageView    *backgroundImageView;
@property (nonatomic, strong) UIButton       *backButton;
@property (nonatomic, strong) UIImageView    *titleImageView;
@property (nonatomic, strong) InputFieldView *emailField;
@property (nonatomic, strong) InputFieldView *passwordField;
@property (nonatomic, strong) UIButton       *nextButton;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) UILabel        *bottomLabel;
@property (nonatomic, assign) NSRange         signInRange;
@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self setupViews];
    [self setupConstraints];
    [self setupActions];
}

- (void)setupViews {
    self.backgroundImageView = [[UIImageView alloc] init];
    self.backgroundImageView.image = [UIImage imageNamed:@"signup_background"];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImageView.clipsToBounds = YES;
    self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;

    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setImage:[UIImage imageNamed:@"ic_back"] forState:UIControlStateNormal];
    self.backButton.translatesAutoresizingMaskIntoConstraints = NO;

    self.titleImageView = [[UIImageView alloc] init];
    self.titleImageView.image = [UIImage imageNamed:@"label_friends_signup"];
    self.titleImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.titleImageView.translatesAutoresizingMaskIntoConstraints = NO;

    self.emailField = [[InputFieldView alloc] initWithIcon:@"ic_email"
                                                     title:@"Mail"
                                               placeholder:@"Your Email"
                                                  isSecure:NO];
    self.emailField.textField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailField.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.emailField.textField.returnKeyType = UIReturnKeyNext;
    self.emailField.textField.delegate = self;

    self.passwordField = [[InputFieldView alloc] initWithIcon:@"ic_password"
                                                        title:@"Password"
                                                  placeholder:@"Your Password"
                                                     isSecure:YES];
    self.passwordField.textField.returnKeyType = UIReturnKeyDone;
    self.passwordField.textField.delegate = self;

    self.nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.nextButton setImage:[UIImage imageNamed:@"btn_next"] forState:UIControlStateNormal];
    self.nextButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.nextButton.translatesAutoresizingMaskIntoConstraints = NO;

    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.loadingIndicator.color = UIColor.whiteColor;
    self.loadingIndicator.hidesWhenStopped = YES;
    self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = NO;

    NSString *text = @"Already have an account?  Sign in";
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text];
    [attr addAttributes:@{
        NSFontAttributeName: [DesignFonts regular:12],
        NSForegroundColorAttributeName: UIColor.grayColor
    } range:NSMakeRange(0, text.length)];
    self.signInRange = [attr addLinkToSubstring:@"Sign in" color:nil];

    self.bottomLabel = [[UILabel alloc] init];
    self.bottomLabel.attributedText = attr;
    self.bottomLabel.textAlignment = NSTextAlignmentCenter;
    self.bottomLabel.userInteractionEnabled = YES;
    self.bottomLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:self.backgroundImageView];
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.titleImageView];
    [self.view addSubview:self.emailField];
    [self.view addSubview:self.passwordField];
    [self.view addSubview:self.nextButton];
    [self.view addSubview:self.loadingIndicator];
    [self.view addSubview:self.bottomLabel];
}

- (void)setupActions {
    [self.backButton addTarget:self action:@selector(didTapBack) forControlEvents:UIControlEventTouchUpInside];
    [self.nextButton addTarget:self action:@selector(didTapNext) forControlEvents:UIControlEventTouchUpInside];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapBottom:)];
    [self.bottomLabel addGestureRecognizer:tap];
}

- (void)setupConstraints {
    [NSLayoutConstraint activateConstraints:@[
        [self.backgroundImageView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.backgroundImageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.backgroundImageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.backgroundImageView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [self.backButton.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:12],
        [self.backButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.backButton.widthAnchor constraintEqualToConstant:kBackButtonSize],
        [self.backButton.heightAnchor constraintEqualToConstant:kBackButtonSize],

        [self.titleImageView.topAnchor constraintEqualToAnchor:self.backButton.bottomAnchor constant:16],
        [self.titleImageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kHorizontalPadding],
        [self.titleImageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-kHorizontalPadding],
        [self.titleImageView.heightAnchor constraintEqualToConstant:56],

        [self.emailField.topAnchor constraintEqualToAnchor:self.titleImageView.bottomAnchor constant:32],
        [self.emailField.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kHorizontalPadding],
        [self.emailField.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-kHorizontalPadding],

        [self.passwordField.topAnchor constraintEqualToAnchor:self.emailField.bottomAnchor constant:kSectionSpacing],
        [self.passwordField.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kHorizontalPadding],
        [self.passwordField.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-kHorizontalPadding],

        [self.bottomLabel.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20],
        [self.bottomLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kHorizontalPadding],
        [self.bottomLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-kHorizontalPadding],

        [self.nextButton.bottomAnchor constraintEqualToAnchor:self.bottomLabel.topAnchor constant:-16],
        [self.nextButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kHorizontalPadding],
        [self.nextButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-kHorizontalPadding],
        [self.nextButton.heightAnchor constraintEqualToConstant:kButtonHeight],

        [self.loadingIndicator.centerXAnchor constraintEqualToAnchor:self.nextButton.centerXAnchor],
        [self.loadingIndicator.centerYAnchor constraintEqualToAnchor:self.nextButton.centerYAnchor],
    ]];
}

#pragma mark - Validation

- (BOOL)isValidEmail:(NSString *)email {
    NSString *regex = @"[A-Z0-9a-z._%+\\-]+@[A-Za-z0-9.\\-]+\\.[A-Za-z]{2,}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:email];
}

- (NSString *)validateInputs {
    NSString *email = [self.emailField.textField.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    NSString *password = self.passwordField.textField.text;

    if (email.length == 0) return @"Please enter your email.";
    if (![self isValidEmail:email]) return @"Please enter a valid email address.";
    if (password.length == 0) return @"Please enter a password.";
    if (password.length < 6) return @"Password must be at least 6 characters.";
    return nil;
}

- (void)showError:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Loading State

- (void)setLoading:(BOOL)loading {
    self.nextButton.userInteractionEnabled = !loading;
    self.nextButton.alpha = loading ? 0.6 : 1.0;
    loading ? [self.loadingIndicator startAnimating] : [self.loadingIndicator stopAnimating];
}

#pragma mark - Actions

- (void)didTapBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didTapNext {
    [self.view endEditing:YES];

    NSString *error = [self validateInputs];
    if (error) {
        [self showError:error];
        return;
    }

    [self setLoading:YES];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setLoading:NO];
        NSString *email = [self.emailField.textField.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
        if ([UserAccountStore accountExistsWithEmail:email]) {
            [self showError:@"This email is already registered."];
            return;
        }

        CreateAccountViewController *vc = [[CreateAccountViewController alloc] init];
        vc.email = email;
        vc.password = self.passwordField.textField.text;
        [self.navigationController pushViewController:vc animated:YES];
    });
}

- (void)didTapBottom:(UITapGestureRecognizer *)gesture {
    if ([self.bottomLabel didTapRange:self.signInRange inGesture:gesture]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailField.textField) {
        [self.passwordField.textField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        [self didTapNext];
    }
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
