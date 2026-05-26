//
//  CoinBalanceStore.h
//  Skiing
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const CoinBalanceStoreDidChangeNotification;

@interface CoinBalanceStore : NSObject

+ (NSInteger)currentBalance;
+ (BOOL)creditCoins:(NSInteger)coins transactionIdentifier:(NSString *)transactionIdentifier;
+ (BOOL)spendCoins:(NSInteger)coins;

@end

NS_ASSUME_NONNULL_END
