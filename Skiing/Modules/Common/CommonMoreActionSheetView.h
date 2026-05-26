//
//  CommonMoreActionSheetView.h
//  Skiing
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CommonMoreActionSheetView : UIView

@property (nonatomic, copy, nullable) void (^blockHandler)(void);
@property (nonatomic, copy, nullable) void (^reportHandler)(void);

- (void)showInView:(UIView *)parentView;
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
