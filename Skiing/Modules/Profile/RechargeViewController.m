//
//  RechargeViewController.m
//  Skiing
//

#import "RechargeViewController.h"
#import "CoinBalanceStore.h"
#import "DesignTokens.h"
#import <StoreKit/StoreKit.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

static CGFloat const kRechargeSidePadding = 24.0;

@interface RechargeViewController () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@property (nonatomic, strong) CAGradientLayer *backgroundGradientLayer;
@property (nonatomic, strong) UILabel *coinBalanceLabel;
@property (nonatomic, strong) SKProductsRequest *productsRequest;
@property (nonatomic, copy) NSArray<NSDictionary<NSString *, id> *> *rechargePackages;
@property (nonatomic, copy) NSDictionary<NSString *, SKProduct *> *productsByIdentifier;
@property (nonatomic, copy) NSArray<UIControl *> *packageRowControls;
@property (nonatomic, copy) NSArray<UIButton *> *priceButtons;
@property (nonatomic, assign, getter=isPurchasing) BOOL purchasing;
@end

#pragma clang diagnostic pop

@implementation RechargeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.75 green:0.78 blue:1.0 alpha:1.0];
    self.rechargePackages = [self defaultRechargePackages];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(updateCoinBalance)
                                               name:CoinBalanceStoreDidChangeNotification
                                             object:nil];
    [self setupBackground];
    [self setupContent];
    [self fetchProducts];
}

- (void)dealloc {
    [self.productsRequest cancel];
    self.productsRequest.delegate = nil;
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self updateCoinBalance];
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
    titleLabel.text = @"Recharge";
    titleLabel.font = [DesignFonts semibold:22];
    titleLabel.textColor = [UIColor colorWithRed:0.17 green:0.17 blue:0.24 alpha:1.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    UIImageView *coinCardImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mine_coin_card"]];
    coinCardImageView.contentMode = UIViewContentModeScaleToFill;
    coinCardImageView.userInteractionEnabled = YES;
    coinCardImageView.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *coinsTitleLabel = [[UILabel alloc] init];
    coinsTitleLabel.text = @"My coins";
    coinsTitleLabel.font = [DesignFonts regular:17];
    coinsTitleLabel.textColor = [UIColor colorWithRed:0.23 green:0.23 blue:0.27 alpha:1.0];
    coinsTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    self.coinBalanceLabel = [[UILabel alloc] init];
    self.coinBalanceLabel.font = [DesignFonts semibold:22];
    self.coinBalanceLabel.textColor = [UIColor colorWithRed:0.19 green:0.19 blue:0.22 alpha:1.0];
    self.coinBalanceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self updateCoinBalance];

    UILabel *hintLabel = [[UILabel alloc] init];
    hintLabel.text = @"*Use coins to unlock posting features and chat with AI.";
    hintLabel.font = [DesignFonts regular:13];
    hintLabel.textColor = [UIColor colorWithRed:0.39 green:0.39 blue:0.50 alpha:1.0];
    hintLabel.textAlignment = NSTextAlignmentCenter;
    hintLabel.translatesAutoresizingMaskIntoConstraints = NO;

    UIScrollView *packageScrollView = [[UIScrollView alloc] init];
    packageScrollView.backgroundColor = UIColor.clearColor;
    packageScrollView.showsVerticalScrollIndicator = NO;
    packageScrollView.translatesAutoresizingMaskIntoConstraints = NO;

    UIStackView *packageStackView = [[UIStackView alloc] init];
    packageStackView.axis = UILayoutConstraintAxisVertical;
    packageStackView.spacing = 18.0;
    packageStackView.translatesAutoresizingMaskIntoConstraints = NO;

    NSMutableArray<UIControl *> *rowControls = [NSMutableArray array];
    NSMutableArray<UIButton *> *priceButtons = [NSMutableArray array];
    for (NSDictionary<NSString *, id> *package in self.rechargePackages) {
        UIView *rowView = [self rechargeRowViewWithPackage:package
                                         rowControlHandler:rowControls
                                        priceButtonHandler:priceButtons];
        [packageStackView addArrangedSubview:rowView];
        [rowView.heightAnchor constraintEqualToConstant:64.0].active = YES;
    }
    self.packageRowControls = rowControls;
    self.priceButtons = priceButtons;

    [self.view addSubview:backButton];
    [self.view addSubview:titleLabel];
    [self.view addSubview:coinCardImageView];
    [coinCardImageView addSubview:coinsTitleLabel];
    [coinCardImageView addSubview:self.coinBalanceLabel];
    [self.view addSubview:hintLabel];
    [self.view addSubview:packageScrollView];
    [packageScrollView addSubview:packageStackView];

    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [backButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [backButton.topAnchor constraintEqualToAnchor:safeArea.topAnchor constant:12],
        [backButton.widthAnchor constraintEqualToConstant:44],
        [backButton.heightAnchor constraintEqualToConstant:44],

        [titleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [titleLabel.centerYAnchor constraintEqualToAnchor:backButton.centerYAnchor],

        [coinCardImageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kRechargeSidePadding],
        [coinCardImageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-kRechargeSidePadding],
        [coinCardImageView.topAnchor constraintEqualToAnchor:backButton.bottomAnchor constant:18],
        [coinCardImageView.heightAnchor constraintEqualToConstant:98],

        [coinsTitleLabel.leadingAnchor constraintEqualToAnchor:coinCardImageView.leadingAnchor constant:24],
        [coinsTitleLabel.topAnchor constraintEqualToAnchor:coinCardImageView.topAnchor constant:25],
        [coinsTitleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:coinCardImageView.trailingAnchor constant:-150],

        [self.coinBalanceLabel.leadingAnchor constraintEqualToAnchor:coinsTitleLabel.leadingAnchor],
        [self.coinBalanceLabel.topAnchor constraintEqualToAnchor:coinsTitleLabel.bottomAnchor constant:8],

        [hintLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kRechargeSidePadding],
        [hintLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-kRechargeSidePadding],
        [hintLabel.topAnchor constraintEqualToAnchor:coinCardImageView.bottomAnchor constant:12],

        [packageScrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [packageScrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [packageScrollView.topAnchor constraintEqualToAnchor:hintLabel.bottomAnchor constant:18],
        [packageScrollView.bottomAnchor constraintEqualToAnchor:safeArea.bottomAnchor constant:0],

        [packageStackView.leadingAnchor constraintEqualToAnchor:packageScrollView.contentLayoutGuide.leadingAnchor constant:kRechargeSidePadding],
        [packageStackView.trailingAnchor constraintEqualToAnchor:packageScrollView.contentLayoutGuide.trailingAnchor constant:-kRechargeSidePadding],
        [packageStackView.topAnchor constraintEqualToAnchor:packageScrollView.contentLayoutGuide.topAnchor],
        [packageStackView.bottomAnchor constraintEqualToAnchor:packageScrollView.contentLayoutGuide.bottomAnchor constant:0],
        [packageStackView.widthAnchor constraintEqualToAnchor:packageScrollView.frameLayoutGuide.widthAnchor constant:-(kRechargeSidePadding * 2.0)],
    ]];
}

- (UIView *)rechargeRowViewWithPackage:(NSDictionary<NSString *, id> *)package
                     rowControlHandler:(NSMutableArray<UIControl *> *)rowControls
                    priceButtonHandler:(NSMutableArray<UIButton *> *)priceButtons {
    UIControl *rowView = [[UIControl alloc] init];
    rowView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.38];
    rowView.layer.cornerRadius = 32.0;
    rowView.tag = rowControls.count;
    [rowView addTarget:self action:@selector(didTapPurchaseButton:) forControlEvents:UIControlEventTouchUpInside];

    UIImageView *coinIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recharge_coin_icon"]];
    coinIconView.contentMode = UIViewContentModeScaleAspectFit;
    coinIconView.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *amountLabel = [[UILabel alloc] init];
    amountLabel.text = [NSString stringWithFormat:@"x%ld", (long)[self coinsForPackage:package]];
    amountLabel.font = [DesignFonts semibold:18];
    amountLabel.textColor = [UIColor colorWithRed:0.18 green:0.18 blue:0.23 alpha:1.0];
    amountLabel.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *originalPriceLabel = [[UILabel alloc] init];
    originalPriceLabel.attributedText = [[NSAttributedString alloc] initWithString:[self originalPriceTextForPackage:package]
                                                                        attributes:@{
        NSStrikethroughStyleAttributeName: @(NSUnderlineStyleSingle),
        NSForegroundColorAttributeName: [UIColor colorWithRed:0.39 green:0.39 blue:0.47 alpha:1.0],
        NSFontAttributeName: [DesignFonts regular:16]
    }];
    originalPriceLabel.translatesAutoresizingMaskIntoConstraints = NO;

    UIButton *priceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    priceButton.backgroundColor = [UIColor colorWithRed:1.0 green:0.94 blue:0.60 alpha:1.0];
    priceButton.layer.cornerRadius = 22.0;
    priceButton.titleLabel.font = [DesignFonts regular:17];
    [priceButton setTitle:[self priceTextForPackage:package] forState:UIControlStateNormal];
    [priceButton setTitleColor:[UIColor colorWithRed:0.17 green:0.17 blue:0.22 alpha:1.0] forState:UIControlStateNormal];
    priceButton.translatesAutoresizingMaskIntoConstraints = NO;
    priceButton.userInteractionEnabled = NO;
    [rowControls addObject:rowView];
    [priceButtons addObject:priceButton];

    [rowView addSubview:coinIconView];
    [rowView addSubview:amountLabel];
    [rowView addSubview:originalPriceLabel];
    [rowView addSubview:priceButton];

    [NSLayoutConstraint activateConstraints:@[
        [coinIconView.leadingAnchor constraintEqualToAnchor:rowView.leadingAnchor constant:22],
        [coinIconView.centerYAnchor constraintEqualToAnchor:rowView.centerYAnchor],
        [coinIconView.widthAnchor constraintEqualToConstant:30],
        [coinIconView.heightAnchor constraintEqualToConstant:30],

        [amountLabel.leadingAnchor constraintEqualToAnchor:coinIconView.trailingAnchor constant:10],
        [amountLabel.centerYAnchor constraintEqualToAnchor:rowView.centerYAnchor],

        [priceButton.trailingAnchor constraintEqualToAnchor:rowView.trailingAnchor constant:-16],
        [priceButton.centerYAnchor constraintEqualToAnchor:rowView.centerYAnchor],
        [priceButton.widthAnchor constraintEqualToConstant:92],
        [priceButton.heightAnchor constraintEqualToConstant:44],

        [originalPriceLabel.trailingAnchor constraintEqualToAnchor:priceButton.leadingAnchor constant:-15],
        [originalPriceLabel.centerYAnchor constraintEqualToAnchor:rowView.centerYAnchor],
        [originalPriceLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:amountLabel.trailingAnchor constant:10],
    ]];

    return rowView;
}

#pragma mark - Package Data

- (NSArray<NSDictionary<NSString *, id> *> *)defaultRechargePackages {
    return @[
        @{@"coins": @28999, @"originalPrice": @"$199.99", @"price": @"$99.99", @"productId": @"hirczpmesrpjjkpf"},
        @{@"coins": @12999, @"originalPrice": @"$109.99", @"price": @"$49.99", @"productId": @"cnzrzykakiadtroz"},
        @{@"coins": @5699, @"originalPrice": @"$49.99", @"price": @"$19.99", @"productId": @"khqnatwrexbefafp"},
        @{@"coins": @2299, @"originalPrice": @"$19.99", @"price": @"$9.99", @"productId": @"aotdsvlouotjwnco"},
        @{@"coins": @699, @"originalPrice": @"$9.99", @"price": @"$4.99", @"productId": @"qprtfqyidjrlsulp"},
        @{@"coins": @149, @"originalPrice": @"$6.99", @"price": @"$1.99", @"productId": @"lqvfogevvzjdobnx"},
        @{@"coins": @69, @"originalPrice": @"$4.99", @"price": @"$0.99", @"productId": @"jxznaatqeekrxvsa"},
    ];
}

- (NSArray<NSString *> *)productIdentifiers {
    NSMutableArray<NSString *> *identifiers = [NSMutableArray arrayWithCapacity:self.rechargePackages.count];
    for (NSDictionary<NSString *, id> *package in self.rechargePackages) {
        NSString *productIdentifier = [self productIdentifierForPackage:package];
        if (productIdentifier.length > 0) {
            [identifiers addObject:productIdentifier];
        }
    }
    return identifiers.copy;
}

- (NSDictionary<NSString *, id> *)packageForProductIdentifier:(NSString *)productIdentifier {
    if (productIdentifier.length == 0) {
        return nil;
    }

    for (NSDictionary<NSString *, id> *package in self.rechargePackages) {
        if ([[self productIdentifierForPackage:package] isEqualToString:productIdentifier]) {
            return package;
        }
    }
    return nil;
}

- (NSInteger)coinsForPackage:(NSDictionary<NSString *, id> *)package {
    NSNumber *coins = package[@"coins"];
    return [coins respondsToSelector:@selector(integerValue)] ? coins.integerValue : 0;
}

- (NSString *)productIdentifierForPackage:(NSDictionary<NSString *, id> *)package {
    NSString *productIdentifier = package[@"productId"];
    return [productIdentifier isKindOfClass:NSString.class] ? productIdentifier : @"";
}

- (NSString *)priceTextForPackage:(NSDictionary<NSString *, id> *)package {
    NSString *price = package[@"price"];
    return [price isKindOfClass:NSString.class] && price.length > 0 ? price : @"$0.99";
}

- (NSString *)originalPriceTextForPackage:(NSDictionary<NSString *, id> *)package {
    NSString *originalPrice = package[@"originalPrice"];
    return [originalPrice isKindOfClass:NSString.class] && originalPrice.length > 0 ? originalPrice : [self priceTextForPackage:package];
}

#pragma mark - StoreKit

- (void)fetchProducts {
    self.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:[self productIdentifiers]]];
    self.productsRequest.delegate = self;
    [self.productsRequest start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSMutableDictionary<NSString *, SKProduct *> *productsByIdentifier = [NSMutableDictionary dictionaryWithCapacity:response.products.count];
    for (SKProduct *product in response.products) {
        productsByIdentifier[product.productIdentifier] = product;
    }
    self.productsByIdentifier = productsByIdentifier.copy;

    dispatch_async(dispatch_get_main_queue(), ^{
        for (NSInteger index = 0; index < self.priceButtons.count && index < self.rechargePackages.count; index++) {
            UIButton *button = self.priceButtons[index];
            NSDictionary<NSString *, id> *package = self.rechargePackages[index];
            SKProduct *product = self.productsByIdentifier[[self productIdentifierForPackage:package]];
            NSString *priceText = product ? [self localizedPriceForProduct:product] : [self priceTextForPackage:package];
            [button setTitle:priceText forState:UIControlStateNormal];
        }
    });
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showAlertWithTitle:@"Recharge unavailable" message:@"Unable to load App Store products. Please try again later."];
    });
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateDeferred: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.purchasing = NO;
                    [self setPurchaseButtonsEnabled:YES];
                    [self showAlertWithTitle:@"Purchase pending" message:@"Your purchase is waiting for approval."];
                });
                break;
            }
            case SKPaymentTransactionStatePurchasing:
                break;
        }
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSDictionary<NSString *, id> *package = [self packageForProductIdentifier:transaction.payment.productIdentifier];
    if (package) {
        [CoinBalanceStore creditCoins:[self coinsForPackage:package] transactionIdentifier:transaction.transactionIdentifier ?: @""];
    }

    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.purchasing = NO;
        [self setPurchaseButtonsEnabled:YES];
        [self updateCoinBalance];
        [self showAlertWithTitle:@"Recharge successful" message:@"Coins have been added to your account."];
    });
}

- (void)failTransaction:(SKPaymentTransaction *)transaction {
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.purchasing = NO;
        [self setPurchaseButtonsEnabled:YES];
        if (transaction.error.code != SKErrorPaymentCancelled) {
            [self showAlertWithTitle:@"Purchase failed" message:transaction.error.localizedDescription ?: @"Please try again later."];
        }
    });
}

- (NSString *)localizedPriceForProduct:(SKProduct *)product {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.locale = product.priceLocale;
    return [formatter stringFromNumber:product.price] ?: @"$9.99";
}

#pragma mark - Actions

- (void)didTapBackButton {
    if (self.navigationController && self.navigationController.viewControllers.firstObject != self) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didTapPurchaseButton:(UIControl *)button {
    if (self.isPurchasing) {
        return;
    }

    if (![SKPaymentQueue canMakePayments]) {
        [self showAlertWithTitle:@"Recharge unavailable" message:@"In-App Purchases are disabled on this device."];
        return;
    }

    if (button.tag < 0 || button.tag >= self.rechargePackages.count) {
        return;
    }

    NSDictionary<NSString *, id> *package = self.rechargePackages[button.tag];
    SKProduct *product = self.productsByIdentifier[[self productIdentifierForPackage:package]];
    if (!product) {
        [self showAlertWithTitle:@"Recharge unavailable"
                         message:@"Product information is not ready. Please confirm the App Store product id and try again."];
        return;
    }

    self.purchasing = YES;
    [self setPurchaseButtonsEnabled:NO];
    [[SKPaymentQueue defaultQueue] addPayment:[SKPayment paymentWithProduct:product]];
}

#pragma mark - Helpers

- (void)updateCoinBalance {
    self.coinBalanceLabel.text = [NSString stringWithFormat:@"%ld", (long)[CoinBalanceStore currentBalance]];
}

- (void)setPurchaseButtonsEnabled:(BOOL)enabled {
    for (UIControl *rowControl in self.packageRowControls) {
        rowControl.enabled = enabled;
        rowControl.alpha = enabled ? 1.0 : 0.62;
    }
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    if (!self.view.window) return;

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
