#import "NCCipherBox.h"

#import "NCSlopeFeatureContext.h"

#import <CommonCrypto/CommonCrypto.h>

@implementation NCCipherBox

+ (NSString *)encryptedHexStringFromText:(NSString *)text {
    if (NCSlopeRouteAesKey.length != kCCKeySizeAES128 || NCSlopeRouteAesVector.length != kCCBlockSizeAES128) {
        return nil;
    }

    NSData *keyData = [NCSlopeRouteAesKey dataUsingEncoding:NSUTF8StringEncoding];
    NSData *ivData = [NCSlopeRouteAesVector dataUsingEncoding:NSUTF8StringEncoding];
    NSData *inputData = [text dataUsingEncoding:NSUTF8StringEncoding];
    if (!keyData || !ivData || !inputData) {
        return nil;
    }

    size_t bufferSize = inputData.length + kCCBlockSizeAES128;
    void *buffer = calloc(bufferSize, 1);
    size_t outputLength = 0;
    CCCryptorStatus status = CCCrypt(kCCEncrypt,
                                     kCCAlgorithmAES,
                                     kCCOptionPKCS7Padding,
                                     keyData.bytes,
                                     kCCKeySizeAES128,
                                     ivData.bytes,
                                     inputData.bytes,
                                     inputData.length,
                                     buffer,
                                     bufferSize,
                                     &outputLength);
    if (status != kCCSuccess) {
        free(buffer);
        return nil;
    }

    NSData *encryptedData = [NSData dataWithBytesNoCopy:buffer length:outputLength freeWhenDone:YES];
    return NCSlopeHexStringFromData(encryptedData);
}

+ (NSDictionary *)dictionaryByDecryptingHexString:(NSString *)hexString {
    if (NCSlopeRouteAesKey.length != kCCKeySizeAES128 || NCSlopeRouteAesVector.length != kCCBlockSizeAES128) {
        return nil;
    }

    NSData *encryptedData = NCSlopeDataFromHexString(hexString);
    NSData *keyData = [NCSlopeRouteAesKey dataUsingEncoding:NSUTF8StringEncoding];
    NSData *ivData = [NCSlopeRouteAesVector dataUsingEncoding:NSUTF8StringEncoding];
    if (!encryptedData || !keyData || !ivData) {
        return nil;
    }

    size_t bufferSize = encryptedData.length + kCCBlockSizeAES128;
    void *buffer = calloc(bufferSize, 1);
    size_t outputLength = 0;
    CCCryptorStatus status = CCCrypt(kCCDecrypt,
                                     kCCAlgorithmAES,
                                     kCCOptionPKCS7Padding,
                                     keyData.bytes,
                                     kCCKeySizeAES128,
                                     ivData.bytes,
                                     encryptedData.bytes,
                                     encryptedData.length,
                                     buffer,
                                     bufferSize,
                                     &outputLength);
    if (status != kCCSuccess) {
        free(buffer);
        return nil;
    }

    NSData *jsonData = [NSData dataWithBytesNoCopy:buffer length:outputLength freeWhenDone:YES];
    id object = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    return [object isKindOfClass:NSDictionary.class] ? object : nil;
}

@end
