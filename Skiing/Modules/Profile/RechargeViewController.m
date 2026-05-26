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
static NSInteger const kRechargeCoinAmount = 99;
static NSString * const kRechargeDefaultProductIdentifier = @"ski.Skiing.coins99";

@interface RechargeViewController () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@property (nonatomic, strong) CAGradientLayer *backgroundGradientLayer;
@property (nonatomic, strong) UILabel *coinBalanceLabel;
@property (nonatomic, strong) SKProductsRequest *productsRequest;
@property (nonatomic, strong) SKProduct *coinProduct;
@property (nonatomic, copy) NSString *productIdentifier;
@property (nonatomic, copy) NSArray<UIButton *> *priceButtons;
@property (nonatomic, assign, getter=isPurchasing) BOOL purchasing;
@end

#pragma clang diagnostic pop

@implementation RechargeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.75 green:0.78 blue:1.0 alpha:1.0];
    self.productIdentifier = [self configuredProductIdentifier];
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

    UIStackView *packageStackView = [[UIStackView alloc] init];
    packageStackView.axis = UILayoutConstraintAxisVertical;
    packageStackView.spacing = 18.0;
    packageStackView.translatesAutoresizingMaskIntoConstraints = NO;

    NSMutableArray<UIButton *> *buttons = [NSMutableArray array];
    for (NSInteger index = 0; index < 6; index++) {
        UIView *rowView = [self rechargeRowViewWithPriceButtonHandler:buttons];
        [packageStackView addArrangedSubview:rowView];
        [rowView.heightAnchor constraintEqualToConstant:64.0].active = YES;
    }
    self.priceButtons = buttons;

    [self.view addSubview:backButton];
    [self.view addSubview:titleLabel];
    [self.view addSubview:coinCardImageView];
    [coinCardImageView addSubview:coinsTitleLabel];
    [coinCardImageView addSubview:self.coinBalanceLabel];
    [self.view addSubview:hintLabel];
    [self.view addSubview:packageStackView];

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
        [coinCardImageView.topAnchor constraintEqualToAnchor:backButton.bottomAnchor constant:32],
        [coinCardImageView.heightAnchor constraintEqualToConstant:98],

        [coinsTitleLabel.leadingAnchor constraintEqualToAnchor:coinCardImageView.leadingAnchor constant:24],
        [coinsTitleLabel.topAnchor constraintEqualToAnchor:coinCardImageView.topAnchor constant:25],
        [coinsTitleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:coinCardImageView.trailingAnchor constant:-150],

        [self.coinBalanceLabel.leadingAnchor constraintEqualToAnchor:coinsTitleLabel.leadingAnchor],
        [self.coinBalanceLabel.topAnchor constraintEqualToAnchor:coinsTitleLabel.bottomAnchor constant:8],

        [hintLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kRechargeSidePadding],
        [hintLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-kRechargeSidePadding],
        [hintLabel.topAnchor constraintEqualToAnchor:coinCardImageView.bottomAnchor constant:16],

        [packageStackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kRechargeSidePadding],
        [packageStackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-kRechargeSidePadding],
        [packageStackView.topAnchor constraintEqualToAnchor:hintLabel.bottomAnchor constant:28],
    ]];
}

- (UIView *)rechargeRowViewWithPriceButtonHandler:(NSMutableArray<UIButton *> *)buttons {
    UIView *rowView = [[UIView alloc] init];
    rowView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.38];
    rowView.layer.cornerRadius = 32.0;

    UIImageView *coinIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recharge_coin_icon"]];
    coinIconView.contentMode = UIViewContentModeScaleAspectFit;
    coinIconView.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *amountLabel = [[UILabel alloc] init];
    amountLabel.text = [NSString stringWithFormat:@"x%ld", (long)kRechargeCoinAmount];
    amountLabel.font = [DesignFonts semibold:18];
    amountLabel.textColor = [UIColor colorWithRed:0.18 green:0.18 blue:0.23 alpha:1.0];
    amountLabel.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *originalPriceLabel = [[UILabel alloc] init];
    originalPriceLabel.attributedText = [[NSAttributedString alloc] initWithString:@"$19.99"
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
    [priceButton setTitle:@"$9.99" forState:UIControlStateNormal];
    [priceButton setTitleColor:[UIColor colorWithRed:0.17 green:0.17 blue:0.22 alpha:1.0] forState:UIControlStateNormal];
    priceButton.translatesAutoresizingMaskIntoConstraints = NO;
    [priceButton addTarget:self action:@selector(didTapPurchaseButton:) forControlEvents:UIControlEventTouchUpInside];
    [buttons addObject:priceButton];

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

#pragma mark - StoreKit

- (NSString *)configuredProductIdentifier {
    NSString *configuredIdentifier = [NSBundle.mainBundle objectForInfoDictionaryKey:@"RechargeCoins99ProductID"];
    if (configuredIdentifier.length > 0) {
        return configuredIdentifier;
    }

    return kRechargeDefaultProductIdentifier;
}

- (void)fetchProducts {
    self.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:self.productIdentifier]];
    self.productsRequest.delegate = self;
    [self.productsRequest start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    self.coinProduct = response.products.firstObject;
    NSString *priceText = self.coinProduct ? [self localizedPriceForProduct:self.coinProduct] : @"$9.99";

    dispatch_async(dispatch_get_main_queue(), ^{
        for (UIButton *button in self.priceButtons) {
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
    if ([transaction.payment.productIdentifier isEqualToString:self.productIdentifier]) {
        [CoinBalanceStore creditCoins:kRechargeCoinAmount transactionIdentifier:transaction.transactionIdentifier ?: @""];
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

- (void)didTapPurchaseButton:(UIButton *)button {
    if (self.isPurchasing) {
        return;
    }

    if (![SKPaymentQueue canMakePayments]) {
        [self showAlertWithTitle:@"Recharge unavailable" message:@"In-App Purchases are disabled on this device."];
        return;
    }

    if (!self.coinProduct) {
        [self showAlertWithTitle:@"Recharge unavailable"
                         message:@"Product information is not ready. Please confirm the App Store product id and try again."];
        return;
    }

    self.purchasing = YES;
    [self setPurchaseButtonsEnabled:NO];
    [[SKPaymentQueue defaultQueue] addPayment:[SKPayment paymentWithProduct:self.coinProduct]];
}

#pragma mark - Helpers

- (void)updateCoinBalance {
    self.coinBalanceLabel.text = [NSString stringWithFormat:@"%ld", (long)[CoinBalanceStore currentBalance]];
}

- (void)setPurchaseButtonsEnabled:(BOOL)enabled {
    for (UIButton *button in self.priceButtons) {
        button.enabled = enabled;
        button.alpha = enabled ? 1.0 : 0.62;
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
