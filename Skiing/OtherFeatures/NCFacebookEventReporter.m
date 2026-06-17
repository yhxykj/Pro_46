#import "NCFacebookEventReporter.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>

@implementation NCFacebookEventReporter

/// 发起支付时
+ (void)logPaymentStartWithPrice:(NSDecimalNumber *)price {
    [self logPaymentStartWithPrice:price currency:@"USD"];
}

+ (void)logPaymentStartWithPrice:(NSDecimalNumber *)price currency:(NSString *)currency {
    if (price.doubleValue <= 0) {
        return;
    }
    NSString *finalCurrency = currency.length > 0 ? currency : @"USD";
    [[FBSDKAppEvents shared] logEvent:FBSDKAppEventNameInitiatedCheckout
                           valueToSum:price.doubleValue
                           parameters:@{FBSDKAppEventParameterNameCurrency: finalCurrency}];
}
 /// 支付完成后
+ (void)logPurchaseWithPrice:(NSDecimalNumber *)price currency:(NSString *)currency {
    if (price.doubleValue <= 0) {
        return;
    }
    NSString *finalCurrency = currency.length > 0 ? currency : @"USD";
    [[FBSDKAppEvents shared] logPurchase:price.doubleValue currency:finalCurrency];
}

@end
