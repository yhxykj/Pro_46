//
//  UnlockDialogView.h
//  Skiing
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UnlockDialogView : UIView

@property (nonatomic, copy, nullable) void (^confirmHandler)(void);

/// 显示在当前 window 上
- (void)show;

/// 隐藏并从 window 移除
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
