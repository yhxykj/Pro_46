//
//  CommentPanelView.h
//  Skiing
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CommentPanelView : UIView

@property (nonatomic, copy, nullable) void (^commentsDidChange)(NSInteger commentCount);

- (instancetype)initWithVideoIdentifier:(NSString *)videoIdentifier;

/// Show the panel by sliding up from the bottom of parentView
- (void)showInView:(UIView *)parentView;

/// Hide the panel
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
