//
//  UILabel+TapRange.h
//  Skiing
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (TapRange)
- (BOOL)didTapRange:(NSRange)range inGesture:(UITapGestureRecognizer *)gesture;
@end

@interface NSMutableAttributedString (Link)
- (NSRange)addLinkToSubstring:(NSString *)substring color:(nullable UIColor *)color;
@end

NS_ASSUME_NONNULL_END
