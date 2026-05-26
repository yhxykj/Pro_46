//
//  CreateAccountViewController.m
//  Skiing
//

#import "CreateAccountViewController.h"
#import "DesignTokens.h"
#import "UILabel+TapRange.h"
#import "MainTabBarController.h"
#import "UserSession.h"
#import "UserAccountStore.h"

@interface CreateAccountViewController ()
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIButton    *backButton;
@property (nonatomic, strong) UIImageView *titleImageView;
@property (nonatomic, strong) UIButton    *avatarButton;
@property (nonatomic, strong) UITextField *usernameField;
@property (nonatomic, strong) UIButton    *createButton;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) UILabel     *bottomLabel;
@property (nonatomic, assign) NSRange      signInRange;
@end

@implementation CreateAccountViewController

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
    self.titleImageView.image = [UIImage imageNamed:@"label_friends_step3"];
    self.titleImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.titleImageView.translatesAutoresizingMaskIntoConstraints = NO;

    self.avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.avatarButton setImage:[UIImage imageNamed:@"avatar_placeholder"] forState:UIControlStateNormal];
    self.avatarButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.avatarButton.layer.cornerRadius = 44;
    self.avatarButton.layer.masksToBounds = YES;
    self.avatarButton.translatesAutoresizingMaskIntoConstraints = NO;

    self.usernameField = [[UITextField alloc] init];
    self.usernameField.placeholder = @"Username";
    self.usernameField.font = [DesignFonts regular:15];
    self.usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.usernameField.returnKeyType = UIReturnKeyDone;
    self.usernameField.delegate = self;
    self.usernameField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 0)];
    self.usernameField.leftViewMode = UITextFieldViewModeAlways;
    self.usernameField.backgroundColor = [DesignColors fieldBackground];
    self.usernameField.layer.cornerRadius = kFieldCornerRadius;
    self.usernameField.layer.masksToBounds = YES;
    self.usernameField.translatesAutoresizingMaskIntoConstraints = NO;

    self.createButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.createButton setImage:[UIImage imageNamed:@"btn_create"] forState:UIControlStateNormal];
    self.createButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.createButton.translatesAutoresizingMaskIntoConstraints = NO;

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
    [self.view addSubview:self.avatarButton];
    [self.view addSubview:self.usernameField];
    [self.view addSubview:self.createButton];
    [self.view addSubview:self.loadingIndicator];
    [self.view addSubview:self.bottomLabel];
}

- (void)setupActions {
    [self.backButton addTarget:self action:@selector(didTapBack) forControlEvents:UIControlEventTouchUpInside];
    [self.avatarButton addTarget:self action:@selector(didTapAvatar) forControlEvents:UIControlEventTouchUpInside];
    [self.createButton addTarget:self action:@selector(didTapCreate) forControlEvents:UIControlEventTouchUpInside];

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

        [self.avatarButton.topAnchor constraintEqualToAnchor:self.titleImageView.bottomAnchor constant:32],
        [self.avatarButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.avatarButton.widthAnchor constraintEqualToConstant:88],
        [self.avatarButton.heightAnchor constraintEqualToConstant:88],

        [self.usernameField.topAnchor constraintEqualToAnchor:self.avatarButton.bottomAnchor constant:kSectionSpacing],
        [self.usernameField.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kHorizontalPadding],
        [self.usernameField.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-kHorizontalPadding],
        [self.usernameField.heightAnchor constraintEqualToConstant:kFieldHeight],

        [self.bottomLabel.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20],
        [self.bottomLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kHorizontalPadding],
        [self.bottomLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-kHorizontalPadding],

        [self.createButton.bottomAnchor constraintEqualToAnchor:self.bottomLabel.topAnchor constant:-16],
        [self.createButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kHorizontalPadding],
        [self.createButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-kHorizontalPadding],
        [self.createButton.heightAnchor constraintEqualToConstant:kButtonHeight],

        [self.loadingIndicator.centerXAnchor constraintEqualToAnchor:self.createButton.centerXAnchor],
        [self.loadingIndicator.centerYAnchor constraintEqualToAnchor:self.createButton.centerYAnchor],
    ]];
}

#pragma mark - Validation

- (NSString *)validateInputs {
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    if (username.length == 0) return @"Please enter a username.";
    if (username.length < 3) return @"Username must be at least 3 characters.";
    if (username.length > 20) return @"Username must be no more than 20 characters.";
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
    self.createButton.userInteractionEnabled = !loading;
    self.createButton.alpha = loading ? 0.6 : 1.0;
    loading ? [self.loadingIndicator startAnimating] : [self.loadingIndicator stopAnimating];
}

#pragma mark - Actions

- (void)didTapBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didTapAvatar {
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [sheet addAction:[UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
            [weakSelf presentPickerWithSource:UIImagePickerControllerSourceTypeCamera];
        }]];
    }

    [sheet addAction:[UIAlertAction actionWithTitle:@"Choose from Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
        [weakSelf presentPickerWithSource:UIImagePickerControllerSourceTypePhotoLibrary];
    }]];

    [sheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:sheet animated:YES completion:nil];
}

- (void)presentPickerWithSource:(UIImagePickerControllerSourceType)source {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = source;
    picker.allowsEditing = YES;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)didTapCreate {
    [self.view endEditing:YES];

    NSString *error = [self validateInputs];
    if (error) {
        [self showError:error];
        return;
    }

    [self setLoading:YES];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setLoading:NO];
        NSString *errorMessage = nil;
        if (![UserAccountStore saveAccountWithEmail:self.email ?: @""
                                           password:self.password ?: @""
                                       errorMessage:&errorMessage]) {
            [self showError:errorMessage ?: @"Unable to create account."];
            return;
        }

        [self navigateToHome];
    });
}

- (void)didTapBottom:(UITapGestureRecognizer *)gesture {
    if ([self.bottomLabel didTapRange:self.signInRange inGesture:gesture]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)navigateToHome {
    [UserSession saveLoginState];
    MainTabBarController *tabBar = [[MainTabBarController alloc] init];
    tabBar.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:tabBar animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    UIImage *edited = info[UIImagePickerControllerEditedImage];
    UIImage *original = info[UIImagePickerControllerOriginalImage];
    UIImage *selected = edited ?: original;

    if (selected) {
        [self.avatarButton setImage:selected forState:UIControlStateNormal];
    }

    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self didTapCreate];
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
