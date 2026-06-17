#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NCFacebookEventReporter : NSObject

+ (void)logPaymentStartWithPrice:(NSDecimalNumber *)price;
+ (void)logPaymentStartWithPrice:(NSDecimalNumber *)price currency:(NSString *)currency;
+ (void)logPurchaseWithPrice:(NSDecimalNumber *)price currency:(NSString *)currency;

@end

NS_ASSUME_NONNULL_END
