//
//  EmptyStateView.m
//  Skiing
//

#import "EmptyStateView.h"
#import "DesignTokens.h"

@interface EmptyStateView ()
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) NSLayoutConstraint *contentCenterYConstraint;
@end

@implementation EmptyStateView

- (instancetype)initWithText:(NSString *)text {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _contentCenterYOffset = -18.0;
        [self setupWithText:text.length > 0 ? text : @"No data available"];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _contentCenterYOffset = -18.0;
        [self setupWithText:@"No data available"];
    }
    return self;
}

- (void)setContentCenterYOffset:(CGFloat)contentCenterYOffset {
    _contentCenterYOffset = contentCenterYOffset;
    self.contentCenterYConstraint.constant = contentCenterYOffset;
}

- (void)setupWithText:(NSString *)text {
    self.backgroundColor = UIColor.clearColor;
    self.userInteractionEnabled = NO;
    self.translatesAutoresizingMaskIntoConstraints = NO;

    self.contentView = [[UIView alloc] init];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;

    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"empty_state_snowflakes"]];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [DesignFonts semibold:17];
    label.textColor = UIColor.whiteColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:self.contentView];
    [self.contentView addSubview:iconView];
    [self.contentView addSubview:label];

    self.contentCenterYConstraint = [self.contentView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor constant:self.contentCenterYOffset];

    [NSLayoutConstraint activateConstraints:@[
        [self.contentView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        self.contentCenterYConstraint,

        [iconView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
        [iconView.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
        [iconView.widthAnchor constraintEqualToConstant:84.0],
        [iconView.heightAnchor constraintEqualToConstant:84.0],

        [label.topAnchor constraintEqualToAnchor:iconView.bottomAnchor constant:10.0],
        [label.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [label.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        [label.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
        [label.widthAnchor constraintGreaterThanOrEqualToConstant:220.0],
    ]];
}

@end
