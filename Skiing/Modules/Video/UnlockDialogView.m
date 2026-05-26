//
//  UnlockDialogView.m
//  Skiing
//

#import "UnlockDialogView.h"
#import "DesignTokens.h"

// 弹框尺寸
static const CGFloat kDialogWidth  = 296.0;
static const CGFloat kDialogHeight = 298.0;

@interface UnlockDialogView ()
@property (nonatomic, strong) UIView *dimView;
@property (nonatomic, strong) UIView *dialogView;
@end

@implementation UnlockDialogView

- (instancetype)init {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self setupViews];
    }
    return self;
}

#pragma mark - Setup

- (void)setupViews {
    // 半透明遮罩
    self.dimView = [[UIView alloc] init];
    self.dimView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self addSubview:self.dimView];

    // 弹框容器（使用背景图）
    self.dialogView = [[UIView alloc] init];
    self.dialogView.clipsToBounds = YES;
    [self addSubview:self.dialogView];

    // 背景图
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dialog_bg"]];
    bgImageView.contentMode = UIViewContentModeScaleToFill;
    bgImageView.frame = CGRectMake(0, 0, kDialogWidth, kDialogHeight);
    [self.dialogView addSubview:bgImageView];

    // 文本标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Unlock posting for 19\ncoins. Do it now?";
    titleLabel.font = [DesignFonts semibold:17];
    titleLabel.textColor = [UIColor colorWithRed:0.20 green:0.20 blue:0.30 alpha:1.0];
    titleLabel.numberOfLines = 2;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.dialogView addSubview:titleLabel];

    // Cancel 按钮（使用图片）
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setImage:[UIImage imageNamed:@"btn_cancel"] forState:UIControlStateNormal];
    cancelButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    [cancelButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.dialogView addSubview:cancelButton];

    // Yes 按钮（使用图片）
    UIButton *yesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [yesButton setImage:[UIImage imageNamed:@"btn_yes"] forState:UIControlStateNormal];
    yesButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    yesButton.translatesAutoresizingMaskIntoConstraints = NO;
    [yesButton addTarget:self action:@selector(didTapYes) forControlEvents:UIControlEventTouchUpInside];
    [self.dialogView addSubview:yesButton];

    // 约束：titleLabel
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:self.dialogView.topAnchor constant:60],
        [titleLabel.leadingAnchor constraintEqualToAnchor:self.dialogView.leadingAnchor constant:24],
        [titleLabel.trailingAnchor constraintEqualToAnchor:self.dialogView.trailingAnchor constant:-24],

        // Cancel 按钮
        [cancelButton.leadingAnchor constraintEqualToAnchor:self.dialogView.leadingAnchor constant:24],
        [cancelButton.bottomAnchor constraintEqualToAnchor:self.dialogView.bottomAnchor constant:-32],
        [cancelButton.widthAnchor constraintEqualToConstant:114],
        [cancelButton.heightAnchor constraintEqualToConstant:44],

        // Yes 按钮
        [yesButton.trailingAnchor constraintEqualToAnchor:self.dialogView.trailingAnchor constant:-24],
        [yesButton.bottomAnchor constraintEqualToAnchor:self.dialogView.bottomAnchor constant:-32],
        [yesButton.widthAnchor constraintEqualToConstant:114],
        [yesButton.heightAnchor constraintEqualToConstant:44],
    ]];

    // 点击遮罩关闭
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [self.dimView addGestureRecognizer:tap];
}

#pragma mark - Show / Dismiss

- (void)show {
    UIWindow *window = [self activeWindow];
    if (!window) return;

    self.frame = window.bounds;
    self.dimView.frame = self.bounds;
    self.dialogView.frame = CGRectMake(
        (CGRectGetWidth(self.bounds) - kDialogWidth) / 2.0,
        (CGRectGetHeight(self.bounds) - kDialogHeight) / 2.0,
        kDialogWidth,
        kDialogHeight
    );

    [window addSubview:self];

    // 入场动画
    self.alpha = 0;
    self.dialogView.transform = CGAffineTransformMakeScale(0.85, 0.85);
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.alpha = 1.0;
        self.dialogView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)dismiss {
    [self dismissWithCompletion:nil];
}

- (void)dismissWithCompletion:(void (^)(void))completion {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
        self.dialogView.transform = CGAffineTransformMakeScale(0.85, 0.85);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - Actions

- (void)didTapYes {
    void (^confirmHandler)(void) = self.confirmHandler;
    [self dismissWithCompletion:^{
        if (confirmHandler) {
            confirmHandler();
        }
    }];
}

#pragma mark - Helpers

- (UIWindow *)activeWindow {
    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if (scene.activationState == UISceneActivationStateForegroundActive &&
            [scene isKindOfClass:[UIWindowScene class]]) {
            UIWindowScene *ws = (UIWindowScene *)scene;
            for (UIWindow *w in ws.windows) {
                if (w.isKeyWindow) return w;
            }
            return ws.windows.firstObject;
        }
    }
    return nil;
}

@end
