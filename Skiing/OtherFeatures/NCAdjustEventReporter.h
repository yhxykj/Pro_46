#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NCAdjustEventReporter : NSObject

+ (void)configureGlobalCallbackParameter;
+ (void)currentAdidWithCompletion:(void (^)(NSString *adid))completion;
+ (void)currentAttributionJSONTextWithCompletion:(void (^)(NSString *jsonText))completion;
+ (void)logPurchaseWithPrice:(NSDecimalNumber *)price currency:(NSString *)currency;
+ (void)logPurchaseWithPrice:(NSDecimalNumber *)price currency:(NSString *)currency transactionId:(nullable NSString *)transactionId;

@end

void NCSlopeConfigureAdjustGlobalCallbackParameter(void);

NS_ASSUME_NONNULL_END
