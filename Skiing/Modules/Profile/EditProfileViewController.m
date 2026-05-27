//
//  EditProfileViewController.m
//  Skiing
//

#import "EditProfileViewController.h"
#import "DesignTokens.h"
#import "UserSession.h"
#import <PhotosUI/PhotosUI.h>

static CGFloat const kEditProfileSidePadding = 24.0;
static NSString * const kProfileDisplayNameDefaultsKey = @"kProfileDisplayNameDefaultsKey";
static NSString * const kDefaultProfileDisplayName = @"Skiing User";
static NSString * const kTestAccountEmail = @"skiing666@gmail.com";
static NSString * const kTestAccountName = @"GardenDream";

@interface EditProfileViewController () <UITextFieldDelegate, PHPickerViewControllerDelegate>
@property (nonatomic, strong) CAGradientLayer *backgroundGradientLayer;
@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UIImageView *avatarImageView;
@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.75 green:0.78 blue:1.0 alpha:1.0];
    [self setupBackground];
    [self setupContent];
    [self setupDismissKeyboardGesture];
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
    titleLabel.text = @"Edit Profile";
    titleLabel.font = [DesignFonts semibold:22];
    titleLabel.textColor = [UIColor colorWithRed:0.17 green:0.17 blue:0.24 alpha:1.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    UIView *avatarContainerView = [[UIView alloc] init];
    avatarContainerView.translatesAutoresizingMaskIntoConstraints = NO;

    UIImageView *avatarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatar_user_12"]];
    avatarView.contentMode = UIViewContentModeScaleAspectFill;
    avatarView.clipsToBounds = YES;
    avatarView.layer.cornerRadius = 45.0;
    avatarView.layer.borderWidth = 2.0;
    avatarView.layer.borderColor = UIColor.whiteColor.CGColor;
    avatarView.userInteractionEnabled = YES;
    avatarView.translatesAutoresizingMaskIntoConstraints = NO;
    self.avatarImageView = avatarView;

    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraButton.backgroundColor = UIColor.whiteColor;
    cameraButton.layer.cornerRadius = 17.0;
    cameraButton.layer.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.08].CGColor;
    cameraButton.layer.shadowOpacity = 1.0;
    cameraButton.layer.shadowRadius = 6.0;
    cameraButton.layer.shadowOffset = CGSizeMake(0, 3);
    cameraButton.translatesAutoresizingMaskIntoConstraints = NO;

    UIImageSymbolConfiguration *configuration = [UIImageSymbolConfiguration configurationWithPointSize:15 weight:UIImageSymbolWeightBold];
    UIImage *cameraImage = [[UIImage systemImageNamed:@"camera.fill" withConfiguration:configuration] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [cameraButton setImage:cameraImage forState:UIControlStateNormal];
    cameraButton.tintColor = [UIColor colorWithRed:0.24 green:0.47 blue:1.0 alpha:1.0];
    [cameraButton addTarget:self action:@selector(didTapAvatarButton) forControlEvents:UIControlEventTouchUpInside];

    UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAvatarButton)];
    [avatarView addGestureRecognizer:avatarTap];

    UIView *fieldContainerView = [[UIView alloc] init];
    fieldContainerView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.42];
    fieldContainerView.layer.cornerRadius = 35.0;
    fieldContainerView.translatesAutoresizingMaskIntoConstraints = NO;

    self.nameTextField = [[UITextField alloc] init];
    self.nameTextField.text = [self currentProfileName];
    self.nameTextField.font = [DesignFonts semibold:15];
    self.nameTextField.textColor = [UIColor colorWithRed:0.16 green:0.16 blue:0.21 alpha:1.0];
    self.nameTextField.tintColor = [UIColor colorWithRed:0.24 green:0.47 blue:1.0 alpha:1.0];
    self.nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.nameTextField.borderStyle = UITextBorderStyleNone;
    self.nameTextField.returnKeyType = UIReturnKeyDone;
    self.nameTextField.delegate = self;
    self.nameTextField.translatesAutoresizingMaskIntoConstraints = NO;

    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    saveButton.backgroundColor = [UIColor colorWithRed:1.0 green:0.94 blue:0.60 alpha:1.0];
    saveButton.layer.cornerRadius = 14.0;
    saveButton.titleLabel.font = [DesignFonts semibold:20];
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor colorWithRed:0.17 green:0.17 blue:0.22 alpha:1.0] forState:UIControlStateNormal];
    saveButton.translatesAutoresizingMaskIntoConstraints = NO;
    [saveButton addTarget:self action:@selector(didTapSaveButton) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:backButton];
    [self.view addSubview:titleLabel];
    [self.view addSubview:avatarContainerView];
    [avatarContainerView addSubview:avatarView];
    [avatarContainerView addSubview:cameraButton];
    [self.view addSubview:fieldContainerView];
    [fieldContainerView addSubview:self.nameTextField];
    [self.view addSubview:saveButton];

    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;

    [NSLayoutConstraint activateConstraints:@[
        [backButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [backButton.topAnchor constraintEqualToAnchor:safeArea.topAnchor constant:12],
        [backButton.widthAnchor constraintEqualToConstant:44],
        [backButton.heightAnchor constraintEqualToConstant:44],

        [titleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [titleLabel.centerYAnchor constraintEqualToAnchor:backButton.centerYAnchor],

        [avatarContainerView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [avatarContainerView.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:78],
        [avatarContainerView.widthAnchor constraintEqualToConstant:116],
        [avatarContainerView.heightAnchor constraintEqualToConstant:116],

        [avatarView.centerXAnchor constraintEqualToAnchor:avatarContainerView.centerXAnchor],
        [avatarView.centerYAnchor constraintEqualToAnchor:avatarContainerView.centerYAnchor],
        [avatarView.widthAnchor constraintEqualToConstant:90],
        [avatarView.heightAnchor constraintEqualToConstant:90],

        [cameraButton.trailingAnchor constraintEqualToAnchor:avatarView.trailingAnchor constant:5],
        [cameraButton.bottomAnchor constraintEqualToAnchor:avatarView.bottomAnchor constant:5],
        [cameraButton.widthAnchor constraintEqualToConstant:34],
        [cameraButton.heightAnchor constraintEqualToConstant:34],

        [fieldContainerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kEditProfileSidePadding],
        [fieldContainerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-kEditProfileSidePadding],
        [fieldContainerView.topAnchor constraintEqualToAnchor:avatarContainerView.bottomAnchor constant:64],
        [fieldContainerView.heightAnchor constraintEqualToConstant:70],

        [self.nameTextField.leadingAnchor constraintEqualToAnchor:fieldContainerView.leadingAnchor constant:22],
        [self.nameTextField.trailingAnchor constraintEqualToAnchor:fieldContainerView.trailingAnchor constant:-22],
        [self.nameTextField.centerYAnchor constraintEqualToAnchor:fieldContainerView.centerYAnchor],
        [self.nameTextField.heightAnchor constraintEqualToConstant:40],

        [saveButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kEditProfileSidePadding],
        [saveButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-kEditProfileSidePadding],
        [saveButton.bottomAnchor constraintEqualToAnchor:safeArea.bottomAnchor constant:-40],
        [saveButton.heightAnchor constraintEqualToConstant:60],
    ]];
}

- (void)setupDismissKeyboardGesture {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

#pragma mark - Actions

- (void)didTapBackButton {
    [self.view endEditing:YES];

    if (self.navigationController && self.navigationController.viewControllers.firstObject != self) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didTapSaveButton {
    [self.view endEditing:YES];

    NSString *nickname = [self.nameTextField.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (nickname.length == 0) {
        [self showAlertWithTitle:@"Nickname required"
                         message:@"Please enter your nickname."
                      completion:nil];
        return;
    }

    [NSUserDefaults.standardUserDefaults setObject:nickname forKey:[self profileDisplayNameDefaultsKey]];
    [NSUserDefaults.standardUserDefaults synchronize];

    [self showAlertWithTitle:@"Profile under review"
                     message:@"Your profile has been saved and is under review."
                  completion:^{
        [self returnToProfilePage];
    }];
}

- (void)didTapAvatarButton {
    if (self.presentedViewController) {
        return;
    }

    [self.view endEditing:YES];

    PHPickerConfiguration *configuration = [[PHPickerConfiguration alloc] init];
    configuration.selectionLimit = 1;
    configuration.filter = [PHPickerFilter imagesFilter];

    PHPickerViewController *picker = [[PHPickerViewController alloc] initWithConfiguration:configuration];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (NSString *)currentProfileName {
    NSString *storedName = [NSUserDefaults.standardUserDefaults stringForKey:[self profileDisplayNameDefaultsKey]];
    NSString *trimmedName = [storedName stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (trimmedName.length > 0) {
        return trimmedName;
    }

    if ([[[UserSession currentEmail] lowercaseString] isEqualToString:kTestAccountEmail]) {
        return kTestAccountName;
    }

    NSString *email = [UserSession currentEmail];
    NSString *name = [[email componentsSeparatedByString:@"@"] firstObject] ?: kDefaultProfileDisplayName;
    NSString *trimmedFallback = [name stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    return trimmedFallback.length > 0 ? trimmedFallback : kDefaultProfileDisplayName;
}

- (NSString *)profileDisplayNameDefaultsKey {
    NSString *email = [[UserSession currentEmail] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet].lowercaseString;
    if (email.length == 0) {
        return kProfileDisplayNameDefaultsKey;
    }

    return [NSString stringWithFormat:@"%@.%@", kProfileDisplayNameDefaultsKey, email];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message completion:(void (^)(void))completion {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (completion) completion();
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)returnToProfilePage {
    if (self.navigationController && self.navigationController.viewControllers.firstObject != self) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - PHPickerViewControllerDelegate

- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results {
    [picker dismissViewControllerAnimated:YES completion:nil];
    PHPickerResult *result = results.firstObject;
    if (!result || ![result.itemProvider canLoadObjectOfClass:UIImage.class]) {
        return;
    }

    [result.itemProvider loadObjectOfClass:UIImage.class completionHandler:^(__kindof id<NSItemProviderReading>  _Nullable object, NSError * _Nullable error) {
        if (error || ![object isKindOfClass:UIImage.class]) {
            return;
        }

        UIImage *image = (UIImage *)object;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.avatarImageView.image = image;
        });
    }];
}

@end
