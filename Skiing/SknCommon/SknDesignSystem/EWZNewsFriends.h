
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static const CGFloat kHorizontalPadding  = 24.0;
static const CGFloat kFieldHeight        = 56.0;
static const CGFloat kFieldCornerRadius  = 24.0;
static const CGFloat kFieldAlpha         = 0.6;
static const CGFloat kIconSize           = 22.0;
static const CGFloat kButtonHeight       = 50.0;
static const CGFloat kLabelIconSpacing   = 8.0;
static const CGFloat kFieldLabelSpacing  = 8.0;
static const CGFloat kSectionSpacing     = 24.0;
static const CGFloat kBackButtonSize     = 36.0;

@interface BGRecharge : NSObject

@property(nonatomic, assign)NSInteger  lifestyleTag;
@property(nonatomic, assign)float  stringMin;
@property(nonatomic, copy)NSString *  register_oPrice_string;
@property(nonatomic, copy)NSString *  mainBlockedPlayerStr;

+ (UIFont *)semibold:(CGFloat)size;
+ (UIFont *)regular:(CGFloat)size;
@end

@interface CLNUnlock : NSObject

@property(nonatomic, copy)NSArray *  identifierExploreProducts_arr;
@property(nonatomic, assign)double  this_v;
@property(nonatomic, assign)long  images_tag;
@property(nonatomic, copy)NSString *  videoFollowRechargeStr;




+(NSArray *)starFinishCost:(double)requestNext;

+(long)shadowAvailablePlayRelationshipAlpha:(NSArray *)shownPublish moditySetup:(NSDictionary *)moditySetup;


+ (UIColor *)fieldBackground;
+ (UIColor *)linkColor;
@end

NS_ASSUME_NONNULL_END
