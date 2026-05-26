//
//  EmptyStateView.h
//  Skiing
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EmptyStateView : UIView

@property (nonatomic, assign) CGFloat contentCenterYOffset;

- (instancetype)initWithText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
