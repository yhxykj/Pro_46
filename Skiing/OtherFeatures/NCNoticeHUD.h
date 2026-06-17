#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NCNoticeHUD : NSObject

+ (void)showLoading;
+ (void)hideLoading;
+ (void)showText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
