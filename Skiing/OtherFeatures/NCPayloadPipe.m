#import "NCPayloadPipe.h"

#import "NCCipherBox.h"

#import <UIKit/UIKit.h>

@implementation NCPayloadPipe

+ (void)sendPath:(NSString *)path parameters:(NSDictionary *)parameters plainReply:(BOOL)plainReply completion:(NCSlopeDictionaryBlock)completion {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", NCSlopeGatewayBaseURL(), path ?: @""]];
    if (!url) {
        completion(nil, NO);
        return;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    request.HTTPMethod = @"POST";

    NSString *deviceNo = NCSlopeCurrentDeviceIdentifier();
    if (deviceNo.length > 0) {
        [request setValue:deviceNo forHTTPHeaderField:@"deviceNo"];
    }

    [request setValue:@"foxcs" forHTTPHeaderField:@"voicesl"];
    [request setValue:NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"] ?: @"" forHTTPHeaderField:@"appVersion"];
    [request setValue:@"file" forHTTPHeaderField:@"files"];
    [request setValue:NCSlopeRoutePushToken forHTTPHeaderField:@"pushToken"];
    [request setValue:NCSlopeRouteAppId forHTTPHeaderField:@"appId"];
    [request setValue:NCSlopeKeychainRead(NCSlopeStoredLoginKey) forHTTPHeaderField:@"loginToken"];

    if (parameters.count > 0) {
        NSString *encryptedText = [NCCipherBox encryptedHexStringFromText:NCSlopeJSONTextFromObject(parameters)];
        if (encryptedText.length > 0) {
            request.HTTPBody = [encryptedText dataUsingEncoding:NSUTF8StringEncoding];
        }
    }

    if (NCSlopeRouteVerboseLog) {
        NSLog(@"%@", request.allHTTPHeaderFields ?: @{});
        NSLog(@"%@", parameters ?: @{});
        NSLog(@"%@", url.absoluteString ?: @"");
    }

    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error || !data) {
            completion(nil, NO);
            return;
        }

        NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (text.length == 0) {
            completion(nil, NO);
            return;
        }

        if (NCSlopeRouteVerboseLog) {
            NSLog(@"%@", text);
        }

        NSDictionary *responseDictionary = NCSlopeDictionaryFromJSONText(text);
        if (!responseDictionary) {
            completion(nil, NO);
            return;
        }

        NSString *resultText = [responseDictionary[@"result"] isKindOfClass:NSString.class] ? responseDictionary[@"result"] : nil;
        if (resultText.length == 0) {
            if (NCSlopeRouteVerboseLog && plainReply) {
                NSLog(@"[NCSlope] plain response payload: %@", responseDictionary ?: @{});
            }
            completion(plainReply ? responseDictionary : nil, plainReply);
            return;
        }

        NSDictionary *decryptedDictionary = [NCCipherBox dictionaryByDecryptingHexString:resultText];
        if (NCSlopeRouteVerboseLog) {
            NSLog(@"[NCSlope] decrypted response payload: %@", decryptedDictionary ?: @{});
        }
        completion(decryptedDictionary, decryptedDictionary != nil);
    }];
    [task resume];
}

@end
