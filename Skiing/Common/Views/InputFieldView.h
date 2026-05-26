//
//  InputFieldView.h
//  Skiing
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface InputFieldView : UIView

@property (nonatomic, readonly, nullable) NSString *text;
@property (nonatomic, readonly) UITextField *textField;

- (instancetype)initWithIcon:(NSString *)icon
                       title:(NSString *)title
                 placeholder:(NSString *)placeholder
                    isSecure:(BOOL)isSecure;

@end

NS_ASSUME_NONNULL_END
