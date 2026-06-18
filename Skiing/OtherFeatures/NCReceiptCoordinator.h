#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NCReceiptCoordinator : NSObject

+ (instancetype)sharedCoordinator;
- (void)beginObservation;
- (void)startProductFlowWithIdentifier:(NSString *)productId orderCode:(NSString *)orderCode;

- (void)reportPurchaseEventWithOrderCode:(NSString *)orderCode transactionId:(NSString *)transactionId;

- (void)submitReceiptForTransaction:(SKPaymentTransaction *)transaction receiptText:(NSString *)receiptText;

@end

NS_ASSUME_NONNULL_END
