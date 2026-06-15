
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WStateView : UIView


@property(nonatomic, assign)long  loadingMark;
@property(nonatomic, assign)long  micIndex;
@property(nonatomic, assign)long  backgroundTag;
@property(nonatomic, assign)int  costSum;




-(UIImageView *)recordDurationPriceSkyPropertyImageView:(BOOL)stringHome backgroundText:(NSInteger)backgroundText usernameCompletion:(NSInteger)usernameCompletion;


@property (nonatomic, assign) CGFloat contentCenterYOffset;

- (instancetype)initWithText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
