//
//  InputFieldView.m
//  Skiing
//

#import "InputFieldView.h"
#import "DesignTokens.h"

@interface InputFieldView ()
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel     *titleLabel;
@property (nonatomic, readwrite, strong) UITextField *textField;
@property (nonatomic, strong) UIButton    *eyeButton;
@property (nonatomic, assign) BOOL         isSecure;
@end

@implementation InputFieldView

- (instancetype)initWithIcon:(NSString *)icon
                       title:(NSString *)title
                 placeholder:(NSString *)placeholder
                    isSecure:(BOOL)isSecure {
    self = [super init];
    if (self) {
        self.isSecure = isSecure;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self setupWithIcon:icon title:title placeholder:placeholder];
    }
    return self;
}

- (nullable NSString *)text {
    return self.textField.text;
}

- (void)setupWithIcon:(NSString *)icon title:(NSString *)title placeholder:(NSString *)placeholder {
    // icon
    self.iconView = [[UIImageView alloc] init];
    self.iconView.image = [UIImage imageNamed:icon];
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;
    self.iconView.translatesAutoresizingMaskIntoConstraints = NO;

    // title
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = title;
    self.titleLabel.font = [DesignFonts semibold:15];
    self.titleLabel.textColor = UIColor.blackColor;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    // text field
    self.textField = [[UITextField alloc] init];
    self.textField.placeholder = placeholder;
    self.textField.font = [DesignFonts regular:15];
    self.textField.backgroundColor = [DesignColors fieldBackground];
    self.textField.layer.cornerRadius = kFieldCornerRadius;
    self.textField.layer.masksToBounds = YES;
    self.textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 0)];
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    [self.textField setSecureTextEntry:self.isSecure];
    self.textField.keyboardType = self.isSecure ? UIKeyboardTypeDefault : UIKeyboardTypeEmailAddress;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.translatesAutoresizingMaskIntoConstraints = NO;

    if (self.isSecure) {
        [self setupEyeButton];
    }

    [self addSubview:self.iconView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.textField];

    [NSLayoutConstraint activateConstraints:@[
        [self.iconView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.iconView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.iconView.widthAnchor constraintEqualToConstant:kIconSize],
        [self.iconView.heightAnchor constraintEqualToConstant:kIconSize],

        [self.titleLabel.centerYAnchor constraintEqualToAnchor:self.iconView.centerYAnchor],
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.iconView.trailingAnchor constant:kLabelIconSpacing],

        [self.textField.topAnchor constraintEqualToAnchor:self.iconView.bottomAnchor constant:kFieldLabelSpacing],
        [self.textField.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.textField.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.textField.heightAnchor constraintEqualToConstant:kFieldHeight],
        [self.textField.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
    ]];
}

- (void)setupEyeButton {
    self.eyeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.eyeButton setImage:[UIImage imageNamed:@"ic_eye_on"]  forState:UIControlStateNormal];
    [self.eyeButton setImage:[UIImage imageNamed:@"ic_eye_off"] forState:UIControlStateSelected];
    [self.eyeButton addTarget:self action:@selector(toggleSecure) forControlEvents:UIControlEventTouchUpInside];

    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, kFieldHeight)];
    self.eyeButton.frame = CGRectMake(8, (kFieldHeight - 24) / 2, 24, 24);
    [container addSubview:self.eyeButton];

    self.textField.rightView = container;
    self.textField.rightViewMode = UITextFieldViewModeAlways;
}

- (void)toggleSecure {
    self.eyeButton.selected = !self.eyeButton.isSelected;
    self.textField.secureTextEntry = !self.eyeButton.isSelected;
}

@end
