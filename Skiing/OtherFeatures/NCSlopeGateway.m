#import "NCSlopeGatewayInternal.h"

#import "NCCipherBox.h"
#import "NCAdjustEventReporter.h"
#import "NCEntryPanelController.h"
#import "NCLaunchCoverController.h"
#import "NCNoticeHUD.h"
#import "NCPayloadPipe.h"
#import "NCReceiptCoordinator.h"
#import "NCSlopeFeatureContext.h"
#import "NCSlopeWebController.h"

#import <UserNotifications/UserNotifications.h>

void NCSlopeActivateFeatureFromScene(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NCSlopeGateway sharedGateway] activateFeature];
    });
}

@implementation NCSlopeGateway

+ (instancetype)sharedGateway {
    static NCSlopeGateway *gateway = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gateway = [[NCSlopeGateway alloc] init];
    });
    return gateway;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _entryURLString = @"";
    }
    return self;
}

- (void)activateFeature {
    (void)NCSlopeRouteAppName;
    (void)NCSlopeGatewayBaseURL();

    [self requestNotificationThenResolveEntry];
    [self presentCoverWindow];
}

- (void)presentCoverWindow {
    UIWindowScene *targetScene = nil;
    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if ([scene isKindOfClass:UIWindowScene.class]) {
            targetScene = (UIWindowScene *)scene;
            break;
        }
    }

    self.overlayWindow = targetScene ? [[UIWindow alloc] initWithWindowScene:targetScene] : [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.overlayWindow.windowLevel = UIWindowLevelNormal + 1;
    self.overlayWindow.rootViewController = [[NCLaunchCoverController alloc] init];
    [self.overlayWindow makeKeyAndVisible];

    [[NCReceiptCoordinator sharedCoordinator] beginObservation];
}

- (void)requestNotificationThenResolveEntry {
    [UNUserNotificationCenter.currentNotificationCenter requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIApplication.sharedApplication registerForRemoteNotifications];
            });
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [NCNoticeHUD showLoading];
        });

        [self probeGatewayAtAttempt:0 maxAttempt:5 completion:^(BOOL reachable) {
            if (reachable) {
                [self fetchEntryStateWithCompletion:^(BOOL shouldContinue) {
                    if (!shouldContinue) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.overlayWindow.hidden = YES;
                            self.overlayWindow = nil;
                        });
                    }
                }];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NCNoticeHUD hideLoading];
                    self.overlayWindow.hidden = YES;
                    self.overlayWindow = nil;
                });
            }
        }];
    }];
}

- (void)probeGatewayAtAttempt:(NSInteger)attempt maxAttempt:(NSInteger)maxAttempt completion:(void (^)(BOOL reachable))completion {
    NSURL *url = [NSURL URLWithString:NCSlopeGatewayBaseURL()];
    if (!url) {
        completion(NO);
        return;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 2;
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error && response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES);
            });
            return;
        }

        if (attempt + 1 >= maxAttempt) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO);
            });
            return;
        }

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self probeGatewayAtAttempt:attempt + 1 maxAttempt:maxAttempt completion:completion];
        });
    }];
    [task resume];
}

- (void)storeDeviceTokenData:(NSData *)deviceToken {
    const unsigned char *bytes = deviceToken.bytes;
    NSMutableString *token = [NSMutableString stringWithCapacity:deviceToken.length * 2];
    for (NSUInteger index = 0; index < deviceToken.length; index++) {
        [token appendFormat:@"%02.2hhx", bytes[index]];
    }
    NCSlopeRoutePushToken = token;
}

- (void)fetchEntryStateWithCompletion:(void (^)(BOOL shouldContinue))completion {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"loktict"] = NSTimeZone.localTimeZone.name ?: @"";

    NSMutableArray *languages = [NSMutableArray array];
    for (UITextInputMode *mode in UITextInputMode.activeInputModes) {
        if (mode.primaryLanguage.length > 0) {
            [languages addObject:mode.primaryLanguage];
        }
    }
    parameters[@"loktick"] = languages;
    parameters[@"lokticg"] = NCSlopeRouteVerboseLog ? @1 : @0;
    parameters[@"lokticd"] = NCSlopeCellularRadioAvailable() ? @1 : @0;
    parameters[@"lokticn"] = NCSlopeProxyLooksLikeVPN() ? @1 : @0;

    [NCNoticeHUD showLoading];
    [NCPayloadPipe sendPath:@"opi/v1/loktico" parameters:parameters plainReply:NO completion:^(NSDictionary * _Nullable payload, BOOL finished) {
        if (!finished) {
            completion(NO);
            return;
        }

        NSNumber *loginFlag = [payload[@"loginFlag"] isKindOfClass:NSNumber.class] ? payload[@"loginFlag"] : nil;
        if (!loginFlag) {
            completion(NO);
            return;
        }

        if (loginFlag.integerValue == 0) {
            self.entryURLString = [payload[@"openValue"] isKindOfClass:NSString.class] ? payload[@"openValue"] : @"";
            NSNumber *locationFlag = [payload[@"locationFlag"] isKindOfClass:NSNumber.class] ? payload[@"locationFlag"] : nil;
            if (locationFlag && locationFlag.integerValue == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NCNoticeHUD hideLoading];
                    NCEntryPanelController *panel = [[NCEntryPanelController alloc] init];
                    panel.hidesBottomBarWhenPushed = YES;
                    self.overlayWindow.rootViewController = [[UINavigationController alloc] initWithRootViewController:panel];
                });
            } else {
                [NCNoticeHUD hideLoading];
                completion(NO);
            }
            return;
        }

        if (loginFlag.integerValue == 1) {
            self.entryURLString = [payload[@"openValue"] isKindOfClass:NSString.class] ? payload[@"openValue"] : @"";
            [self openProtectedWebFlow];
            return;
        }

        completion(NO);
    }];
}

- (void)requestBackupCredentialWithCompletion:(void (^)(BOOL finished))completion {
    [NCAdjustEventReporter currentAdidWithCompletion:^(NSString *adid) {
        NSDictionary *parameters = @{
            @"loktice": @"",
            @"lokticl": @"",
            @"lokticu": UIDevice.currentDevice.identifierForVendor.UUIDString ?: @"",
            @"a": adid ?: @""
        };
        [NCPayloadPipe sendPath:@"opi/v1/lokticd" parameters:parameters plainReply:NO completion:^(NSDictionary * _Nullable payload, BOOL finished) {
            if (finished) {
                NSString *token = [payload[@"token"] isKindOfClass:NSString.class] ? payload[@"token"] : nil;
                NSString *password = [payload[@"password"] isKindOfClass:NSString.class] ? payload[@"password"] : nil;
                if (token.length > 0) {
                    NCSlopeKeychainSave(token, NCSlopeStoredLoginKey);
                }
                if (password.length > 0) {
                    NCSlopeKeychainSave(password, NCSlopeStoredPasswordKey);
                }
                [self openProtectedWebFlow];
            }
            completion(finished);
        }];
    }];
}

- (void)performFastEntry {
    [NCNoticeHUD showLoading];
    [NCAdjustEventReporter currentAdidWithCompletion:^(NSString *adid) {
        NSDictionary *parameters = @{
            @"lokticd": NCSlopeKeychainRead(NCSlopeStoredLoginKey) ?: @"",
            @"lokticn": UIDevice.currentDevice.identifierForVendor.UUIDString ?: @"",
            @"yfhsfa": adid ?: @""
        };

        [NCPayloadPipe sendPath:@"opi/v1/opckiol" parameters:parameters plainReply:NO completion:^(NSDictionary * _Nullable payload, BOOL finished) {
            if (finished) {
                NSString *token = [payload[@"token"] isKindOfClass:NSString.class] ? payload[@"token"] : nil;
                NSString *password = [payload[@"password"] isKindOfClass:NSString.class] ? payload[@"password"] : nil;
                if (token.length > 0) {
                    NCSlopeKeychainSave(token, NCSlopeStoredLoginKey);
                }
                if (password.length > 0) {
                    NCSlopeKeychainSave(password, NCSlopeStoredPasswordKey);
                }
                if (NCSlopeRouteVerboseLog) {
                    NSLog(@"%@", payload);
                }
                [self openProtectedWebFlow];
            }
            NCSlopeTapLocked = NO;
        }];
    }];
}

- (void)openProtectedWebFlow {
    [NCNoticeHUD showLoading];
    NSString *token = NCSlopeKeychainRead(NCSlopeStoredLoginKey);
    if (token.length == 0) {
        [NCNoticeHUD hideLoading];
        NCSlopeTapLocked = NO;
        return;
    }

    NSDictionary *encryptedPayload = @{
        @"token": token,
        @"timestamp": [NSString stringWithFormat:@"%lld", NCSlopeNowMilliseconds()]
    };
    NSString *encryptedText = [NCCipherBox encryptedHexStringFromText:NCSlopeJSONTextFromObject(encryptedPayload)] ?: @"";
    NSString *urlString = [NSString stringWithFormat:@"%@/?openParams=%@&appId=%@", self.entryURLString ?: @"", encryptedText, NCSlopeRouteAppId];

    dispatch_async(dispatch_get_main_queue(), ^{
        
        NCSlopeWebController *webController = [[NCSlopeWebController alloc] initWithURLString:urlString];
        webController.hidesBottomBarWhenPushed = YES;
        self.overlayWindow.rootViewController = [[UINavigationController alloc] initWithRootViewController:webController];
    });
}

@end
