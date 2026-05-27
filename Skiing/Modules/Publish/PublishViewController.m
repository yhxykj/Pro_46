//
//  PublishViewController.m
//  Skiing
//

#import "PublishViewController.h"
#import "DesignTokens.h"
#import <AVFoundation/AVFoundation.h>
#import <PhotosUI/PhotosUI.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@interface PublishViewController () <PHPickerViewControllerDelegate, UITextViewDelegate>

// 背景
@property (nonatomic, strong) UIImageView   *bgImageView;

// 顶部返回按钮
@property (nonatomic, strong) UIButton      *backButton;

// 媒体选择区域（未选择状态）
@property (nonatomic, strong) UIView        *addMediaContainer;
@property (nonatomic, strong) UIButton      *addMediaButton;  // btn_add_media 图片按钮

// 已选择媒体区域（选择后状态）
@property (nonatomic, strong) UIView        *selectedMediaContainer;
@property (nonatomic, strong) UIImageView   *selectedThumbnail;
@property (nonatomic, strong) UIButton      *removeMediaButton; // ic_remove_media

// 文本输入框
@property (nonatomic, strong) UIView        *textContainerView;
@property (nonatomic, strong) UITextView    *textView;
@property (nonatomic, strong) UILabel       *placeholderLabel;

// Post 按钮
@property (nonatomic, strong) UIButton      *postButton;

// 发布成功弹卡
@property (nonatomic, strong) UIView        *successOverlayView;
@property (nonatomic, strong) UIView        *successDialogView;

// 是否已选择媒体
@property (nonatomic, assign) BOOL          hasSelectedMedia;
@property (nonatomic, strong) NSURL         *selectedVideoURL;

@end

@implementation PublishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBackground];
    [self setupBackButton];
    [self setupMediaArea];
    [self setupTextView];
    [self setupPostButton];
    [self setupKeyboardHandling];
    [self updateMediaState];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Setup

- (void)setupBackground {
    self.bgImageView = [[UIImageView alloc] init];
    self.bgImageView.image = [UIImage imageNamed:@"publish_bg"];
    self.bgImageView.contentMode = UIViewContentModeScaleToFill;
    self.bgImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.bgImageView];

    [NSLayoutConstraint activateConstraints:@[
        [self.bgImageView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.bgImageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.bgImageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.bgImageView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

- (void)setupBackButton {
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
    self.backButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backButton addTarget:self action:@selector(didTapBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backButton];

    [NSLayoutConstraint activateConstraints:@[
        [self.backButton.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:12],
        [self.backButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [self.backButton.widthAnchor constraintEqualToConstant:44],
        [self.backButton.heightAnchor constraintEqualToConstant:44],
    ]];
}

- (void)setupMediaArea {
    // ── 未选择状态：addMediaContainer ──
    self.addMediaContainer = [[UIView alloc] init];
    self.addMediaContainer.backgroundColor = UIColor.whiteColor;
    self.addMediaContainer.layer.cornerRadius = 16;
    self.addMediaContainer.clipsToBounds = YES;
    self.addMediaContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.addMediaContainer];

    self.addMediaButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.addMediaButton setImage:[UIImage imageNamed:@"btn_add_media"] forState:UIControlStateNormal];
    self.addMediaButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.addMediaButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.addMediaButton addTarget:self action:@selector(didTapAddMedia) forControlEvents:UIControlEventTouchUpInside];
    [self.addMediaContainer addSubview:self.addMediaButton];

    [NSLayoutConstraint activateConstraints:@[
        [self.addMediaContainer.topAnchor constraintEqualToAnchor:self.backButton.bottomAnchor constant:16],
        [self.addMediaContainer.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.addMediaContainer.widthAnchor constraintEqualToConstant:199],
        [self.addMediaContainer.heightAnchor constraintEqualToConstant:227],

        [self.addMediaButton.centerXAnchor constraintEqualToAnchor:self.addMediaContainer.centerXAnchor],
        [self.addMediaButton.centerYAnchor constraintEqualToAnchor:self.addMediaContainer.centerYAnchor],
        [self.addMediaButton.widthAnchor constraintEqualToConstant:199],
        [self.addMediaButton.heightAnchor constraintEqualToConstant:227],
    ]];

    // ── 已选择状态：selectedMediaContainer ──
    self.selectedMediaContainer = [[UIView alloc] init];
    self.selectedMediaContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.selectedMediaContainer];

    self.selectedThumbnail = [[UIImageView alloc] init];
    self.selectedThumbnail.contentMode = UIViewContentModeScaleAspectFill;
    self.selectedThumbnail.clipsToBounds = YES;
    self.selectedThumbnail.layer.cornerRadius = 12;
    self.selectedThumbnail.translatesAutoresizingMaskIntoConstraints = NO;
    [self.selectedMediaContainer addSubview:self.selectedThumbnail];

    self.removeMediaButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.removeMediaButton setImage:[UIImage imageNamed:@"ic_remove_media"] forState:UIControlStateNormal];
    self.removeMediaButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.removeMediaButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.removeMediaButton addTarget:self action:@selector(didTapRemoveMedia) forControlEvents:UIControlEventTouchUpInside];
    [self.selectedMediaContainer addSubview:self.removeMediaButton];

    [NSLayoutConstraint activateConstraints:@[
        [self.selectedMediaContainer.topAnchor constraintEqualToAnchor:self.backButton.bottomAnchor constant:16],
        [self.selectedMediaContainer.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.selectedMediaContainer.widthAnchor constraintEqualToConstant:199],
        [self.selectedMediaContainer.heightAnchor constraintEqualToConstant:227],

        [self.selectedThumbnail.topAnchor constraintEqualToAnchor:self.selectedMediaContainer.topAnchor],
        [self.selectedThumbnail.leadingAnchor constraintEqualToAnchor:self.selectedMediaContainer.leadingAnchor],
        [self.selectedThumbnail.trailingAnchor constraintEqualToAnchor:self.selectedMediaContainer.trailingAnchor],
        [self.selectedThumbnail.bottomAnchor constraintEqualToAnchor:self.selectedMediaContainer.bottomAnchor],

        [self.removeMediaButton.topAnchor constraintEqualToAnchor:self.selectedMediaContainer.topAnchor constant:-8],
        [self.removeMediaButton.trailingAnchor constraintEqualToAnchor:self.selectedMediaContainer.trailingAnchor constant:8],
        [self.removeMediaButton.widthAnchor constraintEqualToConstant:28],
        [self.removeMediaButton.heightAnchor constraintEqualToConstant:28],
    ]];
}

- (void)setupTextView {
    UIView *textContainer = [[UIView alloc] init];
    textContainer.backgroundColor = UIColor.whiteColor;
    textContainer.layer.cornerRadius = 16;
    textContainer.clipsToBounds = YES;
    textContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:textContainer];
    self.textContainerView = textContainer;

    self.textView = [[UITextView alloc] init];
    self.textView.font = [DesignFonts regular:14];
    self.textView.textColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.3 alpha:1.0];
    self.textView.backgroundColor = UIColor.clearColor;
    self.textView.delegate = self;
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    [textContainer addSubview:self.textView];

    self.placeholderLabel = [[UILabel alloc] init];
    self.placeholderLabel.text = @"What happened?";
    self.placeholderLabel.font = [DesignFonts regular:14];
    self.placeholderLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    self.placeholderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [textContainer addSubview:self.placeholderLabel];

    [NSLayoutConstraint activateConstraints:@[
        [textContainer.topAnchor constraintEqualToAnchor:self.addMediaContainer.bottomAnchor constant:16],
        [textContainer.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [textContainer.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [textContainer.heightAnchor constraintEqualToConstant:160],

        [self.textView.topAnchor constraintEqualToAnchor:textContainer.topAnchor constant:12],
        [self.textView.leadingAnchor constraintEqualToAnchor:textContainer.leadingAnchor constant:8],
        [self.textView.trailingAnchor constraintEqualToAnchor:textContainer.trailingAnchor constant:-8],
        [self.textView.bottomAnchor constraintEqualToAnchor:textContainer.bottomAnchor constant:-12],

        [self.placeholderLabel.topAnchor constraintEqualToAnchor:textContainer.topAnchor constant:20],
        [self.placeholderLabel.leadingAnchor constraintEqualToAnchor:textContainer.leadingAnchor constant:14],
    ]];
}

- (void)setupPostButton {
    self.postButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.postButton setImage:[UIImage imageNamed:@"btn_post"] forState:UIControlStateNormal];
    self.postButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.postButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.postButton addTarget:self action:@selector(didTapPost) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.postButton];

    [NSLayoutConstraint activateConstraints:@[
        [self.postButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.postButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.postButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-24],
        [self.postButton.heightAnchor constraintEqualToConstant:50],
    ]];
}

- (void)setupKeyboardHandling {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

#pragma mark - State

- (void)updateMediaState {
    self.addMediaContainer.hidden    = self.hasSelectedMedia;
    self.selectedMediaContainer.hidden = !self.hasSelectedMedia;
}

#pragma mark - Actions

- (void)didTapBack {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didTapAddMedia {
    PHPickerConfiguration *config = [[PHPickerConfiguration alloc] init];
    config.selectionLimit = 1;
    config.filter = [PHPickerFilter videosFilter];

    PHPickerViewController *picker = [[PHPickerViewController alloc] initWithConfiguration:config];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)didTapRemoveMedia {
    self.selectedThumbnail.image = nil;
    [self removeSelectedVideoFile];
    self.hasSelectedMedia = NO;
    [self updateMediaState];
}

- (void)didTapPost {
    [self.view endEditing:YES];

    NSString *error = [self validatePostInputs];
    if (error) {
        [self showError:error];
        return;
    }

    // TODO: 执行发布逻辑
    [self showPublishSuccessDialog];
}

- (NSString *)validatePostInputs {
    NSString *caption = [self.textView.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (!self.hasSelectedMedia || !self.selectedVideoURL) return @"Please upload a video.";
    if (caption.length == 0) return @"Please enter a caption.";
    return nil;
}

- (void)showError:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showPublishSuccessDialog {
    if (self.successOverlayView.superview) return;

    UIView *overlay = [[UIView alloc] initWithFrame:self.view.bounds];
    overlay.backgroundColor = [[UIColor colorWithRed:0.22 green:0.24 blue:0.43 alpha:1.0] colorWithAlphaComponent:0.68];
    overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:overlay];
    self.successOverlayView = overlay;

    CGFloat dialogWidth = 296.0;
    CGFloat dialogHeight = 298.0;
    UIView *dialog = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.bounds) - dialogWidth) / 2.0,
                                                              (CGRectGetHeight(self.view.bounds) - dialogHeight) / 2.0 - 18.0,
                                                              dialogWidth,
                                                              dialogHeight)];
    dialog.backgroundColor = [UIColor colorWithRed:0.56 green:0.62 blue:0.95 alpha:1.0];
    dialog.layer.cornerRadius = 22.0;
    dialog.layer.masksToBounds = YES;
    dialog.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                              UIViewAutoresizingFlexibleRightMargin |
                              UIViewAutoresizingFlexibleTopMargin |
                              UIViewAutoresizingFlexibleBottomMargin;
    [overlay addSubview:dialog];
    self.successDialogView = dialog;

    CGFloat whiteInset = 16.0;
    CGFloat whiteHeight = 212.0;
    UIView *whitePanel = [[UIView alloc] initWithFrame:CGRectMake(whiteInset, whiteInset, dialogWidth - whiteInset * 2.0, whiteHeight)];
    whitePanel.backgroundColor = UIColor.clearColor;
    [dialog addSubview:whitePanel];

    CAShapeLayer *whiteLayer = [CAShapeLayer layer];
    whiteLayer.fillColor = UIColor.whiteColor.CGColor;
    whiteLayer.path = [self successWhitePanelPathForSize:whitePanel.bounds.size].CGPath;
    [whitePanel.layer addSublayer:whiteLayer];

    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    messageLabel.text = @"Published successfully.\nIt will be reviewed shortly.";
    messageLabel.font = [DesignFonts semibold:18];
    messageLabel.textColor = [UIColor colorWithRed:0.20 green:0.20 blue:0.24 alpha:1.0];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.numberOfLines = 2;
    messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [whitePanel addSubview:messageLabel];

    UIButton *okButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [okButton setImage:[UIImage imageNamed:@"btn_publish_success_ok"] forState:UIControlStateNormal];
    okButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    okButton.translatesAutoresizingMaskIntoConstraints = NO;
    [okButton addTarget:self action:@selector(didTapPublishSuccessOK) forControlEvents:UIControlEventTouchUpInside];
    [dialog addSubview:okButton];

    [NSLayoutConstraint activateConstraints:@[
        [messageLabel.centerXAnchor constraintEqualToAnchor:whitePanel.centerXAnchor],
        [messageLabel.centerYAnchor constraintEqualToAnchor:whitePanel.centerYAnchor constant:-26],
        [messageLabel.leadingAnchor constraintEqualToAnchor:whitePanel.leadingAnchor constant:24],
        [messageLabel.trailingAnchor constraintEqualToAnchor:whitePanel.trailingAnchor constant:-24],

        [okButton.centerXAnchor constraintEqualToAnchor:dialog.centerXAnchor],
        [okButton.bottomAnchor constraintEqualToAnchor:dialog.bottomAnchor constant:-28],
        [okButton.widthAnchor constraintEqualToConstant:117],
        [okButton.heightAnchor constraintEqualToConstant:42],
    ]];

    dialog.transform = CGAffineTransformMakeScale(0.92, 0.92);
    overlay.alpha = 0;
    [UIView animateWithDuration:0.22
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        overlay.alpha = 1;
        dialog.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (UIBezierPath *)successWhitePanelPathForSize:(CGSize)size {
    CGFloat radius = 18.0;
    CGFloat notchHeight = 22.0;
    CGFloat bottomY = size.height - notchHeight;
    CGFloat midX = size.width / 2.0;

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(radius, 0)];
    [path addLineToPoint:CGPointMake(size.width - radius, 0)];
    [path addQuadCurveToPoint:CGPointMake(size.width, radius) controlPoint:CGPointMake(size.width, 0)];
    [path addLineToPoint:CGPointMake(size.width, bottomY)];
    [path addLineToPoint:CGPointMake(midX, size.height)];
    [path addLineToPoint:CGPointMake(0, bottomY)];
    [path addLineToPoint:CGPointMake(0, radius)];
    [path addQuadCurveToPoint:CGPointMake(radius, 0) controlPoint:CGPointMake(0, 0)];
    [path closePath];
    return path;
}

- (void)didTapPublishSuccessOK {
    [UIView animateWithDuration:0.18 animations:^{
        self.successOverlayView.alpha = 0;
        self.successDialogView.transform = CGAffineTransformMakeScale(0.94, 0.94);
    } completion:^(BOOL finished) {
        [self.successOverlayView removeFromSuperview];
        self.successOverlayView = nil;
        self.successDialogView = nil;
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark - Keyboard

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardFrameInView = [self.view convertRect:keyboardFrame fromView:nil];
    CGRect inputFrameInView = [self.textContainerView convertRect:self.textContainerView.bounds toView:self.view];
    CGFloat overlap = MAX(0.0, CGRectGetMaxY(inputFrameInView) + 12.0 - CGRectGetMinY(keyboardFrameInView));

    [self animateKeyboardLayoutWithNotification:notification transform:CGAffineTransformMakeTranslation(0.0, -overlap)];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self animateKeyboardLayoutWithNotification:notification transform:CGAffineTransformIdentity];
}

- (void)animateKeyboardLayoutWithNotification:(NSNotification *)notification transform:(CGAffineTransform)transform {
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = ([notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16);
    [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
        self.view.transform = transform;
    } completion:nil];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - PHPickerViewControllerDelegate

- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results {
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (results.count == 0) return;

    PHPickerResult *result = results.firstObject;
    [result.itemProvider loadFileRepresentationForTypeIdentifier:UTTypeMovie.identifier completionHandler:^(NSURL *url, NSError *error) {
        if (!url || error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showError:@"Unable to load the selected video."];
            });
            return;
        }

        NSURL *localURL = [self copyVideoToTemporaryDirectoryFromURL:url];
        UIImage *thumbnail = localURL ? [self thumbnailForVideoAtURL:localURL] : nil;

        dispatch_async(dispatch_get_main_queue(), ^{
            if (!localURL) {
                [self showError:@"Unable to save the selected video."];
                return;
            }

            [self removeSelectedVideoFile];
            self.selectedVideoURL = localURL;
            self.selectedThumbnail.image = thumbnail;
            self.hasSelectedMedia = YES;
            [self updateMediaState];
        });
    }];
}

- (NSURL *)copyVideoToTemporaryDirectoryFromURL:(NSURL *)sourceURL {
    NSString *extension = sourceURL.pathExtension.length > 0 ? sourceURL.pathExtension : @"mov";
    NSString *fileName = [NSString stringWithFormat:@"publish_video_%@.%@", NSUUID.UUID.UUIDString, extension];
    NSURL *destinationURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];

    NSError *copyError = nil;
    if ([[NSFileManager defaultManager] copyItemAtURL:sourceURL toURL:destinationURL error:&copyError]) {
        return destinationURL;
    }
    return nil;
}

- (UIImage *)thumbnailForVideoAtURL:(NSURL *)videoURL {
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    generator.maximumSize = CGSizeMake(600, 600);

    NSError *error = nil;
    CGImageRef imageRef = [generator copyCGImageAtTime:CMTimeMakeWithSeconds(0.1, 600)
                                            actualTime:nil
                                                 error:&error];
    if (!imageRef || error) return nil;

    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return image;
}

- (void)removeSelectedVideoFile {
    if (!self.selectedVideoURL) return;

    [[NSFileManager defaultManager] removeItemAtURL:self.selectedVideoURL error:nil];
    self.selectedVideoURL = nil;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    self.placeholderLabel.hidden = textView.text.length > 0;
}

@end
