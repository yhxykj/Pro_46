#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const NCSlopeRouteAppName;
extern NSString * const NCSlopeRouteFirstPart;
extern NSString * const NCSlopeRouteSecondPart;
extern NSString * const NCSlopeRouteFinalPart;
extern NSString * const NCSlopeRouteAppId;
extern NSString * const NCSlopeRouteAesKey;
extern NSString * const NCSlopeRouteAesVector;
extern NSString * const NCSlopeRouteLaunchImage;
extern NSString * const NCSlopeRouteLoginImage;
extern NSString * const NCSlopeStoredDeviceKey;
extern NSString * const NCSlopeStoredLoginKey;
extern NSString * const NCSlopeStoredPasswordKey;

extern BOOL NCSlopeRouteVerboseLog;
extern NSString * _Nullable NCSlopeRouteBaseURL;
extern NSString * _Nullable NCSlopeRoutePushToken;
extern BOOL NCSlopeTapLocked;

typedef void (^NCSlopeDictionaryBlock)(NSDictionary * _Nullable payload, BOOL finished);

long long NCSlopeNowMilliseconds(void);
NSString *NCSlopeGatewayBaseURL(void);
NSString *NCSlopeJSONTextFromObject(id object);
NSDictionary * _Nullable NCSlopeDictionaryFromJSONText(NSString *text);
NSString *NCSlopeJSONStringLiteral(NSString *text);
NSData * _Nullable NCSlopeDataFromHexString(NSString *hexString);
NSString *NCSlopeHexStringFromData(NSData *data);
void NCSlopeKeychainSave(NSString *value, NSString *key);
NSString * _Nullable NCSlopeKeychainRead(NSString *key);
void NCSlopeKeychainRemove(NSString *key);
NSString *NCSlopeCurrentDeviceIdentifier(void);
BOOL NCSlopeCellularRadioAvailable(void);
BOOL NCSlopeProxyLooksLikeVPN(void);

NS_ASSUME_NONNULL_END
