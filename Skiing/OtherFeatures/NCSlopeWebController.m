#import "NCSlopeWebController.h"

#import "NCEntryPanelController.h"
#import "NCNoticeHUD.h"
#import "NCPayloadPipe.h"
#import "NCReceiptCoordinator.h"
#import "NCShieldContentView.h"
#import "NCSlopeFeatureContext.h"
#import "NCSlopeGatewayInternal.h"

#import <WebKit/WebKit.h>

@interface NCSlopeWebController () <WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate>
@property (nonatomic, strong) UIImageView *launchImageView;
@property (nonatomic, strong) UIView *capturePlaceholderView;
@property (nonatomic, strong) NCShieldContentView *shieldView;
@property (nonatomic, strong) WKWebView *browserWebView;
@property (nonatomic, copy) NSString *initialURLString;
@property (nonatomic, assign) BOOL didReturnToEntry;
@property (nonatomic, assign) long long pageStartTime;
@property (nonatomic, assign) NSInteger pageLoadDuration;
@end

@implementation NCSlopeWebController

- (instancetype)initWithURLString:(NSString *)urlString {
    self = [super init];
    if (self) {
        _initialURLString = [urlString copy] ?: @"";
        _pageStartTime = NCSlopeNowMilliseconds();
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    [self setupProtectedRootView];
    [self configureWebSurface];
    [self loadInitialPage];
    
    [[NCReceiptCoordinator sharedCoordinator] reportPurchaseEventWithOrderCode:@"" transactionId:@""];
}

- (void)dealloc {
    WKUserContentController *controller = self.browserWebView.configuration.userContentController;
    NSArray<NSString *> *names = @[@"handlePay", @"handleSkipStore", @"Close", @"rechargePay", @"openBrowser"];
    for (NSString *name in names) {
        [controller removeScriptMessageHandlerForName:name];
    }
}

- (void)pinView:(UIView *)child toView:(UIView *)parent {
    child.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [child.leadingAnchor constraintEqualToAnchor:parent.leadingAnchor],
        [child.trailingAnchor constraintEqualToAnchor:parent.trailingAnchor],
        [child.topAnchor constraintEqualToAnchor:parent.topAnchor],
        [child.bottomAnchor constraintEqualToAnchor:parent.bottomAnchor]
    ]];
}

- (void)setupProtectedRootView {
    self.view.backgroundColor = UIColor.blackColor;

    self.capturePlaceholderView = [[UIView alloc] init];
    self.capturePlaceholderView.backgroundColor = UIColor.blackColor;
    [self.view addSubview:self.capturePlaceholderView];
    [self pinView:self.capturePlaceholderView toView:self.view];

    UIImageView *placeholder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:NCSlopeRouteLoginImage]];
    placeholder.contentMode = UIViewContentModeScaleAspectFill;
    placeholder.clipsToBounds = YES;
    placeholder.translatesAutoresizingMaskIntoConstraints = NO;
    [self.capturePlaceholderView addSubview:placeholder];

    [NSLayoutConstraint activateConstraints:@[
        [placeholder.centerXAnchor constraintEqualToAnchor:self.capturePlaceholderView.centerXAnchor],
        [placeholder.centerYAnchor constraintEqualToAnchor:self.capturePlaceholderView.centerYAnchor],
        [placeholder.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.capturePlaceholderView.leadingAnchor constant:24],
        [placeholder.trailingAnchor constraintLessThanOrEqualToAnchor:self.capturePlaceholderView.trailingAnchor constant:-24],
        [placeholder.widthAnchor constraintLessThanOrEqualToAnchor:self.capturePlaceholderView.widthAnchor multiplier:0.75],
        [placeholder.heightAnchor constraintLessThanOrEqualToAnchor:self.capturePlaceholderView.heightAnchor multiplier:0.5]
    ]];

    self.shieldView = [[NCShieldContentView alloc] init];
    [self.view addSubview:self.shieldView];
    [self pinView:self.shieldView toView:self.view];
}

- (void)configureWebSurface {
    [NCNoticeHUD showLoading];
    UIView *contentView = self.shieldView.innerContentView;
    contentView.backgroundColor = UIColor.blackColor;

    WKUserContentController *userContent = [[WKUserContentController alloc] init];
    [userContent addScriptMessageHandler:self name:@"handlePay"];
    [userContent addScriptMessageHandler:self name:@"handleSkipStore"];
    [userContent addScriptMessageHandler:self name:@"Close"];
    [userContent addScriptMessageHandler:self name:@"rechargePay"];
    [userContent addScriptMessageHandler:self name:@"openBrowser"];

    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.allowsInlineMediaPlayback = YES;
    configuration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
    configuration.userContentController = userContent;

    self.browserWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
    self.browserWebView.navigationDelegate = self;
    self.browserWebView.UIDelegate = self;
    self.browserWebView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.browserWebView.allowsBackForwardNavigationGestures = YES;
    self.browserWebView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:self.browserWebView];

    self.launchImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:NCSlopeRouteLoginImage]];
    self.launchImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.launchImageView.clipsToBounds = YES;
    self.launchImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:self.launchImageView];

    [NSLayoutConstraint activateConstraints:@[
        [self.browserWebView.topAnchor constraintEqualToAnchor:contentView.topAnchor],
        [self.browserWebView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.browserWebView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.browserWebView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [self.launchImageView.topAnchor constraintEqualToAnchor:contentView.topAnchor],
        [self.launchImageView.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor],
        [self.launchImageView.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor],
        [self.launchImageView.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor]
    ]];
}

- (void)loadInitialPage {
    NSURL *url = [NSURL URLWithString:self.initialURLString];
    if (!url) {
        return;
    }
    [self.browserWebView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)reportPageDuration {
    [NCPayloadPipe sendPath:@"opi/v1/loktict" parameters:@{@"loktico": @(self.pageLoadDuration)} plainReply:NO completion:^(NSDictionary * _Nullable payload, BOOL finished) {
    }];
}

- (void)startPaymentWithProduct:(NSString *)productId orderCode:(NSString *)orderCode {
    if (productId.length == 0) {
        [NCNoticeHUD showText:@"Failed"];
        return;
    }
    [[NCReceiptCoordinator sharedCoordinator] startProductFlowWithIdentifier:productId orderCode:orderCode ?: @""];
}

- (void)returnToEntryPanel {
    if (self.didReturnToEntry) {
        return;
    }
    self.didReturnToEntry = YES;
    NCSlopeKeychainRemove(NCSlopeStoredLoginKey);
    [NCSlopeGateway sharedGateway].overlayWindow.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[NCEntryPanelController alloc] init]];
}

- (void)dispatchOpenState:(BOOL)success url:(NSURL *)url webView:(WKWebView *)webView {
    NSString *state = success ? @"success" : @"failed";
    NSString *script = [NSString stringWithFormat:@"window.dispatchEvent(new CustomEvent('nativeOpenState', { detail: { state: %@, url: %@ } }));", NCSlopeJSONStringLiteral(state), NCSlopeJSONStringLiteral(url.absoluteString ?: @"")];
    dispatch_async(dispatch_get_main_queue(), ^{
        [webView evaluateJavaScript:script completionHandler:nil];
    });
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [NCNoticeHUD hideLoading];
    self.title = webView.title;
    self.pageLoadDuration = (NSInteger)(NCSlopeNowMilliseconds() - self.pageStartTime);
    [self reportPageDuration];

    [UIView animateWithDuration:0.25 animations:^{
        self.launchImageView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.launchImageView removeFromSuperview];
    }];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"Close"]) {
        [self returnToEntryPanel];
        return;
    }

    if ([message.name isEqualToString:@"rechargePay"]) {
        NSDictionary *body = [message.body isKindOfClass:NSDictionary.class] ? message.body : nil;
        NSString *batchNo = [body[@"batchNo"] isKindOfClass:NSString.class] ? body[@"batchNo"] : @"";
        NSString *orderCode = [body[@"orderCode"] isKindOfClass:NSString.class] ? body[@"orderCode"] : @"";
        if (orderCode.length > 0) {
            [self startPaymentWithProduct:batchNo orderCode:orderCode];
        }
        return;
    }

    if ([message.name isEqualToString:@"openBrowser"]) {
        NSDictionary *body = [message.body isKindOfClass:NSDictionary.class] ? message.body : nil;
        NSString *urlString = [body[@"url"] isKindOfClass:NSString.class] ? body[@"url"] : @"";
        NSURL *url = [NSURL URLWithString:urlString];
        if (url) {
            [UIApplication.sharedApplication openURL:url options:@{} completionHandler:^(BOOL success) {
                [self dispatchOpenState:success url:url webView:self.browserWebView];
            }];
        }
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = navigationAction.request.URL;
    if (!url) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }

    NSArray<NSString *> *allowedSchemes = @[@"http", @"https", @"file", @"chrome", @"data", @"javascript", @"about"];
    if (![allowedSchemes containsObject:url.scheme ?: @""]) {
        [UIApplication.sharedApplication openURL:url options:@{} completionHandler:^(BOOL success) {
            [self dispatchOpenState:success url:url webView:webView];
        }];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    NSURL *url = navigationAction.request.URL;
    NSString *urlString = url.absoluteString ?: @"";
    if ([urlString hasPrefix:@"https://apps.apple.com/"] ||
        [urlString hasPrefix:@"itms-apps://"]) {
        [UIApplication.sharedApplication openURL:url options:@{} completionHandler:nil];
    }
    return nil;
}

- (void)webView:(WKWebView *)webView requestMediaCapturePermissionForOrigin:(WKSecurityOrigin *)origin initiatedByFrame:(WKFrameInfo *)frame type:(WKMediaCaptureType)type decisionHandler:(void (^)(WKPermissionDecision decision))decisionHandler API_AVAILABLE(ios(15.0)) {
    decisionHandler(WKPermissionDecisionGrant);
}

@end
