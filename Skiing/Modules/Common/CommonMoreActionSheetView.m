//
//  CommonMoreActionSheetView.m
//  Skiing
//

#import "CommonMoreActionSheetView.h"
#import "DesignTokens.h"

static CGFloat const kCommonMoreSheetContentHeight = 126.0;
static CGFloat const kCommonMoreSheetActionWidth = 72.0;
static CGFloat const kCommonMoreSheetIconSize = 34.0;

@interface CommonMoreActionSheetView () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *sheetView;
@property (nonatomic, strong) UIControl *blockControl;
@property (nonatomic, strong) UIControl *reportControl;
@property (nonatomic, strong) NSLayoutConstraint *sheetBottomConstraint;
@property (nonatomic, strong) NSLayoutConstraint *sheetHeightConstraint;
@end

@implementation CommonMoreActionSheetView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = [[UIColor colorWithRed:0.22 green:0.24 blue:0.43 alpha:1.0] colorWithAlphaComponent:0.68];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapBackground)];
    tapGesture.delegate = self;
    [self addGestureRecognizer:tapGesture];

    self.sheetView = [[UIView alloc] init];
    self.sheetView.backgroundColor = UIColor.whiteColor;
    self.sheetView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.sheetView];

    self.blockControl = [self actionControlWithImageName:@"common_more_sheet_block_icon" title:@"Block"];
    [self.blockControl addTarget:self action:@selector(didTapBlockAction) forControlEvents:UIControlEventTouchUpInside];

    self.reportControl = [self actionControlWithImageName:@"common_more_sheet_report_icon" title:@"Report"];
    [self.reportControl addTarget:self action:@selector(didTapReportAction) forControlEvents:UIControlEventTouchUpInside];

    [self.sheetView addSubview:self.blockControl];
    [self.sheetView addSubview:self.reportControl];

    self.sheetBottomConstraint = [self.sheetView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor];
    self.sheetHeightConstraint = [self.sheetView.heightAnchor constraintEqualToConstant:kCommonMoreSheetContentHeight];
    [NSLayoutConstraint activateConstraints:@[
        [self.sheetView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.sheetView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        self.sheetBottomConstraint,
        self.sheetHeightConstraint,
    ]];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat top = 24.0;
    self.blockControl.frame = CGRectMake(34.0, top, kCommonMoreSheetActionWidth, 68.0);
    self.reportControl.frame = CGRectMake(126.0, top, kCommonMoreSheetActionWidth, 68.0);
}

- (CGFloat)sheetHeight {
    return kCommonMoreSheetContentHeight + self.safeAreaInsets.bottom;
}

- (void)updateSheetHeight {
    self.sheetHeightConstraint.constant = [self sheetHeight];
}

- (UIControl *)actionControlWithImageName:(NSString *)imageName title:(NSString *)title {
    UIControl *control = [[UIControl alloc] init];

    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.frame = CGRectMake((kCommonMoreSheetActionWidth - kCommonMoreSheetIconSize) / 2.0,
                                0,
                                kCommonMoreSheetIconSize,
                                kCommonMoreSheetIconSize);
    [control addSubview:iconView];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 43.0, kCommonMoreSheetActionWidth, 24.0)];
    titleLabel.text = title;
    titleLabel.font = [DesignFonts regular:16];
    titleLabel.textColor = [UIColor colorWithRed:0.18 green:0.18 blue:0.22 alpha:1.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [control addSubview:titleLabel];

    return control;
}

#pragma mark - Presentation

- (void)showInView:(UIView *)parentView {
    if (self.superview) return;

    self.frame = parentView.bounds;
    [parentView addSubview:self];

    [self updateSheetHeight];
    self.sheetBottomConstraint.constant = [self sheetHeight];
    [self layoutIfNeeded];

    self.alpha = 0;
    self.sheetBottomConstraint.constant = 0;

    [UIView animateWithDuration:0.24
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.alpha = 1;
        [self layoutIfNeeded];
    } completion:nil];
}

- (void)dismiss {
    [self dismissWithCompletion:nil];
}

- (void)dismissWithCompletion:(void (^)(void))completion {
    self.sheetBottomConstraint.constant = [self sheetHeight];
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
        self.alpha = 0;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.sheetBottomConstraint.constant = 0;
        if (completion) completion();
    }];
}

#pragma mark - Actions

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return ![touch.view isDescendantOfView:self.sheetView];
}

- (void)didTapBackground {
    [self dismiss];
}

- (void)didTapBlockAction {
    __weak typeof(self) weakSelf = self;
    [self dismissWithCompletion:^{
        if (weakSelf.blockHandler) weakSelf.blockHandler();
    }];
}

- (void)didTapReportAction {
    __weak typeof(self) weakSelf = self;
    [self dismissWithCompletion:^{
        if (weakSelf.reportHandler) weakSelf.reportHandler();
    }];
}

@end
