//
//  CommentPanelView.m
//  Skiing
//

#import "CommentPanelView.h"
#import "VideoEngagementStore.h"
#import "DesignTokens.h"

// ── Comment cell ─────────────────────────────────────────────
@interface CommentCell : UITableViewCell
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel     *nameLabel;
@property (nonatomic, strong) UILabel     *contentLabel;
@property (nonatomic, strong) UIButton    *actionButton;
- (void)configureActionForOwnComment:(BOOL)isOwnComment;
@end

@implementation CommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) return nil;

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = UIColor.clearColor;

    self.avatarView = [[UIImageView alloc] init];
    self.avatarView.layer.cornerRadius = 20;
    self.avatarView.layer.masksToBounds = NO;       // allow border to show
    self.avatarView.clipsToBounds = YES;
    self.avatarView.contentMode = UIViewContentModeScaleAspectFill;
    self.avatarView.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1];
    // White border
    self.avatarView.layer.borderWidth = 2.0;
    self.avatarView.layer.borderColor = UIColor.whiteColor.CGColor;
    self.avatarView.translatesAutoresizingMaskIntoConstraints = NO;

    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = [DesignFonts semibold:14];
    self.nameLabel.textColor = [UIColor colorWithWhite:0.12 alpha:1];
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;

    self.contentLabel = [[UILabel alloc] init];
    self.contentLabel.font = [DesignFonts regular:13];
    self.contentLabel.textColor = [UIColor colorWithWhite:0.42 alpha:1];
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.translatesAutoresizingMaskIntoConstraints = NO;

    self.actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.actionButton.titleLabel.font = [DesignFonts semibold:12];
    self.actionButton.layer.cornerRadius = 14;
    self.actionButton.layer.masksToBounds = YES;
    self.actionButton.translatesAutoresizingMaskIntoConstraints = NO;

    [self.contentView addSubview:self.avatarView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.actionButton];

    // Avatar: 40×40, left-aligned, vertically centered with name+content block
    // Name + content: right of avatar, stacked vertically
    [NSLayoutConstraint activateConstraints:@[
        // Avatar
        [self.avatarView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [self.avatarView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:14],
        [self.avatarView.widthAnchor constraintEqualToConstant:40],
        [self.avatarView.heightAnchor constraintEqualToConstant:40],

        // Name
        [self.nameLabel.leadingAnchor constraintEqualToAnchor:self.avatarView.trailingAnchor constant:12],
        [self.nameLabel.trailingAnchor constraintEqualToAnchor:self.actionButton.leadingAnchor constant:-12],
        [self.nameLabel.topAnchor constraintEqualToAnchor:self.avatarView.topAnchor constant:2],

        // Action
        [self.actionButton.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [self.actionButton.topAnchor constraintEqualToAnchor:self.avatarView.topAnchor constant:0],
        [self.actionButton.widthAnchor constraintEqualToConstant:62],
        [self.actionButton.heightAnchor constraintEqualToConstant:28],

        // Content
        [self.contentLabel.leadingAnchor constraintEqualToAnchor:self.nameLabel.leadingAnchor],
        [self.contentLabel.trailingAnchor constraintEqualToAnchor:self.nameLabel.trailingAnchor],
        [self.contentLabel.topAnchor constraintEqualToAnchor:self.nameLabel.bottomAnchor constant:4],
        [self.contentLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-14],
    ]];

    return self;
}

- (void)configureActionForOwnComment:(BOOL)isOwnComment {
    NSString *title = isOwnComment ? @"Delete" : @"Report";
    UIColor *backgroundColor = isOwnComment ? [UIColor colorWithRed:1.00 green:0.30 blue:0.34 alpha:1.0] : [UIColor colorWithRed:0.93 green:0.94 blue:1.0 alpha:1.0];
    UIColor *titleColor = isOwnComment ? UIColor.whiteColor : [UIColor colorWithWhite:0.36 alpha:1.0];

    [self.actionButton setTitle:title forState:UIControlStateNormal];
    [self.actionButton setTitleColor:titleColor forState:UIControlStateNormal];
    self.actionButton.backgroundColor = backgroundColor;
    self.actionButton.layer.borderWidth = isOwnComment ? 0 : 1;
    self.actionButton.layer.borderColor = [UIColor colorWithWhite:0.84 alpha:1.0].CGColor;
}

@end

// ── CommentPanelView ─────────────────────────────────────────
@interface CommentPanelView () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) UIView        *dimView;
@property (nonatomic, strong) UIView        *containerView;
@property (nonatomic, strong) UIView        *handleBar;
@property (nonatomic, strong) UITableView   *tableView;
@property (nonatomic, strong) UIView        *inputBar;
@property (nonatomic, strong) UITextField   *inputField;
@property (nonatomic, strong) UIButton      *sendButton;
@property (nonatomic, copy)   NSString      *videoIdentifier;
@property (nonatomic, strong) NSMutableArray<VideoComment *> *comments;
@property (nonatomic, weak)   UIView        *parentView;
@end

static NSString * const kCommentCellID = @"CommentCell";
static const CGFloat kInputBarHeight   = 64.0;

@implementation CommentPanelView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    return [self initWithVideoIdentifier:@"default"];
}

- (instancetype)initWithVideoIdentifier:(NSString *)videoIdentifier {
    self = [super init];
    if (self) {
        _videoIdentifier = [videoIdentifier copy] ?: @"default";
        [self loadComments];
        [self buildSubviews];
    }
    return self;
}

- (void)loadComments {
    self.comments = [[[VideoEngagementStore sharedStore] commentsForVideoIdentifier:self.videoIdentifier] mutableCopy];
}

- (void)buildSubviews {
    // --- Dim overlay (frame layout, full screen) ---
    self.dimView = [[UIView alloc] init];
    self.dimView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [self.dimView addGestureRecognizer:tap];

    // --- Container (frame layout, slides up from bottom) ---
    self.containerView = [[UIView alloc] init];
    self.containerView.backgroundColor = UIColor.whiteColor;
    self.containerView.layer.cornerRadius = 20;
    self.containerView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    self.containerView.layer.masksToBounds = YES;
    self.containerView.clipsToBounds = YES;

    // --- Handle bar (frame layout inside container) ---
    self.handleBar = [[UIView alloc] init];
    self.handleBar.backgroundColor = [UIColor colorWithWhite:0.78 alpha:1];
    self.handleBar.layer.cornerRadius = 2.5;

    // --- TableView (frame layout inside container) ---
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = UIColor.clearColor;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.estimatedRowHeight = 68;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerClass:[CommentCell class] forCellReuseIdentifier:kCommentCellID];

    UITapGestureRecognizer *tableTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tableTap.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tableTap];

    // --- Input bar (frame layout inside container) ---
    self.inputBar = [[UIView alloc] init];
    self.inputBar.backgroundColor = UIColor.whiteColor;

    UIView *separator = [[UIView alloc] init];
    separator.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];

    self.inputField = [[UITextField alloc] init];
    self.inputField.placeholder = @"Add a comment...";
    self.inputField.font = [DesignFonts regular:14];
    self.inputField.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    self.inputField.layer.cornerRadius = 20;
    self.inputField.layer.masksToBounds = YES;
    self.inputField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 14, 0)];
    self.inputField.leftViewMode = UITextFieldViewModeAlways;
    self.inputField.returnKeyType = UIReturnKeySend;
    self.inputField.delegate = self;

    self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.sendButton setImage:[UIImage imageNamed:@"btn_send_comment"] forState:UIControlStateNormal];
    self.sendButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.sendButton addTarget:self action:@selector(didTapSend) forControlEvents:UIControlEventTouchUpInside];

    [self.inputBar addSubview:separator];
    [self.inputBar addSubview:self.inputField];
    [self.inputBar addSubview:self.sendButton];

    [self.containerView addSubview:self.tableView];
    [self.containerView addSubview:self.inputBar];
    [self.containerView addSubview:self.handleBar];

    // Keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Show / Dismiss

- (void)showInView:(UIView *)parentView {
    // Attach to key window so it covers tabbar and everything else
    UIWindow *window = nil;
    for (UIWindowScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if (scene.activationState == UISceneActivationStateForegroundActive &&
            [scene isKindOfClass:[UIWindowScene class]]) {
            window = ((UIWindowScene *)scene).windows.firstObject;
            break;
        }
    }
    if (!window) window = UIApplication.sharedApplication.windows.firstObject;

    self.parentView = window;

    CGRect bounds   = window.bounds;
    CGFloat screenW = bounds.size.width;
    CGFloat screenH = bounds.size.height;
    CGFloat panelH  = screenH * 0.65;

    self.dimView.frame = bounds;
    self.dimView.alpha = 0;
    [window addSubview:self.dimView];

    self.containerView.frame = CGRectMake(0, screenH, screenW, panelH);
    [window addSubview:self.containerView];

    [self layoutContainerSubviewsWithHeight:panelH width:screenW];

    [UIView animateWithDuration:0.35
                          delay:0
         usingSpringWithDamping:0.88
          initialSpringVelocity:0.4
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.dimView.alpha = 1;
        self.containerView.frame = CGRectMake(0, screenH - panelH, screenW, panelH);
    } completion:nil];
}

- (void)layoutContainerSubviewsWithHeight:(CGFloat)panelH width:(CGFloat)panelW {
    // Handle bar: centered at top
    CGFloat handleW = 36, handleH = 4, handleY = 10;
    self.handleBar.frame = CGRectMake((panelW - handleW) / 2.0, handleY, handleW, handleH);

    // Input bar: pinned to bottom with 20pt offset, fixed height
    CGFloat inputBarY = panelH - kInputBarHeight - 20;
    self.inputBar.frame = CGRectMake(0, inputBarY, panelW, kInputBarHeight);

    // Layout inside inputBar
    CGFloat sendW = 40, sendH = 40;
    CGFloat fieldX = 16, fieldH = 40;
    CGFloat fieldW = panelW - fieldX - sendW - 8 - 16; // 16 right padding
    CGFloat fieldY = (kInputBarHeight - fieldH) / 2.0;
    CGFloat sendX  = fieldX + fieldW + 8;
    CGFloat sendY  = (kInputBarHeight - sendH) / 2.0;

    // Separator at top of inputBar
    UIView *separator = self.inputBar.subviews.firstObject;
    separator.frame = CGRectMake(0, 0, panelW, 0.5);

    self.inputField.frame = CGRectMake(fieldX, fieldY, fieldW, fieldH);
    self.sendButton.frame = CGRectMake(sendX, sendY, sendW, sendH);

    // TableView: between handle bar bottom and input bar top
    CGFloat tableY = handleY + 4 + 10; // handleBar bottom + spacing
    CGFloat tableH = inputBarY - tableY;
    self.tableView.frame = CGRectMake(0, tableY, panelW, tableH);
}

- (void)dismiss {
    [self.inputField resignFirstResponder];
    CGFloat screenH = self.parentView.bounds.size.height;
    CGFloat panelW  = self.containerView.frame.size.width;
    CGFloat panelH  = self.containerView.frame.size.height;

    [UIView animateWithDuration:0.28
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
        self.dimView.alpha = 0;
        self.containerView.frame = CGRectMake(0, screenH, panelW, panelH);
    } completion:^(BOOL finished) {
        [self.dimView removeFromSuperview];
        [self.containerView removeFromSuperview];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }];
}

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)note {
    if (!self.parentView) return;

    CGRect kbFrame   = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = ([note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16);
    CGRect kbFrameInParent = [self.parentView convertRect:kbFrame fromView:nil];
    CGFloat screenH  = self.parentView.bounds.size.height;
    CGFloat panelH   = self.containerView.frame.size.height;
    CGFloat panelW   = self.containerView.frame.size.width;
    CGFloat keyboardOverlap = MAX(0.0, screenH - CGRectGetMinY(kbFrameInParent));

    [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
        self.containerView.frame = CGRectMake(0, screenH - panelH - keyboardOverlap, panelW, panelH);
    } completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)note {
    if (!self.parentView) return;

    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = ([note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16);
    CGFloat screenH  = self.parentView.bounds.size.height;
    CGFloat panelH   = self.containerView.frame.size.height;
    CGFloat panelW   = self.containerView.frame.size.width;

    [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
        self.containerView.frame = CGRectMake(0, screenH - panelH, panelW, panelH);
    } completion:nil];
}

- (void)dismissKeyboard {
    [self.inputField resignFirstResponder];
}

#pragma mark - Send

- (void)didTapSend {
    NSString *text = [self.inputField.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    if (text.length == 0) return;

    VideoComment *newItem = [[VideoEngagementStore sharedStore] addCommentText:text
                                                                       username:@"Me"
                                                                     avatarName:@"avatar_user_12"
                                                             forVideoIdentifier:self.videoIdentifier];

    [self.comments insertObject:newItem atIndex:0];
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
    if (self.commentsDidChange) {
        self.commentsDidChange(self.comments.count);
    }

    self.inputField.text = nil;
    [self.inputField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self didTapSend];
    return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:kCommentCellID forIndexPath:indexPath];
    VideoComment *item = self.comments[indexPath.row];
    cell.nameLabel.text    = item.username;
    cell.contentLabel.text = item.content;
    cell.avatarView.image  = [UIImage imageNamed:item.avatarName];
    [cell configureActionForOwnComment:[self isOwnComment:item]];
    [cell.actionButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    cell.actionButton.tag = indexPath.row;
    [cell.actionButton addTarget:self action:@selector(didTapCommentAction:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)didTapCommentAction:(UIButton *)sender {
    NSInteger index = sender.tag;
    if (index < 0 || index >= (NSInteger)self.comments.count) return;

    VideoComment *item = self.comments[index];
    if ([self isOwnComment:item]) {
        [self showDeleteCommentAlertAtIndex:index];
        return;
    }

    [self showReportAlertAtIndex:index];
}

- (void)showDeleteCommentAlertAtIndex:(NSInteger)index {
    UIViewController *presenter = [self topViewController];
    if (!presenter) return;

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete comment?"
                                                                   message:@"This comment will be removed from the video."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete"
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf deleteCommentAtIndex:index];
    }];

    [alert addAction:cancelAction];
    [alert addAction:deleteAction];
    [presenter presentViewController:alert animated:YES completion:nil];
}

- (void)deleteCommentAtIndex:(NSInteger)index {
    if (index < 0 || index >= (NSInteger)self.comments.count) return;

    [[VideoEngagementStore sharedStore] removeCommentAtIndex:index
                                          forVideoIdentifier:self.videoIdentifier];
    [self.comments removeObjectAtIndex:index];
    [self.tableView reloadData];

    if (self.commentsDidChange) {
        self.commentsDidChange(self.comments.count);
    }
}

- (BOOL)isOwnComment:(VideoComment *)comment {
    return [comment.username isEqualToString:@"Me"];
}

- (void)showReportAlertAtIndex:(NSInteger)index {
    UIViewController *presenter = [self topViewController];
    if (!presenter) return;

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Report comment?"
                                                                   message:@"This comment will be removed from the video after you report it."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *reportAction = [UIAlertAction actionWithTitle:@"Report"
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf reportCommentAtIndex:index];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showReportSubmittedAlert];
        });
    }];

    [alert addAction:cancelAction];
    [alert addAction:reportAction];
    [presenter presentViewController:alert animated:YES completion:nil];
}

- (void)reportCommentAtIndex:(NSInteger)index {
    if (index < 0 || index >= (NSInteger)self.comments.count) return;

    [[VideoEngagementStore sharedStore] reportCommentAtIndex:index
                                          forVideoIdentifier:self.videoIdentifier];
    [self.comments removeObjectAtIndex:index];
    [self.tableView reloadData];

    if (self.commentsDidChange) {
        self.commentsDidChange(self.comments.count);
    }
}

- (void)showReportSubmittedAlert {
    UIViewController *presenter = [self topViewController];
    if (!presenter) return;

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Report submitted"
                                                                   message:@"Thanks for helping keep the community safe."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alert addAction:okAction];
    [presenter presentViewController:alert animated:YES completion:nil];
}

- (UIViewController *)topViewController {
    UIWindow *window = nil;
    for (UIWindowScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if (scene.activationState != UISceneActivationStateForegroundActive ||
            ![scene isKindOfClass:UIWindowScene.class]) {
            continue;
        }

        for (UIWindow *sceneWindow in scene.windows) {
            if (sceneWindow.isKeyWindow) {
                window = sceneWindow;
                break;
            }
        }
        if (window) break;
    }
    if (!window && [self.parentView isKindOfClass:UIWindow.class]) {
        window = (UIWindow *)self.parentView;
    }

    UIViewController *controller = window.rootViewController;
    while (controller.presentedViewController) {
        controller = controller.presentedViewController;
    }

    if ([controller isKindOfClass:UINavigationController.class]) {
        controller = ((UINavigationController *)controller).topViewController;
    } else if ([controller isKindOfClass:UITabBarController.class]) {
        controller = ((UITabBarController *)controller).selectedViewController;
    }

    return controller;
}

@end
