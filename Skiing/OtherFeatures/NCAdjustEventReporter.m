#import "NCAdjustEventReporter.h"

#import "NCSlopeFeatureContext.h"

#import <AdjustSdk/ADJAttribution.h>
#import <AdjustSdk/AdjustSdk.h>

// Replace this with the Adjust dashboard purchase event token.
static NSString * const NCAdjustPurchaseEventToken = @"";

@implementation NCAdjustEventReporter

+ (void)configureGlobalCallbackParameter {
    NSString *distinctId = NCSlopeCurrentDeviceIdentifier();
    if (distinctId.length == 0) {
        return;
    }
    [Adjust addGlobalCallbackParameter:distinctId forKey:@"ta_distinct_id"];
}

+ (void)currentAdidWithCompletion:(void (^)(NSString *adid))completion {
    if (!completion) {
        return;
    }
    [Adjust adidWithTimeout:3000 completionHandler:^(NSString * _Nullable adid) {
        completion(adid ?: @"");
    }];
}

+ (void)currentAttributionJSONTextWithCompletion:(void (^)(NSString *jsonText))completion {
    if (!completion) {
        return;
    }
    [Adjust attributionWithTimeout:3000 completionHandler:^(ADJAttribution * _Nullable attribution) {
        NSDictionary *rawPayload = [attribution.jsonResponse isKindOfClass:NSDictionary.class] ? attribution.jsonResponse : nil;
        NSDictionary *fallbackPayload = [attribution.dictionary isKindOfClass:NSDictionary.class] ? attribution.dictionary : nil;
        completion(NCSlopeJSONTextFromObject(rawPayload ?: fallbackPayload ?: @{}));
    }];
}

+ (void)logPurchaseWithPrice:(NSDecimalNumber *)price currency:(NSString *)currency {
    [self logPurchaseWithPrice:price currency:currency transactionId:nil];
}

+ (void)logPurchaseWithPrice:(NSDecimalNumber *)price currency:(NSString *)currency transactionId:(NSString *)transactionId {
    if (NCAdjustPurchaseEventToken.length == 0 || price.doubleValue <= 0) {
        return;
    }

    ADJEvent *event = [[ADJEvent alloc] initWithEventToken:NCAdjustPurchaseEventToken];
    if (!event) {
        return;
    }
    [event setRevenue:price.doubleValue currency:(currency.length > 0 ? currency : @"USD")];
    if (transactionId.length > 0) {
        [event setTransactionId:transactionId];
    }
    [Adjust trackEvent:event];
}

@end

void NCSlopeConfigureAdjustGlobalCallbackParameter(void) {
    [NCAdjustEventReporter configureGlobalCallbackParameter];
}
