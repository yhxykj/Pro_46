#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NCReceiptCoordinator : NSObject

+ (instancetype)sharedCoordinator;
- (void)beginObservation;
- (void)startProductFlowWithIdentifier:(NSString *)productId orderCode:(NSString *)orderCode;

- (void)reportPurchaseEventWithOrderCode:(NSString *)orderCode transactionId:(NSString *)transactionId;

@end

NS_ASSUME_NONNULL_END
