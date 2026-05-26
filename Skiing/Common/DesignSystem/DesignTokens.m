//
//  DesignTokens.m
//  Skiing
//

#import "DesignTokens.h"

@implementation DesignFonts

+ (UIFont *)semibold:(CGFloat)size {
    return [UIFont systemFontOfSize:size weight:UIFontWeightSemibold];
}

+ (UIFont *)regular:(CGFloat)size {
    return [UIFont systemFontOfSize:size weight:UIFontWeightRegular];
}

@end

@implementation DesignColors

+ (UIColor *)fieldBackground {
    return [UIColor colorWithWhite:1.0 alpha:kFieldAlpha];
}

+ (UIColor *)linkColor {
    return [UIColor colorWithRed:0.4 green:0.4 blue:1.0 alpha:1.0];
}

@end
