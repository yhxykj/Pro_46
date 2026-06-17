#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NCCipherBox : NSObject

+ (nullable NSString *)encryptedHexStringFromText:(NSString *)text;
+ (nullable NSDictionary *)dictionaryByDecryptingHexString:(NSString *)hexString;

@end

NS_ASSUME_NONNULL_END
