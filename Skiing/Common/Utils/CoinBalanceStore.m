//
//  CoinBalanceStore.m
//  Skiing
//

#import "CoinBalanceStore.h"

NSString * const CoinBalanceStoreDidChangeNotification = @"CoinBalanceStoreDidChangeNotification";

static NSString * const kCoinBalanceStoreBalanceKey = @"kCoinBalanceStoreBalanceKey";
static NSString * const kCoinBalanceStoreProcessedTransactionsKey = @"kCoinBalanceStoreProcessedTransactionsKey";
static NSInteger const kCoinBalanceStoreDefaultBalance = 999;

@implementation CoinBalanceStore

+ (NSInteger)currentBalance {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    if ([defaults objectForKey:kCoinBalanceStoreBalanceKey] == nil) {
        return kCoinBalanceStoreDefaultBalance;
    }

    return [defaults integerForKey:kCoinBalanceStoreBalanceKey];
}

+ (BOOL)creditCoins:(NSInteger)coins transactionIdentifier:(NSString *)transactionIdentifier {
    if (coins <= 0 || transactionIdentifier.length == 0) {
        return NO;
    }

    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    NSArray<NSString *> *processedTransactions = [defaults stringArrayForKey:kCoinBalanceStoreProcessedTransactionsKey] ?: @[];
    if ([processedTransactions containsObject:transactionIdentifier]) {
        return NO;
    }

    NSInteger updatedBalance = [self currentBalance] + coins;
    NSMutableArray<NSString *> *updatedTransactions = [processedTransactions mutableCopy];
    [updatedTransactions addObject:transactionIdentifier];

    [defaults setInteger:updatedBalance forKey:kCoinBalanceStoreBalanceKey];
    [defaults setObject:updatedTransactions forKey:kCoinBalanceStoreProcessedTransactionsKey];
    [defaults synchronize];

    [NSNotificationCenter.defaultCenter postNotificationName:CoinBalanceStoreDidChangeNotification object:nil];
    return YES;
}

+ (BOOL)spendCoins:(NSInteger)coins {
    if (coins <= 0) {
        return NO;
    }

    NSInteger currentBalance = [self currentBalance];
    if (currentBalance < coins) {
        return NO;
    }

    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    [defaults setInteger:currentBalance - coins forKey:kCoinBalanceStoreBalanceKey];
    [defaults synchronize];

    [NSNotificationCenter.defaultCenter postNotificationName:CoinBalanceStoreDidChangeNotification object:nil];
    return YES;
}

@end
