//
//  CreateAccountViewController.h
//  Skiing
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CreateAccountViewController : UIViewController <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, copy, nullable) NSString *email;
@property (nonatomic, copy, nullable) NSString *password;

@end

NS_ASSUME_NONNULL_END
