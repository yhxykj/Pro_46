#import "NCSlopeFeatureContext.h"

#import <Security/Security.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <UIKit/UIKit.h>

NSString * const NCSlopeRouteAppName = @"Loktic";
NSString * const NCSlopeRouteAppId = @"62313062";
NSString * const NCSlopeRouteAesKey = @"nm4pq5yxmp230cgp";
NSString * const NCSlopeRouteAesVector = @"74ba2f09otf1uya3";
NSString * const NCSlopeRouteLaunchImage = @"showingOutgoing";
NSString * const NCSlopeRouteLoginImage = @"iuhkdsbkhj";
NSString * const NCSlopeStoredDeviceKey = @"lokticdev";
NSString * const NCSlopeStoredLoginKey = @"loktictoko";
NSString * const NCSlopeStoredPasswordKey = @"lokticpend";

BOOL NCSlopeRouteVerboseLog = YES; // 判断是否输出日志
NSString *NCSlopeRouteBaseURL = nil;
NSString *NCSlopeRoutePushToken = nil;
BOOL NCSlopeTapLocked = NO;

long long NCSlopeNowMilliseconds(void) {
    return (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
}

NSString *NCSlopeGatewayBaseURL(void) {
    if (NCSlopeRouteBaseURL.length == 0) {
        NCSlopeRouteBaseURL = [NSString stringWithFormat:@"https://opi.390uafuu.link"];
    }
    return NCSlopeRouteBaseURL;
}

NSString *NCSlopeJSONTextFromObject(id object) {
    if (!object || ![NSJSONSerialization isValidJSONObject:object]) {
        return @"";
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:0 error:nil];
    if (!data) {
        return @"";
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ?: @"";
}

NSDictionary *NCSlopeDictionaryFromJSONText(NSString *text) {
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        return nil;
    }
    id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return [object isKindOfClass:NSDictionary.class] ? object : nil;
}

NSString *NCSlopeJSONStringLiteral(NSString *text) {
    NSData *data = [NSJSONSerialization dataWithJSONObject:@[text ?: @""] options:0 error:nil];
    NSString *arrayText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ?: @"[\"\"]";
    if (arrayText.length >= 2) {
        return [arrayText substringWithRange:NSMakeRange(1, arrayText.length - 2)];
    }
    return @"\"\"";
}

NSData *NCSlopeDataFromHexString(NSString *hexString) {
    NSMutableData *data = [NSMutableData data];
    NSMutableString *pair = [NSMutableString stringWithCapacity:2];
    for (NSUInteger index = 0; index < hexString.length; index++) {
        unichar character = [hexString characterAtIndex:index];
        [pair appendFormat:@"%C", character];
        if (pair.length == 2) {
            unsigned int value = 0;
            NSScanner *scanner = [NSScanner scannerWithString:pair];
            if (![scanner scanHexInt:&value]) {
                return nil;
            }
            UInt8 byte = (UInt8)value;
            [data appendBytes:&byte length:1];
            [pair setString:@""];
        }
    }
    return pair.length == 0 ? data : nil;
}

NSString *NCSlopeHexStringFromData(NSData *data) {
    const unsigned char *bytes = data.bytes;
    NSMutableString *text = [NSMutableString stringWithCapacity:data.length * 2];
    for (NSUInteger index = 0; index < data.length; index++) {
        [text appendFormat:@"%02x", bytes[index]];
    }
    return text;
}

void NCSlopeKeychainSave(NSString *value, NSString *key) {
    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
    if (!data || key.length == 0) {
        return;
    }
    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrAccount: key,
        (__bridge id)kSecValueData: data
    };
    SecItemDelete((__bridge CFDictionaryRef)query);
    SecItemAdd((__bridge CFDictionaryRef)query, nil);
}

NSString *NCSlopeKeychainRead(NSString *key) {
    if (key.length == 0) {
        return nil;
    }
    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrAccount: key,
        (__bridge id)kSecReturnData: @YES,
        (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitOne
    };
    CFTypeRef result = nil;
    SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    NSData *data = CFBridgingRelease(result);
    if (![data isKindOfClass:NSData.class]) {
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

void NCSlopeKeychainRemove(NSString *key) {
    if (key.length == 0) {
        return;
    }
    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrAccount: key
    };
    SecItemDelete((__bridge CFDictionaryRef)query);
}

NSString *NCSlopeCurrentDeviceIdentifier(void) {
    NSString *deviceId = NCSlopeKeychainRead(NCSlopeStoredDeviceKey);
    if (deviceId.length > 0) {
        return deviceId;
    }

    deviceId = UIDevice.currentDevice.identifierForVendor.UUIDString ?: @"132";
    NCSlopeKeychainSave(deviceId, NCSlopeStoredDeviceKey);
    return deviceId;
}

BOOL NCSlopeCellularRadioAvailable(void) {
    Class telephonyClass = NSClassFromString(@"CTTelephonyNetworkInfo");
    if (!telephonyClass) {
        return NO;
    }
    id info = [[telephonyClass alloc] init];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL serviceSelector = NSSelectorFromString(@"serviceCurrentRadioAccessTechnology");
    if (@available(iOS 12.0, *)) {
        if ([info respondsToSelector:serviceSelector]) {
            id serviceInfo = [info performSelector:serviceSelector];
            if ([serviceInfo isKindOfClass:NSDictionary.class]) {
                return [serviceInfo allValues].count > 0;
            }
        }
    }

    SEL radioSelector = NSSelectorFromString(@"currentRadioAccessTechnology");
    if ([info respondsToSelector:radioSelector]) {
        return [info performSelector:radioSelector] != nil;
    }
#pragma clang diagnostic pop
    return NO;
}

BOOL NCSlopeProxyLooksLikeVPN(void) {
    NSDictionary *settings = CFBridgingRelease(CFNetworkCopySystemProxySettings());
    NSDictionary *scoped = settings[@"__SCOPED__"];
    if (![scoped isKindOfClass:NSDictionary.class]) {
        return NO;
    }
    NSArray<NSString *> *markers = @[@"tap", @"tun", @"ppp", @"ipsec", @"utun"];
    for (NSString *key in scoped.allKeys) {
        NSString *lowerKey = key.lowercaseString;
        for (NSString *marker in markers) {
            if ([lowerKey containsString:marker]) {
                return YES;
            }
        }
    }
    return NO;
}
