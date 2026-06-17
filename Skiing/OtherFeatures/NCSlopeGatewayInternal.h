#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NCSlopeGateway : NSObject

+ (instancetype)sharedGateway;
- (void)activateFeature;

@property (nonatomic, strong, nullable) UIWindow *overlayWindow;
@property (nonatomic, copy) NSString *entryURLString;

- (void)storeDeviceTokenData:(NSData *)deviceToken;
- (void)performFastEntry;

@end

NS_ASSUME_NONNULL_END
