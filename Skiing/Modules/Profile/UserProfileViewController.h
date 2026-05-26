//
//  UserProfileViewController.h
//  Skiing
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserProfileViewController : UIViewController
@property (nonatomic, copy) NSString *profileName;
@property (nonatomic, copy) NSString *profileHandle;
@property (nonatomic, copy) NSString *profileAvatarName;
@property (nonatomic, copy) NSArray<NSString *> *profilePostVideoFileNames;
@property (nonatomic, assign) NSInteger profilePostCount;
@end

NS_ASSUME_NONNULL_END
