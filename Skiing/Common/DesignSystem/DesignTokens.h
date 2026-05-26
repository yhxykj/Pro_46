//
//  DesignTokens.h
//  Skiing
//

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

@interface DesignFonts : NSObject
+ (UIFont *)semibold:(CGFloat)size;
+ (UIFont *)regular:(CGFloat)size;
@end

@interface DesignColors : NSObject
+ (UIColor *)fieldBackground;
+ (UIColor *)linkColor;
@end

NS_ASSUME_NONNULL_END
