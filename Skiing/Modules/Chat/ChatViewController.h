//
//  ChatViewController.h
//  Skiing
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatViewController : UIViewController
@property (nonatomic, copy) NSString *roomName;
@property (nonatomic, copy) NSString *roomOnlineText;
@property (nonatomic, copy) NSString *roomDescription;
@end

NS_ASSUME_NONNULL_END
