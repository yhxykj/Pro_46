#import "NCReceiptCoordinator.h"

#import "NCAdjustEventReporter.h"
#import "NCFacebookEventReporter.h"
#import "NCNoticeHUD.h"
#import "NCPayloadPipe.h"
#import "NCSlopeFeatureContext.h"

#import <StoreKit/StoreKit.h>

@interface NCReceiptCoordinator () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@property (nonatomic, strong) NSArray<SKProduct *> *products;
@property (nonatomic, strong) SKProductsRequest *productRequest;
@property (nonatomic, copy) NSString *orderCode;
@property (nonatomic, assign) BOOL observingQueue;
@property (nonatomic, strong) NSDecimalNumber *activePrice;
@property (nonatomic, copy) NSString *activeCurrency;
@end

static NSString * const NCPurchaseEventBridgePath = @"opi/v1/payxj";

@implementation NCReceiptCoordinator

+ (instancetype)sharedCoordinator {
    static NCReceiptCoordinator *coordinator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coordinator = [[NCReceiptCoordinator alloc] init];
    });
    return coordinator;
}

- (void)beginObservation {
    if (self.observingQueue) {
        return;
    }
    self.observingQueue = YES;
    [SKPaymentQueue.defaultQueue addTransactionObserver:self];
}

- (void)startProductFlowWithIdentifier:(NSString *)productId orderCode:(NSString *)orderCode {
    [NCNoticeHUD showLoading];
    self.orderCode = [orderCode copy] ?: @"";
    self.productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:productId]];
    self.productRequest.delegate = self;
    [self.productRequest start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    self.products = response.products;
    if (NCSlopeRouteVerboseLog) {
        NSMutableArray *titles = [NSMutableArray array];
        for (SKProduct *product in response.products) {
            [titles addObject:product.localizedTitle ?: @""];
        }
        NSLog(@"%@", titles);
    }

    if (self.products.count == 0) {
        [NCNoticeHUD hideLoading];
        return;
    }

    SKProduct *product = self.products.firstObject;
    self.activePrice = product.price;
    self.activeCurrency = [self currencyCodeForProduct:product];
    [NCFacebookEventReporter logPaymentStartWithPrice:self.activePrice currency:self.activeCurrency];

    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    payment.applicationUsername = self.orderCode;
    [SKPaymentQueue.defaultQueue addPayment:payment];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased: {
                NSString *orderCode = transaction.payment.applicationUsername.length > 0 ? transaction.payment.applicationUsername : self.orderCode;
                if (orderCode.length == 0) {
                    [SKPaymentQueue.defaultQueue finishTransaction:transaction];
                    [NCNoticeHUD hideLoading];
                    return;
                }
                [self verifyTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStateFailed:
                [NCNoticeHUD hideLoading];
                [SKPaymentQueue.defaultQueue finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [NCNoticeHUD hideLoading];
                [SKPaymentQueue.defaultQueue finishTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

- (void)verifyTransaction:(SKPaymentTransaction *)transaction {
    NSURL *receiptURL = NSBundle.mainBundle.appStoreReceiptURL;
    if (!receiptURL || ![NSFileManager.defaultManager fileExistsAtPath:receiptURL.path]) {
        return;
    }

    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL options:NSDataReadingMappedIfSafe error:nil];
    NSString *receiptText = [receiptData base64EncodedStringWithOptions:0];
    if (receiptText.length > 0) {
        [self submitReceiptForTransaction:transaction receiptText:receiptText];
    }
}

- (void)submitReceiptForTransaction:(SKPaymentTransaction *)transaction receiptText:(NSString *)receiptText {
    NSString *orderCode = transaction.payment.applicationUsername.length > 0 ? transaction.payment.applicationUsername : self.orderCode;
    NSDictionary *parameters = @{
        @"loktict": transaction.transactionIdentifier ?: @"",
        @"lokticp": receiptText ?: @"",
        @"lokticc": NCSlopeJSONTextFromObject(@{@"orderCode": orderCode ?: @""})
    };

    [NCPayloadPipe sendPath:@"opi/v1/lokticp" parameters:parameters plainReply:YES completion:^(NSDictionary * _Nullable payload, BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (finished) {
                [NCNoticeHUD hideLoading];
                NSString *message = [payload[@"message"] isKindOfClass:NSString.class] ? payload[@"message"] : @"";
                [NCNoticeHUD showText:message];
                NSDecimalNumber *price = self.activePrice ?: NSDecimalNumber.zero;
                NSString *currency = self.activeCurrency ?: @"USD";
                NSString *transactionId = transaction.transactionIdentifier ?: @"";
                [NCFacebookEventReporter logPurchaseWithPrice:price currency:currency];
                [NCAdjustEventReporter logPurchaseWithPrice:price currency:currency transactionId:transactionId];
                [self reportPurchaseEventWithOrderCode:orderCode transactionId:transactionId];
                [SKPaymentQueue.defaultQueue finishTransaction:transaction];
            } else {
                [NCNoticeHUD hideLoading];
                [NCNoticeHUD showText:@"Failed"];
            }
        });
    }];
}

- (void)reportPurchaseEventWithOrderCode:(NSString *)orderCode transactionId:(NSString *)transactionId {
    dispatch_group_t group = dispatch_group_create();
    __block NSString *adidText = @"";
    __block NSString *attributionText = @"{}";

    dispatch_group_enter(group);
    [NCAdjustEventReporter currentAdidWithCompletion:^(NSString *adid) {
        adidText = [adid copy] ?: @"";
        dispatch_group_leave(group);
    }];

    dispatch_group_enter(group);
    [NCAdjustEventReporter currentAttributionJSONTextWithCompletion:^(NSString *jsonText) {
        attributionText = [jsonText copy] ?: @"{}";
        dispatch_group_leave(group);
    }];

    dispatch_group_notify(group, dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        NSDictionary *parameters = @{
            @"t": attributionText,
            @"e": @"Purchase",
            @"d": NCSlopeCurrentDeviceIdentifier(),
            @"a": adidText
        };

        [NCPayloadPipe sendPath:NCPurchaseEventBridgePath parameters:parameters plainReply:YES completion:^(NSDictionary * _Nullable payload, BOOL finished) {
            if (NCSlopeRouteVerboseLog) {
                NSLog(@"[NCSlope] purchase event bridge order:%@ transaction:%@ finished:%@ payload:%@", orderCode ?: @"", transactionId ?: @"", finished ? @"YES" : @"NO", payload ?: @{});
            }
        }];
    });
}

- (NSString *)currencyCodeForProduct:(SKProduct *)product {
    NSString *currency = nil;
    if (@available(iOS 10.0, *)) {
        currency = product.priceLocale.currencyCode;
    }
    if (currency.length == 0) {
        currency = [product.priceLocale objectForKey:NSLocaleCurrencyCode];
    }
    return currency.length > 0 ? currency : @"USD";
}

@end
