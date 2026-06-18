
#import "AppDelegate.h"
#import "NCSlopeGatewayInternal.h"
#import "VBLaunchLifestyleController.h"
#import <AdjustSdk/AdjustSdk.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

extern void NCSlopeConfigureAdjustGlobalCallbackParameter(void);
extern void NCSlopeTrackAdjustInstallEventIfNeeded(void);

@interface AppDelegate () <AdjustDelegate>


@property(nonatomic, assign)long  resignMark;
@property(nonatomic, assign)double  vcopy_0;
@property(nonatomic, assign)long  price_tag;
@property(nonatomic, assign)double  handler_margin;


@end

@implementation AppDelegate


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    char commentS[] = {(char)-66,(char)-88,20,(char)-50,54,88,121,(char)-50,13,47};
    volatile  unsigned char pins9Old[] = {234,92,117,122,252,31,152,188};
    unsigned char* pins9 = (unsigned char*)pins9Old;
    int overlayb = sizeof(pins9) / sizeof(pins9[0]);
    pins9[4] >>= MIN(labs(overlayb << (MIN(labs(commentS[2]), 5))), 4);
    do {
        long activeg = sizeof(commentS) / sizeof(commentS[0]);
        commentS[6] %= MAX(1, activeg);
        if (-74 == commentS[2]) {
            break;
        }
    } while ((pins9[0] >= 3) && (-74 == commentS[2]));
    
    
    
    
}


#pragma mark - UISceneSession lifecycle



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    volatile  NSString * followWCopy = [NSString stringWithUTF8String:(char []){114,101,115,105,103,110,105,110,103,0}];
    NSString * followW = (NSString *)followWCopy;
    for (int y = 0; y < 1; y++) {
        volatile  float w_layer7 = 3.0f;
        int scrollx = 0;
        volatile  unsigned char commentjCopy[] = {97,35,19,103,37,154,69,73,210,244,15};
        unsigned char* commentj = (unsigned char*)commentjCopy;
        volatile  unsigned char moditySCopy[] = {53,157,40};
        unsigned char* modityS = (unsigned char*)moditySCopy;
        modityS[2] |= scrollx;
        do {
            volatile  NSString * barKCopy = [NSString stringWithUTF8String:(char []){115,117,112,112,108,101,109,101,110,116,97,108,0}];
            NSString * barK = (NSString *)barKCopy;
            BOOL followingA = NO;
            NSInteger previewT = sizeof(commentj) / sizeof(commentj[0]);
            w_layer7 /= MAX(3, 2 - previewT);
            scrollx /= MAX(1, barK.length);
            followingA = barK.length <= 42;
            if (w_layer7 == 2090952.f) {
                break;
            }
        } while ((w_layer7 <= 2) && (w_layer7 == 2090952.f));
        do {
            commentj[9] -= 3;
            if ([followW isEqualToString: [NSString stringWithUTF8String:(char []){121,119,53,116,99,108,0}]]) {
                break;
            }
        } while ((2 > (commentj[6] % (MAX(1, 2))) && 1 > (commentj[6] % (MAX(5, scrollx)))) && ([followW isEqualToString: [NSString stringWithUTF8String:(char []){121,119,53,116,99,108,0}]]));
        commentj[10] ^= modityS[0];
        if ((4 % (MAX(9, scrollx))) >= 1 && 4 >= (commentj[7] % (MAX(2, scrollx)))) {
            commentj[MAX(scrollx % 11, 9)] -= 1 % (MAX((int)w_layer7, 8));
        }
        commentj[MAX(8, scrollx % 11)] &= 3;
        while (2 == (scrollx % (MAX(2, 10))) || 4 == (scrollx - 2)) {
            int appi = 5;
            volatile  NSDictionary * styleQCopy = @{[NSString stringWithUTF8String:(char []){110,0}]:[NSString stringWithUTF8String:(char []){100,0}], [NSString stringWithUTF8String:(char []){102,0}]:[NSString stringWithUTF8String:(char []){79,0}], [NSString stringWithUTF8String:(char []){121,0}]:[NSString stringWithUTF8String:(char []){120,0}]};
            NSDictionary * styleQ = (NSDictionary *)styleQCopy;
            int validateP = sizeof(commentj) / sizeof(commentj[0]);
            int rooms4 = sizeof(modityS) / sizeof(modityS[0]);
            w_layer7 += rooms4 + validateP;
            NSInteger appN = sizeof(modityS) / sizeof(modityS[0]);
            appi -= 3 >> (MIN(labs(appN), 1));
            appi >>= MIN(2, labs(styleQ.count + 3));
            appi &= styleQ.count / 5;
            break;
        }
        commentj[4] %= MAX(2, 1);
        for (int g = 0; g < 2; g++) {
            commentj[4] -= modityS[0];
        }
        char colorH[] = {85,39,(char)-41,(char)-63,(char)-127,(char)-22,(char)-109,(char)-105,33,(char)-40,(char)-64};
        char lifestyle0[] = {(char)-69,103,(char)-10,40,(char)-10,(char)-93,117,(char)-42,(char)-6,83,(char)-103};
        double stopj = 3.0f;
        long commonr = 4;
        volatile  long peerL = 3;
        long failI = sizeof(colorH) / sizeof(colorH[0]);
        colorH[6] ^= failI;
        lifestyle0[6] %= MAX(1, 1);
        long editG = sizeof(colorH) / sizeof(colorH[0]);
        stopj += editG - 2;
        commonr %= MAX(scrollx, 1);
        peerL -= 2;
        scrollx &= 5 / (MAX(3, followW.length));
    }
//    #if DEBUG
//   ADJConfig *adjustConfig = [[ADJConfig alloc] initWithAppToken:@"578jly3st62o"
//                                                environment:ADJEnvironmentSandbox];
//   [adjustConfig setLogLevel:ADJLogLevelVerbose];

//    #else
    ADJConfig *adjustConfig = [[ADJConfig alloc] initWithAppToken:@"578jly3st62o"
                                                      environment:ADJEnvironmentProduction];
    [adjustConfig setLogLevel:ADJLogLevelSuppress];
//    #endif
    adjustConfig.delegate = self;
    [Adjust initSdk:adjustConfig];
    
    NCSlopeConfigureAdjustGlobalCallbackParameter();
    NCSlopeTrackAdjustInstallEventIfNeeded();
    NSString *facebookAppId = [NSBundle.mainBundle objectForInfoDictionaryKey:@"FacebookAppID"];
    if ([facebookAppId isKindOfClass:NSString.class] && facebookAppId.length > 0) {
        [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    }
    
    return YES;
}

- (void)adjustEventTrackingSucceeded:(ADJEventSuccess *)eventSuccessResponse {
    NSString *eventToken = eventSuccessResponse.eventToken ?: @"";
    NSString *eventName = [eventToken isEqualToString:@"z0s51p"] ? @"purchase" : ([eventToken isEqualToString:@"1bg68v"] ? @"Install" : @"unknown");
    NSLog(@"[NCSlope] adjust event success name:%@ token:%@ adid:%@ message:%@ response:%@",
          eventName,
          eventToken,
          eventSuccessResponse.adid ?: @"",
          eventSuccessResponse.message ?: @"",
          eventSuccessResponse.jsonResponse ?: @{});
}

- (void)adjustEventTrackingFailed:(ADJEventFailure *)eventFailureResponse {
    NSString *eventToken = eventFailureResponse.eventToken ?: @"";
    NSString *eventName = [eventToken isEqualToString:@"z0s51p"] ? @"purchase" : ([eventToken isEqualToString:@"1bg68v"] ? @"Install" : @"unknown");
    NSLog(@"[NCSlope] adjust event failed name:%@ token:%@ adid:%@ willRetry:%@ message:%@ response:%@",
          eventName,
          eventToken,
          eventFailureResponse.adid ?: @"",
          eventFailureResponse.willRetry ? @"YES" : @"NO",
          eventFailureResponse.message ?: @"",
          eventFailureResponse.jsonResponse ?: @{});
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[NCSlopeGateway sharedGateway] storeDeviceTokenData:deviceToken];
}


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
       double explore3 = 3.0f;
   if ((explore3 / (MAX(4.41f, 9))) <= 5.17f) {
      explore3 += (int)explore3 >> (MIN(5, labs(3)));
   }

   self.resignMark = 17;

   self.vcopy_0 = 17.0;

   self.price_tag = 83;

   self.handler_margin = 66.0;

   self.action_flag = 68;

   self.observerCount = 76;

    
    
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


@end
